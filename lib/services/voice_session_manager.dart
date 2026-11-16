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

  int _englishRotationIndex = 0;

  /// Advances and returns the next English voice in rotation.
  Map<dynamic, dynamic>? nextRotatedVoice({
    required List<Map<dynamic, dynamic>> voices,
    required String language,
  }) {
    final filtered = voices.where((v) {
      final loc = (v['locale']?.toString() ?? '').toLowerCase().replaceAll('_', '-');
      return loc.startsWith('en');
    }).toList();

    if (filtered.isEmpty) return null;

    final voice = filtered[_englishRotationIndex % filtered.length];
    _englishRotationIndex = (_englishRotationIndex + 1) % filtered.length;
    return voice;
  }

  /// Resolves the voice to use for an announcement.
  ///
  /// Malayalam is pinned to exactly one studio voice for the whole session —
  /// the pinned favourite when set, otherwise the default studio voice — so a
  /// clock/quote announcement can never change voice mid-sentence. English may
  /// still rotate when the user explicitly selects "rotate".
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
      // Single voice, no rotation. The resolver is session-cached, so every
      // Malayalam announcement reuses the same studio voice.
      return getPreferredVoice(
        voiceResolver: fallbackResolver,
        voiceListMode: voiceListMode,
        favoriteVoiceName: favoriteVoiceName,
        favoriteVoiceLocale: favoriteVoiceLocale,
      );
    }

    if (favoriteVoiceName == '__rotate__') {
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
