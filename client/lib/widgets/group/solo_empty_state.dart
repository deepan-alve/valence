import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/group_provider.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';

/// Full-screen centered empty state shown when the user has no group
/// (i.e. [GroupProvider.hasGroup] is false).
///
/// Copy adapts to the personality toggle via [PersonalityCopy].
///
/// Usage:
/// ```dart
/// // Typically placed as the body of GroupScreen when hasGroup == false
/// const SoloEmptyState(
///   onCreateGroup: _handleCreateGroup,
///   onJoinGroup: _handleJoinGroup,
/// );
/// ```
class SoloEmptyState extends StatelessWidget {
  final VoidCallback? onCreateGroup;
  final VoidCallback? onJoinGroup;

  const SoloEmptyState({
    super.key,
    this.onCreateGroup,
    this.onJoinGroup,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;
    final copy = context.watch<GroupProvider>().copy;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ValenceSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Large icon
            Icon(
              PhosphorIconsRegular.usersThree,
              size: 80,
              color: colors.textSecondary,
            ),
            const SizedBox(height: ValenceSpacing.lg),

            // Title
            Text(
              copy.emptyStateGroupTitle,
              style: typography.h2.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ValenceSpacing.sm),

            // Body
            Text(
              copy.emptyStateGroupBody,
              style: typography.body.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ValenceSpacing.xl),

            // CTA: Create a Group
            ValenceButton(
              label: 'Create a Group',
              fullWidth: true,
              variant: ValenceButtonVariant.primary,
              icon: PhosphorIconsRegular.usersThree,
              onPressed: onCreateGroup,
            ),
            const SizedBox(height: ValenceSpacing.sm),

            // CTA: Join with Invite Link
            ValenceButton(
              label: 'Join with Invite Link',
              fullWidth: true,
              variant: ValenceButtonVariant.secondary,
              icon: PhosphorIconsRegular.link,
              onPressed: onJoinGroup,
            ),
            const SizedBox(height: ValenceSpacing.xl),

            // Social proof caption
            Text(
              copy.emptyStateSocialProof,
              style: typography.caption.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
