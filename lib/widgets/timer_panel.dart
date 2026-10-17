import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

import '../theme/palette.dart' show AppColorAccess;
import 'primary_button.dart';
import 'secondary_button.dart';
import 'preset_grid.dart';
import 'settings_row.dart';
import 'timer_ring.dart';

/// Redesigned Timer panel — the strongest interaction screen.
///
/// Time is the hero. Ring supports the time, doesn't dominate it.
/// Layout: Timer display → Actions → Adjustments → Presets → Options
class TimerPanel extends StatelessWidget {
  final String timerValue;
  final int sliderValue;
  final int durationSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final List<int> presetValues;
  final VoidCallback startTimer;
  final VoidCallback stopTimer;
  final VoidCallback resetTimer;
  final ValueChanged<int> choosePreset;
  final ValueChanged<int> addTimeToRunningTimer;

  final int? armedPresetValue;
  final ValueChanged<int> onPresetTap;

  final bool timerNoiseOn;
  final bool timerSpeakOn;
  final bool timerShowMilliseconds;
  final int timerAnnounceEvery;
  final bool chainModeOn;
  final String chainPresetKey;
  final Map<String, List<int>> chainPresets;
  final int chainIndex;
  final List<int> timerAnnounceOptions;
  final ValueChanged<bool?> onTimerNoiseOnChanged;
  final ValueChanged<bool?> onTimerSpeakOnChanged;
  final ValueChanged<bool?> onTimerShowMillisecondsChanged;
  final ValueChanged<int?> onTimerAnnounceEveryChanged;
  final ValueChanged<bool?> onChainModeChanged;
  final ValueChanged<String?> onChainPresetChanged;
  final bool fullscreenShowClock;
  final ValueChanged<bool?> onFullscreenShowClockChanged;
  final VoidCallback onFullscreenPressed;
  final VoidCallback onFullscreenImmersivePressed;

  // Tagging (study/non-study)
  final bool taggingOn;
  final String sessionTag;
  final ValueChanged<bool> onTaggingOnChanged;
  final ValueChanged<String> onSessionTagChanged;
  final String todaySummary;
  final VoidCallback onDashboardPressed;

  const TimerPanel({
    super.key,
    required this.timerValue,
    required this.sliderValue,
    required this.durationSeconds,
    required this.remainingSeconds,
    required this.isRunning,
    required this.presetValues,
    required this.startTimer,
    required this.stopTimer,
    required this.resetTimer,
    required this.choosePreset,
    required this.addTimeToRunningTimer,
    this.armedPresetValue,
    required this.onPresetTap,
    required this.timerNoiseOn,
    required this.timerSpeakOn,
    required this.timerShowMilliseconds,
    required this.timerAnnounceEvery,
    required this.chainModeOn,
    required this.chainPresetKey,
    required this.chainPresets,
    required this.chainIndex,
    required this.timerAnnounceOptions,
    required this.onTimerNoiseOnChanged,
    required this.onTimerSpeakOnChanged,
    required this.onTimerShowMillisecondsChanged,
    required this.onTimerAnnounceEveryChanged,
    required this.onChainModeChanged,
    required this.onChainPresetChanged,
    required this.fullscreenShowClock,
    required this.onFullscreenShowClockChanged,
    required this.onFullscreenPressed,
    required this.onFullscreenImmersivePressed,
    required this.taggingOn,
    required this.sessionTag,
    required this.onTaggingOnChanged,
    required this.onSessionTagChanged,
    required this.todaySummary,
    required this.onDashboardPressed,
  });

  (String, String, String?) _splitTimer(String value) {
    final dotParts = value.split('.');
    final base = dotParts.first;
    final millis = dotParts.length > 1 ? dotParts[1] : null;
    final parts = base.split(':');
    if (parts.length == 2) return (parts[0], parts[1], millis);
    return ('00', '00', null);
  }

  String _chainPresetLabel(BuildContext context, String preset) {
    final l10n = AppLocalizations.of(context)!;
    return switch (preset) {
      'Pomodoro 25-5x4' => l10n.timerPanelPomodoroPreset,
      'Sprint 50-10x2' => l10n.timerPanelSprintPreset,
      'Quick 15-3x3' => l10n.timerPanelQuickPreset,
      _ => preset,
    };
  }

  String _endLabel(BuildContext context) {
    if (remainingSeconds <= 0) return '';
    final end = DateTime.now().add(Duration(seconds: remainingSeconds));
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(end));
    return AppLocalizations.of(context)!.timerPanelEndsAt(time);
  }

  double get _progress {
    if (durationSeconds <= 0) return 0;
    return (remainingSeconds / durationSeconds).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final timerParts = _splitTimer(timerValue);
    final minutes = timerParts.$1;
    final seconds = timerParts.$2;
    final millis = timerParts.$3;
    final displayTime = millis != null
        ? '$minutes:$seconds.$millis'
        : '$minutes:$seconds';

    return SafeArea(
      child: ColoredBox(
        color: c.background,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const SizedBox(height: 8),

            // ── Timer display area (subtle surface, not heavy card) ──
            Semantics(
              button: true,
              label: AppLocalizations.of(context)!.timerPanelDisplay,
              hint: AppLocalizations.of(context)!.timerPanelFullscreenHint,
              child: GestureDetector(
                onTap: onFullscreenPressed,
                onDoubleTap: onFullscreenImmersivePressed,
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 240),
                    padding: const EdgeInsets.symmetric(
                      vertical: 36,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.surfaceBorder),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Timer ring — always rendered (stable layout, no resize)
                        SizedBox(
                          width: 280,
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_progress > 0)
                                TimerRing(
                                  progress: _progress,
                                  primary: c.primaryAction,
                                  trackColor: c.surfaceBorder,
                                  size: 200,
                                ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.timerPanelRemaining,
                                    style: GoogleFonts.inter(
                                      color: c.textMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      displayTime,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        color: c.textPrimary,
                                        fontSize: 56,
                                        height: 0.9,
                                        fontWeight: FontWeight.w800,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // −1 button (left, vertically centered)
                              if (isRunning)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: IconButton(
                                    tooltip: AppLocalizations.of(
                                      context,
                                    )!.timerPanelRemoveMinute,
                                    constraints: const BoxConstraints.tightFor(
                                      width: 48,
                                      height: 48,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: () => addTimeToRunningTimer(-60),
                                    icon: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: c.surfaceSubtle,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: c.surfaceBorder,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.remove_rounded,
                                        size: 18,
                                        color: c.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              // +5 button (right, vertically centered)
                              if (isRunning)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: IconButton(
                                    tooltip: AppLocalizations.of(
                                      context,
                                    )!.timerPanelAddFiveMinutes,
                                    constraints: const BoxConstraints.tightFor(
                                      width: 48,
                                      height: 48,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: () => addTimeToRunningTimer(300),
                                    icon: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: c.surfaceSubtle,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: c.surfaceBorder,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.add_rounded,
                                        size: 18,
                                        color: c.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // End time badge (when running)
                        if (isRunning && _endLabel(context).isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: c.accentLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: c.accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _endLabel(context),
                                  style: GoogleFonts.inter(
                                    color: c.accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Chain progress
                        if (isRunning && chainModeOn) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: c.accentLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.link_rounded,
                                  size: 14,
                                  color: c.accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.timerPanelStep(chainIndex + 1),
                                  style: GoogleFonts.inter(
                                    color: c.accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Row 1: Start/Pause + Reset (always visible, same size) ──
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: isRunning
                        ? AppLocalizations.of(context)!.timerPanelPause
                        : AppLocalizations.of(context)!.timerPanelStart,
                    icon: isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    onPressed: isRunning ? stopTimer : startTimer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SecondaryButton(
                    label: AppLocalizations.of(context)!.timerPanelReset,
                    icon: Icons.refresh_rounded,
                    onPressed: resetTimer,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            PresetGrid(
              presets: presetValues,
              selectedValue: sliderValue,
              armedValue: armedPresetValue,
              onTap: onPresetTap,
              showCustomButton: true,
              onCustomTap: () => _showCustomTimeDialog(context),
            ),
            const SizedBox(height: 24),

            // ── Sound / Speech toggle row (like clock panel) ───
            Row(
              children: [
                _FeatureToggle(
                  icon: Icons.record_voice_over_rounded,
                  label: AppLocalizations.of(context)!.timerPanelSpeech,
                  active: timerSpeakOn,
                  onTap: () => onTimerSpeakOnChanged(!timerSpeakOn),
                ),
                const SizedBox(width: 10),
                _FeatureToggle(
                  icon: Icons.music_note_rounded,
                  label: AppLocalizations.of(context)!.timerPanelNoise,
                  active: timerNoiseOn,
                  onTap: () => onTimerNoiseOnChanged(!timerNoiseOn),
                ),
                const SizedBox(width: 10),
                _FeatureToggle(
                  icon: Icons.link_rounded,
                  label: AppLocalizations.of(context)!.timerPanelChain,
                  active: chainModeOn,
                  onTap: () => onChainModeChanged(!chainModeOn),
                ),
                const SizedBox(width: 10),
                _FeatureToggle(
                  icon: Icons.access_time_rounded,
                  label: AppLocalizations.of(context)!.timerPanelClock,
                  active: fullscreenShowClock,
                  onTap: () =>
                      onFullscreenShowClockChanged(!fullscreenShowClock),
                ),
              ],
            ),

            // ── Tagging toggle + Study/Non-Study selector ──────
            const SizedBox(height: 16),
            Row(
              children: [
                _FeatureToggle(
                  icon: Icons.label_rounded,
                  label: AppLocalizations.of(context)!.timerPanelTagging,
                  active: taggingOn,
                  onTap: () => onTaggingOnChanged(!taggingOn),
                ),
              ],
            ),
            if (taggingOn) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _FeatureToggle(
                    icon: Icons.menu_book_rounded,
                    label: AppLocalizations.of(context)!.timerPanelStudy,
                    active: sessionTag == 'study',
                    onTap: () => onSessionTagChanged('study'),
                  ),
                  const SizedBox(width: 10),
                  _FeatureToggle(
                    icon: Icons.hourglass_top_rounded,
                    label: AppLocalizations.of(context)!.timerPanelNonStudy,
                    active: sessionTag == 'non-study',
                    onTap: () => onSessionTagChanged('non-study'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Time Utilization dashboard entry
              GestureDetector(
                onTap: onDashboardPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.analytics_rounded, color: c.accent, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.timerPanelTimeUtilization,
                              style: GoogleFonts.inter(
                                color: c.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (todaySummary.isNotEmpty)
                              Text(
                                todaySummary,
                                style: GoogleFonts.inter(
                                  color: c.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: c.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            SettingsToggleRow(
              icon: Icons.timer_outlined,
              label: AppLocalizations.of(context)!.timerPanelShowMilliseconds,
              value: timerShowMilliseconds,
              onChanged: onTimerShowMillisecondsChanged,
            ),
            SettingsRow(
              icon: Icons.timer_outlined,
              label: AppLocalizations.of(context)!.timerPanelAnnounceEvery,
              value: AppLocalizations.of(
                context,
              )!.timerPanelMinutes(timerAnnounceEvery),
              onTap: () => _showAnnounceSheet(context),
            ),
            SettingsRow(
              icon: Icons.link_rounded,
              label: AppLocalizations.of(context)!.timerPanelChainMode,
              value: chainModeOn
                  ? AppLocalizations.of(context)!.timerPanelOn
                  : AppLocalizations.of(context)!.timerPanelOff,
              onTap: () => onChainModeChanged(!chainModeOn),
            ),
            if (chainModeOn)
              SettingsRow(
                icon: Icons.list_alt_rounded,
                label: AppLocalizations.of(context)!.timerPanelPresetSequence,
                value: _chainPresetLabel(context, chainPresetKey),
                onTap: () => _showChainSheet(context),
                showDivider: false,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAnnounceSheet(BuildContext context) async {
    final c = context.appColors;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.timerPanelAnnouncementInterval,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: timerAnnounceOptions.map((mins) {
                    final selected = mins == timerAnnounceEvery;
                    return ListTile(
                      selected: selected,
                      selectedTileColor: c.accentLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected ? c.accent : c.textMuted,
                      ),
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!.timerPanelAnnounceEveryMinutes(mins),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: c.textPrimary,
                        ),
                      ),
                      onTap: () {
                        onTimerAnnounceEveryChanged(mins);
                        Navigator.of(context).pop();
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

  Future<void> _showChainSheet(BuildContext context) async {
    final c = context.appColors;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.timerPanelChainPreset,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: chainPresets.entries.map((entry) {
                    final selected = entry.key == chainPresetKey;
                    return ListTile(
                      selected: selected,
                      selectedTileColor: c.accentLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected ? c.accent : c.textMuted,
                      ),
                      title: Text(
                        _chainPresetLabel(context, entry.key),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: c.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(
                          context,
                        )!.timerPanelSequenceMinutes(entry.value.join(' / ')),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: c.textSecondary,
                        ),
                      ),
                      onTap: () {
                        onChainPresetChanged(entry.key);
                        Navigator.of(context).pop();
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

  Future<void> _showCustomTimeDialog(BuildContext context) async {
    final c = context.appColors;
    final controller = TextEditingController(text: '25');
    String? inputError;
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.timerPanelCustomTimer,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(fontSize: 16, color: c.textPrimary),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.timerPanelMinutesLabel,
              hintText: AppLocalizations.of(context)!.timerPanelMinutesHint,
              suffixText: AppLocalizations.of(
                context,
              )!.timerPanelMinuteAbbreviation,
              errorText: inputError,
            ),
            onChanged: (_) {
              if (inputError != null) {
                setDialogState(() => inputError = null);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(context)!.timerPanelCancel),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                if (parsed != null && parsed >= 1 && parsed <= 720) {
                  Navigator.of(ctx).pop(parsed);
                } else {
                  setDialogState(
                    () => inputError = AppLocalizations.of(
                      context,
                    )!.timerPanelWholeNumberError,
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.timerPanelSet),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (result != null) {
      choosePreset(result);
    }
  }
}

/// Feature toggle card — icon + label + active state (same as clock panel).
class _FeatureToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FeatureToggle({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Expanded(
      child: Semantics(
        button: true,
        toggled: active,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: active ? c.accentLight : c.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? c.accentBorder : c.surfaceBorder,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: active ? c.accent : c.textSecondary,
                  size: 22,
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: GoogleFonts.inter(
                        color: active ? c.textPrimary : c.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  active
                      ? AppLocalizations.of(context)!.timerPanelOn
                      : AppLocalizations.of(context)!.timerPanelOff,
                  style: GoogleFonts.inter(
                    color: active ? c.accent : c.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
