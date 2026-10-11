import 'package:flutter_tts/flutter_tts.dart';

import 'malayalam_tts_service.dart';

/// Centralized speech language manager.
/// The selected language is the single source of truth for all speech.
class SpeechLanguageService {
  static const List<String> supportedLanguages = ['auto', 'english', 'malayalam'];

  /// The active speech language ('auto', 'english', 'malayalam').
  String _language = 'auto';
  String get language => _language;

  /// Available TTS voices (set externally from [FlutterTts.getVoices]).
  List<Map<dynamic, dynamic>> allVoices = [];

  /// Sets the language. Returns true if changed.
  bool setLanguage(String lang) {
    final normalized = lang.trim().toLowerCase();
    if (!supportedLanguages.contains(normalized)) return false;
    if (_language == normalized) return false;
    _language = normalized;
    return true;
  }

  /// Returns voices filtered to the active language.
  List<Map<dynamic, dynamic>> voicesForLanguage() {
    final studioMl = MalayalamTtsService.voices
        .map((v) => Map<String, dynamic>.from(v))
        .toList();

    final ml = allVoices.where((v) {
      final locale = (v['locale']?.toString() ?? '').toLowerCase().replaceAll('_', '-');
      return locale.startsWith('ml') && v['backend'] != 'neural_asset';
    }).toList();

    if (_language == 'malayalam') {
      return [...studioMl, ...ml];
    }
    if (_language == 'english') {
      return allVoices.where((v) {
        final locale = (v['locale']?.toString() ?? '').toLowerCase().replaceAll('_', '-');
        return locale.startsWith('en');
      }).toList();
    }
    // Auto mode: return all voices (Studio Malayalam first, then system ML, then English)
    final en = allVoices.where((v) {
      final locale = (v['locale']?.toString() ?? '').toLowerCase().replaceAll('_', '-');
      return locale.startsWith('en');
    }).toList();
    return [
      ...studioMl,
      ...ml,
      ...en,
    ];
  }

  /// Finds the best voice for the active language from the available voices.
  /// Returns null if no suitable voice exists.
  Map<dynamic, dynamic>? preferredVoice({
    required String? favoriteVoiceName,
    required String? favoriteVoiceLocale,
  }) {
    final langVoices = voicesForLanguage();
    if (langVoices.isEmpty) return null;

    // Try favorite voice first (if not special key like __rotate__ or __auto__)
    if (favoriteVoiceName != null &&
        favoriteVoiceLocale != null &&
        favoriteVoiceName != '__rotate__' &&
        favoriteVoiceName != '__auto__') {
      final match = langVoices.cast<Map<dynamic, dynamic>?>().firstWhere(
        (v) =>
            v?['name']?.toString() == favoriteVoiceName &&
            v?['locale']?.toString() == favoriteVoiceLocale,
        orElse: () => null,
      );
      if (match != null) return match;
    }

    // Prefer enhigh-quality voices (neural, veena, rishi, wavenet)
    for (final v in langVoices) {
      final name = (v['name']?.toString() ?? '').toLowerCase();
      if (name.contains('neural') || name.contains('wavenet')) return v;
    }
    if (_language == 'malayalam') {
      for (final v in langVoices) {
        final name = (v['name']?.toString() ?? '').toLowerCase();
        if (name.contains('veena') || name.contains('rishi')) return v;
      }
    }

    // Fallback: first available voice for language
    if (langVoices.isNotEmpty) return langVoices.first;
    if (_language == 'malayalam') {
      return {'name': 'Standard Malayalam', 'locale': 'ml-IN'};
    }
    return null;
  }



}
