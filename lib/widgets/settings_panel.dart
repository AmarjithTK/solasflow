import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_settings.dart';
import '../models/sound_option.dart';
import '../providers/app_state.dart';
import '../models/speech_model_download_status.dart';

import '../services/desktop_autostart_service.dart';

import '../l10n/app_localizations.dart';

class SettingsPanel extends ConsumerStatefulWidget {
  // ── Side-effect callbacks only (audio, TTS, foreground service) ──
  final List<SoundOption> soundList;
  final List<double> volumeLists;
  final ValueListenable<List<Map<dynamic, dynamic>>> voices;
  final List<String> availableEngines;
  final ValueListenable<String> speechEngineRuntime;
  final ValueListenable<String> speechEngineRuntimeDetail;
  final bool showEnglishVoiceDownload;
  final ValueListenable<SpeechModelDownloadStatus> speechModelDownloadStatus;
  final ValueListenable<String> customModelStatus;
  final Future<void> Function(String directory, String language)
  onImportDesktopModel;
  final Future<void> Function(String language) onClearDesktopModel;
  final String sleepStartLabel;
  final String sleepEndLabel;
  final List<int> goalReminderIntervalOptions;
  final ValueChanged<String?> onSoundChanged;
  final ValueChanged<double?> onNoiseVolumeChanged;
  final ValueChanged<double?> onSpeakVolumeChanged;
  final ValueChanged<bool?> onMaximumSpeechVolumeChanged;
  final ValueChanged<bool?> onSpeechMasterOnChanged;
  final ValueChanged<bool?> onAppDarkThemeChanged;
  final ValueChanged<double?> onAppFontSizeMultiplierChanged;
  final ValueChanged<bool?> onFullscreenDarkThemeChanged;
  final ValueChanged<bool?> onFullscreenDimBrightnessChanged;
  final ValueChanged<double?> onFullscreenDimBrightnessLevelChanged;
  final ValueChanged<bool?> onFullscreenStartLandscapeChanged;
  final ValueChanged<bool?> onMuteSpeechAfterMidnightChanged;
  final ValueChanged<bool?> onGoalReminderOnChanged;
  final ValueChanged<int?> onGoalReminderIntervalChanged;
  final ValueChanged<List<String>> onGoalReminderItemsChanged;
  final ValueChanged<double?>? onFullscreenClockScaleChanged;
  final ValueChanged<bool?>? onFullscreenShowClockChanged;
  final ValueChanged<String?> onNightMuteModeChanged;
  final VoidCallback onPickSleepStart;
  final VoidCallback onPickSleepEnd;
  final ValueChanged<String?> onVoiceListModeChanged;
  final ValueChanged<String?> onSpeechEngineModeChanged;
  final ValueChanged<String?> onFavoriteVoiceChanged;
  final VoidCallback onTestSpeech;
  final VoidCallback onDownloadEnglishVoice;
  final VoidCallback onCancelEnglishVoiceDownload;
  final VoidCallback onOpenHelp;
  final VoidCallback? onBackupSettings;
  final VoidCallback? onRestoreSettings;

  const SettingsPanel({
    super.key,
    required this.soundList,
    required this.volumeLists,
    required this.voices,
    this.availableEngines = const [],
    required this.speechEngineRuntime,
    required this.speechEngineRuntimeDetail,
    required this.showEnglishVoiceDownload,
    required this.speechModelDownloadStatus,
    required this.customModelStatus,
    required this.onImportDesktopModel,
    required this.onClearDesktopModel,
    required this.sleepStartLabel,
    required this.sleepEndLabel,
    required this.goalReminderIntervalOptions,
    required this.onSoundChanged,
    required this.onNoiseVolumeChanged,
    required this.onSpeakVolumeChanged,
    required this.onMaximumSpeechVolumeChanged,
    required this.onSpeechMasterOnChanged,
    required this.onAppDarkThemeChanged,
    required this.onAppFontSizeMultiplierChanged,
    required this.onFullscreenDarkThemeChanged,
    required this.onFullscreenDimBrightnessChanged,
    required this.onFullscreenDimBrightnessLevelChanged,
    required this.onFullscreenStartLandscapeChanged,
    this.onFullscreenClockScaleChanged,
    this.onFullscreenShowClockChanged,
    required this.onMuteSpeechAfterMidnightChanged,
    required this.onGoalReminderOnChanged,
    required this.onGoalReminderIntervalChanged,
    required this.onGoalReminderItemsChanged,
    required this.onNightMuteModeChanged,
    required this.onPickSleepStart,
    required this.onPickSleepEnd,
    required this.onVoiceListModeChanged,
    required this.onSpeechEngineModeChanged,
    required this.onFavoriteVoiceChanged,
    required this.onOpenHelp,
    required this.onTestSpeech,
    required this.onDownloadEnglishVoice,
    required this.onCancelEnglishVoiceDownload,
    this.onBackupSettings,
    this.onRestoreSettings,
  });

  @override
  ConsumerState<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends ConsumerState<SettingsPanel> {
  final DesktopAutostartService _desktopAutostart = DesktopAutostartService();
  DesktopAutostartStatus? _desktopAutostartStatus;
  String? _desktopAutostartError;
  bool _desktopAutostartBusy = false;

  @override
  void initState() {
    super.initState();
    _addLiveSpeechListeners();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      _refreshDesktopAutostart();
    }
  }

  void _addLiveSpeechListeners() {
    widget.voices.addListener(_refreshLiveSpeechState);
    widget.speechEngineRuntime.addListener(_refreshLiveSpeechState);
    widget.speechEngineRuntimeDetail.addListener(_refreshLiveSpeechState);
  }

  void _removeLiveSpeechListeners(SettingsPanel panel) {
    panel.voices.removeListener(_refreshLiveSpeechState);
    panel.speechEngineRuntime.removeListener(_refreshLiveSpeechState);
    panel.speechEngineRuntimeDetail.removeListener(_refreshLiveSpeechState);
  }

  void _refreshLiveSpeechState() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant SettingsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _removeLiveSpeechListeners(oldWidget);
    _addLiveSpeechListeners();
  }

  @override
  void dispose() {
    _removeLiveSpeechListeners(widget);
    super.dispose();
  }

  Future<void> _refreshDesktopAutostart() async {
    try {
      final status = await _desktopAutostart.status();
      if (!mounted) return;
      setState(() {
        _desktopAutostartStatus = status;
        _desktopAutostartError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _desktopAutostartError = error.toString());
    }
  }

  Future<void> _setDesktopAutostart(bool enabled) async {
    if (_desktopAutostartBusy) return;
    setState(() => _desktopAutostartBusy = true);
    try {
      if (enabled) {
        await _desktopAutostart.enable();
      } else {
        await _desktopAutostart.disable();
      }
      await _refreshDesktopAutostart();
    } catch (error) {
      if (!mounted) return;
      setState(() => _desktopAutostartError = error.toString());
    } finally {
      if (mounted) setState(() => _desktopAutostartBusy = false);
    }
  }

  Widget _desktopAutostartCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final status = _desktopAutostartStatus;
    final error = _desktopAutostartError;
    final statusSummary = status == null
        ? l10n.settingsPanelDesktopAutostartChecking
        : !status.installed
        ? l10n.settingsPanelAutostartNotConfigured
        : !status.enabled
        ? l10n.settingsPanelAutostartInstalledDisabled
        : status.serviceState == 'failed'
        ? l10n.settingsPanelAutostartFailed
        : status.active
        ? l10n.settingsPanelAutostartRunning
        : l10n.settingsPanelAutostartNextLogin;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsPanelDesktopAutostartTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            error ?? statusSummary,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsPanelDesktopAutostartDescription,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: _desktopAutostartBusy || status?.enabled == true
                    ? null
                    : () => _setDesktopAutostart(true),
                icon: _desktopAutostartBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.power_settings_new),
                label: Text(l10n.settingsPanelEnable),
              ),
              OutlinedButton.icon(
                onPressed: _desktopAutostartBusy || status?.installed != true
                    ? null
                    : () => _setDesktopAutostart(false),
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.settingsPanelRemove),
              ),
              IconButton(
                tooltip: l10n.settingsPanelRefreshStatus,
                onPressed: _desktopAutostartBusy
                    ? null
                    : _refreshDesktopAutostart,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _previewLanguage =>
      ref.read(settingsProvider).voiceListMode == 'malayalam' ? 'ml' : 'en';
  bool _modelOperationBusy = false;

  Future<void> _changeDesktopModel({required bool clear}) async {
    if (_modelOperationBusy) return;
    // Malayalam always speaks the bundled studio voice clips now, so only the
    // English offline model can be imported or cleared.
    const language = 'en';
    final l10n = AppLocalizations.of(context)!;
    setState(() => _modelOperationBusy = true);
    try {
      if (clear) {
        await widget.onClearDesktopModel(language);
      } else {
        final directory = await FilePicker.platform.getDirectoryPath(
          dialogTitle: l10n.settingsPanelChooseModelFolder,
        );
        if (directory == null || !mounted) return;
        await widget.onImportDesktopModel(directory, language);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.settingsPanelOfflineModelFailed(
                clear ? l10n.settingsPanelClear : l10n.settingsPanelImport,
                error.toString(),
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _modelOperationBusy = false);
    }
  }

  Widget _desktopModelCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsPanelLocalOfflineModel,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsPanelOfflineModelDescription,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: widget.customModelStatus,
            builder: (context, value, _) =>
                Text(value, style: const TextStyle(fontSize: 12)),
          ),
          if (_modelOperationBusy) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _modelOperationBusy
                    ? null
                    : () => _changeDesktopModel(clear: false),
                icon: const Icon(Icons.folder_open),
                label: Text(l10n.settingsPanelImportFolder),
              ),
              OutlinedButton(
                onPressed: _modelOperationBusy
                    ? null
                    : () => _changeDesktopModel(clear: true),
                child: Text(l10n.settingsPanelUseBuiltinVoice),
              ),
              OutlinedButton.icon(
                onPressed: _modelOperationBusy
                    ? null
                    : () {
                        widget.onVoiceListModeChanged(
                          _previewLanguage == 'ml'
                              ? 'malayalam'
                              : 'english',
                        );
                        widget.onTestSpeech();
                      },
                icon: const Icon(Icons.volume_up_outlined),
                label: Text(
                  l10n.settingsPanelTestLanguage(
                    _previewLanguage == 'ml'
                        ? l10n.settingsPanelMalayalam
                        : l10n.settingsPanelEnglish,
                  ),
                ),
              ),
            ],
          ),
          Text(
            l10n.settingsPanelModelLanguageDescription,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _getVolTitle(BuildContext context, double v) {
    final l10n = AppLocalizations.of(context)!;
    if (v == 0.1) return l10n.settingsPanelVeryLow;
    if (v == 0.2) return l10n.settingsPanelLow;
    if (v == 0.6) return l10n.settingsPanelMedium;
    if (v == 0.8) return l10n.settingsPanelHigh;
    return l10n.settingsPanelVeryHigh;
  }

  String _speechModelDownloadMessage(
    SpeechModelDownloadStatus status,
    AppLocalizations l10n,
  ) {
    String mebibytes(int bytes) =>
        '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MiB';

    switch (status.phase) {
      case SpeechModelDownloadPhase.notDownloaded:
        return l10n.settingsPanelDownloadNotDownloaded;
      case SpeechModelDownloadPhase.downloading:
        final amount = status.totalBytes > 0
            ? '${mebibytes(status.receivedBytes)} / ${mebibytes(status.totalBytes)}'
            : '${mebibytes(status.receivedBytes)} downloaded';
        final percent = status.progress;
        return percent == null
            ? l10n.settingsPanelDownloadingKokoro(amount)
            : l10n.settingsPanelDownloadingKokoroPercent(
                (percent * 100).round(),
                amount,
              );
      case SpeechModelDownloadPhase.verifying:
        return l10n.settingsPanelDownloadVerifying;
      case SpeechModelDownloadPhase.installing:
        return l10n.settingsPanelDownloadInstalling;
      case SpeechModelDownloadPhase.ready:
        return l10n.settingsPanelDownloadReady;
      case SpeechModelDownloadPhase.failed:
        return l10n.settingsPanelDownloadFailed(
          status.error ?? l10n.settingsPanelDownloadFailedFallback,
        );
      case SpeechModelDownloadPhase.cancelled:
        return l10n.settingsPanelDownloadCancelled;
    }
  }

  Widget _speechModelDownloadCard(
    BuildContext context,
    SpeechModelDownloadStatus status,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final canStart =
        status.phase == SpeechModelDownloadPhase.notDownloaded ||
        status.canRetry;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_download_outlined, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.settingsPanelKokoroEnglishVoice,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _speechModelDownloadMessage(status, l10n),
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          if (status.isBusy) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: status.progress,
              minHeight: 4,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
          if (canStart || status.isBusy)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: canStart
                  ? FilledButton.tonalIcon(
                      onPressed: widget.onDownloadEnglishVoice,
                      icon: Icon(
                        status.canRetry
                            ? Icons.refresh_rounded
                            : Icons.download_rounded,
                      ),
                      label: Text(
                        status.canRetry
                            ? l10n.settingsPanelRetry
                            : l10n.settingsPanelDownload,
                      ),
                    )
                  : TextButton.icon(
                      onPressed: widget.onCancelEnglishVoiceDownload,
                      icon: const Icon(Icons.close_rounded),
                      label: Text(l10n.settingsPanelCancel),
                    ),
            ),
        ],
      ),
    );
  }

  String _formatMinutesAsTime(BuildContext context, int totalMinutes) {
    final normalized = totalMinutes % (24 * 60);
    final time = TimeOfDay(hour: normalized ~/ 60, minute: normalized % 60);
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  String _soundTitle(BuildContext context, String link) {
    final l10n = AppLocalizations.of(context)!;
    for (final sound in widget.soundList) {
      if (sound.link != link) continue;
      return switch (link) {
        'audio/rain.mp3' => l10n.settingsPanelSoundRain,
        'audio/waterfall.mp3' => l10n.settingsPanelSoundWaterfall,
        'audio/fire.mp3' => l10n.settingsPanelSoundFire,
        'audio/stream.mp3' => l10n.settingsPanelSoundStream,
        _ => sound.title,
      };
    }
    return widget.soundList.isEmpty
        ? l10n.settingsPanelNone
        : widget.soundList.first.title;
  }

  String _voiceCharacterName(BuildContext context, String name, String locale) {
    final l10n = AppLocalizations.of(context)!;
    final lower = name.toLowerCase();
    final isMl = locale.toLowerCase().startsWith('ml');
    if (lower.contains('aoede')) return l10n.settingsPanelAoedeVoice;
    if (lower.contains('kore')) return l10n.settingsPanelKoreVoice;
    if (lower.contains('puck')) return l10n.settingsPanelPuckVoice;
    if (lower.contains('charon')) return l10n.settingsPanelCharonVoice;
    if (lower.contains('veena')) return 'Veena';
    if (lower.contains('rishi')) return 'Rishi';
    if (lower.contains('lessac')) return l10n.settingsPanelPiperLessacVoice;
    if (lower.contains('ryan')) return l10n.settingsPanelPiperRyanVoice;
    if (lower.contains('bella')) return l10n.settingsPanelKokoroBellaVoice;
    if (lower.contains('adam')) return l10n.settingsPanelKokoroAdamVoice;
    if (lower.contains('emma')) return l10n.settingsPanelKokoroEmmaVoice;
    if (lower.contains('george')) return l10n.settingsPanelKokoroGeorgeVoice;
    if (lower.contains('maple')) return l10n.settingsPanelKokoroMapleVoice;
    if (lower.contains('sol')) return l10n.settingsPanelKokoroSolVoice;
    if (lower.contains('vale')) return l10n.settingsPanelKokoroValeVoice;
    if (isMl) {
      if (lower.contains('female')) return l10n.settingsPanelMalayalamFemale;
      if (lower.contains('male')) return l10n.settingsPanelMalayalamMale;
      return l10n.settingsPanelMalayalamNative;
    }
    if (lower.contains('female')) return l10n.settingsPanelFemale;
    if (lower.contains('male')) return l10n.settingsPanelMale;
    if (locale.toLowerCase().startsWith('en-in')) {
      return l10n.settingsPanelIndianEnglish;
    }
    if (locale.toLowerCase().startsWith('en-us')) {
      return l10n.settingsPanelUsEnglish;
    }
    if (locale.toLowerCase().startsWith('en-gb')) {
      return l10n.settingsPanelUkEnglish;
    }
    return name;
  }

  String _speechEngineLabel(BuildContext context, String value) {
    final l10n = AppLocalizations.of(context)!;
    switch (value) {
      case 'system_only':
        return l10n.settingsPanelSystemTtsOnly;
      case 'sherpa_only':
        return l10n.settingsPanelSherpaOnly;
      case 'auto':
        return l10n.settingsPanelAutoBestAvailable;
      case 'com.google.android.tts':
        return l10n.settingsPanelGoogleSpeechServices;
      case 'com.samsung.SMT':
        return l10n.settingsPanelSamsungTextToSpeech;
      default:
        if (value.startsWith('com.')) {
          final parts = value.split('.');
          return parts.length > 1 ? parts.sublist(1).join(' ') : value;
        }
        return value.isNotEmpty ? value : l10n.settingsPanelAuto;
    }
  }

  String _voiceListLabel(BuildContext context, String value) {
    final l10n = AppLocalizations.of(context)!;
    switch (value) {
      case 'english':
        return l10n.settingsPanelEnglish;
      case 'malayalam':
        return l10n.settingsPanelMalayalam;
      default:
        return l10n.settingsPanelAuto;
    }
  }

  String _favoriteVoiceLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = ref.read(settingsProvider);
    final fav = s.favoriteVoiceName;
    if (fav == null || fav == '__auto__' || fav == '__rotate__') {
      return l10n.settingsPanelRotateVoicesDefault;
    }
    return '${_voiceCharacterName(context, s.favoriteVoiceName!, s.favoriteVoiceLocale ?? '')} - ${s.favoriteVoiceLocale ?? ''}';
  }

  String _favoriteVoiceKey() {
    final s = ref.read(settingsProvider);
    if (s.favoriteVoiceName == null ||
        s.favoriteVoiceName == '__auto__' ||
        s.favoriteVoiceName == '__rotate__') {
      return '__rotate__';
    }
    return '${s.favoriteVoiceName}|${s.favoriteVoiceLocale}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final s = ref.watch(settingsProvider);

    final speechEngineOptions = <(String, String, String?)>[
      (
        'auto',
        l10n.settingsPanelAutoSystemDefault,
        l10n.settingsPanelUseDeviceDefaultEngine,
      ),
      (
        'system_only',
        l10n.settingsPanelSystemTtsOnly,
        l10n.settingsPanelUseDeviceSpeechEngine,
      ),
      for (final engine in widget.availableEngines)
        if (engine != 'auto' &&
            engine != 'system_only' &&
            engine != 'sherpa_only')
          (engine, _speechEngineLabel(context, engine), engine),
      if (!kIsWeb)
        (
          'sherpa_only',
          l10n.settingsPanelSherpaOnly,
          l10n.settingsPanelFallbackVoicePlatforms,
        ),
    ];
    final voiceModeOptions = <(String, String, String?)>[
      ('auto', l10n.settingsPanelAuto, l10n.settingsPanelAutoVoiceDescription),
      ('english', l10n.settingsPanelEnglish, null),
      ('malayalam', l10n.settingsPanelMalayalam, null),
    ];
    final nightModeOptions = <(String, String, String?)>[
      (
        'manual',
        l10n.settingsPanelManualMode,
        l10n.settingsPanelSelectedQuietHours,
      ),
      (
        'automatic',
        l10n.settingsPanelAutomaticMode,
        l10n.settingsPanelMuteAfterNightIdle,
      ),
    ];

    final currentLanguageMode = s.voiceListMode.toLowerCase();
    final availableVoices = widget.voices.value;
    final List<Map<dynamic, dynamic>> languageVoices;
    if (currentLanguageMode == 'malayalam') {
      final ml = availableVoices.where((v) {
        final loc = (v['locale']?.toString() ?? '').toLowerCase().replaceAll(
          '_',
          '-',
        );
        return loc.startsWith('ml');
      }).toList();
      languageVoices = ml.isNotEmpty
          ? ml
          : [
              {'name': l10n.settingsPanelStandardMalayalam, 'locale': 'ml-IN'},
            ];
    } else if (currentLanguageMode == 'english') {
      languageVoices = availableVoices.where((v) {
        final loc = (v['locale']?.toString() ?? '').toLowerCase().replaceAll(
          '_',
          '-',
        );
        return loc.startsWith('en');
      }).toList();
    } else {
      final ml = availableVoices.where((v) {
        final loc = (v['locale']?.toString() ?? '').toLowerCase().replaceAll(
          '_',
          '-',
        );
        return loc.startsWith('ml');
      }).toList();
      final en = availableVoices.where((v) {
        final loc = (v['locale']?.toString() ?? '').toLowerCase().replaceAll(
          '_',
          '-',
        );
        return loc.startsWith('en');
      }).toList();
      languageVoices = [
        if (ml.isNotEmpty)
          ...ml
        else
          {'name': l10n.settingsPanelStandardMalayalam, 'locale': 'ml-IN'},
        ...en,
      ];
    }

    final voiceOptions = <(String, String, String?)>[
      (
        '__rotate__',
        currentLanguageMode == 'malayalam'
            ? l10n.settingsPanelRotateMalayalamVoices
            : l10n.settingsPanelRotateVoicesDefault,
        l10n.settingsPanelAlternatesVoices,
      ),
      ...languageVoices.map((voice) {
        final name =
            voice['name']?.toString() ?? l10n.settingsPanelUnknownVoice;
        final locale = voice['locale']?.toString() ?? 'en';
        final key = '$name|$locale';
        return (key, _voiceCharacterName(context, name, locale), name);
      }),
    ];
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: Text(l10n.settingsTab), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _settingsSwitch(
            context,
            icon: Icons.dark_mode_rounded,
            title: l10n.darkThemeLabel,
            subtitle: l10n.settingsPanelDarkThemeDescription,
            value: s.appDarkTheme,
            onChanged: widget.onAppDarkThemeChanged,
          ),
          _settingsDivider(context),
          _settingsSwitch(
            context,
            icon: s.speechMasterOn
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            title: l10n.settingsPanelMasterAudio,
            subtitle: s.speechMasterOn
                ? l10n.settingsPanelAllAudioOn
                : l10n.settingsPanelAllAudioOff,
            value: s.speechMasterOn,
            onChanged: (val) {
              widget.onSpeechMasterOnChanged(val);
            },
          ),
          _settingsDivider(context),
          _settingsSwitch(
            context,
            icon: Icons.flag_rounded,
            title: l10n.settingsPanelGoalReminders,
            subtitle: s.goalReminderItems.isEmpty
                ? l10n.settingsPanelAddGoalToEnableReminders
                : l10n.settingsPanelSpeakSavedGoalEvery(
                    s.goalReminderIntervalMins,
                  ),
            value: s.goalReminderOn,
            onChanged: s.goalReminderItems.isEmpty
                ? null
                : widget.onGoalReminderOnChanged,
          ),
          _settingsDivider(context),
          _settingsOption(
            context,
            icon: Icons.schedule_rounded,
            title: l10n.settingsPanelGoalReminderInterval,
            value: l10n.clockPanelMinutes(s.goalReminderIntervalMins),
            onTap: () => _showStringPicker(
              context,
              title: l10n.settingsPanelGoalReminderInterval,
              currentValue: s.goalReminderIntervalMins.toString(),
              options: widget.goalReminderIntervalOptions
                  .map(
                    (minutes) => (
                      minutes.toString(),
                      l10n.clockPanelMinutes(minutes),
                      null,
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                final minutes = int.tryParse(value ?? '');
                if (minutes != null) {
                  widget.onGoalReminderIntervalChanged(minutes);
                }
              },
            ),
          ),
          _settingsDivider(context),
          _settingsOption(
            context,
            icon: Icons.playlist_add_rounded,
            title: l10n.settingsPanelAddGoal,
            value: l10n.settingsPanelAdd,
            onTap: () => _addGoalReminder(context, s.goalReminderItems),
          ),
          if (s.goalReminderItems.isEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(72, 0, 16, 12),
              child: Text(
                l10n.settingsPanelNoGoalsSaved,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          for (final goal in s.goalReminderItems)
            ListTile(
              dense: true,
              contentPadding: const EdgeInsetsDirectional.only(start: 72, end: 8),
              title: Text(goal),
              trailing: IconButton(
                tooltip: l10n.settingsPanelRemoveGoal,
                icon: const Icon(Icons.close_rounded),
                onPressed: () => widget.onGoalReminderItemsChanged(
                  s.goalReminderItems.where((item) => item != goal).toList(),
                ),
              ),
            ),
          _settingsDivider(context),
          _settingsOption(
            context,
            icon: Icons.music_note_rounded,
            title: l10n.soundLabel,
            value: _soundTitle(context, s.soundChosen),
            onTap: () => _showStringPicker(
              context,
              title: l10n.soundLabel,
              currentValue: s.soundChosen,
              options: widget.soundList
                  .map(
                    (sound) =>
                        (sound.link, _soundTitle(context, sound.link), null),
                  )
                  .toList(),
              onChanged: widget.onSoundChanged,
            ),
          ),
          _settingsDivider(context),
          _settingsOption(
            context,
            icon: Icons.volume_up_rounded,
            title: l10n.settingsPanelNoiseVolume,
            value: _getVolTitle(context, s.noiseVolume),
            onTap: () => _showDoublePicker(
              context,
              title: l10n.settingsPanelNoiseVolume,
              currentValue: s.noiseVolume,
              onChanged: widget.onNoiseVolumeChanged,
            ),
          ),
          _settingsDivider(context),
          _settingsOption(
            context,
            icon: Icons.record_voice_over_rounded,
            title: l10n.settingsPanelSpeechVolume,
            value: _getVolTitle(context, s.speakVolume),
            onTap: () => _showDoublePicker(
              context,
              title: l10n.settingsPanelSpeechVolume,
              currentValue: s.speakVolume,
              onChanged: widget.onSpeakVolumeChanged,
            ),
          ),
          _settingsDivider(context),
          _settingsSwitch(
            context,
            icon: Icons.volume_up_rounded,
            title: l10n.settingsPanelBoostTtsVolume,
            subtitle: l10n.settingsPanelMaximumSpeechVolumeDescription,
            value: s.maximumSpeechVolume,
            onChanged: widget.onMaximumSpeechVolumeChanged,
          ),
          _settingsOption(
            context,
            icon: Icons.spatial_audio_off_rounded,
            title: l10n.settingsPanelSpeechEngine,
            value: _speechEngineLabel(context, s.speechEngineMode),
            onTap: () => _showStringPicker(
              context,
              title: l10n.settingsPanelSpeechEngine,
              currentValue: s.speechEngineMode,
              options: speechEngineOptions,
              onChanged: widget.onSpeechEngineModeChanged,
            ),
          ),
          if (widget.speechEngineRuntime.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(52, 0, 14, 8),
              child: Text(
                '${widget.speechEngineRuntime.value} — ${widget.speechEngineRuntimeDetail.value}',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                maxLines: 2,
              ),
            ),
          if (widget.showEnglishVoiceDownload)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
              child: ValueListenableBuilder<SpeechModelDownloadStatus>(
                valueListenable: widget.speechModelDownloadStatus,
                builder: (context, status, _) =>
                    _speechModelDownloadCard(context, status),
              ),
            ),
          if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
              child: _desktopModelCard(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
              child: _desktopAutostartCard(context),
            ),
          ],
          _settingsOption(
            context,
            icon: Icons.play_circle_outline_rounded,
            title: l10n.settingsPanelTestVoice,
            value: l10n.settingsPanelPlaySample,
            onTap: widget.onTestSpeech,
          ),
          _settingsDivider(context),
          _settingsOption(
            context,
            icon: Icons.language_rounded,
            title: l10n.settingsPanelLanguageList,
            value: _voiceListLabel(context, s.voiceListMode),
            onTap: () => _showStringPicker(
              context,
              title: l10n.settingsPanelLanguageList,
              currentValue: s.voiceListMode,
              options: voiceModeOptions,
              onChanged: widget.onVoiceListModeChanged,
            ),
          ),
          _settingsDivider(context),
          _settingsOption(
            context,
            icon: Icons.person_search_rounded,
            title: l10n.settingsPanelPreferredVoice,
            value: _favoriteVoiceLabel(context),
            onTap: () => _showStringPicker(
              context,
              title: l10n.settingsPanelVoice,
              currentValue: _favoriteVoiceKey(),
              options: voiceOptions,
              onChanged: widget.onFavoriteVoiceChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(52, 8, 14, 0),
            child: Row(
              children: [
                Text(
                  l10n.settingsPanelFontSize,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '${s.appFontSizeMultiplier.toStringAsFixed(1)}x',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Slider(
            value: s.appFontSizeMultiplier,
            min: 0.8,
            max: 1.5,
            divisions: 7,
            label: '${s.appFontSizeMultiplier.toStringAsFixed(1)}x',
            onChanged: (val) {
              widget.onAppFontSizeMultiplierChanged(val);
            },
          ),
          _settingsDivider(context),
          _settingsSwitch(
            context,
            icon: Icons.dark_mode_rounded,
            title: l10n.focusViewDarkTheme,
            value: s.fullscreenDarkTheme,
            onChanged: (val) {
              widget.onFullscreenDarkThemeChanged(val);
            },
          ),
          if (!kIsWeb && defaultTargetPlatform != TargetPlatform.linux) ...[
            _settingsDivider(context),
            _settingsSwitch(
              context,
              icon: Icons.brightness_4_rounded,
              title: l10n.focusViewDimBrightness,
              value: s.fullscreenDimBrightness,
              onChanged: (val) {
                widget.onFullscreenDimBrightnessChanged(val);
              },
            ),
            if (s.fullscreenDimBrightness) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.brightness_low_rounded,
                      size: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(150),
                    ),
                    Expanded(
                      child: Slider(
                        value: s.fullscreenDimBrightnessLevel,
                        min: 0.01,
                        max: 0.5,
                        divisions: 49,
                        label:
                            '${(s.fullscreenDimBrightnessLevel * 100).round()}%',
                        onChanged: (val) {
                          widget.onFullscreenDimBrightnessLevelChanged(val);
                        },
                      ),
                    ),
                    Icon(
                      Icons.brightness_high_rounded,
                      size: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(150),
                    ),
                  ],
                ),
              ),
            ],
            _settingsDivider(context),
          ],
          _settingsSwitch(
            context,
            icon: Icons.screen_rotation_rounded,
            title: l10n.settingsPanelStartLandscape,
            value: s.fullscreenStartLandscape,
            onChanged: (val) {
              widget.onFullscreenStartLandscapeChanged(val);
            },
          ),
          _settingsDivider(context),
          _settingsSwitch(
            context,
            icon: Icons.access_time_rounded,
            title: l10n.settingsPanelShowClockFullscreen,
            subtitle: l10n.settingsPanelShowClockFullscreenDescription,
            value: s.fullscreenShowClock,
            onChanged: (val) {
              widget.onFullscreenShowClockChanged?.call(val);
            },
          ),
          if (s.fullscreenShowClock) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(52, 8, 14, 0),
              child: Row(
                children: [
                  Text(
                    l10n.settingsPanelFullscreenClockSize,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${s.fullscreenClockScale.toStringAsFixed(1)}x',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Slider(
              value: s.fullscreenClockScale
                  .clamp(
                    AppSettings.fullscreenClockScaleOptions.first,
                    AppSettings.fullscreenClockScaleOptions.last,
                  )
                  .toDouble(),
              min: AppSettings.fullscreenClockScaleOptions.first,
              max: AppSettings.fullscreenClockScaleOptions.last,
              divisions: AppSettings.fullscreenClockScaleOptions.length - 1,
              label: '${s.fullscreenClockScale.toStringAsFixed(1)}x',
              onChanged: (val) {
                widget.onFullscreenClockScaleChanged?.call(val);
              },
            ),
          ],
          _settingsDivider(context),
          _settingsSwitch(
            context,
            icon: Icons.nightlight_round,
            title: l10n.settingsPanelEnableSleepMode,
            subtitle: l10n.settingsPanelQuietHoursSpeech,
            value: s.muteSpeechAfterMidnight,
            onChanged: (val) {
              widget.onMuteSpeechAfterMidnightChanged(val);
            },
          ),
          if (s.muteSpeechAfterMidnight) ...[
            _settingsDivider(context),
            _settingsOption(
              context,
              icon: Icons.bedtime_rounded,
              title: l10n.settingsPanelMode,
              value: s.nightMuteMode == 'automatic'
                  ? l10n.settingsPanelAutomaticMode
                  : l10n.settingsPanelManualMode,
              onTap: () => _showStringPicker(
                context,
                title: l10n.settingsPanelSleepMode,
                currentValue: s.nightMuteMode,
                options: nightModeOptions,
                onChanged: (val) {
                  widget.onNightMuteModeChanged(val);
                },
              ),
            ),
            _settingsDivider(context),
            _settingsOption(
              context,
              icon: Icons.schedule_rounded,
              title: l10n.sleepStartLabel,
              value: _formatMinutesAsTime(context, s.sleepStartMinutes),
              onTap: widget.onPickSleepStart,
            ),
            _settingsDivider(context),
            _settingsOption(
              context,
              icon: Icons.alarm_rounded,
              title: l10n.sleepEndLabel,
              value: _formatMinutesAsTime(context, s.sleepEndMinutes),
              onTap: widget.onPickSleepEnd,
            ),
          ],
          ListTile(
            leading: Icon(Icons.backup_rounded, color: cs.primary, size: 22),
            title: Text(
              l10n.settingsPanelBackupAppSettings,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: cs.onSurface,
              ),
            ),
            subtitle: Text(
              l10n.settingsPanelBackupDescription,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
            trailing: Icon(
              Icons.file_download_outlined,
              color: cs.onSurfaceVariant,
              size: 20,
            ),
            onTap: widget.onBackupSettings,
          ),
          _settingsDivider(context),
          ListTile(
            leading: Icon(Icons.restore_rounded, color: cs.primary, size: 22),
            title: Text(
              l10n.settingsPanelRestoreAppSettings,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: cs.onSurface,
              ),
            ),
            subtitle: Text(
              l10n.settingsPanelRestoreDescription,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
            trailing: Icon(
              Icons.file_upload_outlined,
              color: cs.onSurfaceVariant,
              size: 20,
            ),
            onTap: widget.onRestoreSettings,
          ),
          _settingsDivider(context),
          ListTile(
            leading: Icon(
              Icons.help_outline_rounded,
              color: cs.primary,
              size: 22,
            ),
            title: Text(
              l10n.helpTitle,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: cs.onSurface,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant,
            ),
            onTap: widget.onOpenHelp,
          ),
          _settingsDivider(context),
          ListTile(
            leading: Icon(
              Icons.info_outline_rounded,
              color: cs.primary,
              size: 22,
            ),
            title: Text(
              l10n.settingsPanelBuiltBy,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: cs.onSurface,
              ),
            ),
            subtitle: Text(
              l10n.settingsPanelCompany,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              Icons.open_in_new_rounded,
              color: cs.onSurfaceVariant,
              size: 20,
            ),
            onTap: () async {
              final url = Uri.parse('https://atherpulse.in');
              await launchUrl(url, mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addGoalReminder(
    BuildContext context,
    List<String> currentItems,
  ) async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    final goal = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsPanelAddGoal),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.settingsPanelGoalField),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.settingsPanelCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(l10n.settingsPanelAdd),
          ),
        ],
      ),
    );
    controller.dispose();
    final normalizedGoal = goal?.trim() ?? '';
    if (!mounted || normalizedGoal.isEmpty) return;
    widget.onGoalReminderItemsChanged([...currentItems, normalizedGoal]);
  }

  Widget _settingsSwitch(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool?>? onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: cs.onPrimary,
      activeTrackColor: cs.primary,
      secondary: Icon(icon, color: cs.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: cs.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            )
          : null,
    );
  }

  Widget _settingsOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: cs.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: cs.onSurface,
        ),
      ),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _settingsDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 52,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  // ── Bottom sheet pickers ────────────────────────────────────
  Future<void> _showStringPicker(
    BuildContext context, {
    required String title,
    required String currentValue,
    required List<(String, String, String?)> options,
    required ValueChanged<String?> onChanged,
  }) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (listCtx, i) {
                    final o = options[i];
                    final selected = o.$1 == currentValue;
                    return ListTile(
                      selected: selected,
                      selectedTileColor: cs.primaryContainer.withAlpha(80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      leading: Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected ? cs.primary : cs.onSurfaceVariant,
                      ),
                      title: Text(
                        o.$2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: o.$3 != null
                          ? Text(
                              o.$3!,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () {
                        onChanged(o.$1);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDoublePicker(
    BuildContext context, {
    required String title,
    required double currentValue,
    required ValueChanged<double?> onChanged,
  }) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: widget.volumeLists.map((volume) {
                    final selected = volume == currentValue;
                    return ListTile(
                      selected: selected,
                      selectedTileColor: cs.primaryContainer.withAlpha(80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      leading: Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected ? cs.primary : cs.onSurfaceVariant,
                      ),
                      title: Text(
                        _getVolTitle(context, volume),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        '${(volume * 100).round()}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        onChanged(volume);
                        Navigator.of(ctx).pop();
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
