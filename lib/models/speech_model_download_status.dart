import 'package:flutter/foundation.dart';

enum SpeechModelDownloadPhase {
  notDownloaded,
  downloading,
  verifying,
  installing,
  ready,
  failed,
  cancelled,
}

@immutable
class SpeechModelDownloadStatus {
  const SpeechModelDownloadStatus({
    required this.phase,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.error,
  });

  final SpeechModelDownloadPhase phase;
  final int receivedBytes;
  final int totalBytes;
  final String? error;

  bool get isBusy =>
      phase == SpeechModelDownloadPhase.downloading ||
      phase == SpeechModelDownloadPhase.verifying ||
      phase == SpeechModelDownloadPhase.installing;

  bool get canRetry =>
      phase == SpeechModelDownloadPhase.failed ||
      phase == SpeechModelDownloadPhase.cancelled;

  double? get progress {
    if (phase != SpeechModelDownloadPhase.downloading || totalBytes <= 0) {
      return null;
    }
    return (receivedBytes / totalBytes).clamp(0.0, 1.0).toDouble();
  }

  SpeechModelDownloadStatus copyWith({
    SpeechModelDownloadPhase? phase,
    int? receivedBytes,
    int? totalBytes,
    String? error,
    bool clearError = false,
  }) {
    return SpeechModelDownloadStatus(
      phase: phase ?? this.phase,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      error: clearError ? null : error ?? this.error,
    );
  }
}
