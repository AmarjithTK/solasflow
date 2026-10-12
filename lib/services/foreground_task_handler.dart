import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/foreground_notification_state.dart';
import '../models/session_log.dart';
import '../models/timer_runtime.dart';
import 'session_log_service.dart';
import 'timer_runtime_store.dart';
import 'timer_runtime_transitions.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SolasFlowTaskHandler());
}

class SolasFlowTaskHandler extends TaskHandler {
  final TimerRuntimeStore _store = TimerRuntimeStore();
  final SessionLogService _sessionLogService = SessionLogService();
  int _lastPublishedRemaining = -1;
  int _lastStopwatchPublishedSeconds = -1;
  int _lastClockMinute = -1;
  Future<void> _operationTail = Future<void>.value();

  void _enqueue(Future<void> Function() operation) {
    _operationTail = _operationTail
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('Background task operation failed: $error');
        })
        .then((_) => operation());
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await _reconcile(timestamp, force: true);
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _enqueue(() => _reconcile(timestamp));
  }

  Future<void> _reconcile(DateTime now, {bool force = false}) async {
    var runtime = await _store.load();
    final stopwatch = await _store.loadStopwatch();
    final settings = await _store.loadTaskSettings();
    if (runtime.status == TimerRuntimeStatus.running) {
      final remaining = runtime.remainingAt(now);
      if (remaining == 0) {
        if (settings.taggingOn) {
          final segmentSeconds = runtime.segmentStartRemainingSeconds > 0
              ? runtime.segmentStartRemainingSeconds
              : runtime.remainingSeconds;
          final sessionEnd = DateTime.fromMillisecondsSinceEpoch(
            runtime.endAtEpochMs ?? now.millisecondsSinceEpoch,
          );
          await _sessionLogService.logSession(
            SessionLog(
              startTime: sessionEnd.subtract(Duration(seconds: segmentSeconds)),
              endTime: sessionEnd,
              durationSeconds: segmentSeconds,
              tag: settings.sessionTag,
              sessionId: '${runtime.runId}:${runtime.revision}',
            ),
          );
        }
        final advanced = advanceExpiredTimer(runtime, now);
        if (advanced.revision != runtime.revision) {
          runtime = advanced;
          await _store.save(runtime);
          force = true;
        }
      } else if (remaining != runtime.remainingSeconds) {
        runtime = runtime.copyWith(remainingSeconds: remaining);
      }
    }

    final remaining = runtime.remainingAt(now);
    final stopwatchSeconds = stopwatch.elapsedMsAt(now) ~/ 1000;
    final clockMinute = now.millisecondsSinceEpoch ~/ 60000;
    final timerNeedsPublish =
        runtime.status == TimerRuntimeStatus.running &&
        remaining != _lastPublishedRemaining &&
        (remaining <= 10 || remaining % 60 == 0);
    final stopwatchNeedsPublish =
        stopwatch.isRunning &&
        stopwatchSeconds != _lastStopwatchPublishedSeconds &&
        stopwatchSeconds % 30 == 0;
    final clockNeedsPublish =
        settings.clockOn && clockMinute != _lastClockMinute;
    if (!force &&
        !timerNeedsPublish &&
        !stopwatchNeedsPublish &&
        !clockNeedsPublish) {
      return;
    }
    _lastPublishedRemaining = remaining;
    _lastStopwatchPublishedSeconds = stopwatchSeconds;
    _lastClockMinute = clockMinute;
    await _updateNotification(runtime, stopwatch, settings);
  }

  Future<void> _updateNotification(
    TimerRuntime runtime,
    StopwatchRuntime stopwatch,
    AppSettings settings,
  ) async {
    final now = DateTime.now();
    final remaining = runtime.remainingAt(now);
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    final stopwatchTotal = stopwatch.elapsedMsAt(now) ~/ 1000;
    final stopwatchMinutes = (stopwatchTotal ~/ 60).toString().padLeft(2, '0');
    final stopwatchSeconds = (stopwatchTotal % 60).toString().padLeft(2, '0');
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final localizations = await AppLocalizations.delegate.load(
      ui.PlatformDispatcher.instance.locale,
    );
    final presentation = ForegroundNotificationPresentation.fromState(
      ForegroundNotificationState(
        isTimerRunning: runtime.status == TimerRuntimeStatus.running,
        isStopwatchRunning: stopwatch.isRunning,
        isClockRunning: settings.clockOn,
        timerValue: '$minutes:$seconds',
        stopwatchValue: '$stopwatchMinutes:$stopwatchSeconds',
        currentTimeDisplay: currentTime,
        speechMasterOn: settings.speechMasterOn,
        isTimerFinished: runtime.status == TimerRuntimeStatus.finished,
      ),
      localizations,
    );
    final result = await FlutterForegroundTask.updateService(
      notificationTitle: presentation.title,
      notificationText: presentation.text,
      notificationButtons: presentation.buttons,
    );
    if (result is ServiceRequestFailure) {
      debugPrint('Background notification update failed: ${result.error}');
    }
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'open_app') {
      FlutterForegroundTask.launchApp();
      return;
    }
    _enqueue(() => _handleNotificationButton(id));
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  Future<void> _handleNotificationButton(String id) async {
    var runtime = await _store.load();
    var settings = await _store.loadTaskSettings();
    var stopwatch = await _store.loadStopwatch();
    if (id == 'audio:set:on' || id == 'audio:set:off') {
      final enabled = id == 'audio:set:on';
      await _store.saveSpeechMasterOverride(enabled);
      settings = settings.copyWith(speechMasterOn: enabled);
      await _updateNotification(runtime, stopwatch, settings);
      FlutterForegroundTask.sendDataToMain({
        'type': 'speechMaster',
        'value': enabled,
      });
      return;
    }

    if (id == 'btn_timer_repeat' && runtime.durationSeconds > 0) {
      runtime = TimerRuntime.running(
        durationSeconds: runtime.durationSeconds,
        remainingSeconds: runtime.durationSeconds,
        now: DateTime.now(),
        chainModeOn: runtime.chainModeOn,
        chainPresetKey: runtime.chainPresetKey,
        chainIndex: runtime.chainIndex,
        runId: runtime.runId,
        revision: runtime.revision + 1,
      );
      await _store.save(runtime);
      await _updateNotification(runtime, stopwatch, settings);
      FlutterForegroundTask.sendDataToMain({
        'type': 'runtime',
        'snapshot': runtime.toJson(),
      });
      return;
    }

    if (id == 'btn_timer_dismiss' || id == 'btn_exit') {
      runtime = TimerRuntime.idle().copyWith(revision: runtime.revision + 1);
      await _store.save(runtime);
      if (id == 'btn_exit') {
        stopwatch = StopwatchRuntime.idle().copyWith(
          revision: stopwatch.revision + 1,
        );
        await _store.saveStopwatch(stopwatch);
      }
      FlutterForegroundTask.sendDataToMain({
        'type': id == 'btn_exit' ? 'exit' : 'runtime',
        'snapshot': runtime.toJson(),
        'stopwatch': stopwatch.toJson(),
      });
      if (id == 'btn_exit' ||
          (!settings.backgroundPersistenceOn &&
              !stopwatch.isRunning &&
              !settings.clockOn)) {
        final result = await FlutterForegroundTask.stopService();
        if (result is ServiceRequestFailure) {
          debugPrint('Background service stop failed: ${result.error}');
        }
      } else {
        await _updateNotification(runtime, stopwatch, settings);
      }
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isForceRequest) async {}
}
