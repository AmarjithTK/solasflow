import '../models/timer_runtime.dart';

const Map<String, List<int>> timerChainSequences = {
  'Pomodoro 25-5x4': [25, 5, 25, 5, 25, 5, 25, 15],
  'Sprint 50-10x2': [50, 10, 50, 10],
  'Quick 15-3x3': [15, 3, 15, 3, 15, 3],
};

TimerRuntime advanceExpiredTimer(TimerRuntime runtime, DateTime now) {
  if (runtime.status != TimerRuntimeStatus.running ||
      runtime.remainingAt(now) > 0) {
    return runtime;
  }
  if (runtime.chainModeOn) {
    final sequence = timerChainSequences[runtime.chainPresetKey] ?? const [25];
    final nextIndex = runtime.chainIndex + 1;
    if (nextIndex < sequence.length) {
      final nextSeconds = sequence[nextIndex] * 60;
      return TimerRuntime.running(
        durationSeconds: nextSeconds,
        remainingSeconds: nextSeconds,
        now: now,
        chainModeOn: true,
        chainPresetKey: runtime.chainPresetKey,
        chainIndex: nextIndex,
        runId: runtime.runId,
        revision: runtime.revision + 1,
      );
    }
    return runtime.copyWith(
      status: TimerRuntimeStatus.finished,
      remainingSeconds: 0,
      endAtEpochMs: () => null,
      chainIndex: 0,
      revision: runtime.revision + 1,
    );
  }
  return runtime.copyWith(
    status: TimerRuntimeStatus.finished,
    remainingSeconds: 0,
    endAtEpochMs: () => null,
    revision: runtime.revision + 1,
  );
}
