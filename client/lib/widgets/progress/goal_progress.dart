import 'package:flutter/material.dart';
import 'package:valence/models/habit_progress.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Visual 4-stage graduation bar for the habit goal lifecycle.
///
/// Shows Ignition (3d) → Foundation (10d) → Momentum (21d) → Formed (66d)
/// as labeled nodes connected by a filled/unfilled line.
///
/// - Completed stages: [accentSuccess] fill
/// - Current stage: [accentPrimary] fill with bold label
/// - Upcoming stages: [surfaceSunken] fill, [textSecondary] label
///
/// Below the bar: "X days to [NextStage]" or "Habit fully formed!" at Formed.
class GoalProgress extends StatelessWidget {
  final GoalStage goalStage;
  final int daysToNextStage;
  final int totalDaysCompleted;

  static const List<GoalStage> _stages = GoalStage.values;

  const GoalProgress({
    super.key,
    required this.goalStage,
    required this.daysToNextStage,
    required this.totalDaysCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    final currentIndex = _stages.indexOf(goalStage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar row
        SizedBox(
          height: 56,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Connector line (sits behind the nodes)
                  Positioned(
                    left: 0,
                    right: 0,
                    child: _ConnectorLine(
                      currentIndex: currentIndex,
                      stageCount: _stages.length,
                      totalWidth: totalWidth,
                      colors: colors,
                    ),
                  ),
                  // Stage nodes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_stages.length, (i) {
                      final stage = _stages[i];
                      final isCompleted = i < currentIndex;
                      final isCurrent = i == currentIndex;
                      final isUpcoming = i > currentIndex;
                      return _StageNode(
                        stage: stage,
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        isUpcoming: isUpcoming,
                        colors: colors,
                        tokens: tokens,
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: ValenceSpacing.sm),
        // "X days to NextStage" label
        _SubLabel(
          goalStage: goalStage,
          daysToNextStage: daysToNextStage,
          colors: colors,
          tokens: tokens,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _ConnectorLine extends StatelessWidget {
  final int currentIndex;
  final int stageCount;
  final double totalWidth;
  final dynamic colors;

  const _ConnectorLine({
    required this.currentIndex,
    required this.stageCount,
    required this.totalWidth,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    // Node diameter is 28px; line sits in center at y=0.
    const nodeSize = 28.0;
    final segmentWidth =
        (totalWidth - nodeSize * stageCount) / (stageCount - 1);

    return Row(
      children: List.generate(stageCount - 1, (i) {
        // Segment is completed if both its endpoints are completed/current
        final isFilledSegment = i < currentIndex;
        return Row(
          children: [
            SizedBox(width: nodeSize),
            Container(
              width: segmentWidth,
              height: 3,
              decoration: BoxDecoration(
                color: isFilledSegment
                    ? colors.accentSuccess
                    : colors.surfaceSunken,
                borderRadius: ValenceRadii.roundAll,
              ),
            ),
          ],
        );
      })
        ..add(const Row(children: [SizedBox(width: 28)])),
    );
  }
}

class _StageNode extends StatelessWidget {
  final GoalStage stage;
  final bool isCompleted;
  final bool isCurrent;
  final bool isUpcoming;
  final dynamic colors;
  final ValenceTokens tokens;

  const _StageNode({
    required this.stage,
    required this.isCompleted,
    required this.isCurrent,
    required this.isUpcoming,
    required this.colors,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final Color nodeColor;
    if (isCompleted) {
      nodeColor = colors.accentSuccess;
    } else if (isCurrent) {
      nodeColor = colors.accentPrimary;
    } else {
      nodeColor = colors.surfaceSunken;
    }

    final Color labelColor =
        isUpcoming ? colors.textSecondary : colors.textPrimary;
    final FontWeight labelWeight =
        isCurrent ? FontWeight.w700 : FontWeight.w500;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dot
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: nodeColor,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(
                    color: colors.accentPrimary.withValues(alpha: 0.3),
                    width: 3,
                  )
                : null,
          ),
          child: isCompleted
              ? Icon(Icons.check, size: 16, color: colors.textInverse)
              : Center(
                  child: Text(
                    '${stage.targetDays}',
                    style: tokens.typography.caption.copyWith(
                      color: isCurrent ? colors.textInverse : colors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: ValenceSpacing.xs),
        // Stage name label
        Text(
          stage.displayName,
          style: tokens.typography.caption.copyWith(
            color: labelColor,
            fontWeight: labelWeight,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _SubLabel extends StatelessWidget {
  final GoalStage goalStage;
  final int daysToNextStage;
  final dynamic colors;
  final ValenceTokens tokens;

  const _SubLabel({
    required this.goalStage,
    required this.daysToNextStage,
    required this.colors,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    if (goalStage == GoalStage.formed) {
      return Text(
        'Habit fully formed!',
        style: tokens.typography.body.copyWith(
          color: colors.accentSuccess,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final stages = GoalStage.values;
    final nextIndex = stages.indexOf(goalStage) + 1;
    final nextStage = nextIndex < stages.length ? stages[nextIndex] : GoalStage.formed;

    return RichText(
      text: TextSpan(
        style: tokens.typography.body.copyWith(color: colors.textSecondary),
        children: [
          TextSpan(
            text: '$daysToNextStage',
            style: TextStyle(
              color: colors.accentPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: ' days to '),
          TextSpan(
            text: nextStage.displayName,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
