import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Bar chart showing completion rate (0–100%) per day of week (Mon–Sun).
///
/// Uses `fl_chart` [BarChart]. Bars are colored with the habit's assigned
/// [color]. The strongest day is rendered at full opacity; all other bars
/// are rendered at 60% opacity so the peak day stands out.
///
/// [frequencyByDay] maps weekday index (1 = Mon … 7 = Sun) to a rate 0.0–1.0.
class FrequencyChart extends StatelessWidget {
  final Map<int, double> frequencyByDay;
  final Color color;

  static const List<String> _dayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  const FrequencyChart({
    super.key,
    required this.frequencyByDay,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    // Find the strongest day (weekday 1–7 key).
    final maxRate = frequencyByDay.values.fold(0.0, (a, b) => b > a ? b : a);

    final barGroups = List.generate(7, (i) {
      final weekday = i + 1; // 1=Mon … 7=Sun
      final rate = frequencyByDay[weekday] ?? 0.0;
      final isStrongest = rate == maxRate && maxRate > 0;

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: (rate * 100).clamp(0, 100),
            color: color.withValues(alpha: isStrongest ? 1.0 : 0.45),
            width: 18,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(ValenceRadii.small),
            ),
          ),
        ],
      );
    });

    return SizedBox(
      height: 180,
      child: BarChart(
        duration: const Duration(milliseconds: 300),
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          minY: 0,
          barGroups: barGroups,
          barTouchData: BarTouchData(enabled: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colors.borderDefault,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  if (value % 25 != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      '${value.toInt()}%',
                      style: tokens.typography.caption.copyWith(
                        color: colors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= _dayLabels.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      _dayLabels[index],
                      style: tokens.typography.caption.copyWith(
                        color: colors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
