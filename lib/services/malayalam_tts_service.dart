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

  static String resolveVoiceId(Map<dynamic, dynamic>? preferredVoice) {
    if (preferredVoice == null) return 'female_1';
    final name = (preferredVoice['name']?.toString() ?? '').toLowerCase();
    final id = (preferredVoice['id']?.toString() ?? '').toLowerCase();

    if (name.contains('kore') || id == 'female_2' || name.contains('female 2')) {
      return 'female_2';
    }
    if (name.contains('puck') || id == 'male_1' || name.contains('male 1')) {
      return 'male_1';
    }
    if (name.contains('charon') || id == 'male_2' || name.contains('male 2')) {
      return 'male_2';
    }
    if (name.contains('arjun') || name.contains('male')) {
      return 'male_1';
    }
    return 'female_1';
  }

  static String voiceDisplayName(String voiceId) {
    for (final v in voices) {
      if (v['id'] == voiceId) return v['name']!;
    }
    return 'Malayalam Aoede (Female 1 · Natural)';
  }

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
  // String periodText(DateTime now) {
  //   if (now.hour < 12) return 'രാവിലെ';
  //   if (now.hour < 17) return 'ഉച്ചയ്ക്ക്';
  //   if (now.hour < 20) return 'വൈകുന്നേരം';
  //   return 'രാത്രി';
  // }

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

  String defaultQuote() {
    return 'നമുക്ക് മുന്നോട്ട് പോകാം, സമയം നന്നായി ഉപയോഗിക്കുക.';
  }

  List<String> quotesForCategory(String category) {
    switch (category) {
      case 'Focus':
        return const [
          'നിങ്ങളുടെ ശ്രദ്ധയാണ് ഏറ്റവും വലിയ ശക്തി.',
          'ഒരു മണിക്കൂർ നല്ല ശ്രദ്ധയോടെ ചെയ്താൽ വലിയ മാറ്റമുണ്ടാകും.',
          'നന്നായി ശ്രദ്ധിക്കുക, ഫലം തനിയെ വരും.',
          'മറ്റു കാര്യങ്ങൾ മാറ്റി വെച്ച് ഇപ്പോൾ ചെയ്യുന്നതിൽ മാത്രം ശ്രദ്ധിക്കുക.',
          'ഇപ്പോഴത്തെ കുറച്ചു ബുദ്ധിമുട്ട് പിന്നീട് സന്തോഷം നൽകും.',
        ];
      case 'Discipline':
        return const [
          'ചെറിയ കാര്യങ്ങൾ കൃത്യമായി ചെയ്യുന്നതാണ് യഥാർത്ഥ അച്ചടക്കം.',
          'വിജയം എന്നത് എന്നും ചെയ്യുന്ന ചെറിയ ശീലങ്ങളാണ്.',
          'ഇപ്പോഴത്തെ പരിശ്രമം നാളത്തെ ദിവസങ്ങൾ എളുപ്പമാക്കും.',
          'മടി കാണിക്കരുത്, വേണ്ടത് എന്താണോ അത് ചെയ്യുക.',
          'ശരിയായ ശീലങ്ങൾ നമ്മെ ലക്ഷ്യത്തിൽ എത്തിക്കും.',
        ];
      case 'Calm':
        return const [
          'ദീർഘമായി ശ്വാസമെടുക്കൂ, ഈ ഒരു കാര്യത്തിൽ മാത്രം മനസ്സുറപ്പിക്കൂ.',
          'തിരക്ക് പിടിക്കേണ്ട, ശാന്തമായി കാര്യങ്ങൾ ചെയ്യുക.',
          'നമുക്ക് ഇനിയും സമയമുണ്ട്, സമാധാനത്തോടെ ചെയ്യാം.',
          'ഓരോ നിമിഷവും പുതിയൊരു തുടക്കത്തിന് പറ്റിയതാണ്.',
          'ശാന്തമായ മനസ്സോടെ ചെയ്യുന്ന കാര്യങ്ങളെല്ലാം മികച്ചതായിരിക്കും.',
        ];
      case 'Positivity':
        return const [
          'നല്ലത് ചിന്തിക്കുക, നല്ലത് മാത്രം സംഭവിക്കും.',
          'ഇന്നത്തെ പരിശ്രമം നാളത്തെ വലിയ വിജയമായി മാറും.',
          'ചെറിയ കാൽവെപ്പുകളും നമ്മെ മുന്നോട്ട് നയിക്കുന്നു.',
          'നമ്മൾ തുടങ്ങുന്ന സമയമാണ് ഏറ്റവും നല്ല സമയം.',
          'നല്ലൊരു മനസ്സുണ്ടെങ്കിൽ ഏതു വലിയ കാര്യവും എളുപ്പത്തിൽ തീർക്കാം.',
        ];
      case 'Historic Figures':
        return const [
          'നഷ്ടപ്പെട്ട സമയം ഒരിക്കലും തിരികെ കിട്ടില്ല.',
          'നമ്മൾ സ്ഥിരമായി ചെയ്യുന്ന കാര്യങ്ങളാണ് നമ്മുടെ സ്വഭാവം.',
          'സമയം ശരിയായി വിനിയോഗിക്കുന്നവർക്ക് അത് എപ്പോഴും ധാരാളമായിരിക്കും.',
          'ഒന്നും ചെയ്യാതെ ഇരുന്നാൽ ഒന്നും നടക്കില്ല.',
          'സൂര്യപ്രകാശം പോലെ ഒരിടത്ത് മാത്രം ശ്രദ്ധ കേന്ദ്രീകരിച്ചാൽ ഏതു കാര്യവും നടക്കും.',
        ];
      default:
        return const [
          'ഈ സമയം ബുദ്ധിപൂർവ്വം ഉപയോഗിക്കുക.',
          'സ്ഥിരമായുള്ള ചെറിയ മാറ്റങ്ങൾ വലിയ ലക്ഷ്യങ്ങളിൽ എത്തിക്കും.',
          'തിരിച്ചുകിട്ടാത്ത വലിയൊരു സമ്പത്താണ് സമയം.',
          'നമുക്ക് ചെയ്യാൻ പറ്റുന്നത് ഇപ്പോൾ തന്നെ ചെയ്യുക.',
          'ഇന്നത്തെ നമ്മുടെ പ്രവർത്തിയാണ് നമ്മുടെ ഭാവിയെ തീരുമാനിക്കുന്നത്.',
        ];
    }
  }

  static const Map<String, String> _quoteFileMap = {
    'നമുക്ക് മുന്നോട്ട് പോകാം, സമയം നന്നായി ഉപയോഗിക്കുക.': 'default',
    'നിങ്ങളുടെ ശ്രദ്ധയാണ് ഏറ്റവും വലിയ ശക്തി.': 'focus_1',
    'ഒരു മണിക്കൂർ നല്ല ശ്രദ്ധയോടെ ചെയ്താൽ വലിയ മാറ്റമുണ്ടാകും.': 'focus_2',
    'നന്നായി ശ്രദ്ധിക്കുക, ഫലം തനിയെ വരും.': 'focus_3',
    'മറ്റു കാര്യങ്ങൾ മാറ്റി വെച്ച് ഇപ്പോൾ ചെയ്യുന്നതിൽ മാത്രം ശ്രദ്ധിക്കുക.': 'focus_4',
    'ഇപ്പോഴത്തെ കുറച്ചു ബുദ്ധിമുട്ട് പിന്നീട് സന്തോഷം നൽകും.': 'focus_5',
    'ചെറിയ കാര്യങ്ങൾ കൃത്യമായി ചെയ്യുന്നതാണ് യഥാർത്ഥ അച്ചടക്കം.': 'discipline_1',
    'വിജയം എന്നത് എന്നും ചെയ്യുന്ന ചെറിയ ശീലങ്ങളാണ്.': 'discipline_2',
    'ഇപ്പോഴത്തെ പരിശ്രമം നാളത്തെ ദിവസങ്ങൾ എളുപ്പമാക്കും.': 'discipline_3',
    'മടി കാണിക്കരുത്, വേണ്ടത് എന്താണോ അത് ചെയ്യുക.': 'discipline_4',
    'ശരിയായ ശീലങ്ങൾ നമ്മെ ലക്ഷ്യത്തിൽ എത്തിക്കും.': 'discipline_5',
    'ദീർഘമായി ശ്വാസമെടുക്കൂ, ഈ ഒരു കാര്യത്തിൽ മാത്രം മനസ്സുറപ്പിക്കൂ.': 'calm_1',
    'തിരക്ക് പിടിക്കേണ്ട, ശാന്തമായി കാര്യങ്ങൾ ചെയ്യുക.': 'calm_2',
    'നമുക്ക് ഇനിയും സമയമുണ്ട്, സമാധാനത്തോടെ ചെയ്യാം.': 'calm_3',
    'ഓരോ നിമിഷവും പുതിയൊരു തുടക്കത്തിന് പറ്റിയതാണ്.': 'calm_4',
    'ശാന്തമായ മനസ്സോടെ ചെയ്യുന്ന കാര്യങ്ങളെല്ലാം മികച്ചതായിരിക്കും.': 'calm_5',
    'നല്ലത് ചിന്തിക്കുക, നല്ലത് മാത്രം സംഭവിക്കും.': 'positivity_1',
    'ഇന്നത്തെ പരിശ്രമം നാളത്തെ വലിയ വിജയമായി മാറും.': 'positivity_2',
    'ചെറിയ കാൽവെപ്പുകളും നമ്മെ മുന്നോട്ട് നയിക്കുന്നു.': 'positivity_3',
    'നമ്മൾ തുടങ്ങുന്ന സമയമാണ് ഏറ്റവും നല്ല സമയം.': 'positivity_4',
    'നല്ലൊരു മനസ്സുണ്ടെങ്കിൽ ഏതു വലിയ കാര്യവും എളുപ്പത്തിൽ തീർക്കാം.': 'positivity_5',
    'നഷ്ടപ്പെട്ട സമയം ഒരിക്കലും തിരികെ കിട്ടില്ല.': 'historic_1',
    'നമ്മൾ സ്ഥിരമായി ചെയ്യുന്ന കാര്യങ്ങളാണ് നമ്മുടെ സ്വഭാവം.': 'historic_2',
    'സമയം ശരിയായി വിനിയോഗിക്കുന്നവർക്ക് അത് എപ്പോഴും ധാരാളമായിരിക്കും.': 'historic_3',
    'ഒന്നും ചെയ്യാതെ ഇരുന്നാൽ ഒന്നും നടക്കില്ല.': 'historic_4',
    'സൂര്യപ്രകാശം പോലെ ഒരിടത്ത് മാത്രം ശ്രദ്ധ കേന്ദ്രീകരിച്ചാൽ ഏതു കാര്യവും നടക്കും.': 'historic_5',
    'ഈ സമയം ബുദ്ധിപൂർവ്വം ഉപയോഗിക്കുക.': 'general_1',
    'സ്ഥിരമായുള്ള ചെറിയ മാറ്റങ്ങൾ വലിയ ലക്ഷ്യങ്ങളിൽ എത്തിക്കും.': 'general_2',
    'തിരിച്ചുകിട്ടാത്ത വലിയൊരു സമ്പത്താണ് സമയം.': 'general_3',
    'നമുക്ക് ചെയ്യാൻ പറ്റുന്നത് ഇപ്പോൾ തന്നെ ചെയ്യുക.': 'general_4',
    'ഇന്നത്തെ നമ്മുടെ പ്രവർത്തിയാണ് നമ്മുടെ ഭാവിയെ തീരുമാനിക്കുന്നത്.': 'general_5',
  };

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
          clips.add('audio/malayalam/$voice/clock/minutes/m_${m.toString().padLeft(2, '0')}.mp3');
        }
      }
      return clips;
    }

    // 4. Timer remaining: 'ഇനി X മിനിറ്റ്.'
    final remMatch = RegExp(r'ഇനി\s+(\d+)\s+മിനിറ്റ്').firstMatch(trimmed);
    if (remMatch != null) {
      final r = int.tryParse(remMatch.group(1)!);
      if (r != null && r >= 1 && r <= 60) {
        return ['audio/malayalam/$voice/timer/rem_${r.toString().padLeft(2, '0')}.mp3'];
      }
    }

    // 5. Clock announcement: '$hour12 മണി.' or '$hour12 മണി $minute മിനിറ്റ്.'
    final clockMatch = RegExp(r'(\d+)\s*മണി(?:\s*(\d+)\s*മിനിറ്റ്)?').firstMatch(trimmed);
    if (clockMatch != null) {
      final h = int.tryParse(clockMatch.group(1)!);
      final mStr = clockMatch.group(2);
      final m = mStr != null ? int.tryParse(mStr) : null;
      if (h != null && h >= 1 && h <= 12) {
        final clips = <String>[
          'audio/malayalam/$voice/clock/hours/h_${h.toString().padLeft(2, '0')}.mp3',
        ];
        if (m != null && m >= 1 && m <= 59) {
          clips.add('audio/malayalam/$voice/clock/minutes/m_${m.toString().padLeft(2, '0')}.mp3');
        }
        return clips;
      }
    }

    // 6. Motivational Quotes
    for (final entry in _quoteFileMap.entries) {
      if (trimmed == entry.key || trimmed.startsWith(entry.key)) {
        return ['audio/malayalam/$voice/quotes/${entry.value}.mp3'];
      }
    }

    return null;
  }
}
