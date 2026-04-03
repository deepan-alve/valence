// client/lib/widgets/social/miss_logging_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/models/miss_log.dart';
import 'package:valence/providers/group_provider.dart';
import 'package:valence/providers/miss_log_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Bottom sheet for logging a missed habit.
/// Design spec 2.10: quick-select chips + optional free-text.
class MissLoggingSheet extends StatefulWidget {
  final String habitId;
  final String habitName;
  final VoidCallback onDone;

  /// Controls whether the miss is posted to the group feed (PRD 5.4).
  /// Defaults to [HabitVisibility.full] (post to feed).
  final HabitVisibility visibility;

  const MissLoggingSheet({
    super.key,
    required this.habitId,
    required this.habitName,
    required this.onDone,
    this.visibility = HabitVisibility.full,
  });

  /// Show the sheet, injecting existing providers through the route.
  static Future<void> show(
    BuildContext context, {
    required String habitId,
    required String habitName,
    required VoidCallback onDone,
    HabitVisibility visibility = HabitVisibility.full,
  }) {
    final missLogProvider = context.read<MissLogProvider>();
    final groupProvider = context.read<GroupProvider>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider<MissLogProvider>.value(value: missLogProvider),
          ChangeNotifierProvider<GroupProvider>.value(value: groupProvider),
        ],
        child: MissLoggingSheet(
          habitId: habitId,
          habitName: habitName,
          onDone: onDone,
          visibility: visibility,
        ),
      ),
    );
  }

  @override
  State<MissLoggingSheet> createState() => _MissLoggingSheetState();
}

class _MissLoggingSheetState extends State<MissLoggingSheet> {
  MissReason? _selectedReason;
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedReason == null) return;
    context.read<MissLogProvider>().logMiss(
          habitId: widget.habitId,
          habitName: widget.habitName,
          reason: _selectedReason!,
          reasonText: _textController.text.trim().isEmpty
              ? null
              : _textController.text.trim(),
        );
    if (widget.visibility == HabitVisibility.full) {
      context.read<GroupProvider>().postMissToFeed(
            habitName: widget.habitName,
            missReason: _selectedReason!.displayLabel,
          );
    }
    widget.onDone();
    Navigator.pop(context);
  }

  void _skip() {
    widget.onDone();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ValenceRadii.large),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          ValenceSpacing.md,
          ValenceSpacing.md,
          ValenceSpacing.md,
          ValenceSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderDefault,
                  borderRadius: ValenceRadii.roundAll,
                ),
              ),
            ),
            const SizedBox(height: ValenceSpacing.md),

            // Title
            Text(
              'Why did you miss ${widget.habitName}?',
              style: tokens.typography.h3.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: ValenceSpacing.xs),

            // Supportive copy
            Text(
              'No judgment. This helps us help you.',
              style: tokens.typography.body.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: ValenceSpacing.md),

            // Quick-select chips
            Wrap(
              spacing: ValenceSpacing.smMd,
              runSpacing: ValenceSpacing.smMd,
              children: MissReason.values.map((reason) {
                final isSelected = _selectedReason == reason;
                return ChoiceChip(
                  label: Text(reason.displayLabel),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedReason = reason);
                  },
                  selectedColor: colors.accentPrimary,
                  backgroundColor: colors.surfaceSunken,
                  labelStyle: tokens.typography.body.copyWith(
                    color: isSelected ? colors.textInverse : colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: ValenceRadii.roundAll,
                    side: BorderSide(
                      color: isSelected
                          ? colors.accentPrimary
                          : colors.borderDefault,
                    ),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: ValenceSpacing.md),

            // Optional free-text
            TextField(
              controller: _textController,
              maxLength: 200,
              maxLines: 2,
              style: tokens.typography.body.copyWith(
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Tell us more (optional)',
                hintStyle: tokens.typography.body.copyWith(
                  color: colors.textSecondary,
                ),
                filled: true,
                fillColor: colors.surfaceSunken,
                border: OutlineInputBorder(
                  borderRadius: ValenceRadii.mediumAll,
                  borderSide: BorderSide(color: colors.borderDefault),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: ValenceRadii.mediumAll,
                  borderSide: BorderSide(color: colors.borderDefault),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: ValenceRadii.mediumAll,
                  borderSide: BorderSide(color: colors.borderFocus, width: 1.5),
                ),
                counterStyle: tokens.typography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: ValenceSpacing.md),

            // Log button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedReason != null ? _submit : null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: colors.accentPrimary,
                  foregroundColor: colors.textInverse,
                  disabledBackgroundColor: colors.surfaceSunken,
                  disabledForegroundColor: colors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: ValenceRadii.mediumAll,
                  ),
                ),
                child: Text(
                  'Log',
                  style: tokens.typography.body.copyWith(
                    color: _selectedReason != null
                        ? colors.textInverse
                        : colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: ValenceSpacing.sm),

            // Skip button
            Center(
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  'Skip',
                  style: tokens.typography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
