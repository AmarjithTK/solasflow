// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SolasFlow';

  @override
  String get helpTitle => 'Help / Working';

  @override
  String get timerTab => 'Timer';

  @override
  String get clockTab => 'Clock';

  @override
  String get settingsTab => 'Settings';

  @override
  String get presetTab => 'Presets';

  @override
  String get startButton => 'Start';

  @override
  String get pauseButton => 'Pause';

  @override
  String get resumeButton => 'Resume';

  @override
  String get stopButton => 'Stop';

  @override
  String get resetButton => 'Reset';

  @override
  String get skipButton => 'Skip';

  @override
  String get addTimeButton => 'Add Time';

  @override
  String get chainModeLabel => 'Chain Mode';

  @override
  String get chainModeDescription => 'Run preset timers in sequence';

  @override
  String get timerNotificationTitle => 'Timer Running';

  @override
  String get clockNotificationTitle => 'Time Check';

  @override
  String get focusMode => 'Focus Mode';

  @override
  String get fullscreenMode => 'Fullscreen';

  @override
  String get soundLabel => 'Background Sound';

  @override
  String get volumeLabel => 'Volume';

  @override
  String get voiceLabel => 'Voice Selection';

  @override
  String get darkThemeLabel => 'Dark Theme';

  @override
  String get motivationCategoryLabel => 'Motivation Category';

  @override
  String get motivationDelayLabel => 'Quote Delay (seconds)';

  @override
  String get clockIntervalLabel => 'Clock Interval (minutes)';

  @override
  String get timerAnnouncementLabel => 'Announce Every (minutes)';

  @override
  String get nightMuteMode => 'Night Mute Mode';

  @override
  String get sleepStartLabel => 'Sleep Start Time';

  @override
  String get sleepEndLabel => 'Sleep End Time';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get quickActionStart25m => 'Start 25m';

  @override
  String get quickActionResumeLast => 'Resume Last';

  @override
  String get quickActionToggleSpeech => 'Toggle Speech';

  @override
  String get timerForegroundChannelName => 'SolasFlow Timer';

  @override
  String get timerForegroundChannelDescription =>
      'Persistent timer & stopwatch service';

  @override
  String get timerFinishedNotificationTitle => 'Timer Finished';

  @override
  String get stopwatchNotificationTitle => 'Stopwatch Running';

  @override
  String get audioOnLabel => 'Audio ON';

  @override
  String get audioOffLabel => 'Audio OFF';

  @override
  String get timerFinishedNotificationText =>
      'Timer finished! Tap to set next timer.';

  @override
  String notificationTimeRemaining(String value) {
    return 'Time remaining: $value';
  }

  @override
  String notificationElapsed(String value) {
    return 'Elapsed: $value';
  }

  @override
  String get repeatButton => 'Repeat';

  @override
  String get dismissButton => 'Dismiss';

  @override
  String get openButton => 'Open';

  @override
  String get exitButton => 'Exit';

  @override
  String get stopwatchTab => 'Stopwatch';

  @override
  String mainSpeechEngineChangeFailed(String error) {
    return 'Unable to change speech engine: $error';
  }

  @override
  String mainSettingsOpenFailed(String error) {
    return 'Unable to open Settings: $error';
  }

  @override
  String get mainBackupSavedTitle => 'Backup Saved';

  @override
  String get mainSettingsExported => 'Settings exported successfully.';

  @override
  String get mainJsonCopied => 'JSON copied to clipboard';

  @override
  String get mainCopyJson => 'Copy JSON';

  @override
  String get mainDone => 'Done';

  @override
  String get mainBackupFailedTitle => 'Backup failed';

  @override
  String mainBackupFileFailed(String error) {
    return 'The file could not be saved: $error. Copy the settings JSON instead?';
  }

  @override
  String get mainCancel => 'Cancel';

  @override
  String mainBackupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get mainRestoreSettingsTitle => 'Restore Settings';

  @override
  String get mainRestoreSettingsWarning =>
      'This will replace the app preferences in this backup. Local desktop offline-model selections are not included and will stay unchanged. The restored preferences will take effect immediately. Continue?';

  @override
  String get mainRestoreButton => 'Restore';

  @override
  String get mainSettingsRestored => 'Settings restored successfully!';

  @override
  String mainRestoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get mainDesktopAlwaysOnTopNote =>
      'Always on top is a window-manager hint. Some Wayland desktops ignore it; use the compositor’s window rules if needed.';

  @override
  String mainDesktopActionFailed(String error) {
    return 'Desktop action failed: $error';
  }

  @override
  String mainStartupIncomplete(String error) {
    return 'Startup is incomplete: $error';
  }

  @override
  String get mainTimerDurationRangeError => 'Enter a value between 1 and 720';

  @override
  String get mainTimerFinishedTitle => 'Timer finished';

  @override
  String get mainRepeatSameTimer => 'Repeat Same Timer';

  @override
  String get mainStartPresetTimer => 'Start New Preset Timer';

  @override
  String mainMinuteShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get mainCustomDurationMinutes => 'Custom duration (minutes)';

  @override
  String get mainCloseTimer => 'Close timer';

  @override
  String get mainStartCustomTimer => 'Start custom';

  @override
  String get mainTurnAudioOn => 'Turn audio on';

  @override
  String get mainTurnAudioOff => 'Turn audio off';

  @override
  String get mainDesktopControls => 'Desktop controls';

  @override
  String get mainDriveModeCompact => 'Drive Mode — compact';

  @override
  String get mainDriveModeFullscreen => 'Drive Mode — fullscreen';

  @override
  String get mainKeepRunningWhenClosed => 'Keep running when closed';

  @override
  String get mainAlwaysOnTopDesktopHint => 'Always on top (desktop hint)';

  @override
  String get mainHideToBackground => 'Hide to background';

  @override
  String get dashboardTimeUtilization => 'Time Utilization';

  @override
  String get dashboardLoadError => 'Unable to load session history.';

  @override
  String get dashboardNoSessions =>
      'No sessions logged yet.\nEnable tagging and complete a timer to see data.';

  @override
  String get daySummaryStudy => 'Study';

  @override
  String get daySummaryNonStudy => 'Non-study';

  @override
  String get presetGridQuickPresets => 'Quick presets';

  @override
  String get kokoroDownloadTitle => 'Download the Kokoro English voice?';

  @override
  String get kokoroDownloadDescription =>
      'Solas Flow can download an English speech model of about 98.5 MiB for more natural English announcements. The download is verified and then available offline. English and Malayalam bundled voices remain available if you skip it. You can download, cancel, or retry later from Settings.';

  @override
  String get kokoroKeepPiper => 'Keep Piper';

  @override
  String get kokoroAcceptAndDownload => 'Accept and download';

  @override
  String get clockPanelCurrentTime => 'CURRENT TIME';

  @override
  String get clockPanelSound => 'Sound';

  @override
  String get clockPanelNoise => 'Noise';

  @override
  String get clockPanelQuotes => 'Quotes';

  @override
  String get clockPanelBackground => 'Background';

  @override
  String get clockPanelAnnounceInterval => 'Announce interval';

  @override
  String clockPanelMinutes(int count) {
    return '$count min';
  }

  @override
  String clockPanelEveryMinutes(int count) {
    return 'Every $count min';
  }

  @override
  String get clockPanelRepeatCount => 'Repeat count';

  @override
  String clockPanelTimes(int count) {
    return '$count times';
  }

  @override
  String get clockPanelQuoteCategory => 'Quote category';

  @override
  String get clockPanelQuoteDelay => 'Quote delay';

  @override
  String clockPanelSecondsDelay(int seconds) {
    return '$seconds sec delay';
  }

  @override
  String get clockPanelShowSeconds => 'Show seconds';

  @override
  String get clockPanelShowMilliseconds => 'Show milliseconds';

  @override
  String get clockPanelOn => 'On';

  @override
  String get clockPanelOff => 'Off';

  @override
  String get clockPanelCategoryGeneral => 'General';

  @override
  String get clockPanelCategoryGeneralMalayalam => 'General Malayalam';

  @override
  String get clockPanelCategoryFocus => 'Focus';

  @override
  String get clockPanelCategoryDiscipline => 'Discipline';

  @override
  String get clockPanelCategoryCalm => 'Calm';

  @override
  String get clockPanelCategoryPositivity => 'Positivity';

  @override
  String get clockPanelCategoryHistoricFigures => 'Historic Figures';

  @override
  String timerPanelEndsAt(String time) {
    return 'Ends at $time';
  }

  @override
  String get timerPanelDisplay => 'Timer display';

  @override
  String get timerPanelFullscreenHint =>
      'Tap to open fullscreen. Double-tap for immersive fullscreen.';

  @override
  String get timerPanelRemaining => 'Remaining';

  @override
  String get timerPanelRemoveMinute => 'Remove one minute';

  @override
  String get timerPanelAddFiveMinutes => 'Add five minutes';

  @override
  String timerPanelStep(int step) {
    return 'Step $step';
  }

  @override
  String get timerPanelPause => 'Pause';

  @override
  String get timerPanelStart => 'Start';

  @override
  String get timerPanelReset => 'Reset';

  @override
  String get timerPanelSpeech => 'Speech';

  @override
  String get timerPanelNoise => 'Noise';

  @override
  String get timerPanelChain => 'Chain';

  @override
  String get timerPanelClock => 'Clock';

  @override
  String get timerPanelTagging => 'Tagging';

  @override
  String get timerPanelStudy => 'Study';

  @override
  String get timerPanelNonStudy => 'Non-study';

  @override
  String get timerPanelTimeUtilization => 'Time Utilization';

  @override
  String get timerPanelShowMilliseconds => 'Show milliseconds';

  @override
  String get timerPanelAnnounceEvery => 'Announce every';

  @override
  String timerPanelMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get timerPanelOn => 'On';

  @override
  String get timerPanelOff => 'Off';

  @override
  String get timerPanelChainMode => 'Chain mode';

  @override
  String get timerPanelPresetSequence => 'Preset sequence';

  @override
  String get timerPanelAnnouncementInterval => 'Announcement interval';

  @override
  String timerPanelAnnounceEveryMinutes(int minutes) {
    return 'Announce every $minutes min';
  }

  @override
  String get timerPanelChainPreset => 'Chain preset';

  @override
  String get timerPanelCustomTimer => 'Custom timer';

  @override
  String get timerPanelMinutesLabel => 'Minutes';

  @override
  String get timerPanelMinutesHint => 'Enter minutes (1-720)';

  @override
  String get timerPanelMinuteAbbreviation => 'min';

  @override
  String get timerPanelCancel => 'Cancel';

  @override
  String get timerPanelWholeNumberError =>
      'Enter a whole number from 1 to 720.';

  @override
  String get timerPanelSet => 'Set';

  @override
  String timerPanelSequenceMinutes(String values) {
    return '$values min';
  }

  @override
  String get timerPanelPomodoroPreset => 'Pomodoro 25-5x4';

  @override
  String get timerPanelSprintPreset => 'Sprint 50-10x2';

  @override
  String get timerPanelQuickPreset => 'Quick 15-3x3';

  @override
  String get stopwatchPanelElapsed => 'ELAPSED';

  @override
  String stopwatchPanelLaps(int count) {
    return '$count laps';
  }

  @override
  String get stopwatchPanelPause => 'Pause';

  @override
  String get stopwatchPanelStart => 'Start';

  @override
  String get stopwatchPanelLap => 'Lap';

  @override
  String get stopwatchPanelReset => 'Reset';

  @override
  String get stopwatchPanelLapTimes => 'Lap times';

  @override
  String get stopwatchPanelSpeech => 'Speech';

  @override
  String get stopwatchPanelShowMilliseconds => 'Show milliseconds';

  @override
  String get stopwatchPanelOn => 'On';

  @override
  String get stopwatchPanelOff => 'Off';

  @override
  String get stopwatchPanelSpeakDelay => 'Speak delay';

  @override
  String get stopwatchPanelSpeakElapsedEvery => 'Speak elapsed every';

  @override
  String stopwatchPanelSeconds(int seconds) {
    return '$seconds sec';
  }

  @override
  String stopwatchPanelMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get driveModeClock => 'Clock';

  @override
  String get driveModeTimer => 'Timer';

  @override
  String get driveModeStopwatch => 'Stopwatch';

  @override
  String get driveModeCurrentTime => 'Current time';

  @override
  String get driveModeRunning => 'Running';

  @override
  String get driveModePaused => 'Paused';

  @override
  String get driveModeReady => 'Ready';

  @override
  String driveModeDisplaySemantics(String label, String value) {
    return '$label: $value';
  }

  @override
  String get driveModePause => 'Pause';

  @override
  String get driveModeResume => 'Resume';

  @override
  String get driveModeStart => 'Start';

  @override
  String driveModeMinutePreset(int minutes) {
    return '$minutes min';
  }

  @override
  String get driveModeAudioOn => 'Audio on';

  @override
  String get driveModeAudioOff => 'Audio off';

  @override
  String get driveModeSpeakNow => 'Speak now';

  @override
  String get driveModeTitle => 'Drive Mode';

  @override
  String get driveModeClose => 'Close';

  @override
  String get focusViewStop => 'Stop';

  @override
  String get focusViewStart => 'Start';

  @override
  String get focusViewReset => 'Reset';

  @override
  String get focusViewCloseFocusMode => 'Close focus mode';

  @override
  String get focusViewAwake => 'Awake';

  @override
  String get focusViewClock => 'Clock';

  @override
  String get focusViewLightTheme => 'Light theme';

  @override
  String get focusViewDarkTheme => 'Dark theme';

  @override
  String get focusViewDisableDim => 'Disable dim';

  @override
  String get focusViewDimBrightness => 'Dim brightness';

  @override
  String get focusViewUnlockRotation => 'Unlock Rotation';

  @override
  String get focusViewRotateHorizontal => 'Rotate Horizontal';

  @override
  String get focusViewFullscreenModeEntered => 'Fullscreen mode entered';

  @override
  String get focusViewDoubleTapToExit => 'Double tap anywhere to exit';

  @override
  String get settingsPanelDesktopAutostartChecking =>
      'Checking autostart status…';

  @override
  String get settingsPanelAutostartNotConfigured =>
      'Autostart is not configured.';

  @override
  String get settingsPanelAutostartInstalledDisabled =>
      'Autostart is installed but disabled.';

  @override
  String get settingsPanelAutostartFailed => 'Autostart service failed.';

  @override
  String get settingsPanelAutostartRunning => 'Autostart is active.';

  @override
  String get settingsPanelAutostartNextLogin =>
      'Autostart will run at next login.';

  @override
  String get settingsPanelDesktopAutostartTitle =>
      'Start automatically at login';

  @override
  String get settingsPanelDesktopAutostartDescription =>
      'Manage the user-level systemd service that starts Solas Flow when you sign in.';

  @override
  String get settingsPanelEnable => 'Enable';

  @override
  String get settingsPanelRemove => 'Remove';

  @override
  String get settingsPanelRefreshStatus => 'Refresh status';

  @override
  String get settingsPanelChooseModelFolder => 'Choose model folder';

  @override
  String settingsPanelOfflineModelFailed(String action, String error) {
    return 'Could not $action offline model: $error';
  }

  @override
  String get settingsPanelClear => 'clear';

  @override
  String get settingsPanelImport => 'import';

  @override
  String get settingsPanelLocalOfflineModel => 'Local offline speech model';

  @override
  String get settingsPanelOfflineModelDescription =>
      'Import a compatible Sherpa-ONNX model directory for fully offline speech. The selected model is copied into app storage.';

  @override
  String get settingsPanelModelLanguage => 'Model language';

  @override
  String get settingsPanelEnglish => 'English';

  @override
  String get settingsPanelMalayalam => 'Malayalam';

  @override
  String get settingsPanelImportFolder => 'Import folder';

  @override
  String get settingsPanelUseBuiltinVoice => 'Use built-in voice';

  @override
  String settingsPanelTestLanguage(String language) {
    return 'Test $language';
  }

  @override
  String get settingsPanelModelLanguageDescription =>
      'Choose the language for the imported offline model.';

  @override
  String get settingsPanelVeryLow => 'Very low';

  @override
  String get settingsPanelLow => 'Low';

  @override
  String get settingsPanelMedium => 'Medium';

  @override
  String get settingsPanelHigh => 'High';

  @override
  String get settingsPanelVeryHigh => 'Very high';

  @override
  String get settingsPanelKokoroEnglishVoice => 'Kokoro English voice';

  @override
  String get settingsPanelRetry => 'Retry';

  @override
  String get settingsPanelDownload => 'Download';

  @override
  String get settingsPanelCancel => 'Cancel';

  @override
  String get settingsPanelSoundRain => 'Rain';

  @override
  String get settingsPanelSoundWaterfall => 'Waterfall';

  @override
  String get settingsPanelSoundFire => 'Fire';

  @override
  String get settingsPanelSoundStream => 'Stream';

  @override
  String get settingsPanelNone => 'None';

  @override
  String get settingsPanelAoedeVoice => 'Aoede';

  @override
  String get settingsPanelKoreVoice => 'Kore';

  @override
  String get settingsPanelPuckVoice => 'Puck';

  @override
  String get settingsPanelCharonVoice => 'Charon';

  @override
  String get settingsPanelPiperLessacVoice => 'Lessac';

  @override
  String get settingsPanelPiperRyanVoice => 'Ryan';

  @override
  String get settingsPanelKokoroBellaVoice => 'Bella';

  @override
  String get settingsPanelKokoroAdamVoice => 'Adam';

  @override
  String get settingsPanelKokoroEmmaVoice => 'Emma';

  @override
  String get settingsPanelKokoroGeorgeVoice => 'George';

  @override
  String get settingsPanelKokoroMapleVoice => 'Maple';

  @override
  String get settingsPanelKokoroSolVoice => 'Sol';

  @override
  String get settingsPanelKokoroValeVoice => 'Vale';

  @override
  String get settingsPanelMalayalamFemale => 'Malayalam female voice';

  @override
  String get settingsPanelMalayalamMale => 'Malayalam male voice';

  @override
  String get settingsPanelMalayalamNative => 'Malayalam voice';

  @override
  String get settingsPanelFemale => 'Female voice';

  @override
  String get settingsPanelMale => 'Male voice';

  @override
  String get settingsPanelIndianEnglish => 'Indian English';

  @override
  String get settingsPanelUsEnglish => 'US English';

  @override
  String get settingsPanelUkEnglish => 'UK English';

  @override
  String get settingsPanelSystemTtsOnly => 'System TTS only';

  @override
  String get settingsPanelSherpaOnly => 'Sherpa-ONNX only';

  @override
  String get settingsPanelAutoBestAvailable => 'Automatic — best available';

  @override
  String get settingsPanelGoogleSpeechServices => 'Google Speech Services';

  @override
  String get settingsPanelSamsungTextToSpeech => 'Samsung Text-to-Speech';

  @override
  String get settingsPanelAuto => 'Automatic';

  @override
  String get settingsPanelRotateMalayalamVoices => 'Rotate Malayalam voices';

  @override
  String get settingsPanelRotateVoicesDefault => 'Rotate voices';

  @override
  String get settingsPanelAutoSystemDefault => 'Automatic (system default)';

  @override
  String get settingsPanelUseDeviceDefaultEngine =>
      'Use the device\'s default speech engine';

  @override
  String get settingsPanelUseDeviceSpeechEngine =>
      'Use only the device speech engine';

  @override
  String get settingsPanelFallbackVoicePlatforms =>
      'Use the built-in offline voice when available';

  @override
  String get settingsPanelAutoVoiceDescription =>
      'Choose the best available voice automatically';

  @override
  String get settingsPanelManualMode => 'Manual';

  @override
  String get settingsPanelSelectedQuietHours => 'Use the selected quiet hours';

  @override
  String get settingsPanelAutomaticMode => 'Automatic';

  @override
  String get settingsPanelMuteAfterNightIdle =>
      'Mute after the device has been idle at night';

  @override
  String get settingsPanelStandardMalayalam => 'Standard Malayalam';

  @override
  String get settingsPanelAlternatesVoices =>
      'Alternates between available voices';

  @override
  String get settingsPanelUnknownVoice => 'Unknown voice';

  @override
  String get settingsPanelDarkThemeDescription => 'Use a dark appearance';

  @override
  String get settingsPanelMasterAudio => 'Master audio';

  @override
  String get settingsPanelAllAudioOn => 'Speech and ambient audio are enabled';

  @override
  String get settingsPanelAllAudioOff =>
      'Speech and ambient audio are disabled';

  @override
  String get settingsPanelGoalReminders => 'Goal reminders';

  @override
  String get settingsPanelAddGoalToEnableReminders =>
      'Add a goal to enable reminders';

  @override
  String settingsPanelSpeakSavedGoalEvery(int minutes) {
    return 'Speak a saved goal every $minutes minutes';
  }

  @override
  String get settingsPanelGoalReminderInterval => 'Goal reminder interval';

  @override
  String get settingsPanelAddGoal => 'Add goal';

  @override
  String get settingsPanelAdd => 'Add';

  @override
  String get settingsPanelNoGoalsSaved => 'No goals saved';

  @override
  String get settingsPanelRemoveGoal => 'Remove goal';

  @override
  String get settingsPanelNoiseVolume => 'Noise volume';

  @override
  String get settingsPanelSpeechVolume => 'Speech volume';

  @override
  String get settingsPanelBoostTtsVolume => 'Boost speech volume';

  @override
  String get settingsPanelMaximumSpeechVolumeDescription =>
      'Raise speech output to the maximum available volume';

  @override
  String get settingsPanelSpeechEngine => 'Speech engine';

  @override
  String get settingsPanelTestVoice => 'Test voice';

  @override
  String get settingsPanelPlaySample => 'Play sample';

  @override
  String get settingsPanelLanguageList => 'Voice language list';

  @override
  String get settingsPanelPreferredVoice => 'Preferred voice';

  @override
  String get settingsPanelVoice => 'Voice';

  @override
  String get settingsPanelFontSize => 'Font size';

  @override
  String get settingsPanelStartLandscape => 'Start fullscreen in landscape';

  @override
  String get settingsPanelShowClockFullscreen => 'Show clock in fullscreen';

  @override
  String get settingsPanelShowClockFullscreenDescription =>
      'Display the current time above the timer';

  @override
  String get settingsPanelFullscreenClockSize => 'Fullscreen clock size';

  @override
  String get settingsPanelEnableSleepMode => 'Enable sleep mode';

  @override
  String get settingsPanelQuietHoursSpeech =>
      'Silence speech during quiet hours';

  @override
  String get settingsPanelMode => 'Mode';

  @override
  String get settingsPanelSleepMode => 'Sleep mode';

  @override
  String get settingsPanelBackupAppSettings => 'Back up app settings';

  @override
  String get settingsPanelBackupDescription => 'Export your settings to a file';

  @override
  String get settingsPanelRestoreAppSettings => 'Restore app settings';

  @override
  String get settingsPanelRestoreDescription =>
      'Import settings from a backup file';

  @override
  String get settingsPanelChooseBackupFolder => 'Choose backup folder';

  @override
  String get helpPanelSleepModeOff => 'Sleep mode is off';

  @override
  String get helpPanelSleepModeManual => 'Manual quiet hours';

  @override
  String get helpPanelSleepModeAutomatic => 'Automatic night mode';

  @override
  String helpPanelCurrentRange(String range) {
    return 'Quiet hours: $range';
  }

  @override
  String get helpPanelQuickStart => 'Quick start';

  @override
  String get helpPanelConfigureTimerTitle => 'Configure the timer';

  @override
  String get helpPanelConfigureTimerDescription =>
      'Choose a preset or set a custom duration on the Timer tab.';

  @override
  String get helpPanelSetSleepTitle => 'Set sleep hours';

  @override
  String get helpPanelSetSleepDescription =>
      'Enable sleep mode and choose quiet hours to silence speech.';

  @override
  String get helpPanelWidgetControlsTitle => 'Use the home screen widget';

  @override
  String get helpPanelWidgetControlsDescription =>
      'Start, pause, or reset the timer without opening the app.';

  @override
  String get helpPanelFaq => 'Help';

  @override
  String get helpPanelSpeakingClockTitle => 'Speaking clock';

  @override
  String get helpPanelSpeakingClockAnnouncements =>
      'Choose announcement intervals and enable speech in Settings.';

  @override
  String get helpPanelSpeakingClockQuotes =>
      'Enable quotes and choose a category and delay.';

  @override
  String get helpPanelTimerSetupTitle => 'Timer setup';

  @override
  String get helpPanelTimerSetupPreset =>
      'Select a preset or set a custom timer duration.';

  @override
  String get helpPanelTimerSetupSpeech =>
      'Enable speech announcements and adjust their interval.';

  @override
  String get helpPanelTimerSetupChain =>
      'Use chain mode to run a sequence of study and break timers.';

  @override
  String get helpPanelSleepModeTitle => 'Sleep mode';

  @override
  String get helpPanelSleepModeRange =>
      'Set the quiet-hours start and end times in Settings.';

  @override
  String get helpPanelSleepModeManualDescription =>
      'Manual mode uses the times you selected.';

  @override
  String get helpPanelSleepModeAutomaticDescription =>
      'Automatic mode detects nighttime device inactivity.';

  @override
  String get helpPanelSleepModeResumeDescription =>
      'Speech resumes when quiet hours end.';

  @override
  String get helpPanelHomeWidgetTitle => 'Home screen widget';

  @override
  String get helpPanelHomeWidgetSpeech =>
      'The widget can speak timer status when speech is enabled.';

  @override
  String get helpPanelHomeWidgetTimer =>
      'Use the widget controls to start, pause, or reset the timer.';

  @override
  String get helpPanelHomeWidgetQuickSessions =>
      'Quick-session buttons start common timer durations.';

  @override
  String get helpPanelHomeWidgetStatus =>
      'Widget status reflects the current timer session.';

  @override
  String get helpPanelTipsTitle => 'Tips';

  @override
  String get helpPanelTipsSync => 'Settings are stored on this device.';

  @override
  String get helpPanelTipsPermissions =>
      'Allow notifications and background activity for reliable timer alerts.';

  @override
  String get helpPanelTipsBackground =>
      'Keep the app allowed to run in the background for uninterrupted timing.';

  @override
  String get settingsPanelGoalField => 'Goal';

  @override
  String get settingsPanelDownloadNotDownloaded =>
      'Not downloaded · about 98.5 MiB. English speech continues with Piper until then.';

  @override
  String settingsPanelDownloadingKokoro(String amount) {
    return 'Downloading Kokoro English · $amount';
  }

  @override
  String settingsPanelDownloadingKokoroPercent(int percent, String amount) {
    return 'Downloading Kokoro English · $percent% · $amount';
  }

  @override
  String get settingsPanelDownloadVerifying =>
      'Download complete · verifying SHA-256';

  @override
  String get settingsPanelDownloadInstalling =>
      'Installing the offline English voice';

  @override
  String get settingsPanelDownloadReady =>
      'Ready · Kokoro v1.1 English works offline';

  @override
  String settingsPanelDownloadFailed(String error) {
    return 'Download failed · $error';
  }

  @override
  String get settingsPanelDownloadFailedFallback =>
      'Check your connection and retry.';

  @override
  String get settingsPanelDownloadCancelled =>
      'Download cancelled · the bundled Piper voice remains available.';

  @override
  String mainDesktopTimerFinishedBody(int minutes) {
    return '$minutes minute timer completed.';
  }

  @override
  String get settingsPanelBuiltBy => 'Built by Amarjith TK';

  @override
  String get settingsPanelCompany => 'Atherpulse Technologies';

  @override
  String get mainPersistenceWriteFailed =>
      'Could not save app data. Please try again.';
}
