/// Singleton voice session manager that resolves and caches the active
/// TTS voice configuration for the duration of a speech session.
///
/// This prevents language mixing (Malayalam + English) during announcements
/// by locking the voice at session start and only re-resolving when the
/// user explicitly changes language/voice settings.
class VoiceSessionManager {
  VoiceSessionManager._();
  static final VoiceSessionManager _instance = VoiceSessionManager._();
  factory VoiceSessionManager() => _instance;

  /// Cached preferred voice (resolved once per session).
  Map<dynamic, dynamic>? _cachedVoice;

  bool? _cachedIsMalayalam;

  /// The voice list mode at the time of caching.
  String _cachedVoiceListMode = '';

  /// The favorite voice name at the time of caching.
  String? _cachedFavoriteVoiceName;

  /// The favorite voice locale at the time of caching.
  String? _cachedFavoriteVoiceLocale;

  int _malayalamRotationIndex = 0;
  int _englishRotationIndex = 0;

  /// Advances and returns the next voice in rotation for the given language.
  Map<dynamic, dynamic>? nextRotatedVoice({
    required List<Map<dynamic, dynamic>> voices,
    required String language,
  }) {
    final targetLang = language.toLowerCase();
    final filtered = voices.where((v) {
      final loc = (v['locale']?.toString() ?? '').toLowerCase().replaceAll('_', '-');
      return loc.startsWith(targetLang == 'ml' || targetLang == 'malayalam' ? 'ml' : 'en');
    }).toList();

    if (filtered.isEmpty) return null;

    if (targetLang == 'ml' || targetLang == 'malayalam') {
      final voice = filtered[_malayalamRotationIndex % filtered.length];
      _malayalamRotationIndex = (_malayalamRotationIndex + 1) % filtered.length;
      return voice;
    } else {
      final voice = filtered[_englishRotationIndex % filtered.length];
      _englishRotationIndex = (_englishRotationIndex + 1) % filtered.length;
      return voice;
    }
  }

  /// Resolves the voice to use for an announcement.
  /// When Malayalam is active and no specific voice is pinned (or '__rotate__' is chosen),
  /// it rotates through all available Malayalam voices.
  Map<dynamic, dynamic>? resolveVoiceForAnnouncement({
    required List<Map<dynamic, dynamic>> voices,
    required String voiceListMode,
    required String? favoriteVoiceName,
    required String? favoriteVoiceLocale,
    required bool isMalayalam,
    required Map<dynamic, dynamic>? Function() fallbackResolver,
  }) {
    final isExplicitPinned = favoriteVoiceName != null &&
        favoriteVoiceName != '__rotate__' &&
        favoriteVoiceName != '__auto__';

    if (isExplicitPinned) {
      final match = voices.cast<Map<dynamic, dynamic>?>().firstWhere(
        (v) =>
            v?['name']?.toString() == favoriteVoiceName &&
            (favoriteVoiceLocale == null ||
                v?['locale']?.toString() == favoriteVoiceLocale),
        orElse: () => null,
      );
      if (match != null) return match;
    }

    if (isMalayalam) {
      final rotated = nextRotatedVoice(voices: voices, language: 'ml');
      if (rotated != null) return rotated;
    } else if (favoriteVoiceName == '__rotate__') {
      final rotated = nextRotatedVoice(voices: voices, language: 'en');
      if (rotated != null) return rotated;
    }

    return getPreferredVoice(
      voiceResolver: fallbackResolver,
      voiceListMode: voiceListMode,
      favoriteVoiceName: favoriteVoiceName,
      favoriteVoiceLocale: favoriteVoiceLocale,
    );
  }

  /// Whether the cache is valid for the current settings.
  bool _isCacheValid({
    required String voiceListMode,
    required String? favoriteVoiceName,
    required String? favoriteVoiceLocale,
  }) {
    return _cachedVoice != null &&
        _cachedVoiceListMode == voiceListMode &&
        _cachedFavoriteVoiceName == favoriteVoiceName &&
        _cachedFavoriteVoiceLocale == favoriteVoiceLocale;
  }

  /// Returns the cached preferred voice, or resolves a new one if cache is invalid.
  /// [voiceResolver] should return a single preferred voice Map (not a list).
  Map<dynamic, dynamic>? getPreferredVoice({
    required Map<dynamic, dynamic>? Function() voiceResolver,
    required String voiceListMode,
    required String? favoriteVoiceName,
    required String? favoriteVoiceLocale,
  }) {
    if (!_isCacheValid(
      voiceListMode: voiceListMode,
      favoriteVoiceName: favoriteVoiceName,
      favoriteVoiceLocale: favoriteVoiceLocale,
    )) {
      _cachedVoice = voiceResolver();
      _cachedIsMalayalam = null;
      _cachedVoiceListMode = voiceListMode;
      _cachedFavoriteVoiceName = favoriteVoiceName;
      _cachedFavoriteVoiceLocale = favoriteVoiceLocale;
    }
    return _cachedVoice;
  }

  /// Returns the cached Malayalam state, or resolves from voice.
  bool isMalayalamActive({
    required bool Function(Map<dynamic, dynamic>?) isMalayalamResolver,
    required Map<dynamic, dynamic>? preferredVoice,
  }) {
    _cachedIsMalayalam ??= isMalayalamResolver(preferredVoice);
    return _cachedIsMalayalam!;
  }

  /// Resets the entire session cache. Call when user changes voice settings.
  void resetSession() {
    _cachedVoice = null;
    _cachedIsMalayalam = null;
    _cachedVoiceListMode = '';
    _cachedFavoriteVoiceName = null;
    _cachedFavoriteVoiceLocale = null;
  }
}
