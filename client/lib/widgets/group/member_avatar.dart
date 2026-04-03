import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/group_member.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Circular avatar (40 px) with an accessible status ring and optional
/// nudge / kudos action overlays.
///
/// Accessibility rule: status is communicated via both color AND icon —
/// never color alone.
///
/// Status visual encoding:
///   - allDone    → green ring  + ✓ badge
///   - partial    → amber ring  + "X/Y" fraction badge
///   - notStarted → gray ring   + "–" badge
///   - inactive   → gray ring   + 💤 badge
class MemberAvatar extends StatelessWidget {
  final GroupMember member;
  final VoidCallback? onNudge;
  final VoidCallback? onKudos;
  final bool showActions;

  const MemberAvatar({
    super.key,
    required this.member,
    this.onNudge,
    this.onKudos,
    this.showActions = true,
  });

  static const double _avatarSize = 40.0;
  static const double _ringWidth = 3.0;
  static const double _badgeSize = 18.0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final ringColor = _ringColor(member.status, colors);
    final badge = _BadgeWidget(member: member, ringColor: ringColor);
    final actionIcon = _actionIcon(member);

    return Semantics(
      label: _semanticLabel(member),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Outer ring
              Container(
                width: _avatarSize + _ringWidth * 2 + 4,
                height: _avatarSize + _ringWidth * 2 + 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ringColor,
                    width: _ringWidth,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: _AvatarCircle(
                    member: member,
                    size: _avatarSize,
                    colors: colors,
                    typography: typography,
                  ),
                ),
              ),

              // Status badge (bottom-right)
              Positioned(
                bottom: -2,
                right: -2,
                child: badge,
              ),

              // Action icon (top-right) — only when showActions is true
              if (showActions && actionIcon != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: _ActionButton(
                    icon: actionIcon.icon,
                    color: actionIcon.color,
                    label: actionIcon.label,
                    onPressed: actionIcon.onPressed(member, onNudge, onKudos),
                  ),
                ),
            ],
          ),
          const SizedBox(height: ValenceSpacing.xs),
          // Name below avatar
          Text(
            member.isCurrentUser ? '${member.name} (you)' : member.name,
            style: typography.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: member.isCurrentUser ? FontWeight.w600 : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _ringColor(MemberStatus status, dynamic colors) {
    switch (status) {
      case MemberStatus.allDone:
        return colors.accentSuccess;
      case MemberStatus.partial:
        return colors.accentWarning;
      case MemberStatus.notStarted:
        return colors.borderDefault;
      case MemberStatus.inactive:
        return colors.borderDefault;
    }
  }

  _ActionConfig? _actionIcon(GroupMember member) {
    if (member.isCurrentUser) return null;
    if (member.isComplete) {
      return _ActionConfig(
        icon: PhosphorIconsRegular.heart,
        color: Colors.pinkAccent,
        label: 'Send kudos to ${member.name}',
        onPressed: (m, nudge, kudos) => kudos,
      );
    }
    return _ActionConfig(
      icon: PhosphorIconsRegular.bellRinging,
      color: Colors.orangeAccent,
      label: 'Nudge ${member.name}',
      onPressed: (m, nudge, kudos) => nudge,
    );
  }

  String _semanticLabel(GroupMember member) {
    final statusLabel = switch (member.status) {
      MemberStatus.allDone => 'all habits done',
      MemberStatus.partial => '${member.habitsCompleted} of ${member.habitsTotal} habits done',
      MemberStatus.notStarted => 'not started today',
      MemberStatus.inactive => 'inactive',
    };
    final you = member.isCurrentUser ? ' (you)' : '';
    return '${member.name}$you, $statusLabel';
  }
}

/// The solid colored circle with initials (or avatar image in future).
class _AvatarCircle extends StatelessWidget {
  final GroupMember member;
  final double size;
  final dynamic colors;
  final dynamic typography;

  const _AvatarCircle({
    required this.member,
    required this.size,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = member.isCurrentUser
        ? colors.accentPrimary
        : colors.accentSecondary.withValues(alpha: 0.2);
    final fgColor = member.isCurrentUser ? colors.textInverse : colors.accentSecondary;

    if (member.avatarUrl != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(member.avatarUrl!),
        backgroundColor: bgColor,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      alignment: Alignment.center,
      child: Text(
        member.initials,
        style: TextStyle(
          fontFamily: 'Obviously',
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          color: fgColor,
          height: 1.0,
        ),
      ),
    );
  }
}

/// The small badge shown in the bottom-right corner of the avatar ring.
class _BadgeWidget extends StatelessWidget {
  final GroupMember member;
  final Color ringColor;

  const _BadgeWidget({required this.member, required this.ringColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: MemberAvatar._badgeSize,
        minHeight: MemberAvatar._badgeSize,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: ringColor,
        borderRadius: ValenceRadii.roundAll,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: ExcludeSemantics(child: _badgeChild(member)),
    );
  }

  Widget _badgeChild(GroupMember member) {
    switch (member.status) {
      case MemberStatus.allDone:
        return const Icon(Icons.check, size: 11, color: Colors.white);
      case MemberStatus.partial:
        return Text(
          member.progressLabel,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.0,
          ),
        );
      case MemberStatus.notStarted:
        return const Text(
          '–',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.0,
          ),
        );
      case MemberStatus.inactive:
        return const Text(
          '💤',
          style: TextStyle(fontSize: 8, height: 1.0),
        );
    }
  }
}

/// Small action icon shown at the top-right of the avatar.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 11, color: color),
        ),
      ),
    );
  }
}

/// Internal DTO to hold action button config.
class _ActionConfig {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? Function(GroupMember, VoidCallback?, VoidCallback?) onPressed;

  const _ActionConfig({
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
  });
}
