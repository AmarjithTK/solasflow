import 'dart:async';

import '../models/session_log.dart';
import '../models/timer_runtime.dart';
import '../services/session_log_service.dart';
import '../services/timer_runtime_store.dart';
import '../services/timer_runtime_transitions.dart';
import '../services/timer_service.dart';

/// UI and platform boundary for [TimerRuntimeController].
///
/// The host owns presentation and application services; this controller owns
/// timer/stopwatch runtime state, tickers, completion identity and session
/// boundaries. `onTimerFinishedDialog` builds/presents the dialog and returns
/// the selected duration in seconds, or null when dismissed.
abstract interface class TimerRuntimeControllerHost {
  bool get mounted;
  bool get taggingOn;
  String get sessionTag;
  bool get timerSpeakOn;
  int get timerAnnounceEvery;
  bool get stopwatchSpeakOn;
  int get stopwatchSpeakDelaySeconds;
  bool get stopwatchShowMilliseconds;
  bool get backgroundPersistenceOn;
  bool get audioMuted;
  bool get chainModeOn;
  String get chainPresetKey;
  int get sliderMinutes;
  void setChainModeOn(bool value);

  void onTimerRuntimeChanged({
    required TimerRuntime runtime,
    required bool tickerActive,
    required int sliderMinutes,
    required int chainIndex,
    required bool finished,
    required int lastFinishedDurationSeconds,
  });
  void onStopwatchRuntimeChanged({
    required StopwatchRuntime runtime,
    required bool tickerActive,
  });
  void onTimerSpeechRemaining(int minutes);
  void onTimerSpeechNext(int seconds);
  void onTimerSpeechFinished(String runId, int revision);
  void onStopwatchSpeech(
    String text, {
    required bool explicit,
    required int generation,
  });
  String stopwatchElapsedSpeechText(StopwatchRuntime runtime);
  Future<void> applyAudioSettings();
  Future<void> reconcileForeground({required bool force});
  Future<void> stopNotification();
  Future<void> saveLastTimerSeconds(int seconds);
  Future<void> onTimerFinishedEffects(int durationSeconds);
  Future<void> onTimerAlarm();
  Future<int?> onTimerFinishedDialog();
  Future<void> closeTimerFinishedDialog();
  void scheduleRestoredTimerFinishedDialog();
  Future<void> dismissFinishedTimer();
  Future<void> refreshTimerSummary();
  void cancelTimerCompletionSpeech();
  void stopMobileRingtone();
  void onStopwatchSpeechGenerationChanged(int generation);
  void onTimerDialogClosed();
}

/// Owns persisted countdown and stopwatch runtimes and their periodic work.
class TimerRuntimeController {
  TimerRuntimeController({
    required TimerRuntimeControllerHost host,
    TimerRuntimeStore? runtimeStore,
    SessionLogService? sessionLogService,
    TimerService? timerService,
  }) : _host = host,
       _runtimeStore = runtimeStore ?? TimerRuntimeStore(),
       _sessionLogService = sessionLogService ?? SessionLogService(),
       _timerService = timerService ?? TimerService();

  final TimerRuntimeControllerHost _host;
  final TimerRuntimeStore _runtimeStore;
  final SessionLogService _sessionLogService;
  final TimerService _timerService;
  Future<void> clearPersistedRuntimes() async {
    await _runtimeStore.save(TimerRuntime.idle());
    await _runtimeStore.saveStopwatch(StopwatchRuntime.idle());
  }

  void dispose() {
    timerTicker?.cancel();
    stopwatchTicker?.cancel();
    timerTicker = null;
    stopwatchTicker = null;
  }

  TimerRuntime timerRuntime = TimerRuntime.idle();
  StopwatchRuntime stopwatchRuntime = StopwatchRuntime.idle();
  Timer? timerTicker;
  Timer? stopwatchTicker;
  int chainIndex = 0;
  int lastFinishedTimerDurationSeconds = 25 * 60;
  int lastStopwatchNotificationSecond = -1;
  int lastStopwatchAutoAnnouncedSecond = -1;
  int stopwatchSpeechGeneration = 0;
  int alarmGeneration = 0;
  int timerWorkGeneration = 0;
  bool timerCompletionInFlight = false;
  bool timerFinishedDialogOpen = false;
  DateTime? sessionStartTime;
  int? sessionStartRemainingSeconds;
  int? _sliderMinutesOverride;

  int get seconds => timerRuntime.status == TimerRuntimeStatus.idle
      ? 0
      : timerRuntime.remainingAt(DateTime.now());

  int get activeTimerDurationSeconds => timerRuntime.durationSeconds;
  int get stopwatchElapsedSeconds =>
      stopwatchRuntime.elapsedMsAt(DateTime.now()) ~/ 1000;

  bool get isTimerRunning => timerTicker != null;
  bool get isStopwatchRunning => stopwatchTicker != null;

  int _taggedElapsedSeconds(int remaining) =>
      ((sessionStartRemainingSeconds ?? remaining) - remaining).clamp(
        0,
        720 * 60,
      );

  void _changedTimer() {
    final sliderMinutes = _sliderMinutesOverride ?? _host.sliderMinutes;
    _host.onTimerRuntimeChanged(
      runtime: timerRuntime,
      tickerActive: timerTicker != null,
      sliderMinutes: sliderMinutes,
      chainIndex: chainIndex,
      finished: timerRuntime.status == TimerRuntimeStatus.finished,
      lastFinishedDurationSeconds: lastFinishedTimerDurationSeconds,
    );
    _sliderMinutesOverride = null;
  }

  void _changedStopwatch() => _host.onStopwatchRuntimeChanged(
    runtime: stopwatchRuntime,
    tickerActive: stopwatchTicker != null,
  );

  void _invalidateTimerWork() {
    timerWorkGeneration++;
  }

  void _logCurrentSession(int elapsedSeconds, {required String sessionId}) {
    final startedAt = sessionStartTime;
    sessionStartTime = null;
    sessionStartRemainingSeconds = null;
    if (startedAt == null || elapsedSeconds <= 0) return;
    unawaited(
      _sessionLogService.logSession(
        SessionLog(
          startTime: startedAt,
          endTime: DateTime.now(),
          durationSeconds: elapsedSeconds,
          tag: _host.sessionTag,
          sessionId: sessionId,
        ),
      ),
    );
    unawaited(_host.refreshTimerSummary());
  }

  /// Call when tagging is toggled, preserving the active segment boundary.
  void taggingChanged({required bool enabled, required bool wasEnabled}) {
    if (enabled && !wasEnabled && timerTicker != null) {
      sessionStartTime = DateTime.now();
      sessionStartRemainingSeconds = timerRuntime.remainingAt(
        sessionStartTime!,
      );
      timerRuntime = timerRuntime.copyWith(
        segmentStartRemainingSeconds: sessionStartRemainingSeconds,
        revision: timerRuntime.revision + 1,
      );
      unawaited(_runtimeStore.save(timerRuntime));
      _changedTimer();
    } else if (!enabled) {
      if (wasEnabled && timerTicker != null && sessionStartTime != null) {
        final remaining = timerRuntime.remainingAt(DateTime.now());
        _logCurrentSession(
          (sessionStartRemainingSeconds ?? remaining) - remaining,
          sessionId: '${timerRuntime.runId}:${timerRuntime.revision}',
        );
      }
      sessionStartTime = null;
      sessionStartRemainingSeconds = null;
    }
  }

  Future<void> restoreTimerRuntime() async {
    await applyTimerRuntime(await _runtimeStore.load(), restored: true);
  }

  Future<void> restoreStopwatchRuntime() async =>
      applyStopwatchRuntime(await _runtimeStore.loadStopwatch());

  Future<void> applyStopwatchRuntime(StopwatchRuntime runtime) async {
    if (!_host.mounted || runtime.revision < stopwatchRuntime.revision) return;
    _invalidateStopwatchSpeech();
    stopwatchTicker?.cancel();
    stopwatchRuntime = runtime;
    stopwatchTicker = runtime.isRunning
        ? Timer.periodic(_stopwatchPeriod, _tickStopwatch)
        : null;
    _changedStopwatch();
    await _host.reconcileForeground(force: true);
  }

  Duration get _stopwatchPeriod =>
      Duration(milliseconds: _host.stopwatchShowMilliseconds ? 50 : 250);

  void startStopwatch() {
    if (stopwatchTicker != null) return;
    stopwatchRuntime = stopwatchRuntime.copyWith(
      isRunning: true,
      startedAtEpochMs: () => DateTime.now().millisecondsSinceEpoch,
      revision: stopwatchRuntime.revision + 1,
    );
    stopwatchTicker = Timer.periodic(_stopwatchPeriod, _tickStopwatch);
    _changedStopwatch();
    unawaited(_runtimeStore.saveStopwatch(stopwatchRuntime));
    unawaited(_host.reconcileForeground(force: true));
  }

  void stopStopwatch() {
    if (!stopwatchRuntime.isRunning) return;
    _invalidateStopwatchSpeech();
    final elapsed = stopwatchRuntime.elapsedMsAt(DateTime.now());
    stopwatchRuntime = stopwatchRuntime.copyWith(
      isRunning: false,
      accumulatedMs: elapsed,
      startedAtEpochMs: () => null,
      revision: stopwatchRuntime.revision + 1,
    );
    stopwatchTicker?.cancel();
    stopwatchTicker = null;
    _changedStopwatch();
    unawaited(_runtimeStore.saveStopwatch(stopwatchRuntime));
    unawaited(_host.reconcileForeground(force: true));
  }

  void resetStopwatch() {
    _invalidateStopwatchSpeech();
    stopwatchTicker?.cancel();
    stopwatchTicker = null;
    stopwatchRuntime = StopwatchRuntime.idle().copyWith(
      revision: stopwatchRuntime.revision + 1,
    );
    _changedStopwatch();
    unawaited(_runtimeStore.saveStopwatch(stopwatchRuntime));
    unawaited(_host.reconcileForeground(force: true));
  }

  void recordStopwatchLap() {
    stopwatchRuntime = stopwatchRuntime.copyWith(
      lapTimesMs: [
        stopwatchRuntime.elapsedMsAt(DateTime.now()),
        ...stopwatchRuntime.lapTimesMs,
      ],
      revision: stopwatchRuntime.revision + 1,
    );
    _changedStopwatch();
    unawaited(_runtimeStore.saveStopwatch(stopwatchRuntime));
  }

  void _tickStopwatch(Timer timer) {
    final nextSeconds = stopwatchRuntime.elapsedMsAt(DateTime.now()) ~/ 1000;
    _changedStopwatch();
    if (nextSeconds != lastStopwatchNotificationSecond &&
        (nextSeconds % 30 == 0 || nextSeconds <= 3)) {
      lastStopwatchNotificationSecond = nextSeconds;
      unawaited(_host.reconcileForeground(force: true));
    }
    if (_host.stopwatchSpeakOn &&
        nextSeconds > 0 &&
        nextSeconds % _host.stopwatchSpeakDelaySeconds == 0 &&
        nextSeconds != lastStopwatchAutoAnnouncedSecond) {
      lastStopwatchAutoAnnouncedSecond = nextSeconds;
      _host.onStopwatchSpeech(
        _host.stopwatchElapsedSpeechText(stopwatchRuntime),
        explicit: false,
        generation: stopwatchSpeechGeneration,
      );
    }
  }

  void _invalidateStopwatchSpeech() {
    stopwatchSpeechGeneration++;
    _host.onStopwatchSpeechGenerationChanged(stopwatchSpeechGeneration);
  }

  void speakStopwatchElapsedNow() => _host.onStopwatchSpeech(
    _host.stopwatchElapsedSpeechText(stopwatchRuntime),
    explicit: true,
    generation: stopwatchSpeechGeneration,
  );

  Future<void> applyTimerRuntime(
    TimerRuntime runtime, {
    bool restored = false,
  }) async {
    if (!_host.mounted) return;
    final isLocallyRunning =
        timerTicker != null &&
        timerRuntime.status == TimerRuntimeStatus.running;
    if (isLocallyRunning) {
      if ((runtime.status == TimerRuntimeStatus.idle &&
              runtime.revision <= timerRuntime.revision) ||
          (runtime.runId.isNotEmpty &&
              runtime.runId != timerRuntime.runId &&
              runtime.revision <= timerRuntime.revision) ||
          runtime.revision < timerRuntime.revision) {
        return;
      }
    } else if (runtime.runId == timerRuntime.runId &&
        runtime.revision < timerRuntime.revision) {
      return;
    }
    final replacesCurrentRun =
        runtime.runId != timerRuntime.runId ||
        runtime.revision > timerRuntime.revision ||
        runtime.status != timerRuntime.status;
    if (replacesCurrentRun) _invalidateTimerWork();
    var next = runtime;
    final wasFinished = timerRuntime.status == TimerRuntimeStatus.finished;
    if (wasFinished && next.status != TimerRuntimeStatus.finished) {
      _host.stopMobileRingtone();
      _host.cancelTimerCompletionSpeech();
      unawaited(_host.stopNotification());
    }
    if (next.status == TimerRuntimeStatus.running &&
        next.remainingAt(DateTime.now()) == 0) {
      next = advanceExpiredTimer(next, DateTime.now());
      await _runtimeStore.save(next);
    }
    if (!_host.mounted) return;
    timerTicker?.cancel();
    timerTicker = null;
    final remaining = next.remainingAt(DateTime.now());
    if (next.status == TimerRuntimeStatus.running && _host.taggingOn) {
      final segmentChanged =
          timerRuntime.status != TimerRuntimeStatus.running ||
          timerRuntime.runId != next.runId ||
          timerRuntime.chainIndex != next.chainIndex ||
          sessionStartTime == null;
      if (segmentChanged) {
        final segmentStart = next.segmentStartRemainingSeconds > 0
            ? next.segmentStartRemainingSeconds
            : remaining;
        final endAt =
            next.endAtEpochMs ?? DateTime.now().millisecondsSinceEpoch;
        sessionStartTime = DateTime.fromMillisecondsSinceEpoch(
          endAt - segmentStart * 1000,
        );
        sessionStartRemainingSeconds = segmentStart;
      }
    } else {
      sessionStartTime = null;
      sessionStartRemainingSeconds = null;
    }
    timerRuntime = next;
    if (next.durationSeconds > 0) {
      _setSliderMinutes(
        ((next.durationSeconds + 59) ~/ 60).clamp(1, 720).toInt(),
      );
    }
    if (next.status == TimerRuntimeStatus.finished) {
      lastFinishedTimerDurationSeconds = next.durationSeconds;
    }
    chainIndex = next.chainIndex;
    timerTicker = next.status == TimerRuntimeStatus.running
        ? Timer.periodic(const Duration(milliseconds: 250), tick)
        : null;
    _changedTimer();
    if (replacesCurrentRun && timerFinishedDialogOpen) {
      unawaited(_host.closeTimerFinishedDialog());
    }
    unawaited(_host.applyAudioSettings());
    await _host.reconcileForeground(force: true);
    if (restored &&
        next.status == TimerRuntimeStatus.finished &&
        _host.mounted) {
      _host.scheduleRestoredTimerFinishedDialog();
    }
  }

  void _setSliderMinutes(int minutes) {
    _sliderMinutesOverride = minutes;
  }

  void tick(Timer timer) {
    if (timerRuntime.status != TimerRuntimeStatus.running) return;
    final previous = seconds;
    final remaining = timerRuntime.remainingAt(DateTime.now());
    if (remaining == previous) return;
    if (remaining <= 0) {
      unawaited(_completeTimerRun());
      return;
    }
    final crossed = _timerService.crossedAnnouncementMinutes(
      previousSeconds: previous,
      currentSeconds: remaining,
      announceEveryMinutes: _host.timerAnnounceEvery,
    );
    timerRuntime = timerRuntime.copyWith(remainingSeconds: remaining);
    _changedTimer();
    if (_host.timerSpeakOn && crossed.isNotEmpty) {
      _host.onTimerSpeechRemaining(crossed.last);
    }
    if (remaining % 60 == 0 || remaining <= 10 || crossed.isNotEmpty) {
      unawaited(_host.reconcileForeground(force: true));
    }
  }

  Future<void> _completeTimerRun() async {
    if (timerCompletionInFlight ||
        timerRuntime.status != TimerRuntimeStatus.running) {
      return;
    }
    timerCompletionInFlight = true;
    final workGeneration = timerWorkGeneration;
    final sessionId = '${timerRuntime.runId}:${timerRuntime.revision}';
    try {
      if (_host.chainModeOn) {
        final sequence =
            timerChainSequences[_host.chainPresetKey] ?? const [25];
        if (chainIndex < sequence.length - 1) {
          chainIndex++;
          final nextSeconds = sequence[chainIndex] * 60;
          timerRuntime = TimerRuntime.running(
            durationSeconds: nextSeconds,
            remainingSeconds: nextSeconds,
            now: DateTime.now(),
            chainModeOn: true,
            chainPresetKey: _host.chainPresetKey,
            chainIndex: chainIndex,
            runId: timerRuntime.runId,
            revision: timerRuntime.revision + 1,
          );
          try {
            await _runtimeStore.save(timerRuntime);
          } catch (_) {
            // PersistenceErrorReporter already notified by _runtimeStore.
          }
          if (!_host.mounted || workGeneration != timerWorkGeneration) return;
          if (_host.taggingOn && sessionStartTime != null) {
            _logCurrentSession(_taggedElapsedSeconds(0), sessionId: sessionId);
            sessionStartTime = DateTime.now();
            sessionStartRemainingSeconds = nextSeconds;
          }
          _changedTimer();
          if (_host.timerSpeakOn) _host.onTimerSpeechNext(nextSeconds);
          await _host.reconcileForeground(force: true);
          return;
        }
        chainIndex = 0;
      }
      timerTicker?.cancel();
      timerTicker = null;
      lastFinishedTimerDurationSeconds = timerRuntime.durationSeconds > 0
          ? timerRuntime.durationSeconds
          : _host.sliderMinutes * 60;
      timerRuntime = timerRuntime.copyWith(
        status: TimerRuntimeStatus.finished,
        remainingSeconds: 0,
        endAtEpochMs: () => null,
        chainIndex: chainIndex,
        revision: timerRuntime.revision + 1,
      );
      try {
        await _runtimeStore.save(timerRuntime);
      } catch (_) {
        // PersistenceErrorReporter already notified by _runtimeStore.
      }
      if (!_host.mounted || workGeneration != timerWorkGeneration) return;
      _changedTimer();
      await _host.applyAudioSettings();
      await _host.reconcileForeground(force: true);
      if (!_host.mounted || workGeneration != timerWorkGeneration) return;
      await _host.onTimerFinishedEffects(lastFinishedTimerDurationSeconds);
      if (_host.taggingOn && sessionStartTime != null) {
        _logCurrentSession(_taggedElapsedSeconds(0), sessionId: sessionId);
      }
      if (_host.timerSpeakOn) {
        _host.onTimerSpeechFinished(timerRuntime.runId, timerRuntime.revision);
      }
      final generation = ++alarmGeneration;
      if (!_host.audioMuted) await _host.onTimerAlarm();
      if (generation != alarmGeneration) return;
      unawaited(showTimerFinishedDialog());
    } finally {
      timerCompletionInFlight = false;
    }
  }

  void saveChainSettingsToTimerRuntime() {
    if (timerRuntime.status == TimerRuntimeStatus.idle) return;
    timerRuntime = timerRuntime.copyWith(
      chainModeOn: _host.chainModeOn,
      chainPresetKey: _host.chainPresetKey,
      chainIndex: chainIndex,
      revision: timerRuntime.revision + 1,
    );
    unawaited(_runtimeStore.save(timerRuntime));
    _changedTimer();
  }

  void startTimer({int? initialDurationSeconds}) {
    if (timerTicker != null) return;
    if (timerRuntime.status == TimerRuntimeStatus.finished) {
      _host.cancelTimerCompletionSpeech();
      _host.stopMobileRingtone();
    }
    unawaited(_host.stopNotification());
    _invalidateTimerWork();
    var remaining = initialDurationSeconds ?? seconds;
    if (remaining <= 0) {
      if (_host.chainModeOn) {
        final sequence =
            timerChainSequences[_host.chainPresetKey] ?? const [25];
        if (chainIndex >= sequence.length) chainIndex = 0;
        remaining = sequence[chainIndex] * 60;
      } else {
        remaining = _host.sliderMinutes * 60;
      }
    }
    remaining = remaining.clamp(1, 720 * 60);
    final resumedDuration =
        initialDurationSeconds == null &&
            timerRuntime.status == TimerRuntimeStatus.paused
        ? timerRuntime.durationSeconds
        : 0;
    final duration = resumedDuration >= remaining ? resumedDuration : remaining;
    timerRuntime = TimerRuntime.running(
      durationSeconds: duration,
      remainingSeconds: remaining,
      now: DateTime.now(),
      chainModeOn: _host.chainModeOn,
      chainPresetKey: _host.chainPresetKey,
      chainIndex: chainIndex,
      segmentStartRemainingSeconds: remaining,
      revision: timerRuntime.revision + 1,
    );
    timerTicker = Timer.periodic(const Duration(milliseconds: 250), tick);
    if (_host.taggingOn) {
      if (sessionStartTime == null) {
        sessionStartTime = DateTime.now();
        sessionStartRemainingSeconds = remaining;
      }
    } else {
      sessionStartTime = null;
      sessionStartRemainingSeconds = null;
    }
    _changedTimer();
    unawaited(_runtimeStore.save(timerRuntime));
    unawaited(_host.saveLastTimerSeconds(remaining));
    unawaited(_host.applyAudioSettings());
    unawaited(_host.reconcileForeground(force: true));
  }

  void startTimerFromDurationSeconds(int durationSeconds) {
    final safeSeconds = durationSeconds.clamp(1, 720 * 60).toInt();
    final displayMinutes = ((safeSeconds + 59) ~/ 60).clamp(1, 720);
    _host.setChainModeOn(false);
    stopTimer();
    chainIndex = 0;
    _setSliderMinutes(displayMinutes);
    unawaited(_host.stopNotification());
    startTimer(initialDurationSeconds: safeSeconds);
  }

  void replaceWithWidgetPreset(int durationSeconds) {
    timerTicker?.cancel();
    timerTicker = null;
    chainIndex = 0;
    sessionStartTime = null;
    sessionStartRemainingSeconds = null;
    startTimer(initialDurationSeconds: durationSeconds);
  }

  void stopTimer() {
    _invalidateTimerWork();
    if (timerTicker == null) return;
    final remaining = timerRuntime.remainingAt(DateTime.now());
    if (_host.taggingOn && sessionStartTime != null) {
      _logCurrentSession(
        _taggedElapsedSeconds(remaining),
        sessionId: '${timerRuntime.runId}:${timerRuntime.revision}',
      );
    }
    timerTicker?.cancel();
    timerTicker = null;
    timerRuntime = timerRuntime.copyWith(
      status: TimerRuntimeStatus.paused,
      remainingSeconds: remaining,
      endAtEpochMs: () => null,
      revision: timerRuntime.revision + 1,
    );
    unawaited(_runtimeStore.save(timerRuntime));
    if (remaining > 0) unawaited(_host.saveLastTimerSeconds(remaining));
    _changedTimer();
    unawaited(_host.applyAudioSettings());
    unawaited(_host.reconcileForeground(force: true));
  }

  void resetTimer() {
    _invalidateTimerWork();
    final wasFinished = timerRuntime.status == TimerRuntimeStatus.finished;
    if (wasFinished) {
      _host.stopMobileRingtone();
      _host.cancelTimerCompletionSpeech();
      unawaited(_host.stopNotification());
    }
    if (timerTicker != null) stopTimer();
    timerTicker?.cancel();
    timerTicker = null;
    sessionStartTime = null;
    sessionStartRemainingSeconds = null;
    timerRuntime = TimerRuntime.idle().copyWith(
      revision: timerRuntime.revision + 1,
    );
    chainIndex = 0;
    unawaited(_runtimeStore.save(timerRuntime));
    _changedTimer();
    unawaited(_host.reconcileForeground(force: true));
  }

  void addTimeToRunningTimer(int additionalSeconds) {
    if (timerTicker == null ||
        timerRuntime.status != TimerRuntimeStatus.running) {
      return;
    }
    _invalidateTimerWork();
    final previousRemaining = timerRuntime.remainingAt(DateTime.now());
    final remaining =
        (previousRemaining + additionalSeconds).clamp(1, 720 * 60);
    final appliedDelta = remaining - previousRemaining;
    final duration = (timerRuntime.durationSeconds + appliedDelta).clamp(
      1,
      720 * 60,
    );
    if (sessionStartRemainingSeconds != null) {
      sessionStartRemainingSeconds =
          (sessionStartRemainingSeconds! + appliedDelta).clamp(1, 720 * 60);
    }
    timerRuntime = TimerRuntime.running(
      durationSeconds: duration,
      remainingSeconds: remaining,
      now: DateTime.now(),
      chainModeOn: _host.chainModeOn,
      chainPresetKey: _host.chainPresetKey,
      chainIndex: chainIndex,
      runId: timerRuntime.runId,
      segmentStartRemainingSeconds:
          (timerRuntime.segmentStartRemainingSeconds + appliedDelta).clamp(
            1,
            720 * 60,
          ),
      revision: timerRuntime.revision + 1,
    );
    _sliderMinutesOverride = (remaining / 60).ceil().clamp(1, 720);
    _changedTimer();
    unawaited(_runtimeStore.save(timerRuntime));
    unawaited(_host.reconcileForeground(force: true));
  }

  Future<void> showTimerFinishedDialog() async {
    if (!_host.mounted ||
        timerFinishedDialogOpen ||
        timerRuntime.status != TimerRuntimeStatus.finished) {
      return;
    }
    final workGeneration = timerWorkGeneration;
    final finishedRunId = timerRuntime.runId;
    final finishedRevision = timerRuntime.revision;
    timerFinishedDialogOpen = true;
    int? selectedDurationSeconds;
    try {
      selectedDurationSeconds = await _host.onTimerFinishedDialog();
    } finally {
      _host.onTimerDialogClosed();
      timerFinishedDialogOpen = false;
    }
    if (!_host.mounted ||
        workGeneration != timerWorkGeneration ||
        timerRuntime.runId != finishedRunId ||
        timerRuntime.revision != finishedRevision ||
        timerRuntime.status != TimerRuntimeStatus.finished) {
      return;
    }
    if (selectedDurationSeconds == null) {
      await _host.dismissFinishedTimer();
      return;
    }
    startTimerFromDurationSeconds(selectedDurationSeconds);
  }
}
