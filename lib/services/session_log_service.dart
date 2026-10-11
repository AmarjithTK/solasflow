import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/persistence_error_reporter.dart';
import '../core/safe_preference_reads.dart';
import '../models/session_log.dart';

class SessionLogService {
  static const String _prefsKey = 'SessionLogs';
  static const int retentionDays = 90;
  static Future<void> _writeTail = Future<void>.value();
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<void> logSession(SessionLog session) {
    final operation = _writeTail.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      final stored = _decode(
        SafePreferenceReads.stringList(prefs, _prefsKey) ?? const [],
      );
      final sessions = stored.sessions;
      if (session.sessionId.isNotEmpty &&
          sessions.any((saved) => saved.sessionId == session.sessionId)) {
        return;
      }
      sessions.add(session);
      await _writeSessions(
        prefs,
        sessions,
        preservedRecords: stored.unparsedRecords,
      );
      revision.value++;
    });
    _writeTail = operation.catchError((Object error, StackTrace stackTrace) {
      PersistenceErrorReporter.report('Session history', error, stackTrace);
    });
    return operation;
  }

  Future<List<SessionLog>> getSessionsForDate(DateTime date) async {
    final all = await _loadAll();
    return all
        .where((session) => session.overlapsDay(date))
        .toList(growable: false);
  }

  Future<DailySummary> getDailySummary(DateTime date) async {
    final sessions = await getSessionsForDate(date);
    return SessionLog.summarizeForDay(sessions, date);
  }

  Future<List<(DateTime date, DailySummary summary)>> getRecentSummaries({
    int days = 30,
  }) async {
    final all = await _loadAll();
    final now = DateTime.now();
    final results = <(DateTime, DailySummary)>[];
    for (var offset = 0; offset < days; offset++) {
      final date = DateTime(now.year, now.month, now.day - offset);
      final summary = SessionLog.summarizeForDay(all, date);
      if (summary.totalSeconds > 0) results.add((date, summary));
    }
    return results;
  }

  Future<void> prune() {
    final operation = _writeTail.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      final stored = _decode(
        SafePreferenceReads.stringList(prefs, _prefsKey) ?? const [],
      );
      await _writeSessions(
        prefs,
        stored.sessions,
        preservedRecords: stored.unparsedRecords,
      );
    });
    _writeTail = operation.catchError((Object error, StackTrace stackTrace) {
      PersistenceErrorReporter.report(
        'Session history prune',
        error,
        stackTrace,
      );
    });
    return operation;
  }

  Future<List<SessionLog>> _loadAll() async {
    await _writeTail;
    final prefs = await SharedPreferences.getInstance();
    return _decode(
      SafePreferenceReads.stringList(prefs, _prefsKey) ?? const [],
    ).sessions;
  }

  _SessionRecords _decode(List<String> raw) {
    final sessions = <SessionLog>[];
    final unparsedRecords = <String>[];
    for (final line in raw) {
      try {
        final decoded = jsonDecode(line);
        if (decoded is Map<String, dynamic>) {
          sessions.add(SessionLog.fromJson(decoded));
        } else {
          unparsedRecords.add(line);
        }
      } catch (_) {
        unparsedRecords.add(line);
      }
    }
    return _SessionRecords(sessions, unparsedRecords);
  }

  Future<void> _writeSessions(
    SharedPreferences prefs,
    List<SessionLog> sessions, {
    List<String> preservedRecords = const [],
  }) async {
    final cutoff = DateTime.now().subtract(const Duration(days: retentionDays));
    final encoded = [
      ...preservedRecords,
      ...sessions
          .where((session) => session.endTime.isAfter(cutoff))
          .map((session) => jsonEncode(session.toJson())),
    ];
    final written = await prefs.setStringList(_prefsKey, encoded);
    if (!written) throw StateError('SharedPreferences rejected session log');
  }
}

class _SessionRecords {
  final List<SessionLog> sessions;
  final List<String> unparsedRecords;

  const _SessionRecords(this.sessions, this.unparsedRecords);
}
