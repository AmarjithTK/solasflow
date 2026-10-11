import 'package:flutter/foundation.dart';

class PersistenceFailure {
  final int sequence;
  final String source;
  final Object error;
  final StackTrace stackTrace;

  const PersistenceFailure({
    required this.sequence,
    required this.source,
    required this.error,
    required this.stackTrace,
  });
}

class PersistenceErrorReporter {
  static final ValueNotifier<PersistenceFailure?> latest =
      ValueNotifier<PersistenceFailure?>(null);
  static int _sequence = 0;

  static void report(String source, Object error, StackTrace stackTrace) {
    debugPrint('[ERROR] [DB] $source write failed: $error\n$stackTrace');
    latest.value = PersistenceFailure(
      sequence: ++_sequence,
      source: source,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
