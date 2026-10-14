// ============================================================================
// SOLASFLOW - A Productivity Timer & Meditation App
// ============================================================================
//
// **Version:** 1.0.0
// **Platform:** Android, iOS, Web, macOS, Linux, Windows
// **Target:** Dart ^3.11.3, Flutter stable
//
// ## Architecture Overview
//
// This is a feature-modular, service-oriented app for managing focused work
// sessions, clock displays, and motivational quotes. Clean architecture:
//
// - **UI Layer:** Screens & Widgets (main tabs: Timer, Clock, Settings, Presets)
// - **Service Layer:** Business logic (TimerService, SettingsService, etc.)
// - **Features:** Domain-specific modules (motivation/ feature)
// - **Models:** Data classes representing app state
// - **Theme:** Centralized Material 3 styling via palette.dart
//
// ## Key Features
//
// 1. Timer Management: Countdown with customizable presets & chain mode
// 2. Speech: TTS announcements with Malayalam support
// 3. Background Audio: Ambient sounds (rain, waterfall, fire, stream)
// 4. Foreground Service: Persistent notifications during long sessions
// 5. Motivational Quotes: Category-based rotating quotes for focus
// 6. Night Mode: Auto-mute speech after midnight with configurable window
// 7. Localization: Multi-language support (English, Malayalam)
// 8. Theme System: Light/dark mode toggle with Material 3 theming
// 9. Health Checks: Periodic service recovery to prevent OS kills
// 10. Settable Presets: Pomodoro, Sprint, and Quick session types
//
// ## Service Initialization Pattern
//
// Controllers are initialized lazily by `_MainScreenState` and own independent
// runtime/platform responsibilities:
// - TimerRuntimeController: countdown, stopwatch, persistence and sessions
// - SpeechAnnouncementController: speech queue, TTS and announcement timing
// - ForegroundNotificationController: Android service lifecycle and state
// - PlatformIntentController: quick actions, widget channel and task callbacks
//
// Shared services remain injected into their owning controllers and UI.
//
// ## Performance Optimizations
//
// - Display Ticker: 250ms frequency (up from 30ms) for reduced GPU pressure
// - Conditional setState(): Only rebuild if display actually changed
// - Idle Notification Throttle: 4:1 reduction in idle notification syncs
// - Lazy TTS initialization: Voices loaded only when needed
// - Health Check Interval: 30s periodic service recovery
//
// ## Future Roadmap
//
// - [ ] Custom preset creation UI
// - [ ] Session history & analytics
// - [ ] Haptic feedback on timer complete
// - [ ] Circular progress indicator widget
// - [ ] Cloud sync of settings & session history
// - [ ] Wear OS companion app
// - [ ] Export session data to Google Fit

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/persistence_error_reporter.dart';
import 'core/pref_keys.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';

import 'l10n/app_localizations.dart';
import 'models/app_settings.dart';
import 'models/speech_model_download_status.dart';
import 'models/timer_runtime.dart';
import 'models/sound_option.dart';
import 'services/audio_service.dart';
import 'services/desktop_service.dart';
import 'services/malayalam_tts_service.dart';
import 'services/settings_service.dart';
import 'services/speech_service.dart';
import 'services/timer_service.dart';
import 'services/timer_runtime_store.dart';
import 'services/timer_runtime_transitions.dart';
import 'controllers/timer_runtime_controller.dart';
import 'controllers/platform_intent_controller.dart';
import 'controllers/foreground_notification_controller.dart';
import 'controllers/speech_announcement_controller.dart';
import 'features/motivation/motivation_content.dart';
import 'features/motivation/services/quote_rotation_service.dart';
import 'widgets/clock_panel.dart';
import 'widgets/fullscreen_focus_view.dart';
import 'widgets/timer_panel.dart';
import 'widgets/drive_mode_view.dart';
import 'widgets/stopwatch_panel.dart';
import 'widgets/settings_panel.dart';
import 'widgets/help_panel.dart';
import 'widgets/bottom_nav_bar.dart';
import 'services/voice_session_manager.dart';
import 'services/speech_language_service.dart';
import 'services/session_log_service.dart';
import 'widgets/dashboard_screen.dart';
import 'widgets/kokoro_download_consent_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  try {
    final settings = await SettingsService().load(
      defaultSound: 'audio/rain.mp3',
    );
    SettingsNotifier.bootstrap(settings);
  } catch (error, stackTrace) {
    debugPrint('Settings bootstrap failed: $error\n$stackTrace');
    SettingsNotifier.bootstrap(AppSettings.defaults());
  }
  runApp(const ProviderScope(child: SolasFlowApp()));
}

class SolasFlowApp extends ConsumerWidget {
  const SolasFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      settingsProvider.select(
        (settings) => settings.appDarkTheme ? ThemeMode.dark : ThemeMode.light,
      ),
    );
    final fontSizeMultiplier = ref.watch(
      settingsProvider.select((settings) => settings.appFontSizeMultiplier),
    );

    return WithForegroundTask(
      child: Builder(
        builder: (context) {
          return MaterialApp(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            themeMode: themeMode,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(
                    mediaQuery.textScaler.scale(1) * fontSizeMultiplier,
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver
    implements
        PlatformIntentHost,
        TimerRuntimeControllerHost,
        ForegroundNotificationHost,
        SpeechAnnouncementHost {
  @override
  AppSettings get settings => _settings;

  @override
  TimerRuntime get timerRuntime => _timerRuntime;

  @override
  AppLifecycleState? get lifecycleState =>
      WidgetsBinding.instance.lifecycleState;

  @override
  bool get stopwatchRunning => stopwatchInterval != null;

  @override
  bool get desktopHidden => Platform.isLinux && _desktopService.hidden.value;

  @override
  void setSpeechActive(bool active) {
    if (mounted && isSpeechActive != active) {
      setState(() => isSpeechActive = active);
    }
  }

  @override
  void setVoices(List<Map<dynamic, dynamic>> value) {
    if (mounted) setState(() => voices = value);
  }

  @override
  void setGoalReminderNextIndex(int index) {
    goalReminderNextIndex = index;
  }

  @override
  void saveSettings() => _lsSave();

  @override
  void stopMobileRingtone() => _stopMobileRingtone();

  @override
  Future<void> updateSpeechMaster(bool enabled) async {
    await ref
        .read(settingsProvider.notifier)
        .update((settings) => settings.copyWith(speechMasterOn: enabled));
  }

  @override
  void notifyDesktop(String title, String message) {
    unawaited(_desktopService.notify(title, message));
  }

  @override
  void persistClockDeadline(DateTime? dueAt) => _persistClockDeadline(dueAt);

  @override
  void reconcileSpeechForeground() {
    unawaited(_reconcileForeground(force: true));
  }

  @override
  String nextQuoteForCategory(String category) =>
      _nextQuoteForCategory(category);

  @override
  bool get isMounted => mounted;

  @override
  Map<String, Object?> widgetState(String? armedAction) => {
    'clockOn': clockOn,
    'timerSpeakOn': timerSpeakOn,
    'stopwatchSpeakOn': stopwatchSpeakOn,
    'goalReminderOn': goalReminderOn,
    'speechMasterOn': speechMasterOn,
    'timerDisplay': timerDisplayValue,
    'armedAction': armedAction ?? '',
  };

  @override
  Future<void> handleQuickAction(String type) => _handleQuickAction(type);

  @override
  Future<void> handleWidgetAction(String type) => _performWidgetAction(type);

  @override
  Future<void> handleTaskData(Object data) => _handleTaskData(data);
  bool get _supportsForegroundTask =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Plays ambient background sounds (rain, waterfall, fire, stream)
  /// Handles volume and audio session management
  final AudioService _audioService = AudioService();
  final DesktopService _desktopService = DesktopService();

  /// Loads/saves AppSettings from SharedPreferences with versioned migrations
  /// Ensures data compatibility across app versions
  final SettingsService _settingsService = SettingsService();

  /// Queues TTS (text-to-speech) and ringtone announcements
  /// Ensures speech items play sequentially (no overlaps)
  final SpeechService _speechService = SpeechService();

  /// Handles Malayalam-specific TTS voice selection and synthesis
  /// Provides fallback to English if Malayalam unavailable
  final MalayalamTtsService _malayalamTtsService = MalayalamTtsService();

  /// Singleton voice session manager for consistent language selection
  final VoiceSessionManager _voiceSessionManager = VoiceSessionManager();
  final SpeechLanguageService _speechLanguageService = SpeechLanguageService();

  /// Manages timer countdown logic: starts, pauses, resumes, calculates display
  /// Handles announcement timings based on user preferences
  final TimerService _timerService = TimerService();
  late MaterialLocalizations _materialLocalizations;
  late AppLocalizations _appLocalizations;
  bool _platformResourcesInitialized = false;
  int _lastPersistenceFailureSequence = 0;

  /// Cycles through motivational quotes by category
  /// Encapsulates quote rotation state and list management
  final QuoteRotationService _quoteRotationService = QuoteRotationService();

  /// Session log service for study/non-study tagging
  final SessionLogService _sessionLogService = SessionLogService();
  final TimerRuntimeStore _timerRuntimeStore = TimerRuntimeStore();
  late final TimerRuntimeController _timerRuntimeController =
      TimerRuntimeController(
        host: this,
        runtimeStore: _timerRuntimeStore,
        sessionLogService: _sessionLogService,
        timerService: _timerService,
      );
  late final PlatformIntentController _platformIntentController =
      PlatformIntentController(this);
  late final SpeechAnnouncementController _speechAnnouncementController =
      SpeechAnnouncementController(
        host: this,
        speechService: _speechService,
        audioService: _audioService,
        voiceSessionManager: _voiceSessionManager,
        speechLanguageService: _speechLanguageService,
        malayalamTtsService: _malayalamTtsService,
        timerService: _timerService,
      );
  bool _exiting = false;
  bool _driveModeOpen = false;
  bool _dismissFocusAfterFinishedDialog = false;

  /// Today's summary display string for the timer panel
  String _todaySummary = '';
  DateTime _todaySummaryDate = DateTime.now();

  late final ForegroundNotificationController
  _foregroundNotificationController = ForegroundNotificationController(
    host: this,
  );

  /// ============================================================================
  /// TTS & SPEECH STATE - Text-to-speech management
  /// ============================================================================
  /// Manages voice synthesis, queue management, and concurrent speech exclusion

  bool isSpeechActive = false;

  FlutterTts get flutterTts => _speechAnnouncementController.flutterTts;
  List<Map<dynamic, dynamic>> get voices =>
      _speechAnnouncementController.voices;
  set voices(List<Map<dynamic, dynamic>> value) =>
      _speechAnnouncementController.voices = value;
  ValueNotifier<List<Map<dynamic, dynamic>>> get _settingsVoices =>
      _speechAnnouncementController.settingsVoices;
  bool get autoNightMuteActive =>
      _speechAnnouncementController.autoNightMuteActive;
  set autoNightMuteActive(bool value) =>
      _speechAnnouncementController.autoNightMuteActive = value;
  Timer? get nightResumeSpeechTimer =>
      _speechAnnouncementController.nightResumeSpeechTimer;

  /// ============================================================================
  /// TIMER STATE - Timer display & countdown management
  /// ============================================================================
  /// Tracks timer value, intervals, and completion status

  /// Slider input value (0-120 minutes) from timer UI
  int sliderValue = 25;

  int get seconds => _timerRuntimeController.seconds;
  TimerRuntime get _timerRuntime => _timerRuntimeController.timerRuntime;
  Timer? get timerInterval => _timerRuntimeController.timerTicker;

  /// Two-tap confirmation state: the preset value currently awaiting
  /// a second tap before the timer starts.  Null = no button armed.
  int? _armedPresetValue;

  /// 3-second auto-clear timer for the armed preset state.
  Timer? _armedPresetTimer;

  String get timerDisplayValue {
    final now = DateTime.now();
    final remainingMilliseconds =
        _timerRuntime.status == TimerRuntimeStatus.running
        ? _timerRuntime.remainingMillisecondsAt(now)
        : seconds * 1000;
    return _formatTimerDisplayValue(
      seconds,
      remainingMilliseconds: remainingMilliseconds,
    );
  }

  /// ============================================================================
  /// CLOCK STATE - Clock display & periodic announcements
  /// ============================================================================
  /// Manages clock time display and interval-based time announcements

  /// Display ticker: updates UI at 250ms intervals (reduced from 30ms for performance)
  Timer? displayTick;

  /// Current time formatted for display (HH:MM or HH:MM:SS)
  String currentTimeDisplay = "";

  /// Currently active tab index (0=SpeakClock, 1=Timer Setup, 2=Stopwatch, 3=Goals, 4=Settings)
  int currentTabIndex = 1;

  /// ============================================================================
  /// ANNOUNCEMENT TIMING - 10-second gap enforcement between speech segments
  /// ============================================================================
  /// Prevents rapid repeated announcements from overlapping

  /// Stopwatch ticker interval
  Timer? get stopwatchInterval => _timerRuntimeController.stopwatchTicker;
  StopwatchRuntime get _stopwatchRuntime =>
      _timerRuntimeController.stopwatchRuntime;

  int get stopwatchElapsedSeconds =>
      _timerRuntimeController.stopwatchElapsedSeconds;

  String get stopwatchElapsedValue => _formatStopwatchElapsed(
    stopwatchElapsedSeconds,
    showMilliseconds: stopwatchShowMilliseconds,
  );

  AppSettings get _settings => ref.read(settingsProvider);

  void _updateSettings(AppSettings Function(AppSettings current) transform) {
    unawaited(ref.read(settingsProvider.notifier).update(transform));
  }

  @override
  bool get stopwatchSpeakOn => _settings.stopwatchSpeakOn;
  set stopwatchSpeakOn(bool value) =>
      _updateSettings((settings) => settings.copyWith(stopwatchSpeakOn: value));
  bool get timerShowMilliseconds => _settings.timerShowMilliseconds;
  set timerShowMilliseconds(bool value) => _updateSettings(
    (settings) => settings.copyWith(timerShowMilliseconds: value),
  );
  @override
  bool get stopwatchShowMilliseconds => _settings.stopwatchShowMilliseconds;
  set stopwatchShowMilliseconds(bool value) => _updateSettings(
    (settings) => settings.copyWith(stopwatchShowMilliseconds: value),
  );
  @override
  int get stopwatchSpeakDelaySeconds => _settings.stopwatchSpeakDelaySeconds;
  set stopwatchSpeakDelaySeconds(int value) => _updateSettings(
    (settings) => settings.copyWith(stopwatchSpeakDelaySeconds: value),
  );
  String get soundChosen => _settings.soundChosen;
  set soundChosen(String value) =>
      _updateSettings((settings) => settings.copyWith(soundChosen: value));
  double get noiseVolume => _settings.noiseVolume;
  set noiseVolume(double value) =>
      _updateSettings((settings) => settings.copyWith(noiseVolume: value));
  double get speakVolume => _settings.speakVolume;
  set speakVolume(double value) =>
      _updateSettings((settings) => settings.copyWith(speakVolume: value));
  bool get maximumSpeechVolume => _settings.maximumSpeechVolume;
  set maximumSpeechVolume(bool value) => _updateSettings(
    (settings) => settings.copyWith(maximumSpeechVolume: value),
  );
  bool get speechMasterOn => _settings.speechMasterOn;
  set speechMasterOn(bool value) =>
      _updateSettings((settings) => settings.copyWith(speechMasterOn: value));
  bool get clockOn => _settings.clockOn;
  set clockOn(bool value) =>
      _updateSettings((settings) => settings.copyWith(clockOn: value));
  int get clockIntervalMins => _settings.clockIntervalMins;
  set clockIntervalMins(int value) => _updateSettings(
    (settings) => settings.copyWith(clockIntervalMins: value),
  );
  bool get clockShowMilliseconds => _settings.clockShowMilliseconds;
  set clockShowMilliseconds(bool value) => _updateSettings(
    (settings) => settings.copyWith(clockShowMilliseconds: value),
  );
  bool get clockShowSeconds => _settings.clockShowSeconds;
  set clockShowSeconds(bool value) =>
      _updateSettings((settings) => settings.copyWith(clockShowSeconds: value));
  bool get clockSpeakTime => _settings.clockSpeakTime;
  set clockSpeakTime(bool value) =>
      _updateSettings((settings) => settings.copyWith(clockSpeakTime: value));
  int get clockSpeakRepeatCount => _settings.clockSpeakRepeatCount;
  set clockSpeakRepeatCount(int value) => _updateSettings(
    (settings) => settings.copyWith(clockSpeakRepeatCount: value),
  );
  bool get clockNoiseOn => _settings.clockNoiseOn;
  set clockNoiseOn(bool value) =>
      _updateSettings((settings) => settings.copyWith(clockNoiseOn: value));
  bool get motivationOn => _settings.motivationOn;
  set motivationOn(bool value) =>
      _updateSettings((settings) => settings.copyWith(motivationOn: value));
  String get motivationCategory => _settings.motivationCategory;
  set motivationCategory(String value) => _updateSettings(
    (settings) => settings.copyWith(motivationCategory: value),
  );
  int get motivationDelaySeconds => _settings.motivationDelaySeconds;
  set motivationDelaySeconds(int value) => _updateSettings(
    (settings) => settings.copyWith(motivationDelaySeconds: value),
  );
  bool get timerNoiseOn => _settings.timerNoiseOn;
  set timerNoiseOn(bool value) =>
      _updateSettings((settings) => settings.copyWith(timerNoiseOn: value));
  bool get goalReminderOn => _settings.goalReminderOn;
  set goalReminderOn(bool value) =>
      _updateSettings((settings) => settings.copyWith(goalReminderOn: value));
  int get goalReminderIntervalMins => _settings.goalReminderIntervalMins;
  set goalReminderIntervalMins(int value) => _updateSettings(
    (settings) => settings.copyWith(goalReminderIntervalMins: value),
  );
  List<String> get goalReminderItems => _settings.goalReminderItems;
  set goalReminderItems(List<String> value) => _updateSettings(
    (settings) => settings.copyWith(goalReminderItems: value),
  );
  @override
  int get goalReminderNextIndex => _settings.goalReminderNextIndex;
  set goalReminderNextIndex(int value) => _updateSettings(
    (settings) => settings.copyWith(goalReminderNextIndex: value),
  );
  bool get appDarkTheme => _settings.appDarkTheme;
  set appDarkTheme(bool value) =>
      _updateSettings((settings) => settings.copyWith(appDarkTheme: value));
  bool get muteSpeechAfterMidnight => _settings.muteSpeechAfterMidnight;
  set muteSpeechAfterMidnight(bool value) => _updateSettings(
    (settings) => settings.copyWith(muteSpeechAfterMidnight: value),
  );
  String get nightMuteMode => _settings.nightMuteMode;
  set nightMuteMode(String value) =>
      _updateSettings((settings) => settings.copyWith(nightMuteMode: value));
  int get sleepStartMinutes => _settings.sleepStartMinutes;
  set sleepStartMinutes(int value) => _updateSettings(
    (settings) => settings.copyWith(sleepStartMinutes: value),
  );
  int get sleepEndMinutes => _settings.sleepEndMinutes;
  set sleepEndMinutes(int value) =>
      _updateSettings((settings) => settings.copyWith(sleepEndMinutes: value));
  bool get fullscreenDarkTheme => _settings.fullscreenDarkTheme;
  set fullscreenDarkTheme(bool value) => _updateSettings(
    (settings) => settings.copyWith(fullscreenDarkTheme: value),
  );
  bool get fullscreenDimBrightness => _settings.fullscreenDimBrightness;
  set fullscreenDimBrightness(bool value) => _updateSettings(
    (settings) => settings.copyWith(fullscreenDimBrightness: value),
  );
  bool get fullscreenStartLandscape => _settings.fullscreenStartLandscape;
  set fullscreenStartLandscape(bool value) => _updateSettings(
    (settings) => settings.copyWith(fullscreenStartLandscape: value),
  );
  bool get fullscreenShowClock => _settings.fullscreenShowClock;
  set fullscreenShowClock(bool value) => _updateSettings(
    (settings) => settings.copyWith(fullscreenShowClock: value),
  );
  double get fullscreenClockScale => _settings.fullscreenClockScale;
  set fullscreenClockScale(double value) => _updateSettings(
    (settings) => settings.copyWith(fullscreenClockScale: value),
  );
  @override
  bool get backgroundPersistenceOn => _settings.backgroundPersistenceOn;
  set backgroundPersistenceOn(bool value) => _updateSettings(
    (settings) => settings.copyWith(backgroundPersistenceOn: value),
  );
  @override
  bool get taggingOn => _settings.taggingOn;
  set taggingOn(bool value) {
    _timerRuntimeController.taggingChanged(
      enabled: value,
      wasEnabled: taggingOn,
    );
    _updateSettings((settings) => settings.copyWith(taggingOn: value));
  }

  @override
  String get sessionTag => _settings.sessionTag;
  set sessionTag(String value) =>
      _updateSettings((settings) => settings.copyWith(sessionTag: value));
  double get fullscreenDimBrightnessLevel =>
      _settings.fullscreenDimBrightnessLevel;
  set fullscreenDimBrightnessLevel(double value) => _updateSettings(
    (settings) => settings.copyWith(fullscreenDimBrightnessLevel: value),
  );
  @override
  bool get timerSpeakOn => _settings.timerSpeakOn;
  set timerSpeakOn(bool value) =>
      _updateSettings((settings) => settings.copyWith(timerSpeakOn: value));
  @override
  int get timerAnnounceEvery => _settings.timerAnnounceEvery;
  set timerAnnounceEvery(int value) => _updateSettings(
    (settings) => settings.copyWith(timerAnnounceEvery: value),
  );
  String get voiceListMode => _settings.voiceListMode;
  set voiceListMode(String value) =>
      _updateSettings((settings) => settings.copyWith(voiceListMode: value));
  String get speechEngineMode => _settings.speechEngineMode;
  set speechEngineMode(String value) =>
      _updateSettings((settings) => settings.copyWith(speechEngineMode: value));
  String? get favoriteVoiceName => _settings.favoriteVoiceName;
  set favoriteVoiceName(String? value) => _updateSettings(
    (settings) => settings.copyWith(favoriteVoiceName: () => value),
  );
  String? get favoriteVoiceLocale => _settings.favoriteVoiceLocale;
  set favoriteVoiceLocale(String? value) => _updateSettings(
    (settings) => settings.copyWith(favoriteVoiceLocale: () => value),
  );
  double get appFontSizeMultiplier => _settings.appFontSizeMultiplier;
  set appFontSizeMultiplier(double value) => _updateSettings(
    (settings) => settings.copyWith(appFontSizeMultiplier: value),
  );

  List<String> _installedEngines = [];

  @override
  bool get chainModeOn => _settings.chainModeOn;
  set chainModeOn(bool value) {
    if (value == _settings.chainModeOn) return;
    _updateSettings((settings) => settings.copyWith(chainModeOn: value));
  }

  @override
  String get chainPresetKey => _settings.chainPresetKey;
  set chainPresetKey(String value) {
    if (value == _settings.chainPresetKey) return;
    _updateSettings((settings) => settings.copyWith(chainPresetKey: value));
  }

  int get chainIndex => _timerRuntimeController.chainIndex;
  set chainIndex(int value) => _timerRuntimeController.chainIndex = value;

  int get _activeTimerDurationSeconds =>
      _timerRuntimeController.activeTimerDurationSeconds;

  int get _lastFinishedTimerDurationSeconds =>
      _timerRuntimeController.lastFinishedTimerDurationSeconds;

  /// True while the focus fullscreen route is on top.
  bool _fullscreenFocusOpen = false;
  final ValueNotifier<FullscreenFocusMode> _fullscreenFocusMode = ValueNotifier(
    FullscreenFocusMode.clock,
  );

  /// True when the timer has finished but the dialog hasn't been
  /// dismissed yet.  Used by the foreground notification to show
  /// "Timer finished!" with action buttons.
  bool _isTimerFinished = false;

  /// Presets shown in the timer-finished popup.
  final List<int> _timerFinishedPresetMinutes = [
    1,
    2,
    3,
    5,
    10,
    15,
    20,
    25,
    30,
    35,
    40,
    45,
    50,
    60,
    75,
    90,
    120,
  ];

  /// ============================================================================
  /// PRESET CONFIGURATIONS - Predefined timer sequences & options
  /// ============================================================================
  /// These define user-selectable options for different timer modes

  /// Named chains of timer durations (in minutes) to run consecutively.
  final Map<String, List<int>> chainPresets = timerChainSequences;

  /// Sound file path for timer completion notification
  final String notifySound = "audio/notify.mp3";

  /// Available ambient background sounds with user-friendly names
  final List<SoundOption> soundList = [
    SoundOption(AppSettings.rainSound, "Rain"),
    SoundOption(AppSettings.waterfallSound, "Waterfall"),
    SoundOption(AppSettings.fireSound, "Fire"),
    SoundOption(AppSettings.streamSound, "Stream"),
  ];

  /// Available volume levels (0.0-1.0) for numerical selection
  final List<double> volumeLists = AppSettings.volumeOptions;

  /// Quick preset timer values (in minutes) for rapid timer setup
  final List<int> presetValues = [
    1,
    2,
    5,
    10,
    15,
    20,
    25,
    30,
    45,
    60,
    3,
    7,
    12,
    35,
    90,
  ];

  /// Available clock announcement intervals (in minutes)
  final List<int> clockIntervalOptions = AppSettings.clockIntervalOptions;

  /// Allowed repetitions for each clock speech announcement
  final List<int> clockSpeakRepeatOptions = AppSettings.clockSpeakRepeatOptions;

  /// Timer announcement frequency options (announce every N minutes)
  final List<int> timerAnnounceOptions = AppSettings.timerAnnounceOptions;

  /// Stopwatch speech delay options (in seconds)
  final List<int> stopwatchSpeakDelayOptions =
      AppSettings.stopwatchSpeakDelayOptions;

  /// Delay options between motivational quote announcements (in seconds)
  final List<int> motivationDelayOptions = AppSettings.motivationDelayOptions;

  /// Goal reminder interval options in minutes
  final List<int> goalReminderIntervalOptions =
      AppSettings.goalReminderIntervalOptions;

  /// SharedPreferences key for last timer seconds via quick action
  static const String _lastTimerSecondsKey = 'QuickActionLastSeconds';

  // Flag to avoid asking for battery optimization multiple times
  static const String _batteryOptimizationAskedKey = 'BatteryOptAsked';

  Future<void> _requestPermissions() async {
    if (!_supportsForegroundTask) return;
    final prefs = await SharedPreferences.getInstance();
    final bool hasAskedBattery =
        prefs.getBool(_batteryOptimizationAskedKey) ?? false;

    if (!hasAskedBattery &&
        await FlutterForegroundTask.isIgnoringBatteryOptimizations == false) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      await prefs.setBool(_batteryOptimizationAskedKey, true);
    }
    final NotificationPermission status =
        await FlutterForegroundTask.checkNotificationPermission();
    if (status != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  void _initForegroundTask() {
    final localizations = AppLocalizations.of(context)!;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'com.atherpulse.solasflow.timer_fg',
        channelName: localizations.timerForegroundChannelName,
        channelDescription: localizations.timerForegroundChannelDescription,
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
        allowAutoRestart: true,
        stopWithTask: false,
      ),
    );
  }

  String _formatCurrentTime(DateTime now) {
    final formattedTime = _materialLocalizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(now),
    );
    final parts = formattedTime.split(' ');
    final hourMinute = parts.first;
    final suffix = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    if (!clockShowSeconds) {
      return suffix.isEmpty ? hourMinute : '$hourMinute $suffix';
    }

    final seconds = now.second.toString().padLeft(2, '0');
    var time = '$hourMinute:$seconds';
    if (clockShowMilliseconds) {
      time += '.${now.millisecond.toString().padLeft(3, '0')}';
    }
    return suffix.isEmpty ? time : '$time $suffix';
  }

  @override
  bool get foregroundTimerRunning => timerInterval != null;
  @override
  bool get foregroundStopwatchRunning => stopwatchInterval != null;
  @override
  bool get foregroundClockRunning => clockOn;
  @override
  bool get foregroundBackgroundPersistence => backgroundPersistenceOn;
  @override
  bool get foregroundTimerFinished => _isTimerFinished;
  @override
  String get foregroundTimerValue => timerDisplayValue;
  @override
  String get foregroundStopwatchValue => stopwatchElapsedValue;
  @override
  String get foregroundCurrentTime => currentTimeDisplay;
  @override
  bool get foregroundSpeechMasterOn => speechMasterOn;

  @override
  AppLocalizations get appLocalizations => _appLocalizations;

  @override
  Future<void> requestForegroundPermissions() => _requestPermissions();

  @override
  void onForegroundNotificationError(Object error) {
    debugPrint('Foreground state not applied: $error');
  }

  Future<void> _reconcileForeground({bool force = false}) =>
      _foregroundNotificationController.reconcile(force: force);

  Future<void> _syncForegroundNotification({bool force = false}) =>
      _reconcileForeground(force: force);

  Future<void> _initializeForegroundNotification() =>
      _foregroundNotificationController.initialize();

  Future<void> _stopForegroundService() =>
      _foregroundNotificationController.stop();

  void _startForegroundHealthCheck() =>
      _foregroundNotificationController.startHealthCheck();

  Future<void> _saveLastTimerSeconds(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastTimerSecondsKey, value);
  }

  String _formatMinutesAsTime(BuildContext context, int totalMinutes) {
    final normalized = totalMinutes % (24 * 60);
    final time = TimeOfDay(hour: normalized ~/ 60, minute: normalized % 60);
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  Future<void> _pickSleepStartTime() async {
    final initial = TimeOfDay(
      hour: sleepStartMinutes ~/ 60,
      minute: sleepStartMinutes % 60,
    );
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected == null) return;

    setState(() {
      sleepStartMinutes = selected.hour * 60 + selected.minute;
      _lsSave();
    });
    _refreshNightMuteSchedule();
  }

  Future<void> _pickSleepEndTime() async {
    final initial = TimeOfDay(
      hour: sleepEndMinutes ~/ 60,
      minute: sleepEndMinutes % 60,
    );
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected == null) return;

    setState(() {
      sleepEndMinutes = selected.hour * 60 + selected.minute;
      _lsSave();
    });
    _refreshNightMuteSchedule();
  }

  Future<int> _readLastTimerSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastTimerSecondsKey) ?? (sliderValue * 60);
  }

  Future<void> _handleQuickAction(String type) async {
    if (!mounted) return;
    switch (type) {
      case 'start_25m':
        setState(() => currentTabIndex = 1);
        _startTimerFromMinutes(25);
        break;
      case 'resume_last':
        final last = await _readLastTimerSeconds();
        if (!mounted) return;
        setState(() => currentTabIndex = 1);
        startTimer(initialDurationSeconds: last);
        break;
      case 'toggle_speech':
        await _setSpeechMaster(!speechMasterOn);
        break;
      case 'toggle_speech_master':
        await _setSpeechMaster(!speechMasterOn);
        break;
    }
  }

  void _initQuickActions() {
    _platformIntentController.initializeQuickActions(_appLocalizations);
    _startForegroundHealthCheck();
  }

  Future<void> _changeSpeechEngineMode(String mode) async {
    setState(() {
      speechEngineMode = mode;
      _lsSave();
    });
    try {
      if (Platform.isAndroid &&
          mode != 'auto' &&
          mode != 'sherpa_only' &&
          mode != 'system_only') {
        await _speechService.setSpeechEngine(
          flutterTts: flutterTts,
          engine: mode,
        );
      }
      await _initTts(forceRebind: true);
    } catch (error, stackTrace) {
      debugPrint('[ERROR] Speech engine change failed: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _appLocalizations.mainSpeechEngineChangeFailed(error.toString()),
            ),
          ),
        );
      }
    }
  }

  void _openSettings() => unawaited(_openSettingsRoute());

  Future<void> _openSettingsRoute() async {
    try {
      if (Platform.isAndroid && _installedEngines.isEmpty) {
        _installedEngines = await _speechService.getInstalledEngines(
          flutterTts,
        );
      }
    } catch (error, stackTrace) {
      debugPrint(
        '[ERROR] Unable to load Settings voice engines; opening Settings '
        'without engine choices: $error\n$stackTrace',
      );
    }
    if (!mounted) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) => SettingsPanel(
          onAppDarkThemeChanged: (val) {
            if (val == null || val == appDarkTheme) return;
            setState(() {
              appDarkTheme = val;
              _lsSave();
            });
            debugPrint('[UI] App dark theme enabled=$val');
          },
          onAppFontSizeMultiplierChanged: (val) {
            if (val != null) {
              setState(() {
                appFontSizeMultiplier = val;
                _lsSave();
              });
            }
          },
          onFullscreenClockScaleChanged: (val) {
            if (val == null) return;
            setState(() {
              fullscreenClockScale = val;
              _lsSave();
            });
          },
          onFullscreenShowClockChanged: (val) {
            setState(() {
              fullscreenShowClock = val ?? false;
              _lsSave();
            });
          },
          sleepStartLabel: _formatMinutesAsTime(
            context,
            ref.read(settingsProvider).sleepStartMinutes,
          ),
          sleepEndLabel: _formatMinutesAsTime(
            context,
            ref.read(settingsProvider).sleepEndMinutes,
          ),
          soundList: soundList,
          volumeLists: volumeLists,
          goalReminderIntervalOptions: goalReminderIntervalOptions,
          speechEngineRuntime: _speechService.engineUsed,
          speechEngineRuntimeDetail: _speechService.engineDetail,
          showEnglishVoiceDownload: Platform.isLinux,
          speechModelDownloadStatus: _speechService.kokoroDownloadStatus,
          onDownloadEnglishVoice: _downloadKokoroVoiceFromSettings,
          onCancelEnglishVoiceDownload: () =>
              unawaited(_speechService.cancelKokoroVoiceDownload()),
          customModelStatus: _speechService.customModelStatus,
          onImportDesktopModel: (directory, language) =>
              _speechService.importDesktopModel(directory, language: language),
          onClearDesktopModel: (language) =>
              _speechService.clearDesktopModel(language),
          onTestSpeech: _testSpeech,
          voices: _settingsVoices,
          availableEngines: _installedEngines,
          onSoundChanged: (val) {
            setState(() {
              soundChosen = val!;
              _lsSave();
              _applyAudioSettings();
            });
          },
          onNoiseVolumeChanged: (val) {
            setState(() {
              noiseVolume = val!;
              _lsSave();
              _applyAudioSettings();
            });
          },
          onSpeakVolumeChanged: (val) {
            setState(() {
              speakVolume = val!;
              _lsSave();
            });
          },
          onMaximumSpeechVolumeChanged: (val) {
            setState(() {
              maximumSpeechVolume = val ?? false;
              _lsSave();
            });
          },
          onSpeechMasterOnChanged: (val) {
            unawaited(_setSpeechMaster(val ?? true));
          },
          onGoalReminderOnChanged: (value) {
            final enabled = value ?? false;
            if (enabled && goalReminderItems.isEmpty) return;
            if (enabled == goalReminderOn) return;
            setState(() {
              goalReminderOn = enabled;
              _lsSave();
            });
            _restartGoalReminderTimer();
          },
          onGoalReminderIntervalChanged: (value) {
            if (value == null || value == goalReminderIntervalMins) return;
            setState(() {
              goalReminderIntervalMins = value;
              _lsSave();
            });
            _restartGoalReminderTimer();
          },
          onGoalReminderItemsChanged: (items) {
            setState(() {
              goalReminderItems = items;
              if (items.isEmpty) goalReminderOn = false;
              _lsSave();
            });
            _restartGoalReminderTimer();
          },
          onFullscreenDarkThemeChanged: (val) {
            setState(() {
              fullscreenDarkTheme = val ?? true;
              _lsSave();
            });
          },
          onFullscreenDimBrightnessChanged: (val) {
            setState(() {
              fullscreenDimBrightness = val ?? false;
              _lsSave();
            });
          },
          onFullscreenDimBrightnessLevelChanged: (val) {
            setState(() {
              fullscreenDimBrightnessLevel = val ?? 0.08;
              _lsSave();
            });
          },
          onFullscreenStartLandscapeChanged: (val) {
            setState(() {
              fullscreenStartLandscape = val ?? false;
              _lsSave();
            });
          },
          onMuteSpeechAfterMidnightChanged: (val) {
            setState(() {
              muteSpeechAfterMidnight = val ?? false;
              if (!muteSpeechAfterMidnight) {
                autoNightMuteActive = false;
                _cancelNightIdleTimer();
                nightResumeSpeechTimer?.cancel();
              } else if (nightMuteMode == 'automatic') {
                _startNightIdleTimerIfNeeded();
              }
              _lsSave();
            });
            if (_isAudioMuted()) {
              _stopAudioForMute();
            } else {
              _applyAudioSettings();
            }
          },
          onNightMuteModeChanged: (val) {
            if (val == null) return;
            setState(() {
              nightMuteMode = val;
              if (nightMuteMode == 'manual') {
                autoNightMuteActive = false;
                _cancelNightIdleTimer();
                nightResumeSpeechTimer?.cancel();
              } else if (muteSpeechAfterMidnight) {
                autoNightMuteActive = false;
                _startNightIdleTimerIfNeeded();
              }
              _lsSave();
            });
            if (_isAudioMuted()) {
              _stopAudioForMute();
            } else {
              _applyAudioSettings();
            }
          },
          onPickSleepStart: () => unawaited(_pickSleepStartTime()),
          onPickSleepEnd: () => unawaited(_pickSleepEndTime()),
          onVoiceListModeChanged: (val) {
            debugPrint('[SettingsPanel] onVoiceListModeChanged val=$val');
            if (val == null) return;
            _voiceSessionManager.resetSession();
            _cancelPendingSpeech();
            setState(() {
              final normalized = _speechService.normalizeVoiceLanguageMode(val);
              debugPrint('[SettingsPanel] normalized language=$normalized');
              voiceListMode = normalized;
              _speechLanguageService.setLanguage(normalized);
              final available = _availableVoicesForSettings();
              final hasFavorite = available.any(
                (voice) =>
                    voice['name']?.toString() == favoriteVoiceName &&
                    voice['locale']?.toString() == favoriteVoiceLocale,
              );
              if (favoriteVoiceName != '__rotate__' && !hasFavorite) {
                favoriteVoiceName = null;
                favoriteVoiceLocale = null;
              }
              _voiceSessionManager.resetSession();
              _lsSave();
            });
            if (speechMasterOn) _applyAudioSettings();
          },
          onSpeechEngineModeChanged: (val) {
            if (val != null) unawaited(_changeSpeechEngineMode(val));
          },
          onFavoriteVoiceChanged: (val) {
            debugPrint('[SettingsPanel] onFavoriteVoiceChanged val=$val');
            _cancelPendingSpeech();
            setState(() {
              if (val == null || val == '__auto__') {
                favoriteVoiceName = null;
                favoriteVoiceLocale = null;
              } else if (val == '__rotate__') {
                favoriteVoiceName = '__rotate__';
                favoriteVoiceLocale = null;
              } else {
                final parts = val.split('|');
                if (parts.length == 2) {
                  favoriteVoiceName = parts[0];
                  favoriteVoiceLocale = parts[1];
                }
              }
              _voiceSessionManager.resetSession();
              _lsSave();
            });
          },
          onOpenHelp: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => _buildHelpTab()));
          },
          onBackupSettings: () => unawaited(_handleBackupSettings()),
          onRestoreSettings: () => unawaited(_handleRestoreSettings()),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _handleBackupSettings() async {
    if (!mounted) return;
    String? backupJson;
    try {
      final jsonStr = await _settingsService.exportToJson(
        defaultSound: soundList.first.link,
      );
      backupJson = jsonStr;
      final filePath = await _settingsService.exportToUserFolder(
        contents: jsonStr,
        dialogTitle: _appLocalizations.settingsPanelChooseBackupFolder,
      );
      if (!mounted) return;
      if (filePath == null) return; // User cancelled directory picker

      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(_appLocalizations.mainBackupSavedTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_appLocalizations.mainSettingsExported),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  filePath,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonStr));
                Navigator.of(ctx).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_appLocalizations.mainJsonCopied)),
                  );
                }
              },
              child: Text(_appLocalizations.mainCopyJson),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(_appLocalizations.mainDone),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final failedBackupJson = backupJson;
      if (failedBackupJson != null) {
        final copyJson = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(_appLocalizations.mainBackupFailedTitle),
            content: Text(_appLocalizations.mainBackupFileFailed(e.toString())),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(_appLocalizations.mainCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(_appLocalizations.mainCopyJson),
              ),
            ],
          ),
        );
        if (copyJson == true && mounted) {
          await Clipboard.setData(ClipboardData(text: failedBackupJson));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_appLocalizations.mainJsonCopied)),
          );
          return;
        }
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_appLocalizations.mainBackupFailed(e.toString())),
        ),
      );
    }
  }

  Future<void> _handleRestoreSettings() async {
    if (!mounted) return;
    try {
      final imported = await _settingsService.importFromFile();
      if (imported == null) return; // User cancelled the file picker
      if (!mounted) return;

      // Show a preview dialog before applying
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(_appLocalizations.mainRestoreSettingsTitle),
          content: Text(_appLocalizations.mainRestoreSettingsWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(_appLocalizations.mainCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(_appLocalizations.mainRestoreButton),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      await _applyRestoredSettings(imported);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_appLocalizations.mainSettingsRestored)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_appLocalizations.mainRestoreFailed(e.toString())),
        ),
      );
    }
  }

  Future<void> _applyRestoredSettings(AppSettings settings) async {
    final normalized = settings.normalized();
    final shouldMute = !normalized.speechMasterOn;
    _cancelPendingSpeech();
    await _stopTts();
    final settingsWrite = ref
        .read(settingsProvider.notifier)
        .replace(normalized);
    _speechLanguageService.setLanguage(normalized.voiceListMode);
    _voiceSessionManager.resetSession();

    if (shouldMute) {
      await _audioService.stopNotification();
      _stopMobileRingtone();
    }

    if (Platform.isAndroid) {
      final engine = normalized.speechEngineMode;
      if (engine != 'auto' &&
          engine != 'sherpa_only' &&
          engine != 'system_only') {
        await _speechService.setSpeechEngine(
          flutterTts: flutterTts,
          engine: engine,
        );
      }
      await _initTts(forceRebind: true);
    }

    if (normalized.clockOn) {
      startClock();
    } else {
      stopClock();
    }
    _refreshNightMuteSchedule();
    _restartGoalReminderTimer();
    await settingsWrite;
    await _writeWidgetState();
    await _reconcileForeground(force: true);
  }

  Future<void> _openDriveMode({bool fullscreen = false}) async {
    if (_driveModeOpen || _fullscreenFocusOpen) return;
    _driveModeOpen = true;
    debugPrint('[UI] Opening Drive Mode fullscreen=$fullscreen');
    try {
      if (Platform.isLinux && fullscreen) {
        await _desktopService.setFullscreen(true);
      }
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (driveContext) => DriveModeView(
            initialMode: DriveMode.values[currentTabIndex],
            clockTextBuilder: () => currentTimeDisplay,
            timerTextBuilder: () => timerDisplayValue,
            stopwatchTextBuilder: () => stopwatchElapsedValue,
            isTimerRunningBuilder: () => timerInterval != null,
            isStopwatchRunningBuilder: () => stopwatchInterval != null,
            isTimerPausedBuilder: () =>
                _timerRuntime.status == TimerRuntimeStatus.paused,
            isStopwatchPausedBuilder: () =>
                !_stopwatchRuntime.isRunning &&
                _stopwatchRuntime.accumulatedMs > 0,
            audioEnabledBuilder: () => speechMasterOn,
            onTimerStart: () {
              final paused = _timerRuntime.status == TimerRuntimeStatus.paused;
              startTimer();
              speak(
                paused ? 'Timer resumed' : 'Timer started',
                languageOverride: 'en',
              );
            },
            onTimerPause: () {
              stopTimer();
              speak('Timer paused', languageOverride: 'en');
            },
            onStopwatchStart: () {
              final paused = _stopwatchRuntime.accumulatedMs > 0;
              startStopwatch();
              speak(
                paused ? 'Stopwatch resumed' : 'Stopwatch started',
                languageOverride: 'en',
              );
            },
            onStopwatchPause: () {
              stopStopwatch();
              speak('Stopwatch paused', languageOverride: 'en');
            },
            onAudioEnabledChanged: (enabled) =>
                unawaited(_setSpeechMaster(enabled)),
            onModeChanged: (mode) =>
                setState(() => currentTabIndex = mode.index),
            onTimerPresetSelected: (minutes) {
              _startTimerFromMinutes(minutes);
              speak('$minutes minute timer started', languageOverride: 'en');
            },
            onSpeakNow: (mode) {
              switch (mode) {
                case DriveMode.clock:
                  speak(timeToWords(), languageOverride: 'en');
                case DriveMode.timer:
                  speak('$seconds seconds remaining', languageOverride: 'en');
                case DriveMode.stopwatch:
                  speakStopwatchElapsedNow();
              }
            },
            onClose: () => Navigator.of(driveContext).pop(),
          ),
        ),
      );
    } finally {
      _driveModeOpen = false;
      if (Platform.isLinux && fullscreen) {
        await _desktopService.setFullscreen(false);
      }
    }
  }

  Future<void> _handleDesktopAction(String action) async {
    try {
      switch (action) {
        case 'drive':
          await _openDriveMode();
        case 'drive_fullscreen':
          await _openDriveMode(fullscreen: true);
        case 'background':
          await _desktopService.setBackgroundEnabled(
            !_desktopService.backgroundEnabled.value,
          );
        case 'top':
          await _desktopService.setAlwaysOnTop(
            !_desktopService.alwaysOnTop.value,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_appLocalizations.mainDesktopAlwaysOnTopNote),
              ),
            );
          }
        case 'hide':
          await _desktopService.setBackgroundEnabled(true);
          await _desktopService.hide();
      }
      if (mounted) setState(() {});
    } catch (error, stackTrace) {
      debugPrint('[ERROR] Desktop action $action failed: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _appLocalizations.mainDesktopActionFailed(error.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _openFullscreenFocus({
    FullscreenFocusMode? specificMode,
    bool forceHorizontal = false,
    bool startImmersive = false,
  }) async {
    final initialMode =
        specificMode ??
        (currentTabIndex == 2
            ? FullscreenFocusMode.moduleC
            : (timerInterval != null || currentTabIndex == 1
                  ? FullscreenFocusMode.timer
                  : FullscreenFocusMode.clock));
    _fullscreenFocusMode.value = initialMode;
    if (_fullscreenFocusOpen) return;
    _fullscreenFocusOpen = true;
    await Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => FullscreenFocusView(
              initialMode: initialMode,
              modeUpdates: _fullscreenFocusMode,
              initialDarkTheme: fullscreenDarkTheme,
              initialDimBrightness: fullscreenDimBrightness,
              initialDimBrightnessLevel: fullscreenDimBrightnessLevel,
              initialForceLandscape: forceHorizontal
                  ? true
                  : fullscreenStartLandscape,
              initialShowClock: fullscreenShowClock,
              initialClockScale: fullscreenClockScale,
              onShowClockChanged: (show) {
                if (!mounted) return;
                setState(() {
                  fullscreenShowClock = show;
                  _lsSave();
                });
              },
              onClockScaleChanged: (scale) {
                if (!mounted) return;
                setState(() {
                  fullscreenClockScale = scale;
                  _lsSave();
                });
              },
              startImmersive: startImmersive,
              onThemeChanged: (isDark) {
                if (!mounted) return;
                setState(() {
                  fullscreenDarkTheme = isDark;
                  _lsSave();
                });
              },
              onDimBrightnessChanged: (isDimmed) {
                if (!mounted) return;
                setState(() {
                  fullscreenDimBrightness = isDimmed;
                  _lsSave();
                });
              },
              clockTextBuilder: () => currentTimeDisplay,
              timerTextBuilder: () => timerDisplayValue,
              isTimerRunningBuilder: () => timerInterval != null,
              stopwatchTextBuilder: () => stopwatchElapsedValue,
              isStopwatchRunningBuilder: () => stopwatchInterval != null,
              onTimerStart: startTimer,
              onTimerStop: stopTimer,
              onTimerReset: resetTimer,
              onStopwatchStart: startStopwatch,
              onStopwatchStop: stopStopwatch,
              onStopwatchReset: resetStopwatch,
            ),
          ),
        )
        .whenComplete(() {
          _fullscreenFocusOpen = false;
          _fullscreenFocusMode.value = FullscreenFocusMode.clock;
        });
    await SystemChrome.setPreferredOrientations([]);
  }

  Future<void> _exitAppFully() async {
    if (_exiting) return;
    _exiting = true;
    try {
      stopClock();
      _timerRuntimeController.dispose();
      await _timerRuntimeController.clearPersistedRuntimes();
      await _stopTts();
      await _audioService.stopBackground();
      await _audioService.stopNotification();
      await _stopForegroundService();
      await _quoteRotationService.flush();
      if (Platform.isLinux) {
        await _speechService.disposeDesktopSpeech();
        await _settingsService.flush();
      }
    } catch (error, stackTrace) {
      debugPrint('Exit cleanup failed: $error\n$stackTrace');
    }

    if (!mounted) return;
    if (Platform.isAndroid || Platform.isIOS) {
      await SystemNavigator.pop();
      return;
    }
    if (Platform.isLinux) {
      await _desktopService.quit();
      return;
    }
    exit(0);
  }

  void _onPersistenceFailure() {
    final failure = PersistenceErrorReporter.latest.value;
    if (!mounted ||
        failure == null ||
        failure.sequence <= _lastPersistenceFailureSequence) {
      return;
    }
    _lastPersistenceFailureSequence = failure.sequence;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_appLocalizations.mainPersistenceWriteFailed)),
      );
    });
  }

  void _dispatchExternal(Future<void> Function() action) {
    _platformIntentController.dispatch(action);
  }

  Future<void> _handleTaskData(Object data) async {
    if (!mounted) return;
    if (data is Map) {
      final type = data['type']?.toString();
      if (type == 'speechMaster' && data['value'] is bool) {
        await _setSpeechMaster(data['value'] as bool);
        return;
      }
      if (type == 'exit') {
        await _exitAppFully();
        return;
      }
      if (type == 'runtime' && data['snapshot'] is Map) {
        final snapshot = Map<String, dynamic>.from(data['snapshot'] as Map);
        await _applyTimerRuntime(TimerRuntime.fromJson(snapshot));
        if (data['stopwatch'] is Map) {
          await _timerRuntimeController.applyStopwatchRuntime(
            StopwatchRuntime.fromJson(
              Map<String, dynamic>.from(data['stopwatch'] as Map),
            ),
          );
        }
        return;
      }
    }

    if (data is! String) return;
    switch (data) {
      case 'btn_speech_master':
        await _setSpeechMaster(!speechMasterOn);
        return;
      case 'btn_timer_toggle':
        timerInterval == null ? startTimer() : stopTimer();
        return;
      case 'btn_clock_speech':
        toggleClock();
        return;
      case 'btn_stopwatch_toggle':
        stopwatchInterval == null ? startStopwatch() : stopStopwatch();
        return;
      case 'btn_timer_repeat':
        if (_lastFinishedTimerDurationSeconds > 0) {
          _startTimerFromMinutes(
            (_lastFinishedTimerDurationSeconds ~/ 60).clamp(1, 720),
          );
        }
        return;
      case 'btn_timer_dismiss':
        await _dismissFinishedTimer();
        return;
      case 'btn_exit':
        await _exitAppFully();
        return;
      default:
        return;
    }
  }

  void _stopMobileRingtone() {
    if (Platform.isAndroid || Platform.isIOS) {
      FlutterRingtonePlayer().stop();
    }
  }

  Future<void> _setSpeechMaster(bool enabled) async {
    if (!mounted) return;
    await _speechAnnouncementController.setSpeechMaster(enabled);
    await _settingsService.acknowledgeSpeechMasterOverride(enabled);
    await _writeWidgetState();
    await _reconcileForeground(force: true);
  }

  Future<void> _dismissFinishedTimer() async {
    if (!mounted) return;
    _stopMobileRingtone();
    _cancelTimerCompletionSpeech();
    await _audioService.stopNotification();
    _timerRuntimeController.resetTimer();
    await _timerRuntimeStore.save(_timerRuntimeController.timerRuntime);
    if (!mounted) return;
    setState(() => _isTimerFinished = false);
    await _reconcileForeground(force: true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PersistenceErrorReporter.latest.addListener(_onPersistenceFailure);
    _onPersistenceFailure();
    unawaited(SystemChrome.setPreferredOrientations([]));
    _platformIntentController.initializeChannel();
    unawaited(_bootstrap());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_maybePromptForKokoroDownload());
    });
    _speechService.kokoroDownloadStatus.addListener(() {
      if (mounted &&
          Platform.isLinux &&
          _speechService.kokoroDownloadStatus.value.phase ==
              SpeechModelDownloadPhase.ready) {
        final dVoices = _speechService.desktopVoices();
        setState(() {
          voices = dVoices;
          _settingsVoices.value = dVoices;
          _speechLanguageService.allVoices = dVoices;
        });
      }
    });

    displayTick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;

      final now = DateTime.now();
      final display = _formatCurrentTime(now);
      final summaryDate = DateTime(now.year, now.month, now.day);
      if (summaryDate != _todaySummaryDate) {
        _todaySummaryDate = summaryDate;
        unawaited(_refreshTodaySummary());
      }
      if (display != currentTimeDisplay ||
          (timerInterval != null && timerShowMilliseconds)) {
        setState(() => currentTimeDisplay = display);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _materialLocalizations = MaterialLocalizations.of(context);
    _appLocalizations = AppLocalizations.of(context)!;
    currentTimeDisplay = _formatCurrentTime(DateTime.now());
    if (!_platformResourcesInitialized) {
      _platformResourcesInitialized = true;
      _initForegroundTask();
      _initQuickActions();
    }
  }

  Future<void> _bootstrap() async {
    try {
      await _bootstrapImpl();
    } catch (error, stackTrace) {
      debugPrint('[ERROR] App bootstrap failed: $error\n$stackTrace');
      if (!mounted) return;
      await _platformIntentController.releaseBootstrapQueue();
      try {
        await _drainWidgetActions();
      } catch (actionError, actionStackTrace) {
        debugPrint(
          '[ERROR] Queued widget action recovery failed: $actionError\n'
          '$actionStackTrace',
        );
      }
      try {
        await _writeWidgetState();
      } catch (stateError, stateStackTrace) {
        debugPrint(
          '[ERROR] Widget state recovery failed: $stateError\n$stateStackTrace',
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _appLocalizations.mainStartupIncomplete(error.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _bootstrapImpl() async {
    await _quoteRotationService.load();
    await _malayalamTtsService.loadQuoteCatalog();
    final settings = _settings;
    _speechLanguageService.setLanguage(settings.voiceListMode);

    await _audioService.init();
    if (!mounted) return;
    if (Platform.isLinux) {
      final dVoices = _speechService.desktopVoices();
      voices = dVoices;
      _settingsVoices.value = dVoices;
      _speechLanguageService.allVoices = dVoices;
      _desktopService.onQuitRequested = () => unawaited(_exitAppFully());
      await _desktopService.initialize();
      if (!mounted) return;
      if (_speechService.normalizeSpeechEngineMode(speechEngineMode) !=
          'system_only') {
        unawaited(
          _speechService.warmDesktopSpeech(
            useMalayalamNuance: _isMalayalamActive(getPreferredVoice()),
          ),
        );
      }
    }
    if (!mounted) return;
    unawaited(_initTts());
    _applyAudioSettings();
    _restartGoalReminderTimer();
    unawaited(_refreshTodaySummary());
    await _restoreTimerRuntime();
    await _restoreStopwatchRuntime();
    final savedClockDeadline = await _timerRuntimeStore.loadClockNextAt();
    if (!mounted) return;
    if (clockOn) {
      if (savedClockDeadline == null) {
        startClock();
      } else {
        _speechAnnouncementController.restoreClockDeadline(savedClockDeadline);
      }
    } else {
      _persistClockDeadline(null);
    }
    await _initializeForegroundNotification();
    if (!mounted) return;
    await _platformIntentController.markBootstrapReady();
  }

  Future<void> _maybePromptForKokoroDownload() async {
    if (!Platform.isLinux ||
        _speechService.kokoroDownloadStatus.value.phase ==
            SpeechModelDownloadPhase.ready) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    if ((preferences.getBool(PrefKeys.linuxKokoroConsentPromptSeen) ?? false) ||
        (preferences.getBool(PrefKeys.linuxKokoroConsentAccepted) ?? false)) {
      return;
    }
    if (!mounted) return;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => KokoroDownloadConsentDialog(
        onAccept: () => Navigator.of(dialogContext).pop(true),
        onDecline: () => Navigator.of(dialogContext).pop(false),
      ),
    );
    await preferences.setBool(PrefKeys.linuxKokoroConsentPromptSeen, true);
    await preferences.setBool(
      PrefKeys.linuxKokoroConsentAccepted,
      accepted == true,
    );
    if (accepted != true || !mounted) return;
    unawaited(_speechService.downloadKokoroVoice());
  }

  void _downloadKokoroVoiceFromSettings() {
    unawaited(_recordKokoroDownloadConsentAndStart());
  }

  Future<void> _recordKokoroDownloadConsentAndStart() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(PrefKeys.linuxKokoroConsentPromptSeen, true);
    await preferences.setBool(PrefKeys.linuxKokoroConsentAccepted, true);
    if (!mounted) return;
    await _speechService.downloadKokoroVoice();
  }

  void _lsSave() {
    unawaited(_writeWidgetState());
  }

  Future<void> _refreshTodaySummary() async {
    if (!taggingOn) {
      if (_todaySummary.isNotEmpty) setState(() => _todaySummary = '');
      return;
    }
    final summary = await _sessionLogService.getDailySummary(DateTime.now());
    if (!mounted) return;
    final parts = <String>[];
    if (summary.studySeconds > 0) {
      parts.add('Study ${summary.studyFormatted}');
    }
    if (summary.nonStudySeconds > 0) {
      parts.add('Non-study ${summary.nonStudyFormatted}');
    }
    setState(() => _todaySummary = parts.join(' · '));
  }

  /// Start a preset timer from widget (extracted for reuse with tag dialog).
  Future<void> _startPresetFromWidget(int mins) async {
    final safeMins = mins.clamp(1, 720);
    await _audioService.stopNotification();
    _armedPresetTimer?.cancel();
    _armedPresetValue = null;
    setState(() {
      currentTabIndex = 1;
      chainModeOn = false;
      chainIndex = 0;
      sliderValue = safeMins;
      _isTimerFinished = false;
      fullscreenShowClock = true;
    });
    _timerRuntimeController.replaceWithWidgetPreset(safeMins * 60);
    await _saveLastTimerSeconds(safeMins * 60);
    _applyAudioSettings();
    await _reconcileForeground(force: true);
    unawaited(
      _openFullscreenFocus(
        specificMode: FullscreenFocusMode.timer,
        forceHorizontal: true,
        startImmersive: true,
      ),
    );
  }

  Future<void> _writeWidgetState() =>
      _platformIntentController.writeWidgetState();

  Future<void> _drainWidgetActions() =>
      _platformIntentController.drainWidgetActions();

  /// Executes actions after the platform controller applies confirmation.
  Future<void> _performWidgetAction(String type) async {
    if (!mounted) return;

    // ── Immediate actions (no confirmation needed) ──────────────────────
    const presetMap = {
      'start_1m': 1,
      'start_2m': 2,
      'start_3m': 3,
      'start_5m': 5,
      'start_7m': 7,
      'start_10m': 10,
      'start_12m': 12,
      'start_15m': 15,
      'start_20m': 20,
      'start_25m': 25,
      'start_30m': 30,
      'start_35m': 35,
      'start_45m': 45,
      'start_60m': 60,
      'start_90m': 90,
    };

    if (presetMap.containsKey(type)) {
      final mins = presetMap[type]!;
      if (taggingOn && sessionTag.isEmpty) {
        sessionTag = 'Study';
        _lsSave();
      }
      await _startPresetFromWidget(mins);
      return;
    }

    switch (type) {
      case 'toggle_speech_master':
        await _setSpeechMaster(!speechMasterOn);
        break;
      case 'open_fullscreen_clock':
        setState(() => currentTabIndex = 0);
        _openFullscreenFocus(
          specificMode: FullscreenFocusMode.clock,
          forceHorizontal: true,
          startImmersive: true,
        );
        break;
      case 'open_app':
      case 'open_clock':
        setState(() {
          currentTabIndex = 0;
        });
        break;
      case 'open_fullscreen_clock_direct':
        setState(() {
          currentTabIndex = 0;
        });
        _openFullscreenFocus(
          specificMode: FullscreenFocusMode.clock,
          forceHorizontal: true,
          startImmersive: true,
        );
        break;
      case 'resume_last':
        await _handleQuickAction('resume_last');
        break;
      case 'start_timer_fullscreen':
        setState(() {
          currentTabIndex = 1;
        });
        startTimer();
        _openFullscreenFocus(
          specificMode: FullscreenFocusMode.timer,
          forceHorizontal: true,
          startImmersive: true,
        );
        break;
      case 'start_stopwatch_fullscreen':
        setState(() {
          currentTabIndex = 2;
        });
        startStopwatch();
        _openFullscreenFocus(
          specificMode: FullscreenFocusMode.moduleC,
          forceHorizontal: true,
          startImmersive: true,
        );
        break;
      case 'toggle_clock_speech':
        setState(() {
          clockOn = !clockOn;
          _lsSave();
          if (clockOn) {
            startClock();
          } else {
            stopClock();
          }
        });
        _applyAudioSettings();
        unawaited(_syncForegroundNotification(force: true));
        break;
      case 'toggle_timer_speech':
        setState(() {
          timerSpeakOn = !timerSpeakOn;
          _lsSave();
        });
        break;
      case 'toggle_stopwatch_speech':
        setState(() {
          stopwatchSpeakOn = !stopwatchSpeakOn;
          _lsSave();
        });
        if (!stopwatchSpeakOn) {
          _speechAnnouncementController.removeStopwatchAnnouncements();
        }
        break;
      case 'toggle_goals_speech':
        setState(() {
          goalReminderOn = !goalReminderOn;
          _lsSave();
          _restartGoalReminderTimer();
        });
        break;
    }
  }

  void _applyAudioSettings() {
    // Master Audio OFF — prevent all ambient audio
    if (_isAudioMuted()) {
      unawaited(_audioService.stopBackground());
      return;
    }
    final bool shouldTimerPlay = timerInterval != null && timerNoiseOn;
    final bool shouldClockPlay = clockOn && clockNoiseOn;
    final bool shouldPlay = shouldTimerPlay || shouldClockPlay;

    if (shouldPlay) {
      unawaited(
        _audioService.applyBackground(
          shouldPlay: true,
          assetPath: soundChosen,
          volume: noiseVolume,
        ),
      );
    } else {
      unawaited(_audioService.stopBackground());
    }
  }

  void _restartGoalReminderTimer() =>
      _speechAnnouncementController.restartGoalReminderTimer();

  void _testSpeech() => _speechAnnouncementController.testSpeech();

  void _handleNightUsageStateChange(AppLifecycleState state) =>
      _speechAnnouncementController.handleNightUsageStateChange(state);

  void _refreshNightMuteSchedule() =>
      _speechAnnouncementController.refreshNightMuteSchedule();

  void _cancelNightIdleTimer() =>
      _speechAnnouncementController.cancelNightIdleTimer();

  void _startNightIdleTimerIfNeeded() =>
      _speechAnnouncementController.startNightIdleTimerIfNeeded();

  void _stopAudioForMute() => _speechAnnouncementController.stopAudioForMute();

  void _speakStopwatchMessage(
    String text, {
    bool explicit = false,
    int? generation,
  }) => _speechAnnouncementController.speakStopwatchMessage(
    text,
    explicit: explicit,
    stopwatchSpeakOn: stopwatchSpeakOn,
  );

  bool _isAudioMuted() => _speechAnnouncementController.isAudioMuted;

  Future<void> _stopTts() => _speechAnnouncementController.stopTts();
  void _cancelPendingSpeech() =>
      _speechAnnouncementController.cancelPendingSpeech();
  void _cancelTimerCompletionSpeech() =>
      _speechAnnouncementController.cancelTimerCompletionSpeech();
  Future<bool> _initTts({bool forceRebind = false}) =>
      _speechAnnouncementController.initTts(forceRebind: forceRebind);
  List<Map<dynamic, dynamic>> _availableVoicesForSettings() =>
      _speechAnnouncementController.availableVoicesForSettings();
  Map<dynamic, dynamic>? getPreferredVoice() =>
      _speechAnnouncementController.getPreferredVoice();
  bool _isMalayalamActive(Map<dynamic, dynamic>? voice) =>
      _voiceSessionManager.isMalayalamActive(
        isMalayalamResolver: (value) => _malayalamTtsService.isMalayalamMode(
          voiceListMode: _speechLanguageService.language,
          preferredVoice: value,
        ),
        preferredVoice: voice,
      );
  String _nextQuoteForCategory(String category) {
    if (_isMalayalamActive(getPreferredVoice())) {
      return _quoteRotationService.nextQuoteForList(
        key: 'malayalam:$category',
        quotes: _malayalamTtsService.quotesForCategory(category),
        fallbackQuote: _malayalamTtsService.defaultQuote(),
      );
    }
    return _quoteRotationService.nextQuoteFromMap(
      category: category,
      quotesByCategory: quotesByCategory,
      fallbackCategory: 'General',
      fallbackQuote: 'Stay steady and use this moment well.',
      rotationScope: 'english',
    );
  }

  String timeToWords() => _speechAnnouncementController.timeToWords();
  void startClock() => _speechAnnouncementController.startClock();
  void stopClock() => _speechAnnouncementController.stopClock();
  void _scheduleNextClockAnnouncement() =>
      _speechAnnouncementController.scheduleNextClockAnnouncement();
  void speakClock(String text) =>
      _speechAnnouncementController.speakClock(text);
  void speakTimerMessage(
    String text, {
    String? finishedRunId,
    int? finishedRevision,
  }) => _speechAnnouncementController.speakTimerMessage(
    text,
    finishedRunId: finishedRunId,
    finishedRevision: finishedRevision,
  );
  void speak(
    String text, {
    Map<dynamic, dynamic>? voice,
    String? languageOverride,
    bool isTimerAnnouncement = false,
    bool isStopwatchAnnouncement = false,
    bool isTimerCompletion = false,
    String? timerRunId,
    int? timerRevision,
  }) => _speechAnnouncementController.speak(
    text,
    voice: voice,
    languageOverride: languageOverride,
    isTimerAnnouncement: isTimerAnnouncement,
    isStopwatchAnnouncement: isStopwatchAnnouncement,
    isTimerCompletion: isTimerCompletion,
    timerRunId: timerRunId,
    timerRevision: timerRevision,
  );
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _handleNightUsageStateChange(state);
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      _todaySummaryDate = DateTime(now.year, now.month, now.day);
      unawaited(_refreshTodaySummary());
      if (clockOn) _scheduleNextClockAnnouncement();
      _applyAudioSettings();
      _dispatchExternal(() async {
        if (timerInterval == null ||
            _timerRuntime.status != TimerRuntimeStatus.running) {
          await _restoreTimerRuntime();
        }
        await _drainWidgetActions();
        await _reconcileForeground(force: true);
      });
    }
  }

  void _persistClockDeadline(DateTime? dueAt) {
    unawaited(
      _timerRuntimeStore.saveClockNextAt(dueAt).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        debugPrint('[STATE] Failed to persist clock deadline: $error');
      }),
    );
  }

  void toggleClock() {
    setState(() {
      clockOn = !clockOn;
      _lsSave();
      if (clockOn) {
        startClock();
      } else {
        stopClock();
      }
    });
    _applyAudioSettings();
  }

  String _formatTimerDisplayValue(
    int totalSeconds, {
    int? remainingMilliseconds,
  }) {
    final totalMilliseconds = timerShowMilliseconds
        ? (remainingMilliseconds ?? totalSeconds * 1000)
        : totalSeconds * 1000;
    final mins = (totalMilliseconds ~/ 60000).toString().padLeft(2, '0');
    final secs = ((totalMilliseconds ~/ 1000) % 60).toString().padLeft(2, '0');
    if (!timerShowMilliseconds) return '$mins:$secs';
    final millis = (totalMilliseconds % 1000).toString().padLeft(3, '0');
    return '$mins:$secs.$millis';
  }

  String _formatStopwatchElapsed(
    int totalSeconds, {
    bool showMilliseconds = false,
  }) {
    final elapsedMs = _stopwatchRuntime.elapsedMsAt(DateTime.now());
    final effectiveMs = elapsedMs > 0 ? elapsedMs : totalSeconds * 1000;
    final totalForView = effectiveMs ~/ 1000;
    final hours = totalForView ~/ 3600;
    final minutes = (totalForView % 3600) ~/ 60;
    final seconds = totalForView % 60;
    final base = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    if (!showMilliseconds) return base;
    final centiseconds = ((effectiveMs % 1000) ~/ 10).toString().padLeft(
      2,
      '0',
    );
    return '$base.$centiseconds';
  }

  Future<void> _restoreStopwatchRuntime() =>
      _timerRuntimeController.restoreStopwatchRuntime();

  void startStopwatch() => _timerRuntimeController.startStopwatch();

  void stopStopwatch() => _timerRuntimeController.stopStopwatch();

  void resetStopwatch() => _timerRuntimeController.resetStopwatch();

  void speakStopwatchElapsedNow() =>
      _timerRuntimeController.speakStopwatchElapsedNow();

  Future<void> _restoreTimerRuntime() =>
      _timerRuntimeController.restoreTimerRuntime();

  Future<void> _applyTimerRuntime(
    TimerRuntime runtime, {
    bool restored = false,
  }) => _timerRuntimeController.applyTimerRuntime(runtime, restored: restored);

  void _startTimerFromMinutes(int minutes) =>
      _startTimerFromDurationSeconds(minutes.clamp(1, 720) * 60);

  void _startTimerFromDurationSeconds(int durationSeconds) {
    _stopMobileRingtone();
    _armedPresetTimer?.cancel();
    _armedPresetValue = null;
    _timerRuntimeController.startTimerFromDurationSeconds(durationSeconds);
  }

  Future<int?> _showNormalTimerFinishedDialog() async {
    final customController = TextEditingController();
    String? inputError;
    const actionStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, 48)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
    const presetStyle = ButtonStyle(
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );

    final selectedMinutes = await showDialog<int>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          void startCustomTimer() {
            final minutes = int.tryParse(customController.text.trim());
            if (minutes == null || minutes < 1 || minutes > 720) {
              setDialogState(() {
                inputError = _appLocalizations.mainTimerDurationRangeError;
              });
              return;
            }
            Navigator.of(dialogContext).pop(minutes * 60);
          }

          return Dialog.fullscreen(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _appLocalizations.mainTimerFinishedTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(
                                      dialogContext,
                                    ).pop(_lastFinishedTimerDurationSeconds);
                                  },
                                  icon: const Icon(Icons.replay_rounded),
                                  label: Text(
                                    _appLocalizations.mainRepeatSameTimer,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _appLocalizations.mainStartPresetTimer,
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 10),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _timerFinishedPresetMinutes.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 120,
                                        mainAxisExtent: 48,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                  itemBuilder: (context, index) {
                                    final minutes =
                                        _timerFinishedPresetMinutes[index];
                                    return OutlinedButton(
                                      style: presetStyle,
                                      onPressed: () => Navigator.of(
                                        dialogContext,
                                      ).pop(minutes * 60),
                                      child: Text(
                                        _appLocalizations.mainMinuteShort(
                                          minutes,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: customController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: _appLocalizations
                                        .mainCustomDurationMinutes,
                                    errorText: inputError,
                                  ),
                                  onSubmitted: (_) => startCustomTimer(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: actionStyle,
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  child: Text(
                                    _appLocalizations.mainCloseTimer,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  style: actionStyle,
                                  onPressed: startCustomTimer,
                                  child: Text(
                                    _appLocalizations.mainStartCustomTimer,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    customController.dispose();
    return selectedMinutes;
  }

  Future<int?> _showFullscreenTimerFinishedDialog() {
    return showDialog<int>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (dialogContext) {
        final cs = Theme.of(dialogContext).colorScheme;
        final fg = cs.onSurface;
        final bg = cs.surface;
        final surface = cs.surfaceContainerLow;
        final variant = cs.onSurfaceVariant;
        final outline = cs.outlineVariant;
        final primary = cs.primary;
        final selectedBg = cs.primaryContainer;

        Widget presetButton(int mins) {
          return Material(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(dialogContext).pop(mins * 60),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: outline),
                ),
                child: Center(
                  child: Text(
                    _appLocalizations.mainMinuteShort(mins),
                    style: TextStyle(
                      color: fg,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Dialog.fullscreen(
          backgroundColor: bg,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: selectedBg,
                          foregroundColor: fg,
                        ),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      const Spacer(),
                      Text(
                        _appLocalizations.mainTimerFinishedTitle,
                        style: TextStyle(
                          color: fg,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(
                          dialogContext,
                        ).pop(_lastFinishedTimerDurationSeconds);
                      },
                      icon: const Icon(Icons.replay_rounded),
                      label: Text(_appLocalizations.mainRepeatSameTimer),
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _appLocalizations.mainStartPresetTimer,
                      style: TextStyle(
                        color: variant,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      itemCount: _timerFinishedPresetMinutes.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 180,
                            mainAxisExtent: 52,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                      itemBuilder: (context, index) =>
                          presetButton(_timerFinishedPresetMinutes[index]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                      label: Text(_appLocalizations.mainCloseTimer),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: fg,
                        side: BorderSide(color: outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveChainSettingsToTimerRuntime() =>
      _timerRuntimeController.saveChainSettingsToTimerRuntime();

  void startTimer({int? initialDurationSeconds}) {
    _armedPresetTimer?.cancel();
    _armedPresetValue = null;
    _timerRuntimeController.startTimer(
      initialDurationSeconds: initialDurationSeconds,
    );
  }

  void stopTimer() => _timerRuntimeController.stopTimer();

  void resetTimer() {
    _timerRuntimeController.resetTimer();
    if (mounted) setState(() => _isTimerFinished = false);
  }

  void choosePreset(int value) {
    resetTimer();
    setState(() => sliderValue = value.clamp(1, 720));
    startTimer(initialDurationSeconds: sliderValue * 60);
  }

  void addTimeToRunningTimer(int additionalSeconds) {
    _timerRuntimeController.addTimeToRunningTimer(additionalSeconds);
  }

  /// Starts timer preset immediately on tap.
  void _onPresetTap(int val) {
    _armedPresetTimer?.cancel();
    _armedPresetValue = null;
    choosePreset(val);
  }

  Widget _buildSpeakClockTab() {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: ColoredBox(
        color: cs.surface,
        child: ClockPanel(
          onExitApp: () => unawaited(_exitAppFully()),
          onFullscreenPressed: () => _openFullscreenFocus(
            specificMode: FullscreenFocusMode.clock,
            forceHorizontal: true,
          ),
          onFullscreenImmersivePressed: () => _openFullscreenFocus(
            specificMode: FullscreenFocusMode.clock,
            forceHorizontal: true,
            startImmersive: true,
          ),
          currentTimeDisplay: currentTimeDisplay,
          clockIntervalMins: clockIntervalMins,
          clockShowMilliseconds: clockShowMilliseconds,
          clockSpeakTime: clockSpeakTime,
          clockSpeakRepeatCount: clockSpeakRepeatCount,
          clockNoiseOn: clockNoiseOn,
          motivationOn: motivationOn,
          motivationCategory: motivationCategory,
          motivationDelaySeconds: motivationDelaySeconds,
          clockIntervalOptions: clockIntervalOptions,
          clockSpeakRepeatOptions: clockSpeakRepeatOptions,
          motivationCategories: _isMalayalamActive(getPreferredVoice())
              ? motivationCategories
              : motivationCategories
                    .where((category) => category != 'General Malayalam')
                    .toList(growable: false),
          motivationDelayOptions: motivationDelayOptions,
          clockShowSeconds: clockShowSeconds,
          onClockIntervalChanged: (val) {
            if (val == null) return;
            setState(() {
              clockIntervalMins = val;
              _lsSave();
            });
            if (clockOn) startClock();
          },
          onClockShowMillisecondsChanged: (val) {
            setState(() {
              clockShowMilliseconds = val ?? true;
              currentTimeDisplay = _formatCurrentTime(DateTime.now());
              _lsSave();
            });
          },
          onClockShowSecondsChanged: (val) {
            setState(() {
              clockShowSeconds = val ?? true;
              currentTimeDisplay = _formatCurrentTime(DateTime.now());
              _lsSave();
            });
          },
          onClockSpeakTimeChanged: (val) {
            final nowOn = val ?? true;
            final needsStart = nowOn && !clockOn;
            setState(() {
              clockSpeakTime = nowOn;
              if (needsStart) clockOn = true;
              _lsSave();
            });
            if (!nowOn) {
              _speechAnnouncementController.removeClockTimeAnnouncements();
            }
            if (needsStart) {
              startClock();
            } else if (nowOn) {
              speakClock(timeToWords());
            }
          },
          onClockSpeakRepeatCountChanged: (val) {
            if (val == null) return;
            setState(() {
              clockSpeakRepeatCount = val.clamp(1, 3);
              _lsSave();
            });
          },
          onClockNoiseOnChanged: (val) {
            final nowOn = val ?? false;
            final needsStart = nowOn && !clockOn;
            setState(() {
              clockNoiseOn = nowOn;
              if (needsStart) clockOn = true;
              _lsSave();
            });
            if (needsStart) startClock();
            _applyAudioSettings();
          },
          onMotivationChanged: (val) {
            final nowOn = val ?? true;
            final needsStart = nowOn && !clockOn;
            setState(() {
              motivationOn = nowOn;
              if (needsStart) clockOn = true;
              _lsSave();
            });
            if (!nowOn) {
              _speechAnnouncementController.removeQuoteAnnouncements();
            }
            if (needsStart) startClock();
          },
          onMotivationCategoryChanged: (val) {
            if (val == null) return;
            setState(() {
              motivationCategory = val;
              _lsSave();
            });
          },
          onMotivationDelayChanged: (val) {
            if (val == null) return;
            setState(() {
              motivationDelaySeconds = val;
              _lsSave();
            });
          },
          backgroundPersistenceOn: backgroundPersistenceOn,
          onBackgroundPersistenceChanged: (val) {
            setState(() {
              backgroundPersistenceOn = val ?? false;
              _lsSave();
            });
            unawaited(_reconcileForeground(force: true));
          },
        ),
      ),
    );
  }

  Widget _buildTimerSetupTab() {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: ColoredBox(
        color: cs.surface,
        child: TimerPanel(
          onFullscreenPressed: () => _openFullscreenFocus(
            specificMode: FullscreenFocusMode.timer,
            forceHorizontal: true,
          ),
          onFullscreenImmersivePressed: () => _openFullscreenFocus(
            specificMode: FullscreenFocusMode.timer,
            forceHorizontal: true,
            startImmersive: true,
          ),
          timerValue: timerDisplayValue,
          sliderValue: sliderValue,
          remainingSeconds: seconds,
          durationSeconds: _activeTimerDurationSeconds,
          isRunning: timerInterval != null,
          presetValues: presetValues,
          startTimer: startTimer,
          stopTimer: stopTimer,
          resetTimer: resetTimer,
          choosePreset: choosePreset,
          addTimeToRunningTimer: addTimeToRunningTimer,
          armedPresetValue: _armedPresetValue,
          onPresetTap: _onPresetTap,
          timerNoiseOn: timerNoiseOn,
          timerSpeakOn: timerSpeakOn,
          timerShowMilliseconds: timerShowMilliseconds,
          timerAnnounceEvery: timerAnnounceEvery,
          chainModeOn: chainModeOn,
          chainPresetKey: chainPresetKey,
          chainPresets: chainPresets,
          chainIndex: chainIndex,
          timerAnnounceOptions: timerAnnounceOptions,
          fullscreenShowClock: fullscreenShowClock,
          onFullscreenShowClockChanged: (val) {
            setState(() {
              fullscreenShowClock = val ?? false;
              _lsSave();
            });
          },
          onTimerNoiseOnChanged: (val) {
            setState(() {
              timerNoiseOn = val ?? true;
              _lsSave();
            });
            _applyAudioSettings();
          },
          onTimerSpeakOnChanged: (val) {
            final nowOn = val ?? true;
            setState(() {
              timerSpeakOn = nowOn;
              _lsSave();
            });
            if (!nowOn) {
              _speechAnnouncementController.removeTimerAnnouncements();
            }
          },
          onTimerShowMillisecondsChanged: (val) {
            setState(() {
              timerShowMilliseconds = val ?? false;
              _lsSave();
            });
          },
          onTimerAnnounceEveryChanged: (val) {
            if (val == null) return;
            setState(() {
              timerAnnounceEvery = val;
              _lsSave();
            });
          },
          onChainModeChanged: (val) {
            final nextMode = val ?? false;
            if (nextMode == chainModeOn) return;
            setState(() {
              chainModeOn = nextMode;
              chainIndex = 0;
              _lsSave();
            });
            _saveChainSettingsToTimerRuntime();
          },
          onChainPresetChanged: (val) {
            if (val == null || val == chainPresetKey) return;
            setState(() {
              chainPresetKey = val;
              chainIndex = 0;
              _lsSave();
            });
            _saveChainSettingsToTimerRuntime();
          },
          taggingOn: taggingOn,
          sessionTag: sessionTag,
          todaySummary: _todaySummary,
          onTaggingOnChanged: (val) {
            setState(() {
              taggingOn = val;
              _lsSave();
            });
            if (val) _refreshTodaySummary();
          },
          onSessionTagChanged: (val) {
            setState(() {
              sessionTag = val;
              _lsSave();
            });
          },
          onDashboardPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const DashboardScreen()));
          },
        ),
      ),
    );
  }

  int get _lapCount => _stopwatchRuntime.lapTimesMs.length;

  List<String> get _lapTimes => List<String>.generate(
    _stopwatchRuntime.lapTimesMs.length,
    (index) =>
        'Lap ${_stopwatchRuntime.lapTimesMs.length - index}  ${_formatStopwatchElapsed(_stopwatchRuntime.lapTimesMs[index] ~/ 1000, showMilliseconds: stopwatchShowMilliseconds)}',
    growable: false,
  );

  void _recordLap() => _timerRuntimeController.recordStopwatchLap();

  Widget _buildStopwatchTab() {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: ColoredBox(
        color: cs.surface,
        child: StopwatchPanel(
          onFullscreenPressed: () => _openFullscreenFocus(
            specificMode: FullscreenFocusMode.moduleC,
            forceHorizontal: true,
          ),
          onFullscreenImmersivePressed: () => _openFullscreenFocus(
            specificMode: FullscreenFocusMode.moduleC,
            forceHorizontal: true,
            startImmersive: true,
          ),
          elapsedValue: stopwatchElapsedValue,
          isRunning: stopwatchInterval != null,
          startStopwatch: startStopwatch,
          stopStopwatch: stopStopwatch,
          resetStopwatch: resetStopwatch,
          onLap: _recordLap,
          lapCount: _lapCount,
          lapTimes: _lapTimes,
          stopwatchSpeakOn: stopwatchSpeakOn,
          stopwatchShowMilliseconds: stopwatchShowMilliseconds,
          stopwatchSpeakDelaySeconds: stopwatchSpeakDelaySeconds,
          stopwatchSpeakDelayOptions: stopwatchSpeakDelayOptions,
          onStopwatchSpeakOnChanged: (val) {
            final nowOn = val ?? true;
            setState(() {
              stopwatchSpeakOn = nowOn;
              _lsSave();
            });
            if (!nowOn) {
              _speechAnnouncementController.removeStopwatchAnnouncements();
            }
          },
          onStopwatchShowMillisecondsChanged: (val) {
            setState(() {
              stopwatchShowMilliseconds = val ?? false;
              _lsSave();
            });
          },
          onStopwatchSpeakDelayChanged: (val) {
            if (val == null) return;
            setState(() {
              stopwatchSpeakDelaySeconds = val;
              _timerRuntimeController.lastStopwatchAutoAnnouncedSecond = -1;
              _timerRuntimeController.stopwatchSpeechGeneration++;
              _lsSave();
            });
          },
        ),
      ),
    );
  }

  Widget _buildHelpTab() {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.primary),
        title: Text(
          AppLocalizations.of(context)?.helpTitle ?? 'Help / Working',
          style: TextStyle(
            color: cs.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              HelpPanel(
                muteSpeechAfterMidnight: muteSpeechAfterMidnight,
                nightMuteMode: nightMuteMode,
                sleepStartLabel: _formatMinutesAsTime(
                  context,
                  sleepStartMinutes,
                ),
                sleepEndLabel: _formatMinutesAsTime(context, sleepEndMinutes),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PersistenceErrorReporter.latest.removeListener(_onPersistenceFailure);
    _foregroundNotificationController.dispose();
    _armedPresetTimer?.cancel();
    _platformIntentController.dispose();
    _timerRuntimeController.dispose();
    displayTick?.cancel();
    _speechAnnouncementController.dispose();
    unawaited(_stopTts());
    unawaited(_speechService.disposeDesktopSpeech());
    unawaited(_settingsService.flush());
    unawaited(_audioService.dispose());
    _desktopService.dispose();
    _fullscreenFocusMode.dispose();
    super.dispose();
  }

  @override
  int get sliderMinutes => sliderValue;

  @override
  bool get audioMuted => _isAudioMuted();

  @override
  void setChainModeOn(bool value) => chainModeOn = value;

  @override
  void onTimerRuntimeChanged({
    required TimerRuntime runtime,
    required bool tickerActive,
    required int sliderMinutes,
    required int chainIndex,
    required bool finished,
    required int lastFinishedDurationSeconds,
  }) {
    if (!mounted) return;
    setState(() {
      sliderValue = sliderMinutes;
      this.chainIndex = chainIndex;
      chainModeOn = runtime.chainModeOn;
      chainPresetKey = runtime.chainPresetKey;
      _isTimerFinished = finished;
    });
  }

  @override
  void onStopwatchRuntimeChanged({
    required StopwatchRuntime runtime,
    required bool tickerActive,
  }) {
    if (mounted) setState(() {});
  }

  @override
  void onTimerSpeechRemaining(int minutes) {
    final useMalayalam = _isMalayalamActive(getPreferredVoice());
    speakTimerMessage(
      useMalayalam
          ? _malayalamTtsService.timerRemaining(minutes)
          : '$minutes minute${minutes == 1 ? '' : 's'} remaining',
    );
  }

  @override
  void onTimerSpeechNext(int seconds) {
    final useMalayalam = _isMalayalamActive(getPreferredVoice());
    speakTimerMessage(
      useMalayalam
          ? _malayalamTtsService.nextTimerStarting(seconds ~/ 60)
          : 'Starting next timer: ${seconds ~/ 60} minutes',
    );
  }

  @override
  void onTimerSpeechFinished(String runId, int revision) {
    final useMalayalam = _isMalayalamActive(getPreferredVoice());
    speakTimerMessage(
      useMalayalam ? _malayalamTtsService.timerFinished() : 'Timer finished',
      finishedRunId: runId,
      finishedRevision: revision,
    );
  }

  @override
  void onStopwatchSpeech(
    String text, {
    required bool explicit,
    required int generation,
  }) =>
      _speakStopwatchMessage(text, explicit: explicit, generation: generation);

  @override
  String stopwatchElapsedSpeechText(StopwatchRuntime runtime) =>
      _formatStopwatchElapsed(
        runtime.elapsedMsAt(DateTime.now()) ~/ 1000,
        showMilliseconds: stopwatchShowMilliseconds,
      );

  @override
  Future<void> applyAudioSettings() async => _applyAudioSettings();

  @override
  Future<void> reconcileForeground({required bool force}) =>
      _reconcileForeground(force: force);

  @override
  Future<void> stopNotification() => _audioService.stopNotification();
  @override
  void onStopwatchSpeechGenerationChanged(int generation) {
    _speechAnnouncementController.invalidateStopwatchSpeech();
  }

  @override
  Future<void> saveLastTimerSeconds(int seconds) =>
      _saveLastTimerSeconds(seconds);

  @override
  Future<void> onTimerFinishedEffects(int durationSeconds) async {
    if (Platform.isLinux) {
      unawaited(
        _desktopService.notify(
          _appLocalizations.mainTimerFinishedTitle,
          _appLocalizations.mainDesktopTimerFinishedBody(
            (durationSeconds / 60).ceil(),
          ),
        ),
      );
    }
  }

  @override
  Future<void> onTimerAlarm() async {
    if (_isAudioMuted()) return;
    final generation = _timerRuntimeController.alarmGeneration;
    if (Platform.isAndroid) {
      FlutterRingtonePlayer().playAlarm(looping: true);
      Future<void>.delayed(const Duration(seconds: 30), () {
        if (_timerRuntimeController.alarmGeneration == generation) {
          _stopMobileRingtone();
        }
      });
    } else {
      unawaited(
        _audioService.playNotification(
          assetPath: notifySound,
          stopAfter: const Duration(seconds: 10),
        ),
      );
    }
  }

  @override
  Future<int?> onTimerFinishedDialog() async {
    final selected = _fullscreenFocusOpen
        ? await _showFullscreenTimerFinishedDialog()
        : await _showNormalTimerFinishedDialog();
    if (selected == null &&
        _fullscreenFocusOpen &&
        _fullscreenFocusMode.value == FullscreenFocusMode.timer) {
      _dismissFocusAfterFinishedDialog = true;
    }
    return selected;
  }

  @override
  Future<void> closeTimerFinishedDialog() async {
    if (mounted) await Navigator.of(context, rootNavigator: true).maybePop();
  }

  @override
  void scheduleRestoredTimerFinishedDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_timerRuntimeController.showTimerFinishedDialog());
      }
    });
  }

  @override
  Future<void> dismissFinishedTimer() async {
    await _dismissFinishedTimer();
    if (_dismissFocusAfterFinishedDialog) {
      _dismissFocusAfterFinishedDialog = false;
      if (mounted) {
        await Navigator.of(context, rootNavigator: true).maybePop();
      }
    }
  }

  @override
  Future<void> refreshTimerSummary() => _refreshTodaySummary();

  @override
  void cancelTimerCompletionSpeech() => _cancelTimerCompletionSpeech();

  @override
  void onTimerDialogClosed() => _stopMobileRingtone();

  @override
  Widget build(BuildContext context) {
    ref.watch(settingsProvider);
    final appTitle = currentTabIndex == 0
        ? _appLocalizations.clockTab
        : currentTabIndex == 1
        ? _appLocalizations.timerTab
        : _appLocalizations.stopwatchTab;

    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Text(appTitle),
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded),
              tooltip: _appLocalizations.settingsTab,
              onPressed: _openSettings,
            ),
            actions: [
              IconButton(
                onPressed: () => unawaited(_setSpeechMaster(!speechMasterOn)),
                tooltip: speechMasterOn
                    ? _appLocalizations.mainTurnAudioOff
                    : _appLocalizations.mainTurnAudioOn,
                icon: Icon(
                  speechMasterOn
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                ),
              ),
              IconButton(
                onPressed: _openFullscreenFocus,
                tooltip: _appLocalizations.focusMode,
                icon: const Icon(Icons.fullscreen_rounded),
              ),
              if (Platform.isLinux)
                PopupMenuButton<String>(
                  tooltip: _appLocalizations.mainDesktopControls,
                  onSelected: (action) =>
                      unawaited(_handleDesktopAction(action)),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'drive',
                      child: Text(_appLocalizations.mainDriveModeCompact),
                    ),
                    PopupMenuItem(
                      value: 'drive_fullscreen',
                      child: Text(_appLocalizations.mainDriveModeFullscreen),
                    ),
                    const PopupMenuDivider(),
                    CheckedPopupMenuItem(
                      value: 'background',
                      checked: _desktopService.backgroundEnabled.value,
                      child: Text(_appLocalizations.mainKeepRunningWhenClosed),
                    ),
                    CheckedPopupMenuItem(
                      value: 'top',
                      checked: _desktopService.alwaysOnTop.value,
                      child: Text(_appLocalizations.mainAlwaysOnTopDesktopHint),
                    ),
                    PopupMenuItem(
                      value: 'hide',
                      child: Text(_appLocalizations.mainHideToBackground),
                    ),
                  ],
                ),
              IconButton(
                onPressed: () => unawaited(_exitAppFully()),
                tooltip: _appLocalizations.exitButton,
                icon: const Icon(Icons.power_settings_new_rounded),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(currentTabIndex),
              child: currentTabIndex == 0
                  ? _buildSpeakClockTab()
                  : (currentTabIndex == 1
                        ? _buildTimerSetupTab()
                        : _buildStopwatchTab()),
            ),
          ),
          bottomNavigationBar: BottomNavBar(
            selectedIndex: currentTabIndex,
            onDestinationSelected: (index) {
              setState(() {
                currentTabIndex = index;
              });
              if (index != 1) {
                _armedPresetTimer?.cancel();
                _armedPresetValue = null;
              }
            },
            destinations: [
              NavDestination(
                icon: Icons.watch_later_outlined,
                label: _appLocalizations.clockTab,
              ),
              NavDestination(
                icon: Icons.hourglass_empty_rounded,
                label: _appLocalizations.timerTab,
              ),
              NavDestination(
                icon: Icons.timer_outlined,
                label: _appLocalizations.stopwatchTab,
              ),
            ],
          ),
        );
      },
    );
  }
}
