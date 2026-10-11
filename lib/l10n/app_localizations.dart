import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ml.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ml'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SolasFlow'**
  String get appTitle;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help / Working'**
  String get helpTitle;

  /// No description provided for @timerTab.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timerTab;

  /// No description provided for @clockTab.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get clockTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @presetTab.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presetTab;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// No description provided for @pauseButton.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseButton;

  /// No description provided for @resumeButton.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeButton;

  /// No description provided for @stopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopButton;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @addTimeButton.
  ///
  /// In en, this message translates to:
  /// **'Add Time'**
  String get addTimeButton;

  /// No description provided for @chainModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Chain Mode'**
  String get chainModeLabel;

  /// No description provided for @chainModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Run preset timers in sequence'**
  String get chainModeDescription;

  /// No description provided for @timerNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer Running'**
  String get timerNotificationTitle;

  /// No description provided for @clockNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Check'**
  String get clockNotificationTitle;

  /// No description provided for @focusMode.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get focusMode;

  /// No description provided for @fullscreenMode.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreenMode;

  /// No description provided for @soundLabel.
  ///
  /// In en, this message translates to:
  /// **'Background Sound'**
  String get soundLabel;

  /// No description provided for @volumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volumeLabel;

  /// No description provided for @voiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice Selection'**
  String get voiceLabel;

  /// No description provided for @darkThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkThemeLabel;

  /// No description provided for @motivationCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Motivation Category'**
  String get motivationCategoryLabel;

  /// No description provided for @motivationDelayLabel.
  ///
  /// In en, this message translates to:
  /// **'Quote Delay (seconds)'**
  String get motivationDelayLabel;

  /// No description provided for @clockIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Clock Interval (minutes)'**
  String get clockIntervalLabel;

  /// No description provided for @timerAnnouncementLabel.
  ///
  /// In en, this message translates to:
  /// **'Announce Every (minutes)'**
  String get timerAnnouncementLabel;

  /// No description provided for @nightMuteMode.
  ///
  /// In en, this message translates to:
  /// **'Night Mute Mode'**
  String get nightMuteMode;

  /// No description provided for @sleepStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep Start Time'**
  String get sleepStartLabel;

  /// No description provided for @sleepEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep End Time'**
  String get sleepEndLabel;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @quickActionStart25m.
  ///
  /// In en, this message translates to:
  /// **'Start 25m'**
  String get quickActionStart25m;

  /// No description provided for @quickActionResumeLast.
  ///
  /// In en, this message translates to:
  /// **'Resume Last'**
  String get quickActionResumeLast;

  /// No description provided for @quickActionToggleSpeech.
  ///
  /// In en, this message translates to:
  /// **'Toggle Speech'**
  String get quickActionToggleSpeech;

  /// No description provided for @timerForegroundChannelName.
  ///
  /// In en, this message translates to:
  /// **'SolasFlow Timer'**
  String get timerForegroundChannelName;

  /// No description provided for @timerForegroundChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Persistent timer & stopwatch service'**
  String get timerForegroundChannelDescription;

  /// No description provided for @timerFinishedNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer Finished'**
  String get timerFinishedNotificationTitle;

  /// No description provided for @stopwatchNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch Running'**
  String get stopwatchNotificationTitle;

  /// No description provided for @audioOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio ON'**
  String get audioOnLabel;

  /// No description provided for @audioOffLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio OFF'**
  String get audioOffLabel;

  /// No description provided for @timerFinishedNotificationText.
  ///
  /// In en, this message translates to:
  /// **'Timer finished! Tap to set next timer.'**
  String get timerFinishedNotificationText;

  /// No description provided for @notificationTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining: {value}'**
  String notificationTimeRemaining(String value);

  /// No description provided for @notificationElapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed: {value}'**
  String notificationElapsed(String value);

  /// No description provided for @repeatButton.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatButton;

  /// No description provided for @dismissButton.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissButton;

  /// No description provided for @openButton.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openButton;

  /// No description provided for @exitButton.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitButton;

  /// No description provided for @stopwatchTab.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch'**
  String get stopwatchTab;

  /// No description provided for @mainSpeechEngineChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to change speech engine: {error}'**
  String mainSpeechEngineChangeFailed(String error);

  /// No description provided for @mainSettingsOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open Settings: {error}'**
  String mainSettingsOpenFailed(String error);

  /// No description provided for @mainBackupSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup Saved'**
  String get mainBackupSavedTitle;

  /// No description provided for @mainSettingsExported.
  ///
  /// In en, this message translates to:
  /// **'Settings exported successfully.'**
  String get mainSettingsExported;

  /// No description provided for @mainJsonCopied.
  ///
  /// In en, this message translates to:
  /// **'JSON copied to clipboard'**
  String get mainJsonCopied;

  /// No description provided for @mainCopyJson.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get mainCopyJson;

  /// No description provided for @mainDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get mainDone;

  /// No description provided for @mainBackupFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get mainBackupFailedTitle;

  /// No description provided for @mainBackupFileFailed.
  ///
  /// In en, this message translates to:
  /// **'The file could not be saved: {error}. Copy the settings JSON instead?'**
  String mainBackupFileFailed(String error);

  /// No description provided for @mainCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get mainCancel;

  /// No description provided for @mainBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String mainBackupFailed(String error);

  /// No description provided for @mainRestoreSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Settings'**
  String get mainRestoreSettingsTitle;

  /// No description provided for @mainRestoreSettingsWarning.
  ///
  /// In en, this message translates to:
  /// **'This will replace the app preferences in this backup. Local desktop offline-model selections are not included and will stay unchanged. The restored preferences will take effect immediately. Continue?'**
  String get mainRestoreSettingsWarning;

  /// No description provided for @mainRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get mainRestoreButton;

  /// No description provided for @mainSettingsRestored.
  ///
  /// In en, this message translates to:
  /// **'Settings restored successfully!'**
  String get mainSettingsRestored;

  /// No description provided for @mainRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String mainRestoreFailed(String error);

  /// No description provided for @mainDesktopAlwaysOnTopNote.
  ///
  /// In en, this message translates to:
  /// **'Always on top is a window-manager hint. Some Wayland desktops ignore it; use the compositor’s window rules if needed.'**
  String get mainDesktopAlwaysOnTopNote;

  /// No description provided for @mainDesktopActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Desktop action failed: {error}'**
  String mainDesktopActionFailed(String error);

  /// No description provided for @mainStartupIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Startup is incomplete: {error}'**
  String mainStartupIncomplete(String error);

  /// No description provided for @mainTimerDurationRangeError.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between 1 and 720'**
  String get mainTimerDurationRangeError;

  /// No description provided for @mainTimerFinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer finished'**
  String get mainTimerFinishedTitle;

  /// No description provided for @mainRepeatSameTimer.
  ///
  /// In en, this message translates to:
  /// **'Repeat Same Timer'**
  String get mainRepeatSameTimer;

  /// No description provided for @mainStartPresetTimer.
  ///
  /// In en, this message translates to:
  /// **'Start New Preset Timer'**
  String get mainStartPresetTimer;

  /// No description provided for @mainMinuteShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String mainMinuteShort(int minutes);

  /// No description provided for @mainCustomDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Custom duration (minutes)'**
  String get mainCustomDurationMinutes;

  /// No description provided for @mainCloseTimer.
  ///
  /// In en, this message translates to:
  /// **'Close timer'**
  String get mainCloseTimer;

  /// No description provided for @mainStartCustomTimer.
  ///
  /// In en, this message translates to:
  /// **'Start custom'**
  String get mainStartCustomTimer;

  /// No description provided for @mainTurnAudioOn.
  ///
  /// In en, this message translates to:
  /// **'Turn audio on'**
  String get mainTurnAudioOn;

  /// No description provided for @mainTurnAudioOff.
  ///
  /// In en, this message translates to:
  /// **'Turn audio off'**
  String get mainTurnAudioOff;

  /// No description provided for @mainDesktopControls.
  ///
  /// In en, this message translates to:
  /// **'Desktop controls'**
  String get mainDesktopControls;

  /// No description provided for @mainDriveModeCompact.
  ///
  /// In en, this message translates to:
  /// **'Drive Mode — compact'**
  String get mainDriveModeCompact;

  /// No description provided for @mainDriveModeFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Drive Mode — fullscreen'**
  String get mainDriveModeFullscreen;

  /// No description provided for @mainKeepRunningWhenClosed.
  ///
  /// In en, this message translates to:
  /// **'Keep running when closed'**
  String get mainKeepRunningWhenClosed;

  /// No description provided for @mainAlwaysOnTopDesktopHint.
  ///
  /// In en, this message translates to:
  /// **'Always on top (desktop hint)'**
  String get mainAlwaysOnTopDesktopHint;

  /// No description provided for @mainHideToBackground.
  ///
  /// In en, this message translates to:
  /// **'Hide to background'**
  String get mainHideToBackground;

  /// No description provided for @dashboardTimeUtilization.
  ///
  /// In en, this message translates to:
  /// **'Time Utilization'**
  String get dashboardTimeUtilization;

  /// No description provided for @dashboardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load session history.'**
  String get dashboardLoadError;

  /// No description provided for @dashboardNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions logged yet.\nEnable tagging and complete a timer to see data.'**
  String get dashboardNoSessions;

  /// No description provided for @daySummaryStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get daySummaryStudy;

  /// No description provided for @daySummaryNonStudy.
  ///
  /// In en, this message translates to:
  /// **'Non-study'**
  String get daySummaryNonStudy;

  /// No description provided for @presetGridQuickPresets.
  ///
  /// In en, this message translates to:
  /// **'Quick presets'**
  String get presetGridQuickPresets;

  /// No description provided for @kokoroDownloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Download the Kokoro English voice?'**
  String get kokoroDownloadTitle;

  /// No description provided for @kokoroDownloadDescription.
  ///
  /// In en, this message translates to:
  /// **'Solas Flow can download a 140 MiB English speech model for more natural English announcements. The download is verified and then available offline. English and Malayalam bundled voices remain available if you skip it. You can download, cancel, or retry later from Settings.'**
  String get kokoroDownloadDescription;

  /// No description provided for @kokoroKeepPiper.
  ///
  /// In en, this message translates to:
  /// **'Keep Piper'**
  String get kokoroKeepPiper;

  /// No description provided for @kokoroAcceptAndDownload.
  ///
  /// In en, this message translates to:
  /// **'Accept and download'**
  String get kokoroAcceptAndDownload;

  /// No description provided for @clockPanelCurrentTime.
  ///
  /// In en, this message translates to:
  /// **'CURRENT TIME'**
  String get clockPanelCurrentTime;

  /// No description provided for @clockPanelSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get clockPanelSound;

  /// No description provided for @clockPanelNoise.
  ///
  /// In en, this message translates to:
  /// **'Noise'**
  String get clockPanelNoise;

  /// No description provided for @clockPanelQuotes.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get clockPanelQuotes;

  /// No description provided for @clockPanelBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get clockPanelBackground;

  /// No description provided for @clockPanelAnnounceInterval.
  ///
  /// In en, this message translates to:
  /// **'Announce interval'**
  String get clockPanelAnnounceInterval;

  /// No description provided for @clockPanelMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String clockPanelMinutes(int count);

  /// No description provided for @clockPanelEveryMinutes.
  ///
  /// In en, this message translates to:
  /// **'Every {count} min'**
  String clockPanelEveryMinutes(int count);

  /// No description provided for @clockPanelRepeatCount.
  ///
  /// In en, this message translates to:
  /// **'Repeat count'**
  String get clockPanelRepeatCount;

  /// No description provided for @clockPanelTimes.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String clockPanelTimes(int count);

  /// No description provided for @clockPanelQuoteCategory.
  ///
  /// In en, this message translates to:
  /// **'Quote category'**
  String get clockPanelQuoteCategory;

  /// No description provided for @clockPanelQuoteDelay.
  ///
  /// In en, this message translates to:
  /// **'Quote delay'**
  String get clockPanelQuoteDelay;

  /// No description provided for @clockPanelSecondsDelay.
  ///
  /// In en, this message translates to:
  /// **'{seconds} sec delay'**
  String clockPanelSecondsDelay(int seconds);

  /// No description provided for @clockPanelShowSeconds.
  ///
  /// In en, this message translates to:
  /// **'Show seconds'**
  String get clockPanelShowSeconds;

  /// No description provided for @clockPanelShowMilliseconds.
  ///
  /// In en, this message translates to:
  /// **'Show milliseconds'**
  String get clockPanelShowMilliseconds;

  /// No description provided for @clockPanelOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get clockPanelOn;

  /// No description provided for @clockPanelOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get clockPanelOff;

  /// No description provided for @clockPanelCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get clockPanelCategoryGeneral;

  /// No description provided for @clockPanelCategoryGeneralMalayalam.
  ///
  /// In en, this message translates to:
  /// **'General Malayalam'**
  String get clockPanelCategoryGeneralMalayalam;

  /// No description provided for @clockPanelCategoryFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get clockPanelCategoryFocus;

  /// No description provided for @clockPanelCategoryDiscipline.
  ///
  /// In en, this message translates to:
  /// **'Discipline'**
  String get clockPanelCategoryDiscipline;

  /// No description provided for @clockPanelCategoryCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get clockPanelCategoryCalm;

  /// No description provided for @clockPanelCategoryPositivity.
  ///
  /// In en, this message translates to:
  /// **'Positivity'**
  String get clockPanelCategoryPositivity;

  /// No description provided for @clockPanelCategoryHistoricFigures.
  ///
  /// In en, this message translates to:
  /// **'Historic Figures'**
  String get clockPanelCategoryHistoricFigures;

  /// No description provided for @timerPanelEndsAt.
  ///
  /// In en, this message translates to:
  /// **'Ends at {time}'**
  String timerPanelEndsAt(String time);

  /// No description provided for @timerPanelDisplay.
  ///
  /// In en, this message translates to:
  /// **'Timer display'**
  String get timerPanelDisplay;

  /// No description provided for @timerPanelFullscreenHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to open fullscreen. Double-tap for immersive fullscreen.'**
  String get timerPanelFullscreenHint;

  /// No description provided for @timerPanelRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get timerPanelRemaining;

  /// No description provided for @timerPanelRemoveMinute.
  ///
  /// In en, this message translates to:
  /// **'Remove one minute'**
  String get timerPanelRemoveMinute;

  /// No description provided for @timerPanelAddFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'Add five minutes'**
  String get timerPanelAddFiveMinutes;

  /// No description provided for @timerPanelStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step}'**
  String timerPanelStep(int step);

  /// No description provided for @timerPanelPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get timerPanelPause;

  /// No description provided for @timerPanelStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get timerPanelStart;

  /// No description provided for @timerPanelReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get timerPanelReset;

  /// No description provided for @timerPanelSpeech.
  ///
  /// In en, this message translates to:
  /// **'Speech'**
  String get timerPanelSpeech;

  /// No description provided for @timerPanelNoise.
  ///
  /// In en, this message translates to:
  /// **'Noise'**
  String get timerPanelNoise;

  /// No description provided for @timerPanelChain.
  ///
  /// In en, this message translates to:
  /// **'Chain'**
  String get timerPanelChain;

  /// No description provided for @timerPanelClock.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get timerPanelClock;

  /// No description provided for @timerPanelTagging.
  ///
  /// In en, this message translates to:
  /// **'Tagging'**
  String get timerPanelTagging;

  /// No description provided for @timerPanelStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get timerPanelStudy;

  /// No description provided for @timerPanelNonStudy.
  ///
  /// In en, this message translates to:
  /// **'Non-study'**
  String get timerPanelNonStudy;

  /// No description provided for @timerPanelTimeUtilization.
  ///
  /// In en, this message translates to:
  /// **'Time Utilization'**
  String get timerPanelTimeUtilization;

  /// No description provided for @timerPanelShowMilliseconds.
  ///
  /// In en, this message translates to:
  /// **'Show milliseconds'**
  String get timerPanelShowMilliseconds;

  /// No description provided for @timerPanelAnnounceEvery.
  ///
  /// In en, this message translates to:
  /// **'Announce every'**
  String get timerPanelAnnounceEvery;

  /// No description provided for @timerPanelMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String timerPanelMinutes(int minutes);

  /// No description provided for @timerPanelOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get timerPanelOn;

  /// No description provided for @timerPanelOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get timerPanelOff;

  /// No description provided for @timerPanelChainMode.
  ///
  /// In en, this message translates to:
  /// **'Chain mode'**
  String get timerPanelChainMode;

  /// No description provided for @timerPanelPresetSequence.
  ///
  /// In en, this message translates to:
  /// **'Preset sequence'**
  String get timerPanelPresetSequence;

  /// No description provided for @timerPanelAnnouncementInterval.
  ///
  /// In en, this message translates to:
  /// **'Announcement interval'**
  String get timerPanelAnnouncementInterval;

  /// No description provided for @timerPanelAnnounceEveryMinutes.
  ///
  /// In en, this message translates to:
  /// **'Announce every {minutes} min'**
  String timerPanelAnnounceEveryMinutes(int minutes);

  /// No description provided for @timerPanelChainPreset.
  ///
  /// In en, this message translates to:
  /// **'Chain preset'**
  String get timerPanelChainPreset;

  /// No description provided for @timerPanelCustomTimer.
  ///
  /// In en, this message translates to:
  /// **'Custom timer'**
  String get timerPanelCustomTimer;

  /// No description provided for @timerPanelMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get timerPanelMinutesLabel;

  /// No description provided for @timerPanelMinutesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter minutes (1-720)'**
  String get timerPanelMinutesHint;

  /// No description provided for @timerPanelMinuteAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get timerPanelMinuteAbbreviation;

  /// No description provided for @timerPanelCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get timerPanelCancel;

  /// No description provided for @timerPanelWholeNumberError.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number from 1 to 720.'**
  String get timerPanelWholeNumberError;

  /// No description provided for @timerPanelSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get timerPanelSet;

  /// No description provided for @timerPanelSequenceMinutes.
  ///
  /// In en, this message translates to:
  /// **'{values} min'**
  String timerPanelSequenceMinutes(String values);

  /// No description provided for @timerPanelPomodoroPreset.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro 25-5x4'**
  String get timerPanelPomodoroPreset;

  /// No description provided for @timerPanelSprintPreset.
  ///
  /// In en, this message translates to:
  /// **'Sprint 50-10x2'**
  String get timerPanelSprintPreset;

  /// No description provided for @timerPanelQuickPreset.
  ///
  /// In en, this message translates to:
  /// **'Quick 15-3x3'**
  String get timerPanelQuickPreset;

  /// No description provided for @stopwatchPanelElapsed.
  ///
  /// In en, this message translates to:
  /// **'ELAPSED'**
  String get stopwatchPanelElapsed;

  /// No description provided for @stopwatchPanelLaps.
  ///
  /// In en, this message translates to:
  /// **'{count} laps'**
  String stopwatchPanelLaps(int count);

  /// No description provided for @stopwatchPanelPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get stopwatchPanelPause;

  /// No description provided for @stopwatchPanelStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get stopwatchPanelStart;

  /// No description provided for @stopwatchPanelLap.
  ///
  /// In en, this message translates to:
  /// **'Lap'**
  String get stopwatchPanelLap;

  /// No description provided for @stopwatchPanelReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get stopwatchPanelReset;

  /// No description provided for @stopwatchPanelLapTimes.
  ///
  /// In en, this message translates to:
  /// **'Lap times'**
  String get stopwatchPanelLapTimes;

  /// No description provided for @stopwatchPanelSpeech.
  ///
  /// In en, this message translates to:
  /// **'Speech'**
  String get stopwatchPanelSpeech;

  /// No description provided for @stopwatchPanelShowMilliseconds.
  ///
  /// In en, this message translates to:
  /// **'Show milliseconds'**
  String get stopwatchPanelShowMilliseconds;

  /// No description provided for @stopwatchPanelOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get stopwatchPanelOn;

  /// No description provided for @stopwatchPanelOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get stopwatchPanelOff;

  /// No description provided for @stopwatchPanelSpeakDelay.
  ///
  /// In en, this message translates to:
  /// **'Speak delay'**
  String get stopwatchPanelSpeakDelay;

  /// No description provided for @stopwatchPanelSpeakElapsedEvery.
  ///
  /// In en, this message translates to:
  /// **'Speak elapsed every'**
  String get stopwatchPanelSpeakElapsedEvery;

  /// No description provided for @stopwatchPanelSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} sec'**
  String stopwatchPanelSeconds(int seconds);

  /// No description provided for @stopwatchPanelMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String stopwatchPanelMinutes(int minutes);

  /// No description provided for @driveModeClock.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get driveModeClock;

  /// No description provided for @driveModeTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get driveModeTimer;

  /// No description provided for @driveModeStopwatch.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch'**
  String get driveModeStopwatch;

  /// No description provided for @driveModeCurrentTime.
  ///
  /// In en, this message translates to:
  /// **'Current time'**
  String get driveModeCurrentTime;

  /// No description provided for @driveModeRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get driveModeRunning;

  /// No description provided for @driveModePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get driveModePaused;

  /// No description provided for @driveModeReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get driveModeReady;

  /// No description provided for @driveModeDisplaySemantics.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String driveModeDisplaySemantics(String label, String value);

  /// No description provided for @driveModePause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get driveModePause;

  /// No description provided for @driveModeResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get driveModeResume;

  /// No description provided for @driveModeStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get driveModeStart;

  /// No description provided for @driveModeMinutePreset.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String driveModeMinutePreset(int minutes);

  /// No description provided for @driveModeAudioOn.
  ///
  /// In en, this message translates to:
  /// **'Audio on'**
  String get driveModeAudioOn;

  /// No description provided for @driveModeAudioOff.
  ///
  /// In en, this message translates to:
  /// **'Audio off'**
  String get driveModeAudioOff;

  /// No description provided for @driveModeSpeakNow.
  ///
  /// In en, this message translates to:
  /// **'Speak now'**
  String get driveModeSpeakNow;

  /// No description provided for @driveModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Drive Mode'**
  String get driveModeTitle;

  /// No description provided for @driveModeClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get driveModeClose;

  /// No description provided for @focusViewStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get focusViewStop;

  /// No description provided for @focusViewStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get focusViewStart;

  /// No description provided for @focusViewReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get focusViewReset;

  /// No description provided for @focusViewCloseFocusMode.
  ///
  /// In en, this message translates to:
  /// **'Close focus mode'**
  String get focusViewCloseFocusMode;

  /// No description provided for @focusViewAwake.
  ///
  /// In en, this message translates to:
  /// **'Awake'**
  String get focusViewAwake;

  /// No description provided for @focusViewClock.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get focusViewClock;

  /// No description provided for @focusViewLightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get focusViewLightTheme;

  /// No description provided for @focusViewDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get focusViewDarkTheme;

  /// No description provided for @focusViewDisableDim.
  ///
  /// In en, this message translates to:
  /// **'Disable dim'**
  String get focusViewDisableDim;

  /// No description provided for @focusViewDimBrightness.
  ///
  /// In en, this message translates to:
  /// **'Dim brightness'**
  String get focusViewDimBrightness;

  /// No description provided for @focusViewUnlockRotation.
  ///
  /// In en, this message translates to:
  /// **'Unlock Rotation'**
  String get focusViewUnlockRotation;

  /// No description provided for @focusViewRotateHorizontal.
  ///
  /// In en, this message translates to:
  /// **'Rotate Horizontal'**
  String get focusViewRotateHorizontal;

  /// No description provided for @focusViewFullscreenModeEntered.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen mode entered'**
  String get focusViewFullscreenModeEntered;

  /// No description provided for @focusViewDoubleTapToExit.
  ///
  /// In en, this message translates to:
  /// **'Double tap anywhere to exit'**
  String get focusViewDoubleTapToExit;

  /// No description provided for @settingsPanelDesktopAutostartChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking autostart status…'**
  String get settingsPanelDesktopAutostartChecking;

  /// No description provided for @settingsPanelAutostartNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Autostart is not configured.'**
  String get settingsPanelAutostartNotConfigured;

  /// No description provided for @settingsPanelAutostartInstalledDisabled.
  ///
  /// In en, this message translates to:
  /// **'Autostart is installed but disabled.'**
  String get settingsPanelAutostartInstalledDisabled;

  /// No description provided for @settingsPanelAutostartFailed.
  ///
  /// In en, this message translates to:
  /// **'Autostart service failed.'**
  String get settingsPanelAutostartFailed;

  /// No description provided for @settingsPanelAutostartRunning.
  ///
  /// In en, this message translates to:
  /// **'Autostart is active.'**
  String get settingsPanelAutostartRunning;

  /// No description provided for @settingsPanelAutostartNextLogin.
  ///
  /// In en, this message translates to:
  /// **'Autostart will run at next login.'**
  String get settingsPanelAutostartNextLogin;

  /// No description provided for @settingsPanelDesktopAutostartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start automatically at login'**
  String get settingsPanelDesktopAutostartTitle;

  /// No description provided for @settingsPanelDesktopAutostartDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage the user-level systemd service that starts Solas Flow when you sign in.'**
  String get settingsPanelDesktopAutostartDescription;

  /// No description provided for @settingsPanelEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get settingsPanelEnable;

  /// No description provided for @settingsPanelRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get settingsPanelRemove;

  /// No description provided for @settingsPanelRefreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get settingsPanelRefreshStatus;

  /// No description provided for @settingsPanelChooseModelFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose model folder'**
  String get settingsPanelChooseModelFolder;

  /// No description provided for @settingsPanelOfflineModelFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not {action} offline model: {error}'**
  String settingsPanelOfflineModelFailed(String action, String error);

  /// No description provided for @settingsPanelClear.
  ///
  /// In en, this message translates to:
  /// **'clear'**
  String get settingsPanelClear;

  /// No description provided for @settingsPanelImport.
  ///
  /// In en, this message translates to:
  /// **'import'**
  String get settingsPanelImport;

  /// No description provided for @settingsPanelLocalOfflineModel.
  ///
  /// In en, this message translates to:
  /// **'Local offline speech model'**
  String get settingsPanelLocalOfflineModel;

  /// No description provided for @settingsPanelOfflineModelDescription.
  ///
  /// In en, this message translates to:
  /// **'Import a compatible Sherpa-ONNX model directory for fully offline speech. The selected model is copied into app storage.'**
  String get settingsPanelOfflineModelDescription;

  /// No description provided for @settingsPanelModelLanguage.
  ///
  /// In en, this message translates to:
  /// **'Model language'**
  String get settingsPanelModelLanguage;

  /// No description provided for @settingsPanelEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsPanelEnglish;

  /// No description provided for @settingsPanelMalayalam.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get settingsPanelMalayalam;

  /// No description provided for @settingsPanelImportFolder.
  ///
  /// In en, this message translates to:
  /// **'Import folder'**
  String get settingsPanelImportFolder;

  /// No description provided for @settingsPanelUseBuiltinVoice.
  ///
  /// In en, this message translates to:
  /// **'Use built-in voice'**
  String get settingsPanelUseBuiltinVoice;

  /// No description provided for @settingsPanelTestLanguage.
  ///
  /// In en, this message translates to:
  /// **'Test {language}'**
  String settingsPanelTestLanguage(String language);

  /// No description provided for @settingsPanelModelLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language for the imported offline model.'**
  String get settingsPanelModelLanguageDescription;

  /// No description provided for @settingsPanelVeryLow.
  ///
  /// In en, this message translates to:
  /// **'Very low'**
  String get settingsPanelVeryLow;

  /// No description provided for @settingsPanelLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get settingsPanelLow;

  /// No description provided for @settingsPanelMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get settingsPanelMedium;

  /// No description provided for @settingsPanelHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get settingsPanelHigh;

  /// No description provided for @settingsPanelVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high'**
  String get settingsPanelVeryHigh;

  /// No description provided for @settingsPanelKokoroEnglishVoice.
  ///
  /// In en, this message translates to:
  /// **'Kokoro English voice'**
  String get settingsPanelKokoroEnglishVoice;

  /// No description provided for @settingsPanelRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get settingsPanelRetry;

  /// No description provided for @settingsPanelDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get settingsPanelDownload;

  /// No description provided for @settingsPanelCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsPanelCancel;

  /// No description provided for @settingsPanelSoundRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get settingsPanelSoundRain;

  /// No description provided for @settingsPanelSoundWaterfall.
  ///
  /// In en, this message translates to:
  /// **'Waterfall'**
  String get settingsPanelSoundWaterfall;

  /// No description provided for @settingsPanelSoundFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get settingsPanelSoundFire;

  /// No description provided for @settingsPanelSoundStream.
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get settingsPanelSoundStream;

  /// No description provided for @settingsPanelNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get settingsPanelNone;

  /// No description provided for @settingsPanelAoedeVoice.
  ///
  /// In en, this message translates to:
  /// **'Aoede'**
  String get settingsPanelAoedeVoice;

  /// No description provided for @settingsPanelKoreVoice.
  ///
  /// In en, this message translates to:
  /// **'Kore'**
  String get settingsPanelKoreVoice;

  /// No description provided for @settingsPanelPuckVoice.
  ///
  /// In en, this message translates to:
  /// **'Puck'**
  String get settingsPanelPuckVoice;

  /// No description provided for @settingsPanelCharonVoice.
  ///
  /// In en, this message translates to:
  /// **'Charon'**
  String get settingsPanelCharonVoice;

  /// No description provided for @settingsPanelPiperMeeraVoice.
  ///
  /// In en, this message translates to:
  /// **'Meera'**
  String get settingsPanelPiperMeeraVoice;

  /// No description provided for @settingsPanelPiperArjunVoice.
  ///
  /// In en, this message translates to:
  /// **'Arjun'**
  String get settingsPanelPiperArjunVoice;

  /// No description provided for @settingsPanelPiperLessacVoice.
  ///
  /// In en, this message translates to:
  /// **'Lessac'**
  String get settingsPanelPiperLessacVoice;

  /// No description provided for @settingsPanelPiperRyanVoice.
  ///
  /// In en, this message translates to:
  /// **'Ryan'**
  String get settingsPanelPiperRyanVoice;

  /// No description provided for @settingsPanelKokoroBellaVoice.
  ///
  /// In en, this message translates to:
  /// **'Bella'**
  String get settingsPanelKokoroBellaVoice;

  /// No description provided for @settingsPanelKokoroAdamVoice.
  ///
  /// In en, this message translates to:
  /// **'Adam'**
  String get settingsPanelKokoroAdamVoice;

  /// No description provided for @settingsPanelKokoroEmmaVoice.
  ///
  /// In en, this message translates to:
  /// **'Emma'**
  String get settingsPanelKokoroEmmaVoice;

  /// No description provided for @settingsPanelKokoroGeorgeVoice.
  ///
  /// In en, this message translates to:
  /// **'George'**
  String get settingsPanelKokoroGeorgeVoice;

  /// No description provided for @settingsPanelKokoroMapleVoice.
  ///
  /// In en, this message translates to:
  /// **'Maple'**
  String get settingsPanelKokoroMapleVoice;

  /// No description provided for @settingsPanelKokoroSolVoice.
  ///
  /// In en, this message translates to:
  /// **'Sol'**
  String get settingsPanelKokoroSolVoice;

  /// No description provided for @settingsPanelKokoroValeVoice.
  ///
  /// In en, this message translates to:
  /// **'Vale'**
  String get settingsPanelKokoroValeVoice;

  /// No description provided for @settingsPanelMalayalamFemale.
  ///
  /// In en, this message translates to:
  /// **'Malayalam female voice'**
  String get settingsPanelMalayalamFemale;

  /// No description provided for @settingsPanelMalayalamMale.
  ///
  /// In en, this message translates to:
  /// **'Malayalam male voice'**
  String get settingsPanelMalayalamMale;

  /// No description provided for @settingsPanelMalayalamNative.
  ///
  /// In en, this message translates to:
  /// **'Malayalam voice'**
  String get settingsPanelMalayalamNative;

  /// No description provided for @settingsPanelFemale.
  ///
  /// In en, this message translates to:
  /// **'Female voice'**
  String get settingsPanelFemale;

  /// No description provided for @settingsPanelMale.
  ///
  /// In en, this message translates to:
  /// **'Male voice'**
  String get settingsPanelMale;

  /// No description provided for @settingsPanelIndianEnglish.
  ///
  /// In en, this message translates to:
  /// **'Indian English'**
  String get settingsPanelIndianEnglish;

  /// No description provided for @settingsPanelUsEnglish.
  ///
  /// In en, this message translates to:
  /// **'US English'**
  String get settingsPanelUsEnglish;

  /// No description provided for @settingsPanelUkEnglish.
  ///
  /// In en, this message translates to:
  /// **'UK English'**
  String get settingsPanelUkEnglish;

  /// No description provided for @settingsPanelSystemTtsOnly.
  ///
  /// In en, this message translates to:
  /// **'System TTS only'**
  String get settingsPanelSystemTtsOnly;

  /// No description provided for @settingsPanelSherpaOnly.
  ///
  /// In en, this message translates to:
  /// **'Sherpa-ONNX only'**
  String get settingsPanelSherpaOnly;

  /// No description provided for @settingsPanelAutoBestAvailable.
  ///
  /// In en, this message translates to:
  /// **'Automatic — best available'**
  String get settingsPanelAutoBestAvailable;

  /// No description provided for @settingsPanelGoogleSpeechServices.
  ///
  /// In en, this message translates to:
  /// **'Google Speech Services'**
  String get settingsPanelGoogleSpeechServices;

  /// No description provided for @settingsPanelSamsungTextToSpeech.
  ///
  /// In en, this message translates to:
  /// **'Samsung Text-to-Speech'**
  String get settingsPanelSamsungTextToSpeech;

  /// No description provided for @settingsPanelAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get settingsPanelAuto;

  /// No description provided for @settingsPanelRotateAllMalayalamVoices.
  ///
  /// In en, this message translates to:
  /// **'Rotate all Malayalam voices'**
  String get settingsPanelRotateAllMalayalamVoices;

  /// No description provided for @settingsPanelRotateVoicesDefault.
  ///
  /// In en, this message translates to:
  /// **'Rotate voices'**
  String get settingsPanelRotateVoicesDefault;

  /// No description provided for @settingsPanelAutoSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'Automatic (system default)'**
  String get settingsPanelAutoSystemDefault;

  /// No description provided for @settingsPanelUseDeviceDefaultEngine.
  ///
  /// In en, this message translates to:
  /// **'Use the device\'s default speech engine'**
  String get settingsPanelUseDeviceDefaultEngine;

  /// No description provided for @settingsPanelUseDeviceSpeechEngine.
  ///
  /// In en, this message translates to:
  /// **'Use only the device speech engine'**
  String get settingsPanelUseDeviceSpeechEngine;

  /// No description provided for @settingsPanelFallbackVoicePlatforms.
  ///
  /// In en, this message translates to:
  /// **'Use the built-in offline voice when available'**
  String get settingsPanelFallbackVoicePlatforms;

  /// No description provided for @settingsPanelAutoVoiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the best available voice automatically'**
  String get settingsPanelAutoVoiceDescription;

  /// No description provided for @settingsPanelManualMode.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get settingsPanelManualMode;

  /// No description provided for @settingsPanelSelectedQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Use the selected quiet hours'**
  String get settingsPanelSelectedQuietHours;

  /// No description provided for @settingsPanelAutomaticMode.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get settingsPanelAutomaticMode;

  /// No description provided for @settingsPanelMuteAfterNightIdle.
  ///
  /// In en, this message translates to:
  /// **'Mute after the device has been idle at night'**
  String get settingsPanelMuteAfterNightIdle;

  /// No description provided for @settingsPanelStandardMalayalam.
  ///
  /// In en, this message translates to:
  /// **'Standard Malayalam'**
  String get settingsPanelStandardMalayalam;

  /// No description provided for @settingsPanelAlternatesVoices.
  ///
  /// In en, this message translates to:
  /// **'Alternates between available voices'**
  String get settingsPanelAlternatesVoices;

  /// No description provided for @settingsPanelUnknownVoice.
  ///
  /// In en, this message translates to:
  /// **'Unknown voice'**
  String get settingsPanelUnknownVoice;

  /// No description provided for @settingsPanelDarkThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Use a dark appearance'**
  String get settingsPanelDarkThemeDescription;

  /// No description provided for @settingsPanelMasterAudio.
  ///
  /// In en, this message translates to:
  /// **'Master audio'**
  String get settingsPanelMasterAudio;

  /// No description provided for @settingsPanelAllAudioOn.
  ///
  /// In en, this message translates to:
  /// **'Speech and ambient audio are enabled'**
  String get settingsPanelAllAudioOn;

  /// No description provided for @settingsPanelAllAudioOff.
  ///
  /// In en, this message translates to:
  /// **'Speech and ambient audio are disabled'**
  String get settingsPanelAllAudioOff;

  /// No description provided for @settingsPanelGoalReminders.
  ///
  /// In en, this message translates to:
  /// **'Goal reminders'**
  String get settingsPanelGoalReminders;

  /// No description provided for @settingsPanelAddGoalToEnableReminders.
  ///
  /// In en, this message translates to:
  /// **'Add a goal to enable reminders'**
  String get settingsPanelAddGoalToEnableReminders;

  /// No description provided for @settingsPanelSpeakSavedGoalEvery.
  ///
  /// In en, this message translates to:
  /// **'Speak a saved goal every {minutes} minutes'**
  String settingsPanelSpeakSavedGoalEvery(int minutes);

  /// No description provided for @settingsPanelGoalReminderInterval.
  ///
  /// In en, this message translates to:
  /// **'Goal reminder interval'**
  String get settingsPanelGoalReminderInterval;

  /// No description provided for @settingsPanelAddGoal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get settingsPanelAddGoal;

  /// No description provided for @settingsPanelAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get settingsPanelAdd;

  /// No description provided for @settingsPanelNoGoalsSaved.
  ///
  /// In en, this message translates to:
  /// **'No goals saved'**
  String get settingsPanelNoGoalsSaved;

  /// No description provided for @settingsPanelRemoveGoal.
  ///
  /// In en, this message translates to:
  /// **'Remove goal'**
  String get settingsPanelRemoveGoal;

  /// No description provided for @settingsPanelNoiseVolume.
  ///
  /// In en, this message translates to:
  /// **'Noise volume'**
  String get settingsPanelNoiseVolume;

  /// No description provided for @settingsPanelSpeechVolume.
  ///
  /// In en, this message translates to:
  /// **'Speech volume'**
  String get settingsPanelSpeechVolume;

  /// No description provided for @settingsPanelBoostTtsVolume.
  ///
  /// In en, this message translates to:
  /// **'Boost speech volume'**
  String get settingsPanelBoostTtsVolume;

  /// No description provided for @settingsPanelMaximumSpeechVolumeDescription.
  ///
  /// In en, this message translates to:
  /// **'Raise speech output to the maximum available volume'**
  String get settingsPanelMaximumSpeechVolumeDescription;

  /// No description provided for @settingsPanelSpeechEngine.
  ///
  /// In en, this message translates to:
  /// **'Speech engine'**
  String get settingsPanelSpeechEngine;

  /// No description provided for @settingsPanelTestVoice.
  ///
  /// In en, this message translates to:
  /// **'Test voice'**
  String get settingsPanelTestVoice;

  /// No description provided for @settingsPanelPlaySample.
  ///
  /// In en, this message translates to:
  /// **'Play sample'**
  String get settingsPanelPlaySample;

  /// No description provided for @settingsPanelLanguageList.
  ///
  /// In en, this message translates to:
  /// **'Voice language list'**
  String get settingsPanelLanguageList;

  /// No description provided for @settingsPanelPreferredVoice.
  ///
  /// In en, this message translates to:
  /// **'Preferred voice'**
  String get settingsPanelPreferredVoice;

  /// No description provided for @settingsPanelVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get settingsPanelVoice;

  /// No description provided for @settingsPanelFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get settingsPanelFontSize;

  /// No description provided for @settingsPanelStartLandscape.
  ///
  /// In en, this message translates to:
  /// **'Start fullscreen in landscape'**
  String get settingsPanelStartLandscape;

  /// No description provided for @settingsPanelShowClockFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Show clock in fullscreen'**
  String get settingsPanelShowClockFullscreen;

  /// No description provided for @settingsPanelShowClockFullscreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Display the current time above the timer'**
  String get settingsPanelShowClockFullscreenDescription;

  /// No description provided for @settingsPanelFullscreenClockSize.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen clock size'**
  String get settingsPanelFullscreenClockSize;

  /// No description provided for @settingsPanelEnableSleepMode.
  ///
  /// In en, this message translates to:
  /// **'Enable sleep mode'**
  String get settingsPanelEnableSleepMode;

  /// No description provided for @settingsPanelQuietHoursSpeech.
  ///
  /// In en, this message translates to:
  /// **'Silence speech during quiet hours'**
  String get settingsPanelQuietHoursSpeech;

  /// No description provided for @settingsPanelMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get settingsPanelMode;

  /// No description provided for @settingsPanelSleepMode.
  ///
  /// In en, this message translates to:
  /// **'Sleep mode'**
  String get settingsPanelSleepMode;

  /// No description provided for @settingsPanelBackupAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Back up app settings'**
  String get settingsPanelBackupAppSettings;

  /// No description provided for @settingsPanelBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Export your settings to a file'**
  String get settingsPanelBackupDescription;

  /// No description provided for @settingsPanelRestoreAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Restore app settings'**
  String get settingsPanelRestoreAppSettings;

  /// No description provided for @settingsPanelRestoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Import settings from a backup file'**
  String get settingsPanelRestoreDescription;

  /// No description provided for @settingsPanelChooseBackupFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose backup folder'**
  String get settingsPanelChooseBackupFolder;

  /// No description provided for @helpPanelSleepModeOff.
  ///
  /// In en, this message translates to:
  /// **'Sleep mode is off'**
  String get helpPanelSleepModeOff;

  /// No description provided for @helpPanelSleepModeManual.
  ///
  /// In en, this message translates to:
  /// **'Manual quiet hours'**
  String get helpPanelSleepModeManual;

  /// No description provided for @helpPanelSleepModeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic night mode'**
  String get helpPanelSleepModeAutomatic;

  /// No description provided for @helpPanelCurrentRange.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours: {range}'**
  String helpPanelCurrentRange(String range);

  /// No description provided for @helpPanelQuickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick start'**
  String get helpPanelQuickStart;

  /// No description provided for @helpPanelConfigureTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure the timer'**
  String get helpPanelConfigureTimerTitle;

  /// No description provided for @helpPanelConfigureTimerDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a preset or set a custom duration on the Timer tab.'**
  String get helpPanelConfigureTimerDescription;

  /// No description provided for @helpPanelSetSleepTitle.
  ///
  /// In en, this message translates to:
  /// **'Set sleep hours'**
  String get helpPanelSetSleepTitle;

  /// No description provided for @helpPanelSetSleepDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable sleep mode and choose quiet hours to silence speech.'**
  String get helpPanelSetSleepDescription;

  /// No description provided for @helpPanelWidgetControlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Use the home screen widget'**
  String get helpPanelWidgetControlsTitle;

  /// No description provided for @helpPanelWidgetControlsDescription.
  ///
  /// In en, this message translates to:
  /// **'Start, pause, or reset the timer without opening the app.'**
  String get helpPanelWidgetControlsDescription;

  /// No description provided for @helpPanelFaq.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpPanelFaq;

  /// No description provided for @helpPanelSpeakingClockTitle.
  ///
  /// In en, this message translates to:
  /// **'Speaking clock'**
  String get helpPanelSpeakingClockTitle;

  /// No description provided for @helpPanelSpeakingClockAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Choose announcement intervals and enable speech in Settings.'**
  String get helpPanelSpeakingClockAnnouncements;

  /// No description provided for @helpPanelSpeakingClockQuotes.
  ///
  /// In en, this message translates to:
  /// **'Enable quotes and choose a category and delay.'**
  String get helpPanelSpeakingClockQuotes;

  /// No description provided for @helpPanelTimerSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer setup'**
  String get helpPanelTimerSetupTitle;

  /// No description provided for @helpPanelTimerSetupPreset.
  ///
  /// In en, this message translates to:
  /// **'Select a preset or set a custom timer duration.'**
  String get helpPanelTimerSetupPreset;

  /// No description provided for @helpPanelTimerSetupSpeech.
  ///
  /// In en, this message translates to:
  /// **'Enable speech announcements and adjust their interval.'**
  String get helpPanelTimerSetupSpeech;

  /// No description provided for @helpPanelTimerSetupChain.
  ///
  /// In en, this message translates to:
  /// **'Use chain mode to run a sequence of study and break timers.'**
  String get helpPanelTimerSetupChain;

  /// No description provided for @helpPanelSleepModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep mode'**
  String get helpPanelSleepModeTitle;

  /// No description provided for @helpPanelSleepModeRange.
  ///
  /// In en, this message translates to:
  /// **'Set the quiet-hours start and end times in Settings.'**
  String get helpPanelSleepModeRange;

  /// No description provided for @helpPanelSleepModeManualDescription.
  ///
  /// In en, this message translates to:
  /// **'Manual mode uses the times you selected.'**
  String get helpPanelSleepModeManualDescription;

  /// No description provided for @helpPanelSleepModeAutomaticDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatic mode detects nighttime device inactivity.'**
  String get helpPanelSleepModeAutomaticDescription;

  /// No description provided for @helpPanelSleepModeResumeDescription.
  ///
  /// In en, this message translates to:
  /// **'Speech resumes when quiet hours end.'**
  String get helpPanelSleepModeResumeDescription;

  /// No description provided for @helpPanelHomeWidgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Home screen widget'**
  String get helpPanelHomeWidgetTitle;

  /// No description provided for @helpPanelHomeWidgetSpeech.
  ///
  /// In en, this message translates to:
  /// **'The widget can speak timer status when speech is enabled.'**
  String get helpPanelHomeWidgetSpeech;

  /// No description provided for @helpPanelHomeWidgetTimer.
  ///
  /// In en, this message translates to:
  /// **'Use the widget controls to start, pause, or reset the timer.'**
  String get helpPanelHomeWidgetTimer;

  /// No description provided for @helpPanelHomeWidgetQuickSessions.
  ///
  /// In en, this message translates to:
  /// **'Quick-session buttons start common timer durations.'**
  String get helpPanelHomeWidgetQuickSessions;

  /// No description provided for @helpPanelHomeWidgetStatus.
  ///
  /// In en, this message translates to:
  /// **'Widget status reflects the current timer session.'**
  String get helpPanelHomeWidgetStatus;

  /// No description provided for @helpPanelTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get helpPanelTipsTitle;

  /// No description provided for @helpPanelTipsSync.
  ///
  /// In en, this message translates to:
  /// **'Settings are stored on this device.'**
  String get helpPanelTipsSync;

  /// No description provided for @helpPanelTipsPermissions.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications and background activity for reliable timer alerts.'**
  String get helpPanelTipsPermissions;

  /// No description provided for @helpPanelTipsBackground.
  ///
  /// In en, this message translates to:
  /// **'Keep the app allowed to run in the background for uninterrupted timing.'**
  String get helpPanelTipsBackground;

  /// No description provided for @settingsPanelGoalField.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get settingsPanelGoalField;

  /// No description provided for @settingsPanelDownloadNotDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Not downloaded · 140 MiB. English speech continues with Piper until then.'**
  String get settingsPanelDownloadNotDownloaded;

  /// No description provided for @settingsPanelDownloadingKokoro.
  ///
  /// In en, this message translates to:
  /// **'Downloading Kokoro English · {amount}'**
  String settingsPanelDownloadingKokoro(String amount);

  /// No description provided for @settingsPanelDownloadingKokoroPercent.
  ///
  /// In en, this message translates to:
  /// **'Downloading Kokoro English · {percent}% · {amount}'**
  String settingsPanelDownloadingKokoroPercent(int percent, String amount);

  /// No description provided for @settingsPanelDownloadVerifying.
  ///
  /// In en, this message translates to:
  /// **'Download complete · verifying SHA-256'**
  String get settingsPanelDownloadVerifying;

  /// No description provided for @settingsPanelDownloadInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing the offline English voice'**
  String get settingsPanelDownloadInstalling;

  /// No description provided for @settingsPanelDownloadReady.
  ///
  /// In en, this message translates to:
  /// **'Ready · Kokoro v1.1 English works offline'**
  String get settingsPanelDownloadReady;

  /// No description provided for @settingsPanelDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed · {error}'**
  String settingsPanelDownloadFailed(String error);

  /// No description provided for @settingsPanelDownloadFailedFallback.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and retry.'**
  String get settingsPanelDownloadFailedFallback;

  /// No description provided for @settingsPanelDownloadCancelled.
  ///
  /// In en, this message translates to:
  /// **'Download cancelled · the bundled Piper voice remains available.'**
  String get settingsPanelDownloadCancelled;

  /// No description provided for @mainDesktopTimerFinishedBody.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minute timer completed.'**
  String mainDesktopTimerFinishedBody(int minutes);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ml'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ml':
      return AppLocalizationsMl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
