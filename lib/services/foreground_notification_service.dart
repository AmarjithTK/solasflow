import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../models/foreground_notification_state.dart';

/// Single owner for foreground-service start, update, and stop transitions.
class ForegroundNotificationService {
  final String notificationIconMetaDataName;

  Future<void> _operationTail = Future<void>.value();
  String? _lastSignature;
  Object? _lastError;

  ForegroundNotificationService({required this.notificationIconMetaDataName});

  Object? get lastError => _lastError;

  bool get _supportsForegroundTask =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> reconcile({
    required bool shouldRun,
    required ForegroundNotificationPresentation presentation,
    required Function callback,
    bool force = false,
  }) {
    final completer = Completer<bool>();
    _operationTail = _operationTail
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('Foreground predecessor failed: $error');
        })
        .then((_) async {
          try {
            completer.complete(
              await _reconcileNow(
                shouldRun: shouldRun,
                presentation: presentation,
                callback: callback,
                force: force,
              ),
            );
          } catch (error, stackTrace) {
            _lastError = error;
            debugPrint('Foreground reconciliation failed: $error\n$stackTrace');
            completer.complete(false);
          }
        });
    return completer.future;
  }

  Future<bool> _reconcileNow({
    required bool shouldRun,
    required ForegroundNotificationPresentation presentation,
    required Function callback,
    required bool force,
  }) async {
    if (!_supportsForegroundTask) return !shouldRun;

    final running = await _isServiceRunning();
    if (!shouldRun) {
      if (!running) {
        _lastSignature = null;
        _lastError = null;
        return true;
      }
      final result = await FlutterForegroundTask.stopService();
      return _acceptResult(result, onSuccess: () => _lastSignature = null);
    }

    final signature = _signature(presentation);
    if (!running) {
      final result = await FlutterForegroundTask.startService(
        notificationTitle: presentation.title,
        notificationText: presentation.text,
        notificationIcon: NotificationIcon(
          metaDataName: notificationIconMetaDataName,
        ),
        notificationButtons: presentation.buttons,
        callback: callback,
      );
      return _acceptResult(result, onSuccess: () => _lastSignature = signature);
    }

    if (!force && signature == _lastSignature) return true;
    final result = await FlutterForegroundTask.updateService(
      notificationTitle: presentation.title,
      notificationText: presentation.text,
      notificationButtons: presentation.buttons,
    );
    return _acceptResult(result, onSuccess: () => _lastSignature = signature);
  }

  Future<bool> _isServiceRunning() async {
    try {
      return await FlutterForegroundTask.isRunningService;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  bool _acceptResult(
    ServiceRequestResult result, {
    required VoidCallback onSuccess,
  }) {
    if (result is ServiceRequestSuccess) {
      _lastError = null;
      onSuccess();
      return true;
    }
    final error = (result as ServiceRequestFailure).error;
    _lastError = error;
    debugPrint('Foreground service request rejected: $error');
    return false;
  }

  String _signature(ForegroundNotificationPresentation presentation) {
    final buttons = presentation.buttons
        .map((button) => '${button.id}:${button.text}')
        .join('|');
    return '${presentation.title}\u0000${presentation.text}\u0000$buttons';
  }
}
