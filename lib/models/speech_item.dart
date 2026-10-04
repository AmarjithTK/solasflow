class SpeechItem {
  final String text;
  final bool isQuote;
  final bool isClockAnnouncement;
  final int delayMs;
  final String? language; // 'en' or 'ml' - set at enqueue time for consistency
  final Map<dynamic, dynamic>? voice;

  SpeechItem(
    this.text, {
    this.isQuote = false,
    this.isClockAnnouncement = false,
    this.delayMs = 0,
    this.language,
    this.voice,
  });
}
