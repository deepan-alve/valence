import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/feed_item.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/utils/personality_copy.dart';

/// Renders a single event in the group feed timeline.
///
/// Eight distinct layouts, one per [FeedItemType].
/// All colors come from theme tokens — zero hardcoded values.
class FeedItemCard extends StatelessWidget {
  final FeedItem item;
  final PersonalityCopy copy;

  /// Triggered when the user taps the kudos button on a completion card.
  final VoidCallback? onKudos;

  const FeedItemCard({
    super.key,
    required this.item,
    required this.copy,
    this.onKudos,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return switch (item.type) {
      FeedItemType.completion => _CompletionCard(item: item, copy: copy, tokens: tokens, onKudos: onKudos),
      FeedItemType.miss => _MissCard(item: item, copy: copy, tokens: tokens),
      FeedItemType.nudge => _NudgeCard(item: item, copy: copy, tokens: tokens),
      FeedItemType.kudos => _KudosCard(item: item, copy: copy, tokens: tokens),
      FeedItemType.statusNorm => _StatusNormCard(item: item, copy: copy, tokens: tokens),
      FeedItemType.chainLink => _ChainLinkCard(item: item, copy: copy, tokens: tokens),
      FeedItemType.milestone => _MilestoneCard(item: item, copy: copy, tokens: tokens),
      FeedItemType.streakFreeze => _StreakFreezeCard(item: item, copy: copy, tokens: tokens),
    };
  }
}

// ---------------------------------------------------------------------------
// Base card shell
// ---------------------------------------------------------------------------

class _BaseCard extends StatelessWidget {
  final Widget leading;
  final Widget content;
  final Widget? trailing;
  final Color accentColor;
  final ValenceTokens tokens;

  const _BaseCard({
    required this.leading,
    required this.content,
    this.trailing,
    required this.accentColor,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: ValenceSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.md,
        vertical: ValenceSpacing.smMd,
      ),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: ValenceRadii.mediumAll,
        border: Border(
          left: BorderSide(color: accentColor, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: leading,
            ),
          ),
          const SizedBox(width: ValenceSpacing.sm),
          Expanded(child: content),
          if (trailing != null) ...[
            const SizedBox(width: ValenceSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Icon + circle wrapper used as the leading widget.
class _LeadingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _LeadingIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 15, color: color),
    );
  }
}

/// Timestamp pill shown in the trailing position of most cards.
class _TimestampChip extends StatelessWidget {
  final String timeAgo;
  final ValenceTokens tokens;

  const _TimestampChip({required this.timeAgo, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Text(
      timeAgo,
      style: tokens.typography.caption.copyWith(
        color: tokens.colors.textSecondary,
        fontSize: 11,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Completion
// ---------------------------------------------------------------------------

class _CompletionCard extends StatelessWidget {
  final FeedItem item;
  final PersonalityCopy copy;
  final ValenceTokens tokens;
  final VoidCallback? onKudos;

  const _CompletionCard({
    required this.item,
    required this.copy,
    required this.tokens,
    required this.onKudos,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final displayName = item.isMinimalVisibility ? 'their habit' : (item.habitName ?? 'a habit');
    final message = copy.completionMessage(
      item.senderName,
      displayName,
      plugin: item.verificationSource,
    );

    return _BaseCard(
      accentColor: colors.accentSuccess,
      tokens: tokens,
      leading: _LeadingIcon(
        icon: PhosphorIconsRegular.checkCircle,
        color: colors.accentSuccess,
      ),
      trailing: _TimestampChip(timeAgo: item.timeAgo, tokens: tokens),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: tokens.typography.body.copyWith(color: colors.textPrimary),
          ),
          if (item.verificationSource != null) ...[
            const SizedBox(height: ValenceSpacing.xs),
            _VerificationBadge(source: item.verificationSource!, tokens: tokens),
          ],
          if (onKudos != null) ...[
            const SizedBox(height: ValenceSpacing.sm),
            _KudosButton(onPressed: onKudos!, tokens: tokens),
          ],
        ],
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  final String source;
  final ValenceTokens tokens;

  const _VerificationBadge({required this.source, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colors.accentPrimary.withValues(alpha: 0.10),
        borderRadius: ValenceRadii.roundAll,
        border: Border.all(
          color: colors.accentPrimary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsRegular.shieldCheck, size: 11, color: colors.accentPrimary),
          const SizedBox(width: 3),
          Text(
            'Verified via $source',
            style: tokens.typography.overline.copyWith(color: colors.accentPrimary),
          ),
        ],
      ),
    );
  }
}

class _KudosButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ValenceTokens tokens;

  const _KudosButton({required this.onPressed, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    return Semantics(
      label: 'Send kudos',
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsRegular.heart, size: 14, color: colors.accentSocial),
            const SizedBox(width: 4),
            Text(
              'Kudos',
              style: tokens.typography.caption.copyWith(
                color: colors.accentSocial,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Miss
// ---------------------------------------------------------------------------

class _MissCard extends StatelessWidget {
  final FeedItem item;
  final PersonalityCopy copy;
  final ValenceTokens tokens;

  const _MissCard({required this.item, required this.copy, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final displayName = item.isMinimalVisibility ? 'their habit' : (item.habitName ?? 'a habit');
    final message = copy.missMessage(item.senderName, displayName);

    return _BaseCard(
      accentColor: colors.accentWarning,
      tokens: tokens,
      leading: _LeadingIcon(
        icon: PhosphorIconsRegular.heartbeat,
        color: colors.accentWarning,
      ),
      trailing: _TimestampChip(timeAgo: item.timeAgo, tokens: tokens),
      content: Text(
        message,
        style: tokens.typography.body.copyWith(color: colors.textPrimary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Nudge
// ---------------------------------------------------------------------------

class _NudgeCard extends StatelessWidget {
  final FeedItem item;
  final PersonalityCopy copy;
  final ValenceTokens tokens;

  const _NudgeCard({required this.item, required this.copy, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    // The actual LLM message is private — show only that a nudge happened.
    final message = copy.nudgeFeedMessage(
      item.senderName,
      item.receiverName ?? 'someone',
    );

    return _BaseCard(
      accentColor: colors.accentPrimary,
      tokens: tokens,
      leading: _LeadingIcon(
        icon: PhosphorIconsRegular.bellRinging,
        color: colors.accentPrimary,
      ),
      trailing: _TimestampChip(timeAgo: item.timeAgo, tokens: tokens),
      content: Text(
        message,
        style: tokens.typography.body.copyWith(color: colors.textPrimary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Kudos
// ---------------------------------------------------------------------------

class _KudosCard extends StatelessWidget {
  final FeedItem item;
  final PersonalityCopy copy;
  final ValenceTokens tokens;

  const _KudosCard({required this.item, required this.copy, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final message = copy.kudosFeedMessage(
      item.senderName,
      item.receiverName ?? 'someone',
    );

    return _BaseCard(
      accentColor: colors.accentSocial,
      tokens: tokens,
      leading: _LeadingIcon(
        icon: PhosphorIconsRegular.confetti,
        color: colors.accentSocial,
      ),
      trailing: _TimestampChip(timeAgo: item.timeAgo, tokens: tokens),
      content: Text(
        message,
        style: tokens.typography.body.copyWith(color: colors.textPrimary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. StatusNorm
// ---------------------------------------------------------------------------

class _StatusNormCard extends StatelessWidget {
  final FeedItem item;
  final PersonalityCopy copy;
  final ValenceTokens tokens;

  const _StatusNormCard({required this.item, required this.copy, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    // message field holds the streak label e.g. "7-day streak"
    final streakDays = _parseStreakDays(item.message ?? '');
    final message = copy.statusNormMessage(item.senderName, streakDays);

    return _BaseCard(
      accentColor: colors.accentSecondary,
      tokens: tokens,
      leading: _LeadingIcon(
        icon: PhosphorIconsRegular.trendUp,
        color: colors.accentSecondary,
      ),
      trailing: _TimestampChip(timeAgo: item.timeAgo, tokens: tokens),
      content: Text(
        message,
        style: tokens.typography.body.copyWith(color: colors.textPrimary),
      ),
    );
  }

  int _parseStreakDays(String message) {
    final match = RegExp(r'(\d+)').firstMatch(message);
    if (match != null) return int.tryParse(match.group(1) ?? '') ?? 0;
    return 0;
  }
}

// ---------------------------------------------------------------------------
// 6. Chain link
// ---------------------------------------------------------------------------

class _ChainLinkCard extends StatelessWidget {
  final FeedItem item;
  final PersonalityCopy copy;
  final ValenceTokens tokens;

  const _ChainLinkCard({required this.item, required this.copy, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final linkType = item.message ?? 'gold';
    final message = copy.chainLinkMessage(linkType, 0, 0);

    final Color accent;
    final IconData icon;

    switch (linkType.toLowerCase()) {
      case 'gold':
        accent = colors.chainGold;
        icon = PhosphorIconsRegular.medal;
      case 'silver':
        accent = colors.chainSilver;
        icon = PhosphorIconsRegular.medal;
      case 'broken':
        accent = colors.chainBroken;
        icon = PhosphorIconsRegular.linkBreak;
      default:
        accent = colors.borderDefault;
        icon = PhosphorIconsRegular.link;
    }

    return _BaseCard(
      accentColor: accent,
      tokens: tokens,
      leading: _LeadingIcon(icon: icon, color: accent),
      trailing: _TimestampChip(timeAgo: item.timeAgo, tokens: tokens),
      content: Text(
        message,
        style: tokens.typography.body.copyWith(color: colors.textPrimary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. Milestone
// ---------------------------------------------------------------------------

class _MilestoneCard extends StatelessWidget {
  final FeedItem item;
  final PersonalityCopy copy;
  final ValenceTokens tokens;

  const _MilestoneCard({required this.item, required this.copy, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final stage = item.message ?? 'Foundation';
    final days = _stageDays(stage);
    final message = copy.milestoneMessage(
      item.senderName,
      item.habitName ?? 'a habit',
      stage,
      days,
    );

    return _BaseCard(
      accentColor: colors.rankGold,
      tokens: tokens,
      leading: _LeadingIcon(
        icon: PhosphorIconsRegular.target,
        color: colors.rankGold,
      ),
      trailing: _TimestampChip(timeAgo: item.timeAgo, tokens: tokens),
      content: Text(
        message,
        style: tokens.typography.body.copyWith(color: colors.textPrimary),
      ),
    );
  }

  int _stageDays(String stage) {
    switch (stage.toLowerCase()) {
      case 'ignition':
        return 7;
      case 'foundation':
        return 21;
      case 'momentum':
        return 44;
      case 'formed':
        return 66;
      default:
        return 0;
    }
  }
}

// ---------------------------------------------------------------------------
// 8. Streak freeze
// ---------------------------------------------------------------------------

class _StreakFreezeCard extends StatelessWidget {
  final FeedItem item;
  final PersonalityCopy copy;
  final ValenceTokens tokens;

  const _StreakFreezeCard({required this.item, required this.copy, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final message = copy.streakFreezeMessage(item.senderName);

    return _BaseCard(
      accentColor: colors.accentSecondary,
      tokens: tokens,
      leading: _LeadingIcon(
        icon: PhosphorIconsRegular.snowflake,
        color: colors.accentSecondary,
      ),
      trailing: _TimestampChip(timeAgo: item.timeAgo, tokens: tokens),
      content: Text(
        message,
        style: tokens.typography.body.copyWith(color: colors.textPrimary),
      ),
    );
  }
}
