import 'package:flutter/material.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Horizontal row of 7 day chips for selecting a day of the week.
///
/// Each chip shows the day number and short day name. The current day is
/// highlighted with accentPrimary. Past days show a status indicator
/// (color + icon for accessibility). Future days appear grayed out.
class DaySelector extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selectedDay;

  /// Status for each day — keyed by normalized date (midnight).
  final Map<DateTime, DayStatus> dayStatus;

  final ValueChanged<DateTime> onDaySelected;

  const DaySelector({
    super.key,
    required this.days,
    required this.selectedDay,
    required this.dayStatus,
    required this.onDaySelected,
  });

  static const List<String> _shortDayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  /// Normalize a [DateTime] to midnight so map lookups work correctly.
  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  DayStatus _statusFor(DateTime day) {
    return dayStatus[_normalize(day)] ?? DayStatus.future;
  }

  bool _isSelected(DateTime day) =>
      _normalize(day) == _normalize(selectedDay);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SizedBox(
      height: 72,
      child: Row(
        children: days.asMap().entries.map((entry) {
          final day = entry.value;
          final status = _statusFor(day);
          final selected = _isSelected(day);

          return Expanded(
            child: _DayChip(
              dayNumber: day.day,
              shortName: _shortDayNames[(day.weekday - 1) % 7],
              status: status,
              isSelected: selected,
              tokens: tokens,
              onTap: () => onDaySelected(day),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final int dayNumber;
  final String shortName;
  final DayStatus status;
  final bool isSelected;
  final ValenceTokens tokens;
  final VoidCallback onTap;

  const _DayChip({
    required this.dayNumber,
    required this.shortName,
    required this.status,
    required this.isSelected,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final typography = tokens.typography;

    // Determine chip background and text colors
    final Color chipBg;
    final Color dayNumColor;
    final Color dayNameColor;

    if (isSelected) {
      chipBg = colors.accentPrimary;
      dayNumColor = colors.textInverse;
      dayNameColor = colors.textInverse;
    } else {
      chipBg = Colors.transparent;
      dayNumColor = colors.textPrimary;
      dayNameColor = colors.textSecondary;
    }

    // Status indicator (past days only, not selected & not future)
    Widget? statusIndicator;
    if (!isSelected && status != DayStatus.future) {
      statusIndicator = _StatusDot(status: status, colors: colors);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        label: '$shortName $dayNumber, ${_semanticLabel(status)}',
        button: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: ValenceSpacing.xs / 2),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: ValenceRadii.mediumAll,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Day number
              Text(
                dayNumber.toString(),
                style: typography.body.copyWith(
                  color: dayNumColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              // Short day name
              Text(
                shortName,
                style: typography.overline.copyWith(
                  color: dayNameColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              // Status dot (or empty space placeholder for layout stability)
              SizedBox(
                height: 10,
                child: statusIndicator ?? const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _semanticLabel(DayStatus status) {
    switch (status) {
      case DayStatus.allDone:
        return 'all habits completed';
      case DayStatus.partial:
        return 'some habits completed';
      case DayStatus.missed:
        return 'missed';
      case DayStatus.future:
        return 'upcoming';
    }
  }
}

/// A small colored circle with an icon — used for accessibility.
/// Never relies on color alone to convey status.
class _StatusDot extends StatelessWidget {
  final DayStatus status;
  final dynamic colors; // ValenceColors

  const _StatusDot({required this.status, required this.colors});

  @override
  Widget build(BuildContext context) {
    final Color dotColor;
    final IconData icon;
    final String label;

    switch (status) {
      case DayStatus.allDone:
        dotColor = const Color(0xFF22C55E); // green-500
        icon = Icons.check;
        label = 'All done';
      case DayStatus.partial:
        dotColor = const Color(0xFFF59E0B); // amber-500
        icon = Icons.remove;
        label = 'Partial';
      case DayStatus.missed:
        dotColor = const Color(0xFFEF4444); // red-500
        icon = Icons.close;
        label = 'Missed';
      case DayStatus.future:
        return const SizedBox.shrink();
    }

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 7,
          color: Colors.white,
        ),
      ),
    );
  }
}
