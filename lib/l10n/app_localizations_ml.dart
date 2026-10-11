// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'സോളസ്ഫ്ലോ';

  @override
  String get helpTitle => 'സഹായം / വിവരങ്ങൾ';

  @override
  String get timerTab => 'ടൈമർ';

  @override
  String get clockTab => 'ക്ലോക്ക്';

  @override
  String get settingsTab => 'ക്രമീകരണങ്ങൾ';

  @override
  String get presetTab => 'പ്രിസെറ്റ്';

  @override
  String get startButton => 'തുടങ്ങുക';

  @override
  String get pauseButton => 'താൽക്കാലികമായി നിർത്തുക';

  @override
  String get resumeButton => 'തുടരുക';

  @override
  String get stopButton => 'അവസാനിപ്പിക്കുക';

  @override
  String get resetButton => 'പുനരാരംഭിക്കുക';

  @override
  String get skipButton => 'ഒഴിവാക്കുക';

  @override
  String get addTimeButton => 'സമയം ചേർക്കുക';

  @override
  String get chainModeLabel => 'ചെയിൻ മോഡ്';

  @override
  String get chainModeDescription =>
      'ടൈമർ പ്രിസെറ്റുകൾ തുടർച്ചയായി പ്രവർത്തിപ്പിക്കുക';

  @override
  String get timerNotificationTitle => 'ടൈമർ പ്രവർത്തിക്കുന്നു';

  @override
  String get clockNotificationTitle => 'സമയ പരിശോധന';

  @override
  String get focusMode => 'ഏകാഗ്രതാ മോഡ്';

  @override
  String get fullscreenMode => 'പൂർണ്ണ സ്ക്രീൻ';

  @override
  String get soundLabel => 'പശ്ചാത്തല ശബ്ദം';

  @override
  String get volumeLabel => 'ശബ്ദ തീവ്രത';

  @override
  String get voiceLabel => 'വോയിസ്';

  @override
  String get darkThemeLabel => 'ഡാർക്ക് തീം';

  @override
  String get motivationCategoryLabel => 'പ്രചോദന വിഭാഗം';

  @override
  String get motivationDelayLabel => 'ഉദ്ധരണി ഇടവേള (സെക്കൻഡിൽ)';

  @override
  String get clockIntervalLabel => 'ക്ലോക്ക് ഇടവേള (മിനിറ്റിൽ)';

  @override
  String get timerAnnouncementLabel => 'സമയം അറിയിക്കുക (ശേഷിക്കുന്ന മിനിറ്റ്)';

  @override
  String get nightMuteMode => 'രാത്രിയിലെ നിശ്ശബ്ദ മോഡ്';

  @override
  String get sleepStartLabel => 'ഉറങ്ങാൻ തുടങ്ങുന്ന സമയം';

  @override
  String get sleepEndLabel => 'ഉറക്കമുണരുന്ന സമയം';

  @override
  String get today => 'ഇന്ന്';

  @override
  String get yesterday => 'ഇന്നലെ';

  @override
  String get quickActionStart25m => '25 മിനിറ്റ് ആരംഭിക്കുക';

  @override
  String get quickActionResumeLast => 'അവസാനത്തെ ടൈമർ തുടരുക';

  @override
  String get quickActionToggleSpeech => 'സംസാരം മാറ്റുക';

  @override
  String get timerForegroundChannelName => 'സോളസ്ഫ്ലോ ടൈമർ';

  @override
  String get timerForegroundChannelDescription =>
      'നിലനിൽക്കുന്ന ടൈമർ, സ്റ്റോപ്പ്‌വാച്ച് സേവനം';

  @override
  String get timerFinishedNotificationTitle => 'ടൈമർ പൂർത്തിയായി';

  @override
  String get stopwatchNotificationTitle =>
      'സ്റ്റോപ്പ്‌വാച്ച് പ്രവർത്തിക്കുന്നു';

  @override
  String get audioOnLabel => 'ഓഡിയോ ഓൺ';

  @override
  String get audioOffLabel => 'ഓഡിയോ ഓഫ്';

  @override
  String get timerFinishedNotificationText =>
      'ടൈമർ പൂർത്തിയായി! അടുത്ത ടൈമർ സജ്ജമാക്കാൻ ടാപ്പ് ചെയ്യുക.';

  @override
  String notificationTimeRemaining(String value) {
    return 'ശേഷിക്കുന്ന സമയം: $value';
  }

  @override
  String notificationElapsed(String value) {
    return 'കഴിഞ്ഞ സമയം: $value';
  }

  @override
  String get repeatButton => 'ആവർത്തിക്കുക';

  @override
  String get dismissButton => 'അടയ്ക്കുക';

  @override
  String get openButton => 'തുറക്കുക';

  @override
  String get exitButton => 'പുറത്തുകടക്കുക';

  @override
  String get stopwatchTab => 'സ്റ്റോപ്പ്‌വാച്ച്';

  @override
  String mainSpeechEngineChangeFailed(String error) {
    return 'സംസാര എഞ്ചിൻ മാറ്റാനായില്ല: $error';
  }

  @override
  String mainSettingsOpenFailed(String error) {
    return 'ക്രമീകരണങ്ങൾ തുറക്കാനായില്ല: $error';
  }

  @override
  String get mainBackupSavedTitle => 'ബാക്കപ്പ് സംരക്ഷിച്ചു';

  @override
  String get mainSettingsExported =>
      'ക്രമീകരണങ്ങൾ വിജയകരമായി എക്സ്പോർട്ട് ചെയ്തു.';

  @override
  String get mainJsonCopied => 'JSON ക്ലിപ്പ്ബോർഡിലേക്ക് പകർത്തി';

  @override
  String get mainCopyJson => 'JSON പകർത്തുക';

  @override
  String get mainDone => 'പൂർത്തിയായി';

  @override
  String get mainBackupFailedTitle => 'ബാക്കപ്പ് പരാജയപ്പെട്ടു';

  @override
  String mainBackupFileFailed(String error) {
    return 'ഫയൽ സംരക്ഷിക്കാനായില്ല: $error. പകരം ക്രമീകരണ JSON പകർത്തണോ?';
  }

  @override
  String get mainCancel => 'റദ്ദാക്കുക';

  @override
  String mainBackupFailed(String error) {
    return 'ബാക്കപ്പ് പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get mainRestoreSettingsTitle => 'ക്രമീകരണങ്ങൾ പുനഃസ്ഥാപിക്കുക';

  @override
  String get mainRestoreSettingsWarning =>
      'ഈ ബാക്കപ്പിലുള്ള ആപ്പ് മുൻഗണനകൾ നിലവിലുള്ളവയ്ക്ക് പകരമാകും. ഡെസ്‌ക്‌ടോപ്പിലെ പ്രാദേശിക ഓഫ്‌ലൈൻ മോഡൽ തിരഞ്ഞെടുപ്പുകൾ ഉൾപ്പെടില്ല; അവ മാറ്റമില്ലാതെ തുടരും. പുനഃസ്ഥാപിച്ച മുൻഗണനകൾ ഉടൻ പ്രാബല്യത്തിൽ വരും. തുടരട്ടേ?';

  @override
  String get mainRestoreButton => 'പുനഃസ്ഥാപിക്കുക';

  @override
  String get mainSettingsRestored => 'ക്രമീകരണങ്ങൾ വിജയകരമായി പുനഃസ്ഥാപിച്ചു!';

  @override
  String mainRestoreFailed(String error) {
    return 'പുനഃസ്ഥാപിക്കൽ പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get mainDesktopAlwaysOnTopNote =>
      'എല്ലായ്പ്പോഴും മുകളിൽ എന്നത് വിൻഡോ മാനേജറിനുള്ള ഒരു സൂചന മാത്രമാണ്. ചില Wayland ഡെസ്‌ക്‌ടോപ്പുകൾ ഇത് അവഗണിക്കും; ആവശ്യമെങ്കിൽ കമ്പോസിറ്ററിലെ വിൻഡോ നിയമങ്ങൾ ഉപയോഗിക്കുക.';

  @override
  String mainDesktopActionFailed(String error) {
    return 'ഡെസ്‌ക്‌ടോപ്പ് പ്രവർത്തനം പരാജയപ്പെട്ടു: $error';
  }

  @override
  String mainStartupIncomplete(String error) {
    return 'ആരംഭിക്കൽ പൂർത്തിയായില്ല: $error';
  }

  @override
  String get mainTimerDurationRangeError => '1 മുതൽ 720 വരെയുള്ള മൂല്യം നൽകുക';

  @override
  String get mainTimerFinishedTitle => 'ടൈമർ പൂർത്തിയായി';

  @override
  String get mainRepeatSameTimer => 'അതേ ടൈമർ വീണ്ടും ആവർത്തിക്കുക';

  @override
  String get mainStartPresetTimer => 'പുതിയ മുൻസജ്ജ ടൈമർ ആരംഭിക്കുക';

  @override
  String mainMinuteShort(int minutes) {
    return '$minutes മിനിറ്റ്';
  }

  @override
  String get mainCustomDurationMinutes => 'ഇഷ്ടാനുസൃത ദൈർഘ്യം (മിനിറ്റുകൾ)';

  @override
  String get mainCloseTimer => 'ടൈമർ അടയ്ക്കുക';

  @override
  String get mainStartCustomTimer => 'ഇഷ്ടാനുസൃതമായി ആരംഭിക്കുക';

  @override
  String get mainTurnAudioOn => 'ഓഡിയോ ഓൺ ചെയ്യുക';

  @override
  String get mainTurnAudioOff => 'ഓഡിയോ ഓഫ് ചെയ്യുക';

  @override
  String get mainDesktopControls => 'ഡെസ്‌ക്‌ടോപ്പ് നിയന്ത്രണങ്ങൾ';

  @override
  String get mainDriveModeCompact => 'ഡ്രൈവ് മോഡ് — ഒതുക്കമുള്ളത്';

  @override
  String get mainDriveModeFullscreen => 'ഡ്രൈവ് മോഡ് — പൂർണ്ണസ്‌ക്രീൻ';

  @override
  String get mainKeepRunningWhenClosed => 'അടച്ചാലും പ്രവർത്തിപ്പിക്കുക';

  @override
  String get mainAlwaysOnTopDesktopHint =>
      'എല്ലായ്പ്പോഴും മുകളിൽ (ഡെസ്‌ക്‌ടോപ്പ് സൂചന)';

  @override
  String get mainHideToBackground => 'പശ്ചാത്തലത്തിലേക്ക് മറയ്ക്കുക';

  @override
  String get dashboardTimeUtilization => 'സമയ വിനിയോഗം';

  @override
  String get dashboardLoadError => 'സെഷൻ ചരിത്രം ലോഡ് ചെയ്യാനായില്ല.';

  @override
  String get dashboardNoSessions =>
      'ഇതുവരെ സെഷനുകളൊന്നും രേഖപ്പെടുത്തിയിട്ടില്ല.\nഡാറ്റ കാണാൻ ടാഗിംഗ് പ്രവർത്തനക്ഷമമാക്കി ഒരു ടൈമർ പൂർത്തിയാക്കുക.';

  @override
  String get daySummaryStudy => 'പഠനം';

  @override
  String get daySummaryNonStudy => 'പഠനേതരം';

  @override
  String get presetGridQuickPresets => 'വേഗത്തിലുള്ള മുൻസജ്ജീകരണങ്ങൾ';

  @override
  String get kokoroDownloadTitle => 'Kokoro ഇംഗ്ലീഷ് ശബ്ദം ഡൗൺലോഡ് ചെയ്യണോ?';

  @override
  String get kokoroDownloadDescription =>
      'കൂടുതൽ സ്വാഭാവികമായ ഇംഗ്ലീഷ് അറിയിപ്പുകൾക്കായി Solas Flow-ന് 140 MiB ഇംഗ്ലീഷ് സംഭാഷണ മോഡൽ ഡൗൺലോഡ് ചെയ്യാം. ഡൗൺലോഡ് പരിശോധിച്ച ശേഷം ഓഫ്‌ലൈനായി ലഭ്യമാകും. ഒഴിവാക്കിയാലും ഉൾപ്പെടുത്തിയിട്ടുള്ള ഇംഗ്ലീഷ്, മലയാളം ശബ്ദങ്ങൾ ലഭ്യമായിരിക്കും. പിന്നീട് ക്രമീകരണങ്ങളിൽ നിന്ന് ഡൗൺലോഡ് ചെയ്യാനോ റദ്ദാക്കാനോ വീണ്ടും ശ്രമിക്കാനോ കഴിയും.';

  @override
  String get kokoroKeepPiper => 'Piper തന്നെ നിലനിർത്തുക';

  @override
  String get kokoroAcceptAndDownload => 'അംഗീകരിച്ച് ഡൗൺലോഡ് ചെയ്യുക';

  @override
  String get clockPanelCurrentTime => 'നിലവിലെ സമയം';

  @override
  String get clockPanelSound => 'ശബ്ദം';

  @override
  String get clockPanelNoise => 'ശബ്ദം';

  @override
  String get clockPanelQuotes => 'ഉദ്ധരണികൾ';

  @override
  String get clockPanelBackground => 'പശ്ചാത്തലം';

  @override
  String get clockPanelAnnounceInterval => 'അറിയിപ്പ് ഇടവേള';

  @override
  String clockPanelMinutes(int count) {
    return '$count മിനിറ്റ്';
  }

  @override
  String clockPanelEveryMinutes(int count) {
    return 'ഓരോ $count മിനിറ്റിലും';
  }

  @override
  String get clockPanelRepeatCount => 'ആവർത്തനങ്ങളുടെ എണ്ണം';

  @override
  String clockPanelTimes(int count) {
    return '$count തവണ';
  }

  @override
  String get clockPanelQuoteCategory => 'ഉദ്ധരണി വിഭാഗം';

  @override
  String get clockPanelQuoteDelay => 'ഉദ്ധരണി വൈകൽ';

  @override
  String clockPanelSecondsDelay(int seconds) {
    return '$seconds സെക്കൻഡ് വൈകൽ';
  }

  @override
  String get clockPanelShowSeconds => 'സെക്കൻഡുകൾ കാണിക്കുക';

  @override
  String get clockPanelShowMilliseconds => 'മില്ലിസെക്കൻഡുകൾ കാണിക്കുക';

  @override
  String get clockPanelOn => 'ഓൺ';

  @override
  String get clockPanelOff => 'ഓഫ്';

  @override
  String get clockPanelCategoryGeneral => 'പൊതുവായത്';

  @override
  String get clockPanelCategoryGeneralMalayalam => 'പൊതുവായ മലയാളം';

  @override
  String get clockPanelCategoryFocus => 'ശ്രദ്ധ';

  @override
  String get clockPanelCategoryDiscipline => 'അച്ചടക്കം';

  @override
  String get clockPanelCategoryCalm => 'ശാന്തത';

  @override
  String get clockPanelCategoryPositivity => 'അനുകൂല ചിന്ത';

  @override
  String get clockPanelCategoryHistoricFigures => 'ചരിത്രപ്രസിദ്ധർ';

  @override
  String timerPanelEndsAt(String time) {
    return 'അവസാനിക്കുന്നത് $time ന്';
  }

  @override
  String get timerPanelDisplay => 'ടൈമർ ഡിസ്പ്ലേ';

  @override
  String get timerPanelFullscreenHint =>
      'പൂർണ്ണ സ്‌ക്രീൻ തുറക്കാൻ ടാപ്പ് ചെയ്യുക. ഇമേഴ്‌സീവ് പൂർണ്ണ സ്‌ക്രീനിനായി രണ്ടുതവണ ടാപ്പ് ചെയ്യുക.';

  @override
  String get timerPanelRemaining => 'ശേഷിക്കുന്നത്';

  @override
  String get timerPanelRemoveMinute => 'ഒരു മിനിറ്റ് കുറയ്ക്കുക';

  @override
  String get timerPanelAddFiveMinutes => 'അഞ്ച് മിനിറ്റ് ചേർക്കുക';

  @override
  String timerPanelStep(int step) {
    return 'ഘട്ടം $step';
  }

  @override
  String get timerPanelPause => 'താൽക്കാലികമായി നിർത്തുക';

  @override
  String get timerPanelStart => 'ആരംഭിക്കുക';

  @override
  String get timerPanelReset => 'പുനഃസജ്ജമാക്കുക';

  @override
  String get timerPanelSpeech => 'സംസാരം';

  @override
  String get timerPanelNoise => 'ശബ്ദം';

  @override
  String get timerPanelChain => 'ശൃംഖല';

  @override
  String get timerPanelClock => 'ഘടികാരം';

  @override
  String get timerPanelTagging => 'ടാഗിംഗ്';

  @override
  String get timerPanelStudy => 'പഠനം';

  @override
  String get timerPanelNonStudy => 'പഠനേതരം';

  @override
  String get timerPanelTimeUtilization => 'സമയ വിനിയോഗം';

  @override
  String get timerPanelShowMilliseconds => 'മില്ലിസെക്കൻഡുകൾ കാണിക്കുക';

  @override
  String get timerPanelAnnounceEvery => 'അറിയിപ്പ് ഇടവേള';

  @override
  String timerPanelMinutes(int minutes) {
    return '$minutes മിനിറ്റ്';
  }

  @override
  String get timerPanelOn => 'ഓൺ';

  @override
  String get timerPanelOff => 'ഓഫ്';

  @override
  String get timerPanelChainMode => 'ശൃംഖല മോഡ്';

  @override
  String get timerPanelPresetSequence => 'മുൻകൂട്ടി സജ്ജമാക്കിയ ക്രമം';

  @override
  String get timerPanelAnnouncementInterval => 'അറിയിപ്പ് ഇടവേള';

  @override
  String timerPanelAnnounceEveryMinutes(int minutes) {
    return 'ഓരോ $minutes മിനിറ്റിലും അറിയിക്കുക';
  }

  @override
  String get timerPanelChainPreset => 'ശൃംഖല മുൻസജ്ജീകരണം';

  @override
  String get timerPanelCustomTimer => 'ഇഷ്ടാനുസൃത ടൈമർ';

  @override
  String get timerPanelMinutesLabel => 'മിനിറ്റുകൾ';

  @override
  String get timerPanelMinutesHint => 'മിനിറ്റുകൾ നൽകുക (1-720)';

  @override
  String get timerPanelMinuteAbbreviation => 'മിനിറ്റ്';

  @override
  String get timerPanelCancel => 'റദ്ദാക്കുക';

  @override
  String get timerPanelWholeNumberError =>
      '1 മുതൽ 720 വരെയുള്ള പൂർണ്ണ സംഖ്യ നൽകുക.';

  @override
  String get timerPanelSet => 'സജ്ജമാക്കുക';

  @override
  String timerPanelSequenceMinutes(String values) {
    return '$values മിനിറ്റ്';
  }

  @override
  String get timerPanelPomodoroPreset => 'പൊമൊഡോറോ 25-5x4';

  @override
  String get timerPanelSprintPreset => 'സ്പ്രിന്റ് 50-10x2';

  @override
  String get timerPanelQuickPreset => 'ക്വിക്ക് 15-3x3';

  @override
  String get stopwatchPanelElapsed => 'കഴിഞ്ഞ സമയം';

  @override
  String stopwatchPanelLaps(int count) {
    return '$count ലാപ്പുകൾ';
  }

  @override
  String get stopwatchPanelPause => 'താൽക്കാലികമായി നിർത്തുക';

  @override
  String get stopwatchPanelStart => 'ആരംഭിക്കുക';

  @override
  String get stopwatchPanelLap => 'ലാപ്പ്';

  @override
  String get stopwatchPanelReset => 'പുനഃസജ്ജമാക്കുക';

  @override
  String get stopwatchPanelLapTimes => 'ലാപ്പ് സമയങ്ങൾ';

  @override
  String get stopwatchPanelSpeech => 'സംസാരം';

  @override
  String get stopwatchPanelShowMilliseconds => 'മില്ലിസെക്കൻഡുകൾ കാണിക്കുക';

  @override
  String get stopwatchPanelOn => 'ഓൺ';

  @override
  String get stopwatchPanelOff => 'ഓഫ്';

  @override
  String get stopwatchPanelSpeakDelay => 'സംസാര വൈകൽ';

  @override
  String get stopwatchPanelSpeakElapsedEvery => 'കഴിഞ്ഞ സമയം സംസാരിക്കുക ഓരോ';

  @override
  String stopwatchPanelSeconds(int seconds) {
    return '$seconds സെക്കൻഡ്';
  }

  @override
  String stopwatchPanelMinutes(int minutes) {
    return '$minutes മിനിറ്റ്';
  }

  @override
  String get driveModeClock => 'ഘടികാരം';

  @override
  String get driveModeTimer => 'ടൈമർ';

  @override
  String get driveModeStopwatch => 'സ്റ്റോപ്പ്‌വാച്ച്';

  @override
  String get driveModeCurrentTime => 'നിലവിലെ സമയം';

  @override
  String get driveModeRunning => 'പ്രവർത്തിക്കുന്നു';

  @override
  String get driveModePaused => 'താൽക്കാലികമായി നിർത്തി';

  @override
  String get driveModeReady => 'തയ്യാറാണ്';

  @override
  String driveModeDisplaySemantics(String label, String value) {
    return '$label: $value';
  }

  @override
  String get driveModePause => 'താൽക്കാലികമായി നിർത്തുക';

  @override
  String get driveModeResume => 'പുനരാരംഭിക്കുക';

  @override
  String get driveModeStart => 'ആരംഭിക്കുക';

  @override
  String driveModeMinutePreset(int minutes) {
    return '$minutes മിനിറ്റ്';
  }

  @override
  String get driveModeAudioOn => 'ഓഡിയോ ഓൺ';

  @override
  String get driveModeAudioOff => 'ഓഡിയോ ഓഫ്';

  @override
  String get driveModeSpeakNow => 'ഇപ്പോൾ പറയുക';

  @override
  String get driveModeTitle => 'ഡ്രൈവ് മോഡ്';

  @override
  String get driveModeClose => 'അടയ്ക്കുക';

  @override
  String get focusViewStop => 'നിർത്തുക';

  @override
  String get focusViewStart => 'ആരംഭിക്കുക';

  @override
  String get focusViewReset => 'പുനഃസജ്ജമാക്കുക';

  @override
  String get focusViewCloseFocusMode => 'ഫോക്കസ് മോഡ് അടയ്ക്കുക';

  @override
  String get focusViewAwake => 'ഉണർന്നിരിക്കുക';

  @override
  String get focusViewClock => 'ഘടികാരം';

  @override
  String get focusViewLightTheme => 'ലൈറ്റ് തീം';

  @override
  String get focusViewDarkTheme => 'ഡാർക്ക് തീം';

  @override
  String get focusViewDisableDim => 'മങ്ങൽ പ്രവർത്തനരഹിതമാക്കുക';

  @override
  String get focusViewDimBrightness => 'തെളിച്ചം കുറയ്ക്കുക';

  @override
  String get focusViewUnlockRotation => 'റൊട്ടേഷൻ അൺലോക്ക് ചെയ്യുക';

  @override
  String get focusViewRotateHorizontal => 'തിരശ്ചീനമായി തിരിക്കുക';

  @override
  String get focusViewFullscreenModeEntered =>
      'പൂർണ്ണസ്‌ക്രീൻ മോഡിൽ പ്രവേശിച്ചു';

  @override
  String get focusViewDoubleTapToExit =>
      'പുറത്തുകടക്കാൻ എവിടെയും രണ്ടുതവണ ടാപ്പ് ചെയ്യുക';

  @override
  String get settingsPanelDesktopAutostartChecking =>
      'ഓട്ടോസ്റ്റാർട്ട് നില പരിശോധിക്കുന്നു…';

  @override
  String get settingsPanelAutostartNotConfigured =>
      'ഓട്ടോസ്റ്റാർട്ട് ക്രമീകരിച്ചിട്ടില്ല.';

  @override
  String get settingsPanelAutostartInstalledDisabled =>
      'ഓട്ടോസ്റ്റാർട്ട് ഇൻസ്റ്റാൾ ചെയ്തിട്ടുണ്ടെങ്കിലും പ്രവർത്തനരഹിതമാണ്.';

  @override
  String get settingsPanelAutostartFailed =>
      'ഓട്ടോസ്റ്റാർട്ട് സേവനം പരാജയപ്പെട്ടു.';

  @override
  String get settingsPanelAutostartRunning => 'ഓട്ടോസ്റ്റാർട്ട് സജീവമാണ്.';

  @override
  String get settingsPanelAutostartNextLogin =>
      'അടുത്ത ലോഗിനിൽ ഓട്ടോസ്റ്റാർട്ട് പ്രവർത്തിക്കും.';

  @override
  String get settingsPanelDesktopAutostartTitle => 'ലോഗിനിൽ സ്വയം ആരംഭിക്കുക';

  @override
  String get settingsPanelDesktopAutostartDescription =>
      'സൈൻ ഇൻ ചെയ്യുമ്പോൾ Solas Flow ആരംഭിക്കുന്ന ഉപയോക്തൃ systemd സേവനം നിയന്ത്രിക്കുക.';

  @override
  String get settingsPanelEnable => 'പ്രവർത്തനക്ഷമമാക്കുക';

  @override
  String get settingsPanelRemove => 'നീക്കം ചെയ്യുക';

  @override
  String get settingsPanelRefreshStatus => 'നില പുതുക്കുക';

  @override
  String get settingsPanelChooseModelFolder => 'മോഡൽ ഫോൾഡർ തിരഞ്ഞെടുക്കുക';

  @override
  String settingsPanelOfflineModelFailed(String action, String error) {
    return 'ഓഫ്‌ലൈൻ മോഡൽ $action ചെയ്യാനായില്ല: $error';
  }

  @override
  String get settingsPanelClear => 'മായ്ക്കുക';

  @override
  String get settingsPanelImport => 'ഇറക്കുമതി ചെയ്യുക';

  @override
  String get settingsPanelLocalOfflineModel => 'പ്രാദേശിക ഓഫ്‌ലൈൻ സംഭാഷണ മോഡൽ';

  @override
  String get settingsPanelOfflineModelDescription =>
      'പൂർണ്ണമായും ഓഫ്‌ലൈൻ സംഭാഷണത്തിനായി അനുയോജ്യമായ Sherpa-ONNX മോഡൽ ഡയറക്ടറി ഇറക്കുമതി ചെയ്യുക. തിരഞ്ഞെടുത്ത മോഡൽ ആപ്പ് സ്റ്റോറേജിലേക്ക് പകർത്തും.';

  @override
  String get settingsPanelModelLanguage => 'മോഡൽ ഭാഷ';

  @override
  String get settingsPanelEnglish => 'ഇംഗ്ലീഷ്';

  @override
  String get settingsPanelMalayalam => 'മലയാളം';

  @override
  String get settingsPanelImportFolder => 'ഫോൾഡർ ഇറക്കുമതി ചെയ്യുക';

  @override
  String get settingsPanelUseBuiltinVoice => 'അന്തർനിർമ്മിത ശബ്ദം ഉപയോഗിക്കുക';

  @override
  String settingsPanelTestLanguage(String language) {
    return '$language പരീക്ഷിക്കുക';
  }

  @override
  String get settingsPanelModelLanguageDescription =>
      'ഇറക്കുമതി ചെയ്ത ഓഫ്‌ലൈൻ മോഡലിന്റെ ഭാഷ തിരഞ്ഞെടുക്കുക.';

  @override
  String get settingsPanelVeryLow => 'വളരെ കുറവ്';

  @override
  String get settingsPanelLow => 'കുറവ്';

  @override
  String get settingsPanelMedium => 'ഇടത്തരം';

  @override
  String get settingsPanelHigh => 'കൂടുതൽ';

  @override
  String get settingsPanelVeryHigh => 'വളരെ കൂടുതൽ';

  @override
  String get settingsPanelKokoroEnglishVoice => 'Kokoro ഇംഗ്ലീഷ് ശബ്ദം';

  @override
  String get settingsPanelRetry => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get settingsPanelDownload => 'ഡൗൺലോഡ് ചെയ്യുക';

  @override
  String get settingsPanelCancel => 'റദ്ദാക്കുക';

  @override
  String get settingsPanelSoundRain => 'മഴ';

  @override
  String get settingsPanelSoundWaterfall => 'വെള്ളച്ചാട്ടം';

  @override
  String get settingsPanelSoundFire => 'തീ';

  @override
  String get settingsPanelSoundStream => 'നീരൊഴുക്ക്';

  @override
  String get settingsPanelNone => 'ഒന്നുമില്ല';

  @override
  String get settingsPanelAoedeVoice => 'Aoede';

  @override
  String get settingsPanelKoreVoice => 'Kore';

  @override
  String get settingsPanelPuckVoice => 'Puck';

  @override
  String get settingsPanelCharonVoice => 'Charon';

  @override
  String get settingsPanelPiperMeeraVoice => 'Meera';

  @override
  String get settingsPanelPiperArjunVoice => 'Arjun';

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
  String get settingsPanelMalayalamFemale => 'മലയാളം സ്ത്രീ ശബ്ദം';

  @override
  String get settingsPanelMalayalamMale => 'മലയാളം പുരുഷ ശബ്ദം';

  @override
  String get settingsPanelMalayalamNative => 'മലയാളം ശബ്ദം';

  @override
  String get settingsPanelFemale => 'സ്ത്രീ ശബ്ദം';

  @override
  String get settingsPanelMale => 'പുരുഷ ശബ്ദം';

  @override
  String get settingsPanelIndianEnglish => 'ഇന്ത്യൻ ഇംഗ്ലീഷ്';

  @override
  String get settingsPanelUsEnglish => 'അമേരിക്കൻ ഇംഗ്ലീഷ്';

  @override
  String get settingsPanelUkEnglish => 'ബ്രിട്ടീഷ് ഇംഗ്ലീഷ്';

  @override
  String get settingsPanelSystemTtsOnly => 'സിസ്റ്റം TTS മാത്രം';

  @override
  String get settingsPanelSherpaOnly => 'Sherpa-ONNX മാത്രം';

  @override
  String get settingsPanelAutoBestAvailable =>
      'ഓട്ടോമാറ്റിക് — ലഭ്യമായ മികച്ചത്';

  @override
  String get settingsPanelGoogleSpeechServices => 'Google Speech Services';

  @override
  String get settingsPanelSamsungTextToSpeech => 'Samsung Text-to-Speech';

  @override
  String get settingsPanelAuto => 'ഓട്ടോമാറ്റിക്';

  @override
  String get settingsPanelRotateAllMalayalamVoices =>
      'എല്ലാ മലയാള ശബ്ദങ്ങളും മാറിമാറി ഉപയോഗിക്കുക';

  @override
  String get settingsPanelRotateVoicesDefault =>
      'ശബ്ദങ്ങൾ മാറിമാറി ഉപയോഗിക്കുക';

  @override
  String get settingsPanelAutoSystemDefault =>
      'ഓട്ടോമാറ്റിക് (സിസ്റ്റം ഡിഫോൾട്ട്)';

  @override
  String get settingsPanelUseDeviceDefaultEngine =>
      'ഉപകരണത്തിന്റെ ഡിഫോൾട്ട് സംഭാഷണ എഞ്ചിൻ ഉപയോഗിക്കുക';

  @override
  String get settingsPanelUseDeviceSpeechEngine =>
      'ഉപകരണ സംഭാഷണ എഞ്ചിൻ മാത്രം ഉപയോഗിക്കുക';

  @override
  String get settingsPanelFallbackVoicePlatforms =>
      'ലഭ്യമെങ്കിൽ അന്തർനിർമ്മിത ഓഫ്‌ലൈൻ ശബ്ദം ഉപയോഗിക്കുക';

  @override
  String get settingsPanelAutoVoiceDescription =>
      'ലഭ്യമായ മികച്ച ശബ്ദം സ്വയം തിരഞ്ഞെടുക്കുക';

  @override
  String get settingsPanelManualMode => 'മാനുവൽ';

  @override
  String get settingsPanelSelectedQuietHours =>
      'തിരഞ്ഞെടുത്ത നിശ്ശബ്ദ സമയങ്ങൾ ഉപയോഗിക്കുക';

  @override
  String get settingsPanelAutomaticMode => 'ഓട്ടോമാറ്റിക്';

  @override
  String get settingsPanelMuteAfterNightIdle =>
      'രാത്രിയിൽ ഉപകരണം നിഷ്‌ക്രിയമായ ശേഷം മ്യൂട്ട് ചെയ്യുക';

  @override
  String get settingsPanelStandardMalayalam => 'സാധാരണ മലയാളം';

  @override
  String get settingsPanelAlternatesVoices =>
      'ലഭ്യമായ ശബ്ദങ്ങൾ മാറിമാറി ഉപയോഗിക്കുന്നു';

  @override
  String get settingsPanelUnknownVoice => 'അറിയാത്ത ശബ്ദം';

  @override
  String get settingsPanelDarkThemeDescription => 'ഇരുണ്ട രൂപം ഉപയോഗിക്കുക';

  @override
  String get settingsPanelMasterAudio => 'പ്രധാന ഓഡിയോ';

  @override
  String get settingsPanelAllAudioOn =>
      'സംസാരവും പശ്ചാത്തല ഓഡിയോയും പ്രവർത്തനക്ഷമമാണ്';

  @override
  String get settingsPanelAllAudioOff =>
      'സംസാരവും പശ്ചാത്തല ഓഡിയോയും പ്രവർത്തനരഹിതമാണ്';

  @override
  String get settingsPanelGoalReminders => 'ലക്ഷ്യ ഓർമ്മപ്പെടുത്തലുകൾ';

  @override
  String get settingsPanelAddGoalToEnableReminders =>
      'ഓർമ്മപ്പെടുത്തലുകൾ പ്രവർത്തനക്ഷമമാക്കാൻ ലക്ഷ്യം ചേർക്കുക';

  @override
  String settingsPanelSpeakSavedGoalEvery(int minutes) {
    return 'സംരക്ഷിച്ച ലക്ഷ്യം ഓരോ $minutes മിനിറ്റിലും പറയുക';
  }

  @override
  String get settingsPanelGoalReminderInterval =>
      'ലക്ഷ്യ ഓർമ്മപ്പെടുത്തൽ ഇടവേള';

  @override
  String get settingsPanelAddGoal => 'ലക്ഷ്യം ചേർക്കുക';

  @override
  String get settingsPanelAdd => 'ചേർക്കുക';

  @override
  String get settingsPanelNoGoalsSaved => 'ലക്ഷ്യങ്ങളൊന്നും സംരക്ഷിച്ചിട്ടില്ല';

  @override
  String get settingsPanelRemoveGoal => 'ലക്ഷ്യം നീക്കം ചെയ്യുക';

  @override
  String get settingsPanelNoiseVolume => 'ശബ്ദത്തിന്റെ വോള്യം';

  @override
  String get settingsPanelSpeechVolume => 'സംസാര വോള്യം';

  @override
  String get settingsPanelBoostTtsVolume => 'സംസാര വോള്യം വർധിപ്പിക്കുക';

  @override
  String get settingsPanelMaximumSpeechVolumeDescription =>
      'സംസാര ഔട്ട്പുട്ട് ലഭ്യമായ പരമാവധി വോള്യത്തിലേക്ക് ഉയർത്തുക';

  @override
  String get settingsPanelSpeechEngine => 'സംസാര എഞ്ചിൻ';

  @override
  String get settingsPanelTestVoice => 'ശബ്ദം പരീക്ഷിക്കുക';

  @override
  String get settingsPanelPlaySample => 'സാമ്പിൾ പ്ലേ ചെയ്യുക';

  @override
  String get settingsPanelLanguageList => 'ശബ്ദ ഭാഷാ പട്ടിക';

  @override
  String get settingsPanelPreferredVoice => 'മുൻഗണനാ ശബ്ദം';

  @override
  String get settingsPanelVoice => 'ശബ്ദം';

  @override
  String get settingsPanelFontSize => 'ഫോണ്ട് വലുപ്പം';

  @override
  String get settingsPanelStartLandscape =>
      'പൂർണ്ണ സ്‌ക്രീൻ തിരശ്ചീനമായി ആരംഭിക്കുക';

  @override
  String get settingsPanelShowClockFullscreen =>
      'പൂർണ്ണ സ്‌ക്രീനിൽ ഘടികാരം കാണിക്കുക';

  @override
  String get settingsPanelShowClockFullscreenDescription =>
      'ടൈമറിന് മുകളിൽ നിലവിലെ സമയം കാണിക്കുക';

  @override
  String get settingsPanelFullscreenClockSize =>
      'പൂർണ്ണ സ്‌ക്രീൻ ഘടികാര വലുപ്പം';

  @override
  String get settingsPanelEnableSleepMode =>
      'സ്ലീപ്പ് മോഡ് പ്രവർത്തനക്ഷമമാക്കുക';

  @override
  String get settingsPanelQuietHoursSpeech =>
      'നിശ്ശബ്ദ സമയങ്ങളിൽ സംസാരം നിർത്തുക';

  @override
  String get settingsPanelMode => 'മോഡ്';

  @override
  String get settingsPanelSleepMode => 'സ്ലീപ്പ് മോഡ്';

  @override
  String get settingsPanelBackupAppSettings =>
      'ആപ്പ് ക്രമീകരണങ്ങൾ ബാക്കപ്പ് ചെയ്യുക';

  @override
  String get settingsPanelBackupDescription =>
      'ക്രമീകരണങ്ങൾ ഫയലിലേക്ക് എക്സ്പോർട്ട് ചെയ്യുക';

  @override
  String get settingsPanelRestoreAppSettings =>
      'ആപ്പ് ക്രമീകരണങ്ങൾ പുനഃസ്ഥാപിക്കുക';

  @override
  String get settingsPanelRestoreDescription =>
      'ബാക്കപ്പ് ഫയലിൽ നിന്ന് ക്രമീകരണങ്ങൾ ഇറക്കുമതി ചെയ്യുക';

  @override
  String get settingsPanelChooseBackupFolder =>
      'ബാക്കപ്പ് ഫോൾഡർ തിരഞ്ഞെടുക്കുക';

  @override
  String get helpPanelSleepModeOff => 'സ്ലീപ്പ് മോഡ് ഓഫാണ്';

  @override
  String get helpPanelSleepModeManual => 'മാനുവൽ നിശ്ശബ്ദ സമയം';

  @override
  String get helpPanelSleepModeAutomatic => 'ഓട്ടോമാറ്റിക് രാത്രി മോഡ്';

  @override
  String helpPanelCurrentRange(String range) {
    return 'നിശ്ശബ്ദ സമയം: $range';
  }

  @override
  String get helpPanelQuickStart => 'വേഗത്തിൽ തുടങ്ങുക';

  @override
  String get helpPanelConfigureTimerTitle => 'ടൈമർ ക്രമീകരിക്കുക';

  @override
  String get helpPanelConfigureTimerDescription =>
      'ടൈമർ ടാബിൽ ഒരു മുൻസജ്ജീകരണം തിരഞ്ഞെടുക്കുക അല്ലെങ്കിൽ ഇഷ്ടാനുസൃത സമയം സജ്ജമാക്കുക.';

  @override
  String get helpPanelSetSleepTitle => 'ഉറക്ക സമയം സജ്ജമാക്കുക';

  @override
  String get helpPanelSetSleepDescription =>
      'സ്ലീപ്പ് മോഡ് പ്രവർത്തനക്ഷമമാക്കി സംസാരം നിർത്താൻ നിശ്ശബ്ദ സമയം തിരഞ്ഞെടുക്കുക.';

  @override
  String get helpPanelWidgetControlsTitle => 'ഹോം സ്‌ക്രീൻ വിജറ്റ് ഉപയോഗിക്കുക';

  @override
  String get helpPanelWidgetControlsDescription =>
      'ആപ്പ് തുറക്കാതെ ടൈമർ ആരംഭിക്കുക, നിർത്തുക, പുനഃസജ്ജമാക്കുക.';

  @override
  String get helpPanelFaq => 'സഹായം';

  @override
  String get helpPanelSpeakingClockTitle => 'സംസാരിക്കുന്ന ഘടികാരം';

  @override
  String get helpPanelSpeakingClockAnnouncements =>
      'അറിയിപ്പ് ഇടവേളകൾ തിരഞ്ഞെടുക്കുകയും ക്രമീകരണങ്ങളിൽ സംസാരം പ്രവർത്തനക്ഷമമാക്കുകയും ചെയ്യുക.';

  @override
  String get helpPanelSpeakingClockQuotes =>
      'ഉദ്ധരണികൾ പ്രവർത്തനക്ഷമമാക്കി വിഭാഗവും വൈകലും തിരഞ്ഞെടുക്കുക.';

  @override
  String get helpPanelTimerSetupTitle => 'ടൈമർ സജ്ജീകരണം';

  @override
  String get helpPanelTimerSetupPreset =>
      'ഒരു മുൻസജ്ജീകരണം തിരഞ്ഞെടുക്കുക അല്ലെങ്കിൽ ഇഷ്ടാനുസൃത ടൈമർ സമയം സജ്ജമാക്കുക.';

  @override
  String get helpPanelTimerSetupSpeech =>
      'സംസാര അറിയിപ്പുകൾ പ്രവർത്തനക്ഷമമാക്കി അവയുടെ ഇടവേള ക്രമീകരിക്കുക.';

  @override
  String get helpPanelTimerSetupChain =>
      'പഠന, ഇടവേള ടൈമറുകളുടെ ക്രമം പ്രവർത്തിപ്പിക്കാൻ ശൃംഖല മോഡ് ഉപയോഗിക്കുക.';

  @override
  String get helpPanelSleepModeTitle => 'സ്ലീപ്പ് മോഡ്';

  @override
  String get helpPanelSleepModeRange =>
      'ക്രമീകരണങ്ങളിൽ നിശ്ശബ്ദ സമയത്തിന്റെ ആരംഭവും അവസാനവും സജ്ജമാക്കുക.';

  @override
  String get helpPanelSleepModeManualDescription =>
      'മാനുവൽ മോഡ് നിങ്ങൾ തിരഞ്ഞെടുത്ത സമയങ്ങൾ ഉപയോഗിക്കുന്നു.';

  @override
  String get helpPanelSleepModeAutomaticDescription =>
      'ഓട്ടോമാറ്റിക് മോഡ് രാത്രി ഉപകരണ നിഷ്‌ക്രിയത കണ്ടെത്തുന്നു.';

  @override
  String get helpPanelSleepModeResumeDescription =>
      'നിശ്ശബ്ദ സമയം അവസാനിക്കുമ്പോൾ സംസാരം പുനരാരംഭിക്കും.';

  @override
  String get helpPanelHomeWidgetTitle => 'ഹോം സ്‌ക്രീൻ വിജറ്റ്';

  @override
  String get helpPanelHomeWidgetSpeech =>
      'സംസാരം പ്രവർത്തനക്ഷമമായിരിക്കുമ്പോൾ വിജറ്റിന് ടൈമർ നില പറയാം.';

  @override
  String get helpPanelHomeWidgetTimer =>
      'ടൈമർ ആരംഭിക്കാനും നിർത്താനും പുനഃസജ്ജമാക്കാനും വിജറ്റ് നിയന്ത്രണങ്ങൾ ഉപയോഗിക്കുക.';

  @override
  String get helpPanelHomeWidgetQuickSessions =>
      'വേഗത്തിലുള്ള സെഷൻ ബട്ടണുകൾ സാധാരണ ടൈമർ ദൈർഘ്യങ്ങൾ ആരംഭിക്കുന്നു.';

  @override
  String get helpPanelHomeWidgetStatus =>
      'വിജറ്റ് നില നിലവിലെ ടൈമർ സെഷനെ പ്രതിഫലിപ്പിക്കുന്നു.';

  @override
  String get helpPanelTipsTitle => 'സൂചനകൾ';

  @override
  String get helpPanelTipsSync => 'ക്രമീകരണങ്ങൾ ഈ ഉപകരണത്തിൽ സൂക്ഷിക്കുന്നു.';

  @override
  String get helpPanelTipsPermissions =>
      'വിശ്വസനീയമായ ടൈമർ അറിയിപ്പുകൾക്കായി അറിയിപ്പുകളും പശ്ചാത്തല പ്രവർത്തനവും അനുവദിക്കുക.';

  @override
  String get helpPanelTipsBackground =>
      'തടസ്സമില്ലാത്ത ടൈമിംഗിനായി ആപ്പിന് പശ്ചാത്തലത്തിൽ പ്രവർത്തിക്കാൻ അനുമതി നൽകുക.';

  @override
  String get settingsPanelGoalField => 'ലക്ഷ്യം';

  @override
  String get settingsPanelDownloadNotDownloaded =>
      'ഡൗൺലോഡ് ചെയ്തിട്ടില്ല · 140 MiB. അതുവരെ ഇംഗ്ലീഷ് സംഭാഷണത്തിന് Piper തുടരും.';

  @override
  String settingsPanelDownloadingKokoro(String amount) {
    return 'Kokoro ഇംഗ്ലീഷ് ഡൗൺലോഡ് ചെയ്യുന്നു · $amount';
  }

  @override
  String settingsPanelDownloadingKokoroPercent(int percent, String amount) {
    return 'Kokoro ഇംഗ്ലീഷ് ഡൗൺലോഡ് ചെയ്യുന്നു · $percent% · $amount';
  }

  @override
  String get settingsPanelDownloadVerifying =>
      'ഡൗൺലോഡ് പൂർത്തിയായി · SHA-256 പരിശോധിക്കുന്നു';

  @override
  String get settingsPanelDownloadInstalling =>
      'ഓഫ്‌ലൈൻ ഇംഗ്ലീഷ് ശബ്ദം ഇൻസ്റ്റാൾ ചെയ്യുന്നു';

  @override
  String get settingsPanelDownloadReady =>
      'തയ്യാർ · Kokoro v1.1 ഇംഗ്ലീഷ് ഓഫ്‌ലൈനായി പ്രവർത്തിക്കുന്നു';

  @override
  String settingsPanelDownloadFailed(String error) {
    return 'ഡൗൺലോഡ് പരാജയപ്പെട്ടു · $error';
  }

  @override
  String get settingsPanelDownloadFailedFallback =>
      'കണക്ഷൻ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get settingsPanelDownloadCancelled =>
      'ഡൗൺലോഡ് റദ്ദാക്കി · ഉൾപ്പെടുത്തിയ Piper ശബ്ദം തുടർന്നും ലഭ്യമാണ്.';

  @override
  String mainDesktopTimerFinishedBody(int minutes) {
    return '$minutes മിനിറ്റ് ടൈമർ പൂർത്തിയായി.';
  }
}
