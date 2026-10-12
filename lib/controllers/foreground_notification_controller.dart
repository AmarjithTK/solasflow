import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../l10n/app_localizations.dart';
import '../models/foreground_notification_state.dart';
import '../services/foreground_notification_service.dart';
import '../services/foreground_task_handler.dart';

abstract interface class ForegroundNotificationHost {
  bool get mounted;
  bool get foregroundTimerRunning;
  bool get foregroundStopwatchRunning;
  bool get foregroundClockRunning;
  bool get foregroundBackgroundPersistence;
  bool get foregroundTimerFinished;
  String get foregroundTimerValue;
  String get foregroundStopwatchValue;
  String get foregroundCurrentTime;
  bool get foregroundSpeechMasterOn;
  AppLocalizations get appLocalizations;
  Future<void> requestForegroundPermissions();
  void onForegroundNotificationError(Object error);
}

class ForegroundNotificationController {
  ForegroundNotificationController({required ForegroundNotificationHost host})
    : _host = host,
      _service = ForegroundNotificationService(
        notificationIconMetaDataName:
            'com.atherpulse.solasflow.service.NOTIFICATION_ICON',
      );

  final ForegroundNotificationHost _host;
  final ForegroundNotificationService _service;
  Timer? _healthCheck;

  bool get _shouldRun =>
      _host.foregroundBackgroundPersistence ||
      _host.foregroundTimerRunning ||
      _host.foregroundStopwatchRunning ||
      _host.foregroundClockRunning ||
      _host.foregroundTimerFinished;

  ForegroundNotificationState _state() => ForegroundNotificationState(
    isTimerRunning: _host.foregroundTimerRunning,
    isStopwatchRunning: _host.foregroundStopwatchRunning,
    isClockRunning: _host.foregroundClockRunning,
    timerValue: _host.foregroundTimerValue,
    stopwatchValue: _host.foregroundStopwatchValue,
    currentTimeDisplay: _host.foregroundCurrentTime,
    speechMasterOn: _host.foregroundSpeechMasterOn,
    isTimerFinished: _host.foregroundTimerFinished,
  );

  ForegroundNotificationPresentation _presentation() =>
      ForegroundNotificationPresentation.fromState(
        _state(),
        _host.appLocalizations,
      );

  Future<void> reconcile({bool force = false}) async {
    if (Platform.isLinux) return;
    final ok = await _service.reconcile(
      shouldRun: _shouldRun,
      presentation: _presentation(),
      callback: startCallback,
      force: force,
    );
    if (!ok && _service.lastError != null) {
      _host.onForegroundNotificationError(_service.lastError!);
    }
  }

  Future<void> initialize() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _host.requestForegroundPermissions();
      await reconcile(force: true);
    }
  }

  Future<void> stop() async {
    await _service.reconcile(
      shouldRun: false,
      presentation: _presentation(),
      callback: startCallback,
      force: true,
    );
  }

  void startHealthCheck() {
    _healthCheck?.cancel();
    _healthCheck = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_host.mounted || !_shouldRun) return;
      unawaited(reconcile(force: true));
    });
  }

  void dispose() {
    _healthCheck?.cancel();
    _healthCheck = null;
  }
}
