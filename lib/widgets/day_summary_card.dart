import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../models/session_log.dart';

/// A card showing study/non-study totals for a single day.
///
/// Designed to be modular — an [onTap] callback can be added later
/// to navigate to session detail view.
class DaySummaryCard extends StatelessWidget {
  final DateTime date;
  final DailySummary summary;
  final VoidCallback? onTap;

  const DaySummaryCard({
    super.key,
    required this.date,
    required this.summary,
    this.onTap,
  });

  String _dayLabel(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    final localizations = AppLocalizations.of(context)!;
    if (diff == 0) return localizations.today;
    if (diff == 1) return localizations.yesterday;
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final studyColor =
        isLight ? const Color(0xFF15803D) : const Color(0xFF4ADE80);
    final nonStudyColor =
        isLight ? const Color(0xFFB45309) : const Color(0xFFFBBF24);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dayLabel(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      summary.totalFormatted,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Study row
                _SummaryRow(
                  icon: Icons.menu_book_rounded,
                  label: AppLocalizations.of(context)!.daySummaryStudy,
                  time: summary.studyFormatted,
                  color: studyColor,
                ),
                const SizedBox(height: 8),
                // Non-study row
                _SummaryRow(
                  icon: Icons.hourglass_top_rounded,
                  label: AppLocalizations.of(context)!.daySummaryNonStudy,
                  time: summary.nonStudyFormatted,
                  color: nonStudyColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color color;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          time,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
