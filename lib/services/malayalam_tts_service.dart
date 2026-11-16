import 'dart:convert';

import 'package:flutter/services.dart';

class MalayalamTtsService {
  static const List<Map<String, String>> voices = [
    {
      'id': 'female_1',
      'name': 'Malayalam Aoede (Female 1 · Natural)',
      'locale': 'ml-IN',
      'gender': 'female',
      'backend': 'neural_asset',
    },
    {
      'id': 'female_2',
      'name': 'Malayalam Kore (Female 2 · Clear)',
      'locale': 'ml-IN',
      'gender': 'female',
      'backend': 'neural_asset',
    },
    {
      'id': 'male_1',
      'name': 'Malayalam Puck (Male 1 · Upbeat)',
      'locale': 'ml-IN',
      'gender': 'male',
      'backend': 'neural_asset',
    },
    {
      'id': 'male_2',
      'name': 'Malayalam Charon (Male 2 · Deep)',
      'locale': 'ml-IN',
      'gender': 'male',
      'backend': 'neural_asset',
    },
  ];

  /// The single Malayalam voice used when the user has not pinned one.
  /// Studio neural voice set only — the Piper Meera/Arjun models were removed.
  static const String defaultVoiceId = 'female_1';

  static String resolveVoiceId(Map<dynamic, dynamic>? preferredVoice) {
    if (preferredVoice == null) return defaultVoiceId;
    final name = (preferredVoice['name']?.toString() ?? '').toLowerCase();
    final id = (preferredVoice['id']?.toString() ?? '').toLowerCase();

    if (name.contains('kore') ||
        id == 'female_2' ||
        name.contains('female 2')) {
      return 'female_2';
    }
    if (name.contains('puck') || id == 'male_1' || name.contains('male 1')) {
      return 'male_1';
    }
    if (name.contains('charon') || id == 'male_2' || name.contains('male 2')) {
      return 'male_2';
    }
    // Any stale Piper/legacy selection (Meera, Arjun, system voice) resolves
    // to the default studio voice so Malayalam never switches voice sets.
    return defaultVoiceId;
  }

  static String voiceDisplayName(String voiceId) {
    for (final v in voices) {
      if (v['id'] == voiceId) return v['name']!;
    }
    return 'Malayalam Aoede (Female 1 · Natural)';
  }

  static Map<String, dynamic> defaultVoice() =>
      Map<String, dynamic>.from(voices.first);

  bool isMalayalamMode({
    required String voiceListMode,
    required Map<dynamic, dynamic>? preferredVoice,
  }) {
    final mode = voiceListMode.trim().toLowerCase();
    if (mode == 'malayalam') return true;

    final locale = preferredVoice?['locale']?.toString().toLowerCase() ?? '';
    if (locale.startsWith('ml')) return true;
    return false;
  }

  String clockAnnouncement(DateTime now) {
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute;

    if (minute == 0) {
      return '$hour12 മണി.';
    }

    return '$hour12 മണി $minute മിനിറ്റ്.';
  }

  String timerRemaining(int minutes) {
    return 'ഇനി $minutes മിനിറ്റ്.';
  }

  String nextTimerStarting(int minutes) {
    return 'അടുത്ത ടൈമർ ആരംഭിക്കുന്നു. സമയം $minutes മിനിറ്റ്.';
  }

  String timerFinished() {
    return 'സമയം തീർന്നു.';
  }

  static const String _quoteCatalogPath =
      'assets/audio/malayalam/shared_quotes/quote_catalog.json';
  Map<String, List<String>> _quotesByCategory = {};
  final Map<String, String> _quoteIdsByText = {};
  final Map<String, String> _voiceQuoteFilesById = {};
  final Map<String, String> _sharedQuoteFilesById = {};
  String _defaultQuote = '';
  bool _quoteCatalogLoaded = false;

  Future<void> loadQuoteCatalog() async {
    if (_quoteCatalogLoaded) return;
    final decoded = jsonDecode(await rootBundle.loadString(_quoteCatalogPath));
    if (decoded is! Map<String, dynamic> ||
        decoded['categories'] is! List ||
        decoded['default'] is! Map<String, dynamic>) {
      throw const FormatException('Invalid Malayalam quote catalog');
    }

    final ids = <String>{};
    final categories = <String, List<String>>{};
    final quoteIdsByText = <String, String>{};
    final voiceQuoteFilesById = <String, String>{};
    final sharedQuoteFilesById = <String, String>{};

    void addQuote(Map<String, dynamic> quote) {
      final id = quote['id'];
      final text = quote['text'];
      if (id is! String || id.isEmpty || text is! String || text.isEmpty) {
        throw const FormatException('Invalid Malayalam quote entry');
      }
      if (!ids.add(id)) {
        throw FormatException('Duplicate Malayalam quote id: $id');
      }
      quoteIdsByText.putIfAbsent(text, () => id);
      final voiceAsset = quote['voice_asset'];
      final sharedAsset = quote['shared_asset'];
      if (voiceAsset is String && voiceAsset.isNotEmpty) {
        voiceQuoteFilesById[id] = voiceAsset;
      }
      if (sharedAsset is String && sharedAsset.isNotEmpty) {
        sharedQuoteFilesById[id] = sharedAsset;
      }
      final hasVoiceAsset = voiceAsset is String && voiceAsset.isNotEmpty;
      final hasSharedAsset = sharedAsset is String && sharedAsset.isNotEmpty;
      if (!hasVoiceAsset && !hasSharedAsset) {
        throw FormatException('Quote has no audio asset: $id');
      }
    }

    final defaultQuote = decoded['default'] as Map<String, dynamic>;
    addQuote(defaultQuote);
    final defaultText = defaultQuote['text'] as String;
    final rawCategories = decoded['categories'] as List<dynamic>;
    for (final rawCategory in rawCategories) {
      if (rawCategory is! Map<String, dynamic> ||
          rawCategory['name'] is! String ||
          rawCategory['quotes'] is! List) {
        throw const FormatException('Invalid Malayalam quote category');
      }
      final category = rawCategory['name'] as String;
      if (categories.containsKey(category)) {
        throw FormatException('Duplicate Malayalam quote category: $category');
      }
      final quotes = <String>[];
      for (final rawQuote in rawCategory['quotes'] as List<dynamic>) {
        if (rawQuote is! Map<String, dynamic>) {
          throw const FormatException('Invalid Malayalam quote entry');
        }
        addQuote(rawQuote);
        quotes.add(rawQuote['text'] as String);
      }
      categories[category] = List<String>.unmodifiable(quotes);
    }

    _quotesByCategory = categories;
    _quoteIdsByText
      ..clear()
      ..addAll(quoteIdsByText);
    _voiceQuoteFilesById
      ..clear()
      ..addAll(voiceQuoteFilesById);
    _sharedQuoteFilesById
      ..clear()
      ..addAll(sharedQuoteFilesById);
    _defaultQuote = defaultText;
    _quoteCatalogLoaded = true;
  }

  String defaultQuote() => _defaultQuote;

  List<String> quotesForCategory(String category) =>
      _quotesByCategory[category] ?? _quotesByCategory['General'] ?? const [];

  List<String>? resolveAudioClips(String text, {String voiceId = 'female_1'}) {
    final trimmed = text.trim();
    final voice = resolveVoiceId({'id': voiceId, 'name': voiceId});

    // 1. Sound test phrase
    if (trimmed.contains('ശബ്ദ പരിശോധന') || trimmed.contains('തയ്യാറാണ്')) {
      return ['audio/malayalam/$voice/test.mp3'];
    }

    // 2. Timer finished: 'സമയം തീർന്നു.'
    if (trimmed == 'സമയം തീർന്നു.' || trimmed == 'സമയം തീർന്നു') {
      return ['audio/malayalam/$voice/timer/finished.mp3'];
    }

    // 3. Next timer starting: 'അടുത്ത ടൈമർ ആരംഭിക്കുന്നു. സമയം X മിനിറ്റ്.'
    if (trimmed.startsWith('അടുത്ത ടൈമർ ആരംഭിക്കുന്നു')) {
      final clips = <String>['audio/malayalam/$voice/timer/starting.mp3'];
      final minMatch = RegExp(r'(\d+)\s*മിനിറ്റ്').firstMatch(trimmed);
      if (minMatch != null) {
        final m = int.tryParse(minMatch.group(1)!);
        if (m != null && m >= 1 && m <= 59) {
          clips.add(
            'audio/malayalam/$voice/clock/minutes/m_${m.toString().padLeft(2, '0')}.mp3',
          );
        }
      }
      return clips;
    }

    // 4. Timer remaining: 'ഇനി X മിനിറ്റ്.'
    final remMatch = RegExp(r'ഇനി\s+(\d+)\s+മിനിറ്റ്').firstMatch(trimmed);
    if (remMatch != null) {
      final r = int.tryParse(remMatch.group(1)!);
      if (r != null && r >= 1 && r <= 60) {
        return [
          'audio/malayalam/$voice/timer/rem_${r.toString().padLeft(2, '0')}.mp3',
        ];
      }
    }

    // 5. Clock announcement: '$hour12 മണി.' or '$hour12 മണി $minute മിനിറ്റ്.'
    final clockMatch = RegExp(
      r'(\d+)\s*മണി(?:\s*(\d+)\s*മിനിറ്റ്)?',
    ).firstMatch(trimmed);
    if (clockMatch != null) {
      final h = int.tryParse(clockMatch.group(1)!);
      final mStr = clockMatch.group(2);
      final m = mStr != null ? int.tryParse(mStr) : null;
      if (h != null && h >= 1 && h <= 12) {
        final clips = <String>[
          'audio/malayalam/$voice/clock/hours/h_${h.toString().padLeft(2, '0')}.mp3',
        ];
        if (m != null && m >= 1 && m <= 59) {
          clips.add(
            'audio/malayalam/$voice/clock/minutes/m_${m.toString().padLeft(2, '0')}.mp3',
          );
        }
        return clips;
      }
    }

    // 6. Motivational Quotes
    for (final entry in _quoteIdsByText.entries) {
      if (!_voiceQuoteFilesById.containsKey(entry.value) ||
          (trimmed != entry.key && !trimmed.startsWith(entry.key))) {
        continue;
      }
      return [
        'audio/malayalam/$voice/quotes/${_voiceQuoteFilesById[entry.value]}.mp3',
      ];
    }
    for (final entry in _quoteIdsByText.entries) {
      if (!_sharedQuoteFilesById.containsKey(entry.value) ||
          (trimmed != entry.key && !trimmed.startsWith(entry.key))) {
        continue;
      }
      return [
        'audio/malayalam/shared_quotes/${_sharedQuoteFilesById[entry.value]}.mp3',
      ];
    }

    return null;
  }
}
