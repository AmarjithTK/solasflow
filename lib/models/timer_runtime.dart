enum TimerRuntimeStatus { idle, running, paused, finished }

class TimerRuntime {
  final String runId;
  final TimerRuntimeStatus status;
  final int durationSeconds;
  final int remainingSeconds;
  final int? endAtEpochMs;
  final bool chainModeOn;
  final String chainPresetKey;
  final int chainIndex;
  final int revision;
  final int segmentStartRemainingSeconds;

  final Stopwatch? _monotonicClock;
  final int _monotonicBaseMs;

  const TimerRuntime({
    required this.runId,
    required this.status,
    required this.durationSeconds,
    required this.remainingSeconds,
    required this.endAtEpochMs,
    required this.chainModeOn,
    required this.chainPresetKey,
    required this.chainIndex,
    required this.revision,
    this.segmentStartRemainingSeconds = 0,
  }) : _monotonicClock = null,
       _monotonicBaseMs = 0;

  TimerRuntime._({
    required this.runId,
    required this.status,
    required this.durationSeconds,
    required this.remainingSeconds,
    required this.endAtEpochMs,
    required this.chainModeOn,
    required this.chainPresetKey,
    required this.chainIndex,
    required this.revision,
    this.segmentStartRemainingSeconds = 0,
    Stopwatch? monotonicClock,
    int monotonicBaseMs = 0,
  }) : _monotonicClock = monotonicClock,
       _monotonicBaseMs = monotonicBaseMs;

  factory TimerRuntime.idle() => const TimerRuntime(
    runId: '',
    status: TimerRuntimeStatus.idle,
    durationSeconds: 0,
    remainingSeconds: 0,
    endAtEpochMs: null,
    chainModeOn: false,
    chainPresetKey: 'Pomodoro 25-5x4',
    chainIndex: 0,
    revision: 0,
  );

  factory TimerRuntime.running({
    required int durationSeconds,
    required int remainingSeconds,
    required DateTime now,
    required bool chainModeOn,
    required String chainPresetKey,
    required int chainIndex,
    String? runId,
    int revision = 1,
    int? segmentStartRemainingSeconds,
  }) {
    final safeRemaining = remainingSeconds.clamp(1, 720 * 60);
    final monotonicClock = Stopwatch()..start();
    return TimerRuntime._(
      runId: runId ?? '${now.microsecondsSinceEpoch}',
      status: TimerRuntimeStatus.running,
      durationSeconds: durationSeconds.clamp(1, 720 * 60),
      remainingSeconds: safeRemaining,
      endAtEpochMs: now
          .add(Duration(seconds: safeRemaining))
          .millisecondsSinceEpoch,
      chainModeOn: chainModeOn,
      chainPresetKey: chainPresetKey,
      chainIndex: chainIndex,
      revision: revision,
      segmentStartRemainingSeconds:
          (segmentStartRemainingSeconds ?? safeRemaining).clamp(1, 720 * 60),
      monotonicClock: monotonicClock,
      monotonicBaseMs: safeRemaining * 1000,
    );
  }

  int _remainingMsAt(DateTime now) {
    if (status != TimerRuntimeStatus.running) {
      return remainingSeconds.clamp(0, 720 * 60) * 1000;
    }
    final monotonicClock = _monotonicClock;
    if (monotonicClock != null) {
      return (_monotonicBaseMs - monotonicClock.elapsedMilliseconds).clamp(
        0,
        720 * 60 * 1000,
      );
    }
    if (endAtEpochMs == null) {
      return remainingSeconds.clamp(0, 720 * 60) * 1000;
    }
    return (endAtEpochMs! - now.millisecondsSinceEpoch).clamp(
      0,
      720 * 60 * 1000,
    );
  }

  int remainingMillisecondsAt(DateTime now) => _remainingMsAt(now);

  int remainingAt(DateTime now) {
    final remainingMs = _remainingMsAt(now);
    return ((remainingMs + 999) ~/ 1000).clamp(0, 720 * 60);
  }

  TimerRuntime copyWith({
    String? runId,
    TimerRuntimeStatus? status,
    int? durationSeconds,
    int? remainingSeconds,
    int? Function()? endAtEpochMs,
    bool? chainModeOn,
    String? chainPresetKey,
    int? chainIndex,
    int? revision,
    int? segmentStartRemainingSeconds,
  }) => TimerRuntime._(
    runId: runId ?? this.runId,
    status: status ?? this.status,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    endAtEpochMs: endAtEpochMs == null ? this.endAtEpochMs : endAtEpochMs(),
    chainModeOn: chainModeOn ?? this.chainModeOn,
    chainPresetKey: chainPresetKey ?? this.chainPresetKey,
    chainIndex: chainIndex ?? this.chainIndex,
    revision: revision ?? this.revision,
    segmentStartRemainingSeconds:
        segmentStartRemainingSeconds ?? this.segmentStartRemainingSeconds,
    monotonicClock: _monotonicClock,
    monotonicBaseMs: _monotonicBaseMs,
  );

  Map<String, dynamic> toJson() {
    final now = DateTime.now();
    final remainingMs = status == TimerRuntimeStatus.running
        ? _remainingMsAt(now)
        : 0;
    final remaining = status == TimerRuntimeStatus.running
        ? (remainingMs + 999) ~/ 1000
        : remainingSeconds;
    final persistedEndAt = status == TimerRuntimeStatus.running
        ? now.millisecondsSinceEpoch + remainingMs
        : endAtEpochMs;
    return {
      'runId': runId,
      'status': status.name,
      'durationSeconds': durationSeconds,
      'remainingSeconds': remaining,
      'endAtEpochMs': persistedEndAt,
      'chainModeOn': chainModeOn,
      'chainPresetKey': chainPresetKey,
      'chainIndex': chainIndex,
      'revision': revision,
      'segmentStartRemainingSeconds': segmentStartRemainingSeconds,
    };
  }

  factory TimerRuntime.fromJson(Map<String, dynamic> json) {
    final statusName = json['status']?.toString();
    final status = TimerRuntimeStatus.values.firstWhere(
      (value) => value.name == statusName,
      orElse: () => TimerRuntimeStatus.idle,
    );
    int readInt(String key, [int fallback = 0]) {
      final value = json[key];
      return value is num ? value.toInt() : fallback;
    }

    final durationSeconds = readInt('durationSeconds').clamp(0, 720 * 60);
    if (durationSeconds == 0) return TimerRuntime.idle();
    final remainingSeconds = readInt(
      'remainingSeconds',
    ).clamp(0, 720 * 60);
    final endAtEpochMs = json['endAtEpochMs'] is num
        ? readInt('endAtEpochMs')
        : null;
    final normalizedStatus =
        status == TimerRuntimeStatus.running && endAtEpochMs == null
        ? remainingSeconds == 0
              ? TimerRuntimeStatus.finished
              : TimerRuntimeStatus.paused
        : status;
    final nowEpochMs = DateTime.now().millisecondsSinceEpoch;
    final restoredRemainingMs =
        normalizedStatus == TimerRuntimeStatus.running && endAtEpochMs != null
        ? (endAtEpochMs - nowEpochMs).clamp(0, 720 * 60 * 1000)
        : remainingSeconds * 1000;
    final restoredRemainingSeconds = (restoredRemainingMs + 999) ~/ 1000;
    final monotonicClock = normalizedStatus == TimerRuntimeStatus.running
        ? (Stopwatch()..start())
        : null;


    return TimerRuntime._(
      runId: json['runId']?.toString() ?? '',
      status: normalizedStatus,
      durationSeconds: durationSeconds,
      remainingSeconds: restoredRemainingSeconds,
      endAtEpochMs: normalizedStatus == TimerRuntimeStatus.running
          ? nowEpochMs + restoredRemainingMs
          : endAtEpochMs,
      chainModeOn: json['chainModeOn'] == true,
      chainPresetKey: json['chainPresetKey']?.toString() ?? 'Pomodoro 25-5x4',
      chainIndex: readInt('chainIndex').clamp(0, 1000),
      revision: readInt('revision').clamp(0, 1 << 30),
      segmentStartRemainingSeconds: readInt(
        'segmentStartRemainingSeconds',
        remainingSeconds,
      ).clamp(0, 720 * 60),
      monotonicClock: monotonicClock,
      monotonicBaseMs: restoredRemainingMs,
    );
  }
}

class StopwatchRuntime {
  final bool isRunning;
  final int accumulatedMs;
  final int? startedAtEpochMs;
  final int revision;
  final List<int> lapTimesMs;

  final Stopwatch? _monotonicClock;

  const StopwatchRuntime({
    required this.isRunning,
    required this.accumulatedMs,
    required this.startedAtEpochMs,
    required this.revision,
    this.lapTimesMs = const [],
  }) : _monotonicClock = null;

  StopwatchRuntime._({
    required this.isRunning,
    required this.accumulatedMs,
    required this.startedAtEpochMs,
    required this.revision,
    this.lapTimesMs = const [],
    Stopwatch? monotonicClock,
  }) : _monotonicClock = monotonicClock;

  factory StopwatchRuntime.idle() => const StopwatchRuntime(
    isRunning: false,
    accumulatedMs: 0,
    startedAtEpochMs: null,
    revision: 0,
  );

  int elapsedMsAt(DateTime now) {
    if (!isRunning) return accumulatedMs;
    final monotonicClock = _monotonicClock;
    if (monotonicClock != null) {
      return accumulatedMs + monotonicClock.elapsedMilliseconds;
    }
    final startedAt = startedAtEpochMs;
    if (startedAt == null) return accumulatedMs;
    return accumulatedMs +
        (now.millisecondsSinceEpoch - startedAt).clamp(0, 1 << 52);
  }

  StopwatchRuntime copyWith({
    bool? isRunning,
    int? accumulatedMs,
    int? Function()? startedAtEpochMs,
    int? revision,
    List<int>? lapTimesMs,
  }) {
    final nextIsRunning = isRunning ?? this.isRunning;
    final monotonicClock = !nextIsRunning
        ? null
        : this.isRunning
        ? _monotonicClock
        : (Stopwatch()..start());
    return StopwatchRuntime._(
      isRunning: nextIsRunning,
      accumulatedMs: accumulatedMs ?? this.accumulatedMs,
      startedAtEpochMs: startedAtEpochMs == null
          ? this.startedAtEpochMs
          : startedAtEpochMs(),
      revision: revision ?? this.revision,
      lapTimesMs: List<int>.unmodifiable(lapTimesMs ?? this.lapTimesMs),
      monotonicClock: monotonicClock,
    );
  }

  Map<String, dynamic> toJson() {
    final now = DateTime.now();
    return {
      'isRunning': isRunning,
      'accumulatedMs': isRunning ? elapsedMsAt(now) : accumulatedMs,
      'startedAtEpochMs': isRunning
          ? now.millisecondsSinceEpoch
          : startedAtEpochMs,
      'revision': revision,
      'lapTimesMs': lapTimesMs,
    };
  }

  factory StopwatchRuntime.fromJson(Map<String, dynamic> json) {
    int readInt(String key, [int fallback = 0]) {
      final value = json[key];
      return value is num ? value.toInt() : fallback;
    }

    final isRunning = json['isRunning'] == true;
    final storedAccumulatedMs = readInt('accumulatedMs').clamp(0, 1 << 52);
    final storedStartedAtEpochMs = json['startedAtEpochMs'] is num
        ? readInt('startedAtEpochMs')
        : null;
    final now = DateTime.now();
    final nowEpochMs = now.millisecondsSinceEpoch;
    final accumulatedMs = isRunning && storedStartedAtEpochMs != null
        ? (storedAccumulatedMs +
                  (nowEpochMs - storedStartedAtEpochMs).clamp(0, 1 << 52))
              .clamp(0, 1 << 52)
        : storedAccumulatedMs;
    final monotonicClock = isRunning && storedStartedAtEpochMs != null
        ? (Stopwatch()..start())
        : null;

    return StopwatchRuntime._(
      isRunning: isRunning,
      accumulatedMs: accumulatedMs,
      startedAtEpochMs: isRunning && storedStartedAtEpochMs != null
          ? nowEpochMs
          : storedStartedAtEpochMs,
      revision: readInt('revision').clamp(0, 1 << 30),
      lapTimesMs: json['lapTimesMs'] is List
          ? List<int>.unmodifiable(
              (json['lapTimesMs'] as List)
                  .whereType<num>()
                  .map((value) => value.toInt().clamp(0, 1 << 52)),
            )
          : const [],
      monotonicClock: monotonicClock,
    );
  }
}
