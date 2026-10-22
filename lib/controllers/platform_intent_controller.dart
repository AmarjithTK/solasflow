import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:quick_actions/quick_actions.dart';

import '../l10n/app_localizations.dart';

abstract interface class PlatformIntentHost {
  bool get isMounted;

  Map<String, Object?> widgetState(String? armedAction);

  Future<void> handleQuickAction(String type);

  Future<void> handleWidgetAction(String type);

  Future<void> handleTaskData(Object data);
}

class PlatformIntentController {
  static const Duration _confirmationWindow = Duration(seconds: 3);
  static const MethodChannel _widgetChannel = MethodChannel(
    'com.atherpulse.solasflow/widget',
  );

  final PlatformIntentHost _host;
  final QuickActions _quickActions = const QuickActions();
  bool _supportsQuickActions = false;
  bool _bootstrapReady = false;
  String? _armedAction;
  Timer? _armedTimer;
  Future<void> _widgetDrainTail = Future<void>.value();
  final List<Future<void> Function()> _pendingExternalActions = [];

  PlatformIntentController(this._host);

  String? get armedAction => _armedAction;
  void _receiveTaskData(Object data) {
    dispatch(() => _host.handleTaskData(data));
  }

  void initializeChannel() {
    FlutterForegroundTask.addTaskDataCallback(_receiveTaskData);
    _widgetChannel.setMethodCallHandler((call) async {
      if (call.method == 'widgetActionsAvailable') {
        dispatch(drainWidgetActions);
      }
    });
  }

  bool initializeQuickActions(AppLocalizations localizations) {
    _supportsQuickActions =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (!_supportsQuickActions) return false;

    try {
      _quickActions.initialize((type) {
        dispatch(() => _host.handleQuickAction(type));
      });
      _quickActions.setShortcutItems(<ShortcutItem>[
        ShortcutItem(
          type: 'start_25m',
          localizedTitle: localizations.quickActionStart25m,
          icon: 'icon_start',
        ),
        ShortcutItem(
          type: 'resume_last',
          localizedTitle: localizations.quickActionResumeLast,
          icon: 'icon_resume',
        ),
        ShortcutItem(
          type: 'toggle_speech',
          localizedTitle: localizations.quickActionToggleSpeech,
          icon: 'icon_speech',
        ),
      ]);
    } on MissingPluginException {
      debugPrint('QuickActions plugin unavailable on this platform/runtime.');
    } on PlatformException catch (error) {
      debugPrint('QuickActions failed: $error');
    }
    return true;
  }

  void dispatch(Future<void> Function() action) {
    if (!_bootstrapReady) {
      _pendingExternalActions.add(action);
      return;
    }
    unawaited(
      action().catchError((Object error, StackTrace stackTrace) {
        debugPrint('[ERROR] Dispatched action failed: $error\n$stackTrace');
      }),
    );
  }

  Future<void> markBootstrapReady() async {
    await releaseBootstrapQueue();
    await drainWidgetActions();
    await writeWidgetState();
  }

  Future<void> releaseBootstrapQueue() async {
    _bootstrapReady = true;
    final pending = List<Future<void> Function()>.of(_pendingExternalActions);
    _pendingExternalActions.clear();
    for (final action in pending) {
      try {
        await action();
      } catch (error, stackTrace) {
        debugPrint('[ERROR] Queued startup action failed: $error\n$stackTrace');
      }
      if (!_host.isMounted) return;
    }
  }

  Future<void> writeWidgetState() async {
    if (!Platform.isAndroid) return;
    try {
      await _widgetChannel.invokeMethod<bool>(
        'updateWidgetState',
        _host.widgetState(_armedAction),
      );
    } on PlatformException catch (error) {
      debugPrint('Widget state update failed: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Widget channel unavailable: $error');
    }
  }

  Future<void> handleWidgetAction(String type) async {
    if (!_host.isMounted) return;
    if (type == 'toggle_speech_master' || type == 'open_fullscreen_clock') {
      if (_armedAction == type) {
        _armedTimer?.cancel();
        _armedAction = null;
        unawaited(writeWidgetState());
        await _host.handleWidgetAction(type);
        return;
      }

      _armedTimer?.cancel();
      _armedAction = type;
      unawaited(writeWidgetState());
      _armedTimer = Timer(_confirmationWindow, () {
        if (!_host.isMounted) return;
        _armedAction = null;
        unawaited(writeWidgetState());
      });
      return;
    }
    await _host.handleWidgetAction(type);
  }

  Future<void> drainWidgetActions() {
    _widgetDrainTail = _widgetDrainTail
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('Previous widget drain failed: $error');
        })
        .then((_) => _drainWidgetActionsNow());
    return _widgetDrainTail;
  }

  Future<void> _drainWidgetActionsNow() async {
    if (!Platform.isAndroid || !_host.isMounted) return;
    try {
      final queued = await _widgetChannel.invokeListMethod<dynamic>(
        'drainWidgetActions',
      );
      for (final raw in queued ?? const <dynamic>[]) {
        if (raw is! Map) continue;
        final id = raw['id']?.toString();
        final action = raw['action']?.toString();
        if (id == null || action == null) continue;
        if (action == 'toggle_speech_master' ||
            action == 'open_fullscreen_clock') {
          final receivedAtEpochMs =
              int.tryParse(raw['receivedAtEpochMs']?.toString() ?? '') ?? 0;
          final ageMs =
              DateTime.now().millisecondsSinceEpoch - receivedAtEpochMs;
          if (ageMs < 0 || ageMs >= _confirmationWindow.inMilliseconds) {
            await _widgetChannel.invokeMethod<bool>('ackWidgetAction', {
              'id': id,
            });
            continue;
          }
        }
        await handleWidgetAction(action);
        await _widgetChannel.invokeMethod<bool>('ackWidgetAction', {'id': id});
        if (!_host.isMounted) return;
      }
    } on PlatformException catch (error) {
      debugPrint('Widget action drain failed: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Widget channel unavailable: $error');
    }
  }

  void dispose() {
    _armedTimer?.cancel();
    _armedTimer = null;
    _widgetChannel.setMethodCallHandler(null);
    FlutterForegroundTask.removeTaskDataCallback(_receiveTaskData);
  }
}
