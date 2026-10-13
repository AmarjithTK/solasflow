import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/persistence_error_reporter.dart';
import '../core/pref_keys.dart';
import '../core/safe_preference_reads.dart';
import '../models/app_settings.dart';

/// Stores one validated, versioned settings document.
///
/// Legacy keys are read only for the one-time migration. All writes are
/// serialized and replace one JSON value, so a crash cannot leave a mixture of
/// two settings revisions.
class SettingsService {
  static const int currentSchemaVersion = 9;
  static const String snapshotKey = 'SettingsSnapshotV9';
  static const String speechMasterOverrideKey = 'SpeechMasterTaskOverride';

  static Future<void> _writeTail = Future<void>.value();

  Future<AppSettings> load({required String defaultSound}) async {
    await flush();
    final prefs = await SharedPreferences.getInstance();
    await _runLegacyMigrations(prefs);

    AppSettings settings;
    final hasSnapshot = prefs.containsKey(snapshotKey);
    final schemaVersion = SafePreferenceReads.integer(
      prefs,
      PrefKeys.settingsSchemaVersion,
    );
    final encoded = SafePreferenceReads.string(prefs, snapshotKey);
    if (hasSnapshot &&
        schemaVersion != null &&
        schemaVersion != currentSchemaVersion) {
      debugPrint(
        'Ignoring settings snapshot schema $schemaVersion; '
        'expected $currentSchemaVersion.',
      );
      settings = AppSettings.defaults(defaultSound: defaultSound);
    } else if (encoded == null) {
      settings = hasSnapshot
          ? AppSettings.defaults(defaultSound: defaultSound)
          : _loadLegacy(prefs, defaultSound: defaultSound);
    } else {
      try {
        final decoded = jsonDecode(encoded);
        settings = decoded is Map<String, dynamic>
            ? AppSettings.fromJson(decoded)
            : AppSettings.defaults(defaultSound: defaultSound);
      } catch (error) {
        debugPrint('Ignoring corrupt settings snapshot: $error');
        settings = AppSettings.defaults(defaultSound: defaultSound);
      }
    }

    final taskOverride = SafePreferenceReads.boolean(
      prefs,
      speechMasterOverrideKey,
    );
    if (taskOverride != null) {
      settings = settings.copyWith(speechMasterOn: taskOverride).normalized();
    }

    try {
      await save(settings);
      if (taskOverride != null) {
        await acknowledgeSpeechMasterOverride(taskOverride);
      }
    } catch (error, stackTrace) {
      PersistenceErrorReporter.report('Settings bootstrap', error, stackTrace);
    }
    return settings;
  }

  Future<void> save(AppSettings settings) {
    final stable = AppSettings.fromJson(settings.normalized().toJson());
    final encoded = jsonEncode(stable.toJson());
    final operation = _writeTail.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      final written = await prefs.setString(snapshotKey, encoded);
      if (!written) {
        throw StateError('SharedPreferences rejected settings snapshot write');
      }
      final versionWritten = await prefs.setInt(
        PrefKeys.settingsSchemaVersion,
        currentSchemaVersion,
      );
      if (!versionWritten) {
        throw StateError('SharedPreferences rejected settings schema write');
      }
    });
    _writeTail = operation.catchError((Object error, StackTrace stackTrace) {
      PersistenceErrorReporter.report('Settings', error, stackTrace);
    });
    return operation;
  }

  Future<void> acknowledgeSpeechMasterOverride(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    if (SafePreferenceReads.boolean(prefs, speechMasterOverrideKey) ==
        enabled) {
      final removed = await prefs.remove(speechMasterOverrideKey);
      if (!removed) {
        throw StateError('SharedPreferences rejected speech override removal');
      }
    }
  }

  Future<void> flush() => _writeTail;

  AppSettings _loadLegacy(
    SharedPreferences prefs, {
    required String defaultSound,
  }) {
    final sound =
        SafePreferenceReads.string(prefs, PrefKeys.soundChosen) ?? defaultSound;
    final defaults = AppSettings.defaults(defaultSound: defaultSound);
    return AppSettings(
      soundChosen: sound,
      noiseVolume:
          SafePreferenceReads.decimal(prefs, PrefKeys.noiseVolume) ??
          defaults.noiseVolume,
      speakVolume:
          SafePreferenceReads.decimal(prefs, PrefKeys.speakVolume) ??
          defaults.speakVolume,
      maximumSpeechVolume:
          SafePreferenceReads.boolean(prefs, PrefKeys.maximumSpeechVolume) ??
          ((SafePreferenceReads.boolean(prefs, 'TtsVolumeBoostEnabled') ??
                  false) ||
              (SafePreferenceReads.boolean(
                    prefs,
                    'TtsMaxVolumeLockEnabled',
                  ) ??
                  false)),
      clockOn:
          SafePreferenceReads.boolean(prefs, PrefKeys.clockOn) ??
          defaults.clockOn,
      clockIntervalMins:
          SafePreferenceReads.integer(prefs, PrefKeys.clockIntervalMins) ??
          defaults.clockIntervalMins,
      clockShowMilliseconds:
          SafePreferenceReads.boolean(prefs, PrefKeys.clockShowMilliseconds) ??
          defaults.clockShowMilliseconds,
      clockShowSeconds:
          SafePreferenceReads.boolean(prefs, PrefKeys.clockShowSeconds) ??
          defaults.clockShowSeconds,
      clockSpeakTime:
          SafePreferenceReads.boolean(prefs, PrefKeys.clockSpeakTime) ??
          defaults.clockSpeakTime,
      clockSpeakRepeatCount:
          SafePreferenceReads.integer(prefs, PrefKeys.clockSpeakRepeatCount) ??
          defaults.clockSpeakRepeatCount,
      clockNoiseOn:
          SafePreferenceReads.boolean(prefs, PrefKeys.clockNoiseOn) ??
          defaults.clockNoiseOn,
      motivationOn:
          SafePreferenceReads.boolean(prefs, PrefKeys.motivationOn) ??
          defaults.motivationOn,
      motivationCategory:
          SafePreferenceReads.string(prefs, PrefKeys.motivationCategory) ??
          defaults.motivationCategory,
      motivationDelaySeconds:
          SafePreferenceReads.integer(prefs, PrefKeys.motivationDelaySeconds) ??
          defaults.motivationDelaySeconds,
      timerSpeakOn:
          SafePreferenceReads.boolean(prefs, PrefKeys.timerSpeakOn) ??
          defaults.timerSpeakOn,
      timerAnnounceEvery:
          SafePreferenceReads.integer(prefs, PrefKeys.timerAnnounceEvery) ??
          defaults.timerAnnounceEvery,
      timerShowMilliseconds:
          SafePreferenceReads.boolean(prefs, PrefKeys.timerShowMilliseconds) ??
          defaults.timerShowMilliseconds,
      timerNoiseOn:
          SafePreferenceReads.boolean(prefs, PrefKeys.timerNoiseOn) ??
          defaults.timerNoiseOn,
      goalReminderOn:
          SafePreferenceReads.boolean(prefs, PrefKeys.goalReminderOn) ??
          defaults.goalReminderOn,
      goalReminderIntervalMins:
          SafePreferenceReads.integer(
            prefs,
            PrefKeys.goalReminderIntervalMins,
          ) ??
          defaults.goalReminderIntervalMins,
      goalReminderItems:
          SafePreferenceReads.stringList(
            prefs,
            PrefKeys.goalReminderItems,
          ) ??
          const [],
      goalReminderNextIndex:
          SafePreferenceReads.integer(
            prefs,
            PrefKeys.goalReminderNextIndex,
          ) ??
          defaults.goalReminderNextIndex,
      stopwatchSpeakOn:
          SafePreferenceReads.boolean(prefs, PrefKeys.stopwatchSpeakOn) ??
          defaults.stopwatchSpeakOn,
      stopwatchShowMilliseconds:
          SafePreferenceReads.boolean(
            prefs,
            PrefKeys.stopwatchShowMilliseconds,
          ) ??
          defaults.stopwatchShowMilliseconds,
      stopwatchSpeakDelaySeconds:
          SafePreferenceReads.integer(
            prefs,
            PrefKeys.stopwatchSpeakDelaySeconds,
          ) ??
          defaults.stopwatchSpeakDelaySeconds,
      muteSpeechAfterMidnight:
          SafePreferenceReads.boolean(prefs, PrefKeys.muteSpeechAfterMidnight) ??
          defaults.muteSpeechAfterMidnight,
      nightMuteMode:
          SafePreferenceReads.string(prefs, PrefKeys.nightMuteMode) ??
          defaults.nightMuteMode,
      sleepStartMinutes:
          SafePreferenceReads.integer(prefs, PrefKeys.sleepStartMinutes) ??
          defaults.sleepStartMinutes,
      sleepEndMinutes:
          SafePreferenceReads.integer(prefs, PrefKeys.sleepEndMinutes) ??
          defaults.sleepEndMinutes,
      appDarkTheme:
          SafePreferenceReads.boolean(prefs, PrefKeys.appDarkTheme) ??
          defaults.appDarkTheme,
      fullscreenDarkTheme:
          SafePreferenceReads.boolean(prefs, PrefKeys.fullscreenDarkTheme) ??
          defaults.fullscreenDarkTheme,
      fullscreenDimBrightness:
          SafePreferenceReads.boolean(prefs, PrefKeys.fullscreenDimBrightness) ??
          defaults.fullscreenDimBrightness,
      fullscreenStartLandscape:
          SafePreferenceReads.boolean(
            prefs,
            PrefKeys.fullscreenStartLandscape,
          ) ??
          defaults.fullscreenStartLandscape,
      fullscreenShowClock:
          SafePreferenceReads.boolean(prefs, PrefKeys.fullscreenShowClock) ??
          defaults.fullscreenShowClock,
      fullscreenClockScale:
          SafePreferenceReads.decimal(prefs, PrefKeys.fullscreenClockScale) ??
          defaults.fullscreenClockScale,
      voiceListMode:
          SafePreferenceReads.string(prefs, PrefKeys.voiceListMode) ??
          defaults.voiceListMode,
      speechEngineMode:
          SafePreferenceReads.string(prefs, PrefKeys.speechEngineMode) ??
          defaults.speechEngineMode,
      favoriteVoiceName:
          SafePreferenceReads.string(prefs, PrefKeys.favoriteVoiceName),
      favoriteVoiceLocale:
          SafePreferenceReads.string(prefs, PrefKeys.favoriteVoiceLocale),
      speechMasterOn:
          SafePreferenceReads.boolean(prefs, PrefKeys.speechMasterOn) ??
          defaults.speechMasterOn,
      appFontSizeMultiplier:
          SafePreferenceReads.decimal(prefs, PrefKeys.appFontSizeMultiplier) ??
          defaults.appFontSizeMultiplier,
      backgroundPersistenceOn:
          SafePreferenceReads.boolean(prefs, PrefKeys.backgroundPersistenceOn) ??
          defaults.backgroundPersistenceOn,
      fullscreenDimBrightnessLevel:
          SafePreferenceReads.decimal(
            prefs,
            PrefKeys.fullscreenDimBrightnessLevel,
          ) ??
          defaults.fullscreenDimBrightnessLevel,
      taggingOn:
          SafePreferenceReads.boolean(prefs, PrefKeys.taggingOn) ??
          defaults.taggingOn,
      sessionTag:
          SafePreferenceReads.string(prefs, PrefKeys.sessionTag) ??
          defaults.sessionTag,
    ).normalized();
  }

  Future<void> _runLegacyMigrations(SharedPreferences prefs) async {
    if (!prefs.containsKey(PrefKeys.maximumSpeechVolume)) {
      final oldBoost =
          SafePreferenceReads.boolean(prefs, 'TtsVolumeBoostEnabled') ?? false;
      final oldLock =
          SafePreferenceReads.boolean(prefs, 'TtsMaxVolumeLockEnabled') ??
          false;
      await prefs.setBool(PrefKeys.maximumSpeechVolume, oldBoost || oldLock);
    }
  }

  Future<String> exportToJson({required String defaultSound}) async {
    await flush();
    final settings = await load(defaultSound: defaultSound);
    return const JsonEncoder.withIndent('  ').convert(settings.toJson());
  }

  AppSettings importFromJson(String jsonString) {
    final decoded = const JsonDecoder().convert(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a Solas Flow settings object.');
    }
    const requiredKeys = {
      'soundChosen',
      'noiseVolume',
      'speakVolume',
      'clockOn',
      'clockIntervalMins',
      'timerSpeakOn',
      'timerAnnounceEvery',
      'appDarkTheme',
      'speechMasterOn',
    };
    if (!requiredKeys.every(decoded.containsKey) ||
        decoded['soundChosen'] is! String ||
        decoded['noiseVolume'] is! num ||
        decoded['speakVolume'] is! num ||
        decoded['clockOn'] is! bool ||
        decoded['clockIntervalMins'] is! num ||
        decoded['timerSpeakOn'] is! bool ||
        decoded['timerAnnounceEvery'] is! num ||
        decoded['appDarkTheme'] is! bool ||
        decoded['speechMasterOn'] is! bool) {
      throw const FormatException('Invalid or incomplete Solas Flow settings.');
    }
    return AppSettings.fromJson(decoded);
  }

  Future<String?> exportToUserFolder({
    required String contents,
    required String dialogTitle,
  }) async {
    try {
      final directory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle,
      );
      if (directory == null) return null;
      final now = DateTime.now();
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final time =
          '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}_${now.microsecondsSinceEpoch}';
      final file = File('$directory/SolasFlow_Settings_${date}_$time.json');
      await file.create(exclusive: true);
      try {
        await file.writeAsString(contents, flush: true);
      } catch (_) {
        await file.delete();
        rethrow;
      }
      return file.path;
    } catch (error) {
      debugPrint('Settings export failed: $error');
      rethrow;
    }
  }

  Future<AppSettings?> importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null) {
      throw const FormatException(
        'The selected backup file has no readable path.',
      );
    }
    try {
      return importFromJson(await File(path).readAsString());
    } catch (error) {
      debugPrint('Settings import failed: $error');
      rethrow;
    }
  }
}
