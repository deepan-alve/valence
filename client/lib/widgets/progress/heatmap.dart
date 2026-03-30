import 'package:flutter/material.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// GitHub-style contribution heatmap grid.
///
/// Displays [weeks] × 7 days of completion data, scrollable horizontally.
/// Each cell is a 12×12px rounded rectangle with a 2px gap.
/// Color: [surfaceSunken] for empty/missed, [color] at full opacity for completed.
///
/// Month labels appear on top (Jan, Feb, …).
/// Day labels appear on the left (M, W, F).
///
/// [data] maps a normalized date (midnight) to a completion count.
/// Any value > 0 is treated as completed.
class ValenceHeatmap extends StatelessWidget {
  final Map<DateTime, int> data;
  final Color color;
  final int weeks;

  static const double _cellSize = 12.0;
  static const double _gap = 2.0;
  static const double _dayLabelWidth = 16.0;
  static const double _monthLabelHeight = 16.0;

  const ValenceHeatmap({
    super.key,
    required this.data,
    required this.color,
    this.weeks = 12,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    // Build a [weeks × 7] grid of dates, oldest first (col=0, row=0 is oldest Mon).
    final today = DateTime.now();
    // Align so the last column ends on today's weekday.
    final daysBack = (weeks * 7) - 1;
    final startDate = today.subtract(Duration(days: daysBack));

    // Pre-build month label positions: (column index, month label).
    final monthLabels = <int, String>{};
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    for (int col = 0; col < weeks; col++) {
      // The Monday of this column
      final colStart = startDate.add(Duration(days: col * 7));
      if (col == 0 || colStart.month != startDate.add(Duration(days: (col - 1) * 7)).month) {
        monthLabels[col] = monthNames[colStart.month - 1];
      }
    }

    final totalWidth =
        _dayLabelWidth + weeks * (_cellSize + _gap) - _gap;
    final totalHeight =
        _monthLabelHeight + ValenceSpacing.xs + 7 * (_cellSize + _gap) - _gap;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        height: totalHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month labels row
            SizedBox(
              height: _monthLabelHeight,
              child: Stack(
                children: monthLabels.entries.map((e) {
                  final left = _dayLabelWidth + e.key * (_cellSize + _gap);
                  return Positioned(
                    left: left,
                    top: 0,
                    child: Text(
                      e.value,
                      style: tokens.typography.caption.copyWith(
                        color: colors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: ValenceSpacing.xs),
            // Day labels + cell grid
            SizedBox(
              height: 7 * (_cellSize + _gap) - _gap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day labels column (M, W, F)
                  SizedBox(
                    width: _dayLabelWidth,
                    child: Column(
                      children: List.generate(7, (row) {
                        const labels = ['M', '', 'W', '', 'F', '', ''];
                        // Last row has no bottom gap so height matches the cell column.
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: row < 6 ? _gap : 0,
                          ),
                          child: SizedBox(
                            height: _cellSize,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: labels[row].isNotEmpty
                                  ? Text(
                                      labels[row],
                                      style: tokens.typography.caption.copyWith(
                                        color: colors.textSecondary,
                                        fontSize: 9,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Cells grid: weeks columns, 7 rows each
                  ...List.generate(weeks, (col) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: col < weeks - 1 ? _gap : 0,
                      ),
                      child: Column(
                        children: List.generate(7, (row) {
                          final dayOffset = col * 7 + row;
                          final date = startDate.add(Duration(days: dayOffset));
                          final normalized =
                              DateTime(date.year, date.month, date.day);
                          final count = data[normalized] ?? 0;
                          final isCompleted = count > 0;
                          // Future cells are empty
                          final isFuture = normalized.isAfter(
                            DateTime(today.year, today.month, today.day),
                          );

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: row < 6 ? _gap : 0,
                            ),
                            child: Container(
                              width: _cellSize,
                              height: _cellSize,
                              decoration: BoxDecoration(
                                color: (!isFuture && isCompleted)
                                    ? color
                                    : colors.surfaceSunken,
                                borderRadius: ValenceRadii.smallAll,
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
