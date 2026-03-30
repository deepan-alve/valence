import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/group_provider.dart';
import 'package:valence/services/llm_nudge_service.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';
import 'package:valence/widgets/shared/valence_toast.dart';

/// Bottom sheet shown when a user taps nudge on a group member.
///
/// Shows a personality-aware header, an LLM-generated preview message
/// (read-only), and send/cancel actions.
///
/// Usage:
/// ```dart
/// NudgeSheet.show(
///   context,
///   memberId: 'u4',
///   memberName: 'Ravi',
///   habitName: 'Exercise',
///   streakDays: 7,
///   missReasons: ['tired'],
/// );
/// ```
class NudgeSheet extends StatefulWidget {
  final String memberId;
  final String memberName;
  final String habitName;
  final int streakDays;
  final List<String> missReasons;

  const NudgeSheet({
    super.key,
    required this.memberId,
    required this.memberName,
    this.habitName = 'their habit',
    this.streakDays = 0,
    this.missReasons = const [],
  });

  /// Convenience: open as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String memberId,
    required String memberName,
    String habitName = 'their habit',
    int streakDays = 0,
    List<String> missReasons = const [],
  }) {
    final groupProvider = context.read<GroupProvider>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: groupProvider,
        child: NudgeSheet(
          memberId: memberId,
          memberName: memberName,
          habitName: habitName,
          streakDays: streakDays,
          missReasons: missReasons,
        ),
      ),
    );
  }

  @override
  State<NudgeSheet> createState() => _NudgeSheetState();
}

class _NudgeSheetState extends State<NudgeSheet> {
  final _llmService = LlmNudgeService();
  String? _nudgeMessage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessage();
  }

  Future<void> _loadMessage() async {
    final msg = await _llmService.generateNudgeMessage(
      receiverName: widget.memberName,
      habitName: widget.habitName,
      streakDays: widget.streakDays,
      recentMissReasons: widget.missReasons,
    );
    if (mounted) {
      setState(() {
        _nudgeMessage = '"$msg"';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;
    final groupProvider = context.read<GroupProvider>();
    final copy = groupProvider.copy;

    final alreadyNudged = groupProvider.hasNudgedToday(widget.memberId);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(ValenceSpacing.md),
        padding: const EdgeInsets.fromLTRB(
          ValenceSpacing.lg,
          ValenceSpacing.lg,
          ValenceSpacing.lg,
          ValenceSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: ValenceSpacing.lg),

            // Header row: icon + title
            Row(
              children: [
                Icon(
                  PhosphorIconsRegular.bellRinging,
                  color: colors.accentPrimary,
                  size: 24,
                ),
                const SizedBox(width: ValenceSpacing.sm),
                Expanded(
                  child: Text(
                    copy.nudgeSheetTitle(widget.memberName),
                    style: typography.h2.copyWith(color: colors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ValenceSpacing.sm),

            // Body copy
            Text(
              copy.nudgeSheetBody(widget.memberName),
              style: typography.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: ValenceSpacing.md),

            // LLM preview message (read-only)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ValenceSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceSunken,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.borderDefault),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.sparkle,
                        size: 13,
                        color: colors.accentSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI-generated message (private to ${widget.memberName})',
                        style: typography.overline.copyWith(
                          color: colors.accentSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ValenceSpacing.sm),
                  if (_loading)
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: colors.surfaceSunken,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.accentPrimary,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.surfaceSunken,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _nudgeMessage ?? '',
                            style: tokens.typography.body.copyWith(
                              color: colors.textPrimary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        if (_llmService.lastCallWasFallback) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Auto-generated nudge (AI is busy)',
                            style: tokens.typography.caption
                                .copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: ValenceSpacing.xs),
                  Text(
                    'Only ${widget.memberName} will see this',
                    style: typography.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),

            // Already-nudged state
            if (alreadyNudged) ...[
              const SizedBox(height: ValenceSpacing.md),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: colors.accentWarning),
                  const SizedBox(width: ValenceSpacing.xs),
                  Expanded(
                    child: Text(
                      copy.nudgeAlreadySent,
                      style: typography.caption.copyWith(color: colors.accentWarning),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: ValenceSpacing.lg),

            // Actions
            ValenceButton(
              label: 'Send Nudge',
              fullWidth: true,
              variant: ValenceButtonVariant.primary,
              icon: PhosphorIconsRegular.paperPlaneTilt,
              onPressed: alreadyNudged
                  ? null
                  : () {
                      groupProvider.sendNudge(widget.memberId);
                      ValenceToast.show(
                        context,
                        message: copy.nudgeSentToast(widget.memberName),
                        type: ToastType.success,
                      );
                      Navigator.of(context).pop();
                    },
            ),
            const SizedBox(height: ValenceSpacing.sm),
            ValenceButton(
              label: 'Cancel',
              fullWidth: true,
              variant: ValenceButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: ValenceSpacing.sm),
          ],
          ),
        ),
      ),
    );
  }
}
