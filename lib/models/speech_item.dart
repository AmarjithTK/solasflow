class SpeechItem {
  final String text;
  final bool isQuote;
  final bool isClockAnnouncement;
  final bool isTimerAnnouncement;
  final bool isTimerCompletion;
  final int? timerRevision;
  final String? timerRunId;
  final bool isStopwatchAnnouncement;
  final int delayMs;
  final String? language; // 'en' or 'ml' - set at enqueue time for consistency
  final Map<dynamic, dynamic>? voice;

  SpeechItem(
    this.text, {
    this.isQuote = false,
    this.isClockAnnouncement = false,
    this.isTimerAnnouncement = false,
    this.isStopwatchAnnouncement = false,
    this.isTimerCompletion = false,
    this.timerRevision,
    this.timerRunId,
    this.delayMs = 0,
    this.language,
    this.voice,
  });
}
