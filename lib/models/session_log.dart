int _localDayOffset(DateTime timestamp, {bool nextDay = false}) =>
    timestamp.isUtc
    ? 0
    : DateTime(
        timestamp.year,
        timestamp.month,
        timestamp.day + (nextDay ? 1 : 0),
      ).timeZoneOffset.inMinutes;
final RegExp _explicitZoneSuffix = RegExp(r'(?:Z|[+-]\d{2}:\d{2})$');

DateTime _parseStoredTimestamp(String value) {
  final parsed = DateTime.parse(value);
  if (_explicitZoneSuffix.hasMatch(value)) return parsed.toUtc();
  return DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
    parsed.microsecond,
  );
}

/// A single timer session record with study/non-study tag.
///
/// Stored as JSON in SharedPreferences. Each completed or partial timer
/// session is logged with its start/end times, duration, and tag.

class SessionLog {
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final String tag; // "study" | "non-study"
  final String sessionId;
  final int startTimeOffsetMinutes;
  final int endTimeOffsetMinutes;
  final int startDayOffsetMinutes;
  final int endDayOffsetMinutes;
  final int startNextDayOffsetMinutes;
  final int endNextDayOffsetMinutes;

  SessionLog({
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.tag,
    this.sessionId = '',
    int? startTimeOffsetMinutes,
    int? endTimeOffsetMinutes,
    int? startDayOffsetMinutes,
    int? endDayOffsetMinutes,
    int? startNextDayOffsetMinutes,
    int? endNextDayOffsetMinutes,
  }) : startTimeOffsetMinutes =
           startTimeOffsetMinutes ??
           (startTime.isUtc ? 0 : startTime.timeZoneOffset.inMinutes),
       endTimeOffsetMinutes =
           endTimeOffsetMinutes ??
           (endTime.isUtc ? 0 : endTime.timeZoneOffset.inMinutes),
       startDayOffsetMinutes =
           startDayOffsetMinutes ?? _localDayOffset(startTime),
       endDayOffsetMinutes =
           endDayOffsetMinutes ?? _localDayOffset(endTime),
       startNextDayOffsetMinutes =
           startNextDayOffsetMinutes ??
           _localDayOffset(startTime, nextDay: true),
       endNextDayOffsetMinutes =
           endNextDayOffsetMinutes ?? _localDayOffset(endTime, nextDay: true);

  bool get isStudy => tag == 'study';
  bool get isNonStudy => tag == 'non-study';

  String get formattedDuration {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  int get _startOffsetMinutes => startTimeOffsetMinutes;
  int get _endOffsetMinutes => endTimeOffsetMinutes;
  int get _startDayOffsetMinutes => startDayOffsetMinutes;
  int get _endDayOffsetMinutes => endDayOffsetMinutes;
  int get _startNextDayOffsetMinutes => startNextDayOffsetMinutes;
  int get _endNextDayOffsetMinutes => endNextDayOffsetMinutes;

  DateTime get localStartTime => _localWallTime(
    startTime,
    _startOffsetMinutes,
  );
  DateTime get localEndTime => _localWallTime(endTime, _endOffsetMinutes);

  DateTime _localWallTime(DateTime timestamp, int offsetMinutes) =>
      DateTime.fromMillisecondsSinceEpoch(
        timestamp.toUtc().millisecondsSinceEpoch + offsetMinutes * 60000,
        isUtc: true,
      );

  int _offsetAtDayStart(DateTime day) {
    final startDate = localStartTime;
    final endDate = localEndTime;
    if (_sameDate(day, startDate)) return _startDayOffsetMinutes;
    if (_sameDate(
      day,
      DateTime(startDate.year, startDate.month, startDate.day + 1),
    )) {
      return _startNextDayOffsetMinutes;
    }
    if (_sameDate(day, endDate)) return _endDayOffsetMinutes;
    if (_sameDate(
      day,
      DateTime(endDate.year, endDate.month, endDate.day + 1),
    )) {
      return _endNextDayOffsetMinutes;
    }
    return _startNextDayOffsetMinutes;
  }

  bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  int _dayBoundaryEpochMs(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch -
      _offsetAtDayStart(day) * 60000;

  Map<String, dynamic> toJson() => {
    'startTime': startTime.toUtc().toIso8601String(),
    'endTime': endTime.toUtc().toIso8601String(),
    'startTimeOffsetMinutes': _startOffsetMinutes,
    'endTimeOffsetMinutes': _endOffsetMinutes,
    'startDayOffsetMinutes': _startDayOffsetMinutes,
    'endDayOffsetMinutes': _endDayOffsetMinutes,
    'startNextDayOffsetMinutes': _startNextDayOffsetMinutes,
    'endNextDayOffsetMinutes': _endNextDayOffsetMinutes,
    'durationSeconds': durationSeconds,
    'tag': tag,
    if (sessionId.isNotEmpty) 'sessionId': sessionId,
  };

  factory SessionLog.fromJson(Map<String, dynamic> json) {
    final startTime = _parseStoredTimestamp(json['startTime'] as String);
    final endTime = _parseStoredTimestamp(json['endTime'] as String);
    int offset(String key, DateTime timestamp) {
      final saved = json[key];
      if (saved is num) return saved.toInt();
      return timestamp.isUtc ? 0 : timestamp.timeZoneOffset.inMinutes;
    }

    int dayOffset(String key, DateTime timestamp, {bool nextDay = false}) {
      final saved = json[key];
      if (saved is num) return saved.toInt();
      if (timestamp.isUtc) return 0;
      return DateTime(
        timestamp.year,
        timestamp.month,
        timestamp.day + (nextDay ? 1 : 0),
      ).timeZoneOffset.inMinutes;
    }

    return SessionLog(
      startTime: startTime,
      endTime: endTime,
      durationSeconds: json['durationSeconds'] as int,
      tag: json['tag'] as String,
      sessionId: json['sessionId']?.toString() ?? '',
      startTimeOffsetMinutes: offset('startTimeOffsetMinutes', startTime),
      endTimeOffsetMinutes: offset('endTimeOffsetMinutes', endTime),
      startDayOffsetMinutes: dayOffset('startDayOffsetMinutes', startTime),
      endDayOffsetMinutes: dayOffset('endDayOffsetMinutes', endTime),
      startNextDayOffsetMinutes: dayOffset(
        'startNextDayOffsetMinutes',
        startTime,
        nextDay: true,
      ),
      endNextDayOffsetMinutes: dayOffset(
        'endNextDayOffsetMinutes',
        endTime,
        nextDay: true,
      ),
    );
  }

  bool overlapsDay(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = DateTime(day.year, day.month, day.day + 1);
    return _overlapMilliseconds(dayStart, dayEnd) > 0;
  }

  int secondsWithin(DateTime dayStart, DateTime dayEnd) {
    final overlapMs = _overlapMilliseconds(dayStart, dayEnd);
    if (overlapMs <= 0) return 0;
    final wallMs = endTime.toUtc().difference(startTime.toUtc()).inMilliseconds;
    if (wallMs <= 0) return durationSeconds;
    return (durationSeconds * overlapMs / wallMs).round();
  }

  int _overlapMilliseconds(DateTime dayStart, DateTime dayEnd) {
    final sessionStartMs = startTime.toUtc().millisecondsSinceEpoch;
    final sessionEndMs = endTime.toUtc().millisecondsSinceEpoch;
    final dayStartMs = _dayBoundaryEpochMs(dayStart);
    final dayEndMs = _dayBoundaryEpochMs(dayEnd);
    if (sessionStartMs >= dayEndMs || sessionEndMs <= dayStartMs) return 0;
    final clippedStart = sessionStartMs > dayStartMs
        ? sessionStartMs
        : dayStartMs;
    final clippedEnd = sessionEndMs < dayEndMs ? sessionEndMs : dayEndMs;
    return clippedEnd - clippedStart;
  }

  /// Daily summary for a group of sessions.
  static DailySummary summarize(List<SessionLog> sessions) {
    int studySeconds = 0;
    int nonStudySeconds = 0;
    for (final s in sessions) {
      if (s.isStudy) {
        studySeconds += s.durationSeconds;
      } else {
        nonStudySeconds += s.durationSeconds;
      }
    }
    return DailySummary(
      studySeconds: studySeconds,
      nonStudySeconds: nonStudySeconds,
    );
  }

  static DailySummary summarizeForDay(List<SessionLog> sessions, DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = DateTime(day.year, day.month, day.day + 1);
    var studySeconds = 0;
    var nonStudySeconds = 0;
    for (final session in sessions) {
      final seconds = session.secondsWithin(dayStart, dayEnd);
      if (session.isStudy) {
        studySeconds += seconds;
      } else {
        nonStudySeconds += seconds;
      }
    }
    return DailySummary(
      studySeconds: studySeconds,
      nonStudySeconds: nonStudySeconds,
    );
  }
}

/// Aggregated study/non-study totals for a single day.
class DailySummary {
  final int studySeconds;
  final int nonStudySeconds;

  const DailySummary({
    required this.studySeconds,
    required this.nonStudySeconds,
  });

  int get totalSeconds => studySeconds + nonStudySeconds;

  String get studyFormatted => _format(studySeconds);
  String get nonStudyFormatted => _format(nonStudySeconds);
  String get totalFormatted => _format(totalSeconds);

  static String _format(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
