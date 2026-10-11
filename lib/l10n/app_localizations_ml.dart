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
  String get motivationLabel => 'പ്രചോദനം കാണിക്കുക';

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
  String get longPressToDone =>
      'പൂർത്തിയായെന്ന് അടയാളപ്പെടുത്താൻ ടൈമറിൽ ദീർഘനേരം അമർത്തുക';

  @override
  String get sessionCompleted => 'സെഷൻ പൂർത്തിയായി!';

  @override
  String get motivationQuote => 'പ്രചോദനം';

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
}
