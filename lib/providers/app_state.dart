import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../services/settings_service.dart';

/// The immutable, complete settings snapshot used by every UI surface.
typedef SettingsState = AppSettings;

/// Owns the only in-memory copy of user settings.
///
/// [bootstrap] is called before `runApp`, so consumers never render temporary
/// defaults and external actions cannot race a later preferences load.
class SettingsNotifier extends Notifier<AppSettings> {
  static AppSettings _bootSettings = AppSettings.defaults();

  static void bootstrap(AppSettings settings) {
    _bootSettings = settings.normalized();
  }

  @override
  AppSettings build() => _bootSettings;

  final SettingsService _settingsService = SettingsService();

  Future<void> replace(AppSettings settings) {
    final snapshot = settings.normalized();
    if (snapshot == state) return Future.value();
    _bootSettings = snapshot;
    state = snapshot;
    return _persist(snapshot);
  }

  Future<void> update(AppSettings Function(AppSettings current) transform) {
    final snapshot = transform(state).normalized();
    if (snapshot == state) return Future.value();
    _bootSettings = snapshot;
    state = snapshot;
    return _persist(snapshot);
  }

  Future<void> _persist(AppSettings settings) {
    final write = _settingsService.save(settings);
    unawaited(write.catchError((Object error, StackTrace stackTrace) {}));
    return write;
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
