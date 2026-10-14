import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/app_settings.dart';
import '../models/speech_item.dart';
import '../models/timer_runtime.dart';
import '../services/audio_service.dart';
import '../services/malayalam_tts_service.dart';
import '../services/speech_language_service.dart';
import '../services/speech_service.dart';
import '../services/timer_service.dart';
import '../services/voice_session_manager.dart';

abstract interface class SpeechAnnouncementHost {
  bool get mounted;
  AppSettings get settings;
  TimerRuntime get timerRuntime;
  AppLifecycleState? get lifecycleState;
  bool get stopwatchRunning;
  int get goalReminderNextIndex;
  bool get desktopHidden;
  void setSpeechActive(bool active);
  void setVoices(List<Map<dynamic, dynamic>> voices);
  void setGoalReminderNextIndex(int index);
  void saveSettings();
  void stopMobileRingtone();
  Future<void> applyAudioSettings();
  Future<void> updateSpeechMaster(bool enabled);
  void notifyDesktop(String title, String message);
  void persistClockDeadline(DateTime? dueAt);
  void reconcileSpeechForeground();
  String nextQuoteForCategory(String category);
}

class SpeechAnnouncementController {
  SpeechAnnouncementController({
    required SpeechAnnouncementHost host,
    required SpeechService speechService,
    required AudioService audioService,
    required VoiceSessionManager voiceSessionManager,
    required SpeechLanguageService speechLanguageService,
    required MalayalamTtsService malayalamTtsService,
    required TimerService timerService,
  }) : _host = host,
       _speechService = speechService,
       _audioService = audioService,
       _voiceSessionManager = voiceSessionManager,
       _speechLanguageService = speechLanguageService,
       _malayalamTtsService = malayalamTtsService,
       _timerService = timerService;

  final SpeechAnnouncementHost _host;
  final SpeechService _speechService;
  final AudioService _audioService;
  final VoiceSessionManager _voiceSessionManager;
  final SpeechLanguageService _speechLanguageService;
  final MalayalamTtsService _malayalamTtsService;
  final TimerService _timerService;

  FlutterTts flutterTts = FlutterTts();
  bool _ttsReady = false;
  Future<void>? _ttsInitInFlight;
  DateTime _nextTtsInitAllowedAt = DateTime.fromMillisecondsSinceEpoch(0);
  final Queue<SpeechItem> speechQueue = Queue<SpeechItem>();
  Timer? clockTimer;
  DateTime? nextClockAt;
  SpeechItem? _activeSpeechItem;
  int _speechGeneration = 0;
  int _clockScheduleGeneration = 0;
  Future<void> _announcementTail = Future<void>.value();
  final Stopwatch _announcementClock = Stopwatch()..start();
  int _lastAnnouncementElapsedMs = -10000;
  bool isSpeechActive = false;
  int get clockIntervalMins => _settings.clockIntervalMins;
  int get clockSpeakRepeatCount => _settings.clockSpeakRepeatCount;
  int get motivationDelaySeconds => _settings.motivationDelaySeconds;
  String get motivationCategory => _settings.motivationCategory;
  List<Map<dynamic, dynamic>> voices = [];
  final ValueNotifier<List<Map<dynamic, dynamic>>> settingsVoices =
      ValueNotifier(const []);

  bool autoNightMuteActive = false;
  Timer? nightIdleTimer;
  Timer? nightWindowTimer;
  Timer? nightResumeSpeechTimer;
  Timer? _goalReminderTimer;
  DateTime? _nextGoalReminderAt;
  int _stopwatchSpeechGeneration = 0;

  AppSettings get _settings => _host.settings;
  bool get speechMasterOn => _settings.speechMasterOn;
  bool get clockOn => _settings.clockOn;
  bool get clockSpeakTime => _settings.clockSpeakTime;
  bool get motivationOn => _settings.motivationOn;
  bool get timerSpeakOn => _settings.timerSpeakOn;
  bool get stopwatchSpeakOn => _settings.stopwatchSpeakOn;
  bool get muteSpeechAfterMidnight => _settings.muteSpeechAfterMidnight;
  String get nightMuteMode => _settings.nightMuteMode;
  int get sleepStartMinutes => _settings.sleepStartMinutes;
  int get sleepEndMinutes => _settings.sleepEndMinutes;
  String get speechEngineMode => _settings.speechEngineMode;
  double get speakVolume => _settings.speakVolume;
  bool get maximumSpeechVolume => _settings.maximumSpeechVolume;
  String? get favoriteVoiceName => _settings.favoriteVoiceName;
  String? get favoriteVoiceLocale => _settings.favoriteVoiceLocale;

  bool get isAudioMuted => _isAudioMuted();

  Future<void> setSpeechMaster(bool enabled) async {
    if (!_host.mounted) return;
    final settingsWrite = _host.updateSpeechMaster(enabled);
    if (!enabled) {
      cancelPendingSpeech();
      await _stopTts();
      await _audioService.stopBackground();
      await _audioService.stopNotification();
      _host.stopMobileRingtone();
    } else {
      unawaited(_host.applyAudioSettings());
    }
    await settingsWrite;
  }

  Future<void> stopTts() => _stopTts();

  Future<void> _stopTts() async {
    try {
      await _speechService.stopDesktopSpeech();
      if (!Platform.isLinux) await flutterTts.stop();
    } finally {
      if (Platform.isLinux) await _audioService.setSpeechDucking(false);
    }
  }

  Future<bool> initTts({bool forceRebind = false}) async {
    if (Platform.isLinux) {
      _ttsReady = true;
      return true;
    }
    final existing = _ttsInitInFlight;
    if (existing != null) {
      await existing;
      if (!forceRebind) return _ttsReady;
    }
    if (!forceRebind &&
        !_ttsReady &&
        DateTime.now().isBefore(_nextTtsInitAllowedAt)) {
      return false;
    }
    if (forceRebind) {
      final previous = flutterTts;
      await previous.stop().timeout(
        const Duration(seconds: 5),
        onTimeout: () {},
      );
      flutterTts = FlutterTts();
      _voiceSessionManager.resetSession();
      _ttsReady = false;
      _nextTtsInitAllowedAt = DateTime.fromMillisecondsSinceEpoch(0);
    }
    final tts = flutterTts;
    final completer = Completer<void>();
    _ttsInitInFlight = completer.future;
    try {
      tts.setErrorHandler((message) {
        if (identical(tts, flutterTts)) _ttsReady = false;
        debugPrint('TTS error: $message');
      });
      try {
        await tts.awaitSpeakCompletion(true);
        final engine = _speechService.normalizeSpeechEngineMode(
          speechEngineMode,
        );
        if (Platform.isAndroid &&
            engine != 'auto' &&
            engine != 'system_only' &&
            engine != 'sherpa_only') {
          await _speechService.setSpeechEngine(flutterTts: tts, engine: engine);
        }
      } on MissingPluginException {
        _nextTtsInitAllowedAt = DateTime.now().add(const Duration(seconds: 20));
        return false;
      } on PlatformException catch (error) {
        _nextTtsInitAllowedAt = DateTime.now().add(const Duration(seconds: 20));
        debugPrint('TTS init failed: $error');
        return false;
      }
      _ttsReady = true;
      for (var attempt = 1; attempt <= 4; attempt++) {
        try {
          final loaded = _speechService.parseSupportedVoices(
            await tts.getVoices,
          );
          final merged = [
            ..._speechService.malayalamVoices(),
            ...loaded.where(
              (voice) => !(voice['locale']?.toString().toLowerCase() ?? '')
                  .startsWith('ml'),
            ),
          ];
          if (_host.mounted && identical(tts, flutterTts)) {
            voices = merged;
            settingsVoices.value = merged;
            _speechLanguageService.allVoices = merged;
            _host.setVoices(merged);
          }
          break;
        } catch (error) {
          debugPrint('TTS getVoices attempt $attempt failed: $error');
        }
        await Future<void>.delayed(Duration(milliseconds: 250 * attempt));
      }
    } finally {
      completer.complete();
      if (identical(_ttsInitInFlight, completer.future)) {
        _ttsInitInFlight = null;
      }
    }
    return _ttsReady;
  }

  Future<bool> ensureTtsReady({bool forceRebind = false}) async {
    if (_ttsReady && !forceRebind) return true;
    return initTts(forceRebind: forceRebind);
  }

  List<Map<dynamic, dynamic>> availableVoicesForSettings() {
    _speechLanguageService.allVoices = voices;
    return _speechLanguageService.voicesForLanguage();
  }

  Map<dynamic, dynamic>? getPreferredVoice() =>
      _voiceSessionManager.getPreferredVoice(
        voiceResolver: () => _speechService.preferredVoice(
          voices: voices,
          voiceListMode: _speechLanguageService.language,
          favoriteVoiceName: favoriteVoiceName,
          favoriteVoiceLocale: favoriteVoiceLocale,
        ),
        voiceListMode: _speechLanguageService.language,
        favoriteVoiceName: favoriteVoiceName,
        favoriteVoiceLocale: favoriteVoiceLocale,
      );

  bool _isMalayalamActive(Map<dynamic, dynamic>? preferredVoice) =>
      _voiceSessionManager.isMalayalamActive(
        isMalayalamResolver: (voice) => _malayalamTtsService.isMalayalamMode(
          voiceListMode: _speechLanguageService.language,
          preferredVoice: voice,
        ),
        preferredVoice: preferredVoice,
      );

  Map<dynamic, dynamic>? resolveVoiceForNewAnnouncement({
    required bool useMalayalam,
  }) => _voiceSessionManager.resolveVoiceForAnnouncement(
    voices: voices,
    voiceListMode: _speechLanguageService.language,
    favoriteVoiceName: favoriteVoiceName,
    favoriteVoiceLocale: favoriteVoiceLocale,
    isMalayalam: useMalayalam,
    fallbackResolver: () => _speechService.preferredVoice(
      voices: voices,
      voiceListMode: _speechLanguageService.language,
      favoriteVoiceName: favoriteVoiceName,
      favoriteVoiceLocale: favoriteVoiceLocale,
    ),
  );

  Map<dynamic, dynamic>? _preferredEnglishAnnouncementVoice() {
    final english = voices
        .where(
          (voice) =>
              voice['locale']?.toString().toLowerCase().startsWith('en') ??
              false,
        )
        .toList();
    if (english.isEmpty) return null;
    return _speechService.preferredVoice(
      voices: english,
      voiceListMode: 'english',
      favoriteVoiceName: favoriteVoiceName,
      favoriteVoiceLocale: favoriteVoiceLocale,
    );
  }

  void startClock() {
    stopClock();
    if (!clockOn) return;
    if (clockSpeakTime || motivationOn) speakClock(timeToWords());
    nextClockAt = DateTime.now().add(Duration(minutes: clockIntervalMins));
    scheduleNextClockAnnouncement();
    _host.reconcileSpeechForeground();
  }

  void scheduleNextClockAnnouncement() {
    clockTimer?.cancel();
    final due = nextClockAt;
    if (due == null || !clockOn) return;
    _host.persistClockDeadline(due);
    final now = DateTime.now();
    clockTimer = Timer(
      due.isAfter(now) ? due.difference(now) : Duration.zero,
      () {
        if (!_host.mounted || !clockOn) return;
        final firedAt = DateTime.now();
        if (clockSpeakTime || motivationOn) speakClock(timeToWords());
        nextClockAt = _timerService.nextClockAnnouncementAt(
          firedAt: firedAt,
          intervalMinutes: clockIntervalMins,
        );
        scheduleNextClockAnnouncement();
      },
    );
  }

  void restoreClockDeadline(DateTime? dueAt) {
    nextClockAt = dueAt;
    scheduleNextClockAnnouncement();
  }

  bool _isSpeechItemEnabled(SpeechItem item) {
    if (item.isClockAnnouncement &&
        (!clockOn || (item.isQuote ? !motivationOn : !clockSpeakTime))) {
      return false;
    }
    if (item.isTimerAnnouncement && !timerSpeakOn) return false;
    final timer = _host.timerRuntime;
    if (item.isTimerCompletion &&
        (timer.status != TimerRuntimeStatus.finished ||
            timer.runId != item.timerRunId ||
            timer.revision != item.timerRevision)) {
      return false;
    }
    if (item.isStopwatchAnnouncement && !stopwatchSpeakOn) return false;
    return true;
  }

  Future<void> drainQueue() async {
    if (!_host.mounted || _isAudioMuted()) {
      speechQueue.clear();
      if (isSpeechActive && _host.mounted) {
        isSpeechActive = false;
        _host.setSpeechActive(false);
      }
      return;
    }
    if (isSpeechActive || speechQueue.isEmpty) return;
    final generation = _speechGeneration;
    isSpeechActive = true;
    _host.setSpeechActive(true);
    final item = speechQueue.removeFirst();
    if (item.delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: item.delayMs));
    }
    if (!_host.mounted ||
        generation != _speechGeneration ||
        _isAudioMuted() ||
        !_isSpeechItemEnabled(item)) {
      if (_host.mounted) {
        isSpeechActive = false;
        _host.setSpeechActive(false);
        if (generation == _speechGeneration) unawaited(drainQueue());
      }
      return;
    }
    final mode = _speechService.normalizeSpeechEngineMode(speechEngineMode);
    final desktop = Platform.isLinux || Platform.isWindows;
    final desktopSherpaOnly = desktop && mode == 'sherpa_only';
    if (!desktopSherpaOnly && !desktop) {
      final ready = await ensureTtsReady();
      if (!ready) {
        if (_host.mounted) {
          isSpeechActive = false;
          _host.setSpeechActive(false);
        }
        speechQueue.clear();
        return;
      }
      if (!_host.mounted || generation != _speechGeneration) return;
      if (!_isSpeechItemEnabled(item)) {
        isSpeechActive = false;
        _host.setSpeechActive(false);
        unawaited(drainQueue());
        return;
      }
    }
    final activeVoice = item.voice ?? getPreferredVoice();
    final itemUsesMalayalam = item.language == null
        ? _isMalayalamActive(activeVoice)
        : item.language!.toLowerCase().startsWith('ml');
    try {
      if (Platform.isLinux) {
        await _audioService.setSpeechDucking(true);
        if (!_host.mounted ||
            generation != _speechGeneration ||
            _isAudioMuted() ||
            !_isSpeechItemEnabled(item)) {
          return;
        }
        if (_host.desktopHidden) _host.notifyDesktop('Solas Flow', item.text);
      }
      _activeSpeechItem = item;
      await _speechService.speakItem(
        flutterTts: flutterTts,
        item: item,
        speakVolume: speakVolume,
        maximumSpeechVolume: maximumSpeechVolume,
        preferredVoice: activeVoice,
        useMalayalamNuance: itemUsesMalayalam,
        speechEngineMode: speechEngineMode,
      );
    } catch (error) {
      debugPrint('TTS speak failed, retrying after rebind: $error');
      if (generation == _speechGeneration) {
        try {
          final rebound = await ensureTtsReady(forceRebind: true);
          if (rebound && generation == _speechGeneration) {
            await _speechService.speakItem(
              flutterTts: flutterTts,
              item: item,
              speakVolume: speakVolume,
              maximumSpeechVolume: maximumSpeechVolume,
              preferredVoice: item.voice ?? getPreferredVoice(),
              useMalayalamNuance: itemUsesMalayalam,
              speechEngineMode: speechEngineMode,
            );
          }
        } catch (retryError) {
          debugPrint('TTS retry failed: $retryError');
        }
      }
    } finally {
      if (Platform.isLinux &&
          generation == _speechGeneration &&
          (speechQueue.isEmpty || speechQueue.first.delayMs > 0)) {
        await _audioService.setSpeechDucking(false);
      }
      if (identical(_activeSpeechItem, item)) _activeSpeechItem = null;
      if (_host.mounted) {
        isSpeechActive = false;
        _host.setSpeechActive(false);
        if (generation == _speechGeneration && !_isAudioMuted()) {
          unawaited(drainQueue());
        }
      }
    }
  }

  void stopClock() {
    _clockScheduleGeneration++;
    speechQueue.removeWhere((item) => item.isClockAnnouncement);
    clockTimer?.cancel();
    clockTimer = null;
    nextClockAt = null;
    _host.persistClockDeadline(null);
    _host.reconcileSpeechForeground();
  }

  Future<void> toggleClock() async {
    if (clockOn) {
      stopClock();
    } else {
      startClock();
    }
    await _host.applyAudioSettings();
  }

  void cancelPendingSpeech() {
    _speechGeneration++;
    speechQueue.clear();
    if (isSpeechActive && _host.mounted) {
      isSpeechActive = false;
      _host.setSpeechActive(false);
    }
    unawaited(_stopTts());
  }

  void cancelTimerCompletionSpeech() {
    speechQueue.removeWhere((item) => item.isTimerCompletion);
    if (_activeSpeechItem?.isTimerCompletion == true) unawaited(_stopTts());
  }

  void removeClockTimeAnnouncements() => speechQueue.removeWhere(
    (item) => item.isClockAnnouncement && !item.isQuote,
  );

  void removeQuoteAnnouncements() =>
      speechQueue.removeWhere((item) => item.isQuote);

  void removeTimerAnnouncements() =>
      speechQueue.removeWhere((item) => item.isTimerAnnouncement);

  void removeStopwatchAnnouncements() =>
      speechQueue.removeWhere((item) => item.isStopwatchAnnouncement);

  void speak(
    String text, {
    Map<dynamic, dynamic>? voice,
    String? languageOverride,
    bool isTimerAnnouncement = false,
    bool isStopwatchAnnouncement = false,
    bool isTimerCompletion = false,
    String? timerRunId,
    int? timerRevision,
  }) {
    if (_isAudioMuted()) {
      speechQueue.clear();
      return;
    }
    final preferred = getPreferredVoice();
    final useMalayalam = languageOverride == 'en'
        ? false
        : _isMalayalamActive(preferred);
    final language = languageOverride ?? (useMalayalam ? 'ml' : 'en');
    final activeVoice =
        voice ??
        (languageOverride == 'en'
            ? _preferredEnglishAnnouncementVoice()
            : resolveVoiceForNewAnnouncement(useMalayalam: useMalayalam));
    speechQueue.add(
      SpeechItem(
        text,
        language: language,
        voice: activeVoice,
        isTimerAnnouncement: isTimerAnnouncement,
        isStopwatchAnnouncement: isStopwatchAnnouncement,
        isTimerCompletion: isTimerCompletion,
        timerRunId: timerRunId,
        timerRevision: timerRevision,
      ),
    );
    unawaited(drainQueue());
  }

  bool _isNightTime() {
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;
    if (sleepStartMinutes == sleepEndMinutes) {
      return false;
    }
    if (sleepStartMinutes < sleepEndMinutes) {
      return minutes >= sleepStartMinutes && minutes < sleepEndMinutes;
    }
    return minutes >= sleepStartMinutes || minutes < sleepEndMinutes;
  }

  void _cancelNightIdleTimer() {
    nightIdleTimer?.cancel();
    nightIdleTimer = null;
    nightWindowTimer?.cancel();
    nightWindowTimer = null;
  }

  void cancelNightIdleTimer() => _cancelNightIdleTimer();

  void startNightIdleTimerIfNeeded() => _startNightIdleTimerIfNeeded();

  void stopAudioForMute() => _stopAudioForMute();

  void _startNightIdleTimerIfNeeded() {
    _cancelNightIdleTimer();
    if (!muteSpeechAfterMidnight ||
        nightMuteMode != 'automatic' ||
        sleepStartMinutes == sleepEndMinutes) {
      return;
    }
    if (!_isNightTime()) {
      final now = DateTime.now();
      var next = DateTime(
        now.year,
        now.month,
        now.day,
        sleepStartMinutes ~/ 60,
        sleepStartMinutes % 60,
      );
      if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
      nightWindowTimer = Timer(next.difference(now), () {
        if (_host.lifecycleState != AppLifecycleState.resumed) {
          _startNightIdleTimerIfNeeded();
        }
      });
      return;
    }
    nightIdleTimer = Timer(const Duration(minutes: 5), () {
      if (!_host.mounted ||
          !muteSpeechAfterMidnight ||
          nightMuteMode != 'automatic' ||
          !_isNightTime() ||
          _host.lifecycleState == AppLifecycleState.resumed) {
        return;
      }
      autoNightMuteActive = true;
      cancelPendingSpeech();
      unawaited(_audioService.stopBackground());
      unawaited(_audioService.stopNotification());
      _host.stopMobileRingtone();
      final now = DateTime.now();
      var end = DateTime(
        now.year,
        now.month,
        now.day,
        sleepEndMinutes ~/ 60,
        sleepEndMinutes % 60,
      );
      if (!end.isAfter(now)) end = end.add(const Duration(days: 1));
      nightWindowTimer = Timer(end.difference(now), () {
        if (!_host.mounted ||
            !autoNightMuteActive ||
            !muteSpeechAfterMidnight ||
            nightMuteMode != 'automatic' ||
            _isNightTime()) {
          return;
        }
        autoNightMuteActive = false;
        unawaited(_host.applyAudioSettings());
      });
    });
  }

  void refreshNightMuteSchedule() {
    _cancelNightIdleTimer();
    if (muteSpeechAfterMidnight && nightMuteMode == 'automatic') {
      _startNightIdleTimerIfNeeded();
    }
    if (_isAudioMuted()) {
      _stopAudioForMute();
    } else {
      unawaited(_host.applyAudioSettings());
    }
  }

  void _stopAudioForMute() {
    cancelPendingSpeech();
    unawaited(_audioService.stopBackground());
    unawaited(_audioService.stopNotification());
    _host.stopMobileRingtone();
  }

  void _scheduleNightResumeAnnouncement() {
    nightResumeSpeechTimer?.cancel();
    if (!muteSpeechAfterMidnight ||
        nightMuteMode != 'automatic' ||
        !_isNightTime()) {
      return;
    }
    nightResumeSpeechTimer = Timer(const Duration(seconds: 5), () {
      if (!_host.mounted ||
          !muteSpeechAfterMidnight ||
          nightMuteMode != 'automatic' ||
          !_isNightTime()) {
        return;
      }
      speakTimerMessage(timeToWords());
    });
  }

  void handleNightUsageStateChange(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      autoNightMuteActive = false;
      _cancelNightIdleTimer();
      _scheduleNightResumeAnnouncement();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _startNightIdleTimerIfNeeded();
    }
  }

  bool _isAudioMuted() {
    if (!speechMasterOn) return true;
    if (!muteSpeechAfterMidnight || !_isNightTime()) {
      if (autoNightMuteActive) {
        autoNightMuteActive = false;
        unawaited(_restoreAudioAfterNightMute());
      }
      return false;
    }
    if (nightMuteMode == 'manual') return true;
    return autoNightMuteActive;
  }

  Future<void> _restoreAudioAfterNightMute() async {
    if (!_host.mounted || _isAudioMuted()) return;
    await _host.applyAudioSettings();
  }

  void _speakAfterGap({
    required String text,
    required VoidCallback onFire,
    bool Function()? isStillValid,
  }) {
    final generation = _speechGeneration;
    _announcementTail = _announcementTail
        .catchError((Object error, StackTrace stack) {
          debugPrint('Announcement predecessor failed: $error');
        })
        .then((_) async {
          final elapsed = _announcementClock.elapsedMilliseconds;
          final wait = (10000 - (elapsed - _lastAnnouncementElapsedMs)).clamp(
            0,
            10000,
          );
          if (wait > 0) {
            await Future<void>.delayed(Duration(milliseconds: wait));
          }
          if (!_host.mounted ||
              generation != _speechGeneration ||
              _isAudioMuted() ||
              (isStillValid != null && !isStillValid())) {
            return;
          }
          _lastAnnouncementElapsedMs = _announcementClock.elapsedMilliseconds;
          onFire();
        });
  }

  String timeToWords() {
    final preferred = getPreferredVoice();
    return _isMalayalamActive(preferred)
        ? _malayalamTtsService.clockAnnouncement(DateTime.now())
        : _timerService.timeToWords(DateTime.now());
  }

  void speakClock(String text) {
    if (_isAudioMuted()) {
      speechQueue.clear();
      return;
    }
    final generation = _clockScheduleGeneration;
    _speakAfterGap(
      text: text,
      isStillValid: () =>
          clockOn &&
          (clockSpeakTime || motivationOn) &&
          generation == _clockScheduleGeneration,
      onFire: () {
        final preferred = getPreferredVoice();
        final ml = _isMalayalamActive(preferred);
        final voice = resolveVoiceForNewAnnouncement(useMalayalam: ml);
        speechQueue.removeWhere((item) => item.isClockAnnouncement);
        if (clockSpeakTime) {
          final current = timeToWords();
          for (var i = 0; i < clockSpeakRepeatCount.clamp(1, 3); i++) {
            speechQueue.add(
              SpeechItem(
                current,
                isClockAnnouncement: true,
                delayMs: i == 0 ? 0 : 350,
                language: ml ? 'ml' : 'en',
                voice: voice,
              ),
            );
          }
        }
        if (motivationOn) {
          speechQueue.add(
            SpeechItem(
              _host.nextQuoteForCategory(motivationCategory),
              isQuote: true,
              isClockAnnouncement: true,
              delayMs: motivationDelaySeconds * 1000,
              language: ml ? 'ml' : 'en',
              voice: voice,
            ),
          );
        }
        unawaited(drainQueue());
      },
    );
  }

  void speakTimerMessage(
    String text, {
    String? finishedRunId,
    int? finishedRevision,
  }) {
    if (_isAudioMuted()) {
      speechQueue.clear();
      return;
    }
    final ml = _isMalayalamActive(getPreferredVoice());
    final voice = resolveVoiceForNewAnnouncement(useMalayalam: ml);
    _speakAfterGap(
      text: text,
      isStillValid: () =>
          timerSpeakOn &&
          (finishedRunId == null ||
              (_host.timerRuntime.status == TimerRuntimeStatus.finished &&
                  _host.timerRuntime.runId == finishedRunId &&
                  _host.timerRuntime.revision == finishedRevision)),
      onFire: () => speak(
        text,
        voice: voice,
        isTimerAnnouncement: true,
        isTimerCompletion: finishedRunId != null,
        timerRunId: finishedRunId,
        timerRevision: finishedRevision,
      ),
    );
  }

  void speakStopwatchMessage(
    String text, {
    bool explicit = false,
    required bool stopwatchSpeakOn,
  }) {
    if (_isAudioMuted()) {
      speechQueue.clear();
      return;
    }
    final generation = _stopwatchSpeechGeneration;
    _speakAfterGap(
      text: text,
      isStillValid: () =>
          generation == _stopwatchSpeechGeneration &&
          (explicit || (_host.stopwatchRunning && stopwatchSpeakOn)),
      onFire: () => speak(
        text,
        isStopwatchAnnouncement: !explicit,
        languageOverride: 'en',
      ),
    );
  }

  void invalidateStopwatchSpeech() => _stopwatchSpeechGeneration++;

  void speakGoalReminderMessage(
    String text, {
    required bool goalReminderOn,
    required bool hasGoals,
  }) {
    if (_isAudioMuted()) {
      speechQueue.clear();
      return;
    }
    _speakAfterGap(
      text: text,
      isStillValid: () => goalReminderOn && hasGoals,
      onFire: () => speak(text),
    );
  }

  void announceNextGoalReminder({required bool force}) {
    final items = _settings.goalReminderItems;
    if ((!_settings.goalReminderOn && !force) || items.isEmpty) return;
    final index =
        ((_host.goalReminderNextIndex % items.length) + items.length) %
        items.length;
    _host.setGoalReminderNextIndex((index + 1) % items.length);
    _host.saveSettings();
    speakGoalReminderMessage(
      'Goal reminder: ${items[index]}',
      goalReminderOn: _settings.goalReminderOn,
      hasGoals: items.isNotEmpty,
    );
  }

  void restartGoalReminderTimer() {
    _goalReminderTimer?.cancel();
    _goalReminderTimer = null;
    _nextGoalReminderAt = null;
    if (!_settings.goalReminderOn || _settings.goalReminderItems.isEmpty) {
      return;
    }
    _nextGoalReminderAt = DateTime.now().add(
      Duration(minutes: _settings.goalReminderIntervalMins),
    );
    _scheduleNextGoalReminder();
  }

  void _scheduleNextGoalReminder() {
    final due = _nextGoalReminderAt;
    if (due == null ||
        !_settings.goalReminderOn ||
        _settings.goalReminderItems.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final delay = due.isAfter(now) ? due.difference(now) : Duration.zero;
    _goalReminderTimer = Timer(delay, () {
      if (!_host.mounted ||
          !_settings.goalReminderOn ||
          _settings.goalReminderItems.isEmpty) {
        return;
      }
      announceNextGoalReminder(force: false);
      final interval = Duration(minutes: _settings.goalReminderIntervalMins);
      var next = due.add(interval);
      final current = DateTime.now();
      while (!next.isAfter(current)) {
        next = next.add(interval);
      }
      _nextGoalReminderAt = next;
      _scheduleNextGoalReminder();
    });
  }

  void testSpeech() {
    final preferred = getPreferredVoice();
    final ml = _isMalayalamActive(preferred);
    final voice = resolveVoiceForNewAnnouncement(useMalayalam: ml);
    speak(
      ml
          ? 'ഇത് ശബ്ദ പരിശോധനയാണ്. നിങ്ങളുടെ ടൈമർ ആരംഭിക്കാൻ തയ്യാറാണ്.'
          : 'This is a voice test. Your focus timer is ready.',
      voice: voice,
    );
  }

  void dispose() {
    clockTimer?.cancel();
    nightIdleTimer?.cancel();
    nightWindowTimer?.cancel();
    nightResumeSpeechTimer?.cancel();
    _goalReminderTimer?.cancel();
    settingsVoices.dispose();
  }
}
