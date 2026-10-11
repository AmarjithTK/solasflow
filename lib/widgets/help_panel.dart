import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class HelpPanel extends StatelessWidget {
  final bool muteSpeechAfterMidnight;
  final String nightMuteMode;
  final String sleepStartLabel;
  final String sleepEndLabel;

  const HelpPanel({
    super.key,
    required this.muteSpeechAfterMidnight,
    required this.nightMuteMode,
    required this.sleepStartLabel,
    required this.sleepEndLabel,
  });

  Widget _quickStep(
    BuildContext context,
    int index,
    String title,
    String subtitle,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              '$index',
              style: TextStyle(
                color: cs.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(
    BuildContext context, {
    required String title,
    required List<String> points,
    bool initiallyExpanded = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        iconColor: cs.primary,
        collapsedIconColor: cs.onSurfaceVariant,
        title: Text(
          title,
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        children: points
            .map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final range = '$sleepStartLabel → $sleepEndLabel';
    final sleepModeStatus = !muteSpeechAfterMidnight
        ? l10n.helpPanelSleepModeOff
        : (nightMuteMode == 'manual'
              ? l10n.helpPanelSleepModeManual
              : l10n.helpPanelSleepModeAutomatic);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primaryContainer, cs.surfaceContainerLow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sleepModeStatus,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (muteSpeechAfterMidnight)
                      Text(
                        l10n.helpPanelCurrentRange(range),
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.helpPanelQuickStart,
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        _quickStep(
          context,
          1,
          l10n.helpPanelConfigureTimerTitle,
          l10n.helpPanelConfigureTimerDescription,
        ),
        _quickStep(
          context,
          2,
          l10n.helpPanelSetSleepTitle,
          l10n.helpPanelSetSleepDescription,
        ),
        _quickStep(
          context,
          3,
          l10n.helpPanelWidgetControlsTitle,
          l10n.helpPanelWidgetControlsDescription,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.helpPanelFaq,
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
        _faqItem(
          context,
          title: l10n.helpPanelSpeakingClockTitle,
          points: [
            l10n.helpPanelSpeakingClockAnnouncements,
            l10n.helpPanelSpeakingClockQuotes,
          ],
        ),
        _faqItem(
          context,
          title: l10n.helpPanelTimerSetupTitle,
          points: [
            l10n.helpPanelTimerSetupPreset,
            l10n.helpPanelTimerSetupSpeech,
            l10n.helpPanelTimerSetupChain,
          ],
        ),
        _faqItem(
          context,
          title: l10n.helpPanelSleepModeTitle,
          initiallyExpanded: true,
          points: [
            l10n.helpPanelSleepModeRange,
            l10n.helpPanelSleepModeManualDescription,
            l10n.helpPanelSleepModeAutomaticDescription,
            l10n.helpPanelSleepModeResumeDescription,
          ],
        ),
        _faqItem(
          context,
          title: l10n.helpPanelHomeWidgetTitle,
          points: [
            l10n.helpPanelHomeWidgetSpeech,
            l10n.helpPanelHomeWidgetTimer,
            l10n.helpPanelHomeWidgetQuickSessions,
            l10n.helpPanelHomeWidgetStatus,
          ],
        ),
        _faqItem(
          context,
          title: l10n.helpPanelTipsTitle,
          points: [
            l10n.helpPanelTipsSync,
            l10n.helpPanelTipsPermissions,
            l10n.helpPanelTipsBackground,
          ],
        ),
      ],
    );
  }
}
