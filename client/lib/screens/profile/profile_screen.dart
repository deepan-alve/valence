// client/lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/models/user_profile.dart';
import 'package:valence/providers/profile_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/utils/icon_resolver.dart';
import 'package:valence/widgets/core/valence_card.dart';
import 'package:valence/widgets/gamification/rank_badge.dart';
import 'package:valence/widgets/gamification/spark_balance.dart';
import 'package:valence/widgets/gamification/xp_progress.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: const _ProfileScreenBody(),
    );
  }
}

class _ProfileScreenBody extends StatelessWidget {
  const _ProfileScreenBody();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final provider = context.watch<ProfileProvider>();
    final profile = provider.profile;

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ValenceSpacing.md),
          children: [
            _buildProfileHeader(tokens, profile),
            const SizedBox(height: ValenceSpacing.lg),
            XPProgress(
              currentRank: profile.rank,
              progress: profile.rankProgress,
              xpRemaining: profile.xpRemaining,
            ),
            const SizedBox(height: ValenceSpacing.lg),
            _buildEquippedPreview(tokens, profile),
            const SizedBox(height: ValenceSpacing.lg),
            _buildStatsSection(tokens, provider.stats),
            const SizedBox(height: ValenceSpacing.lg),
            _buildHabitSection(
              tokens, 'Active Habits', provider.activeHabits,
              isArchived: false,
              onArchive: provider.archiveHabit,
            ),
            const SizedBox(height: ValenceSpacing.md),
            if (provider.archivedHabits.isNotEmpty)
              _buildArchivedSection(tokens, provider),
            const SizedBox(height: ValenceSpacing.lg),
            _buildPluginSection(tokens, provider.plugins),
            const SizedBox(height: ValenceSpacing.lg),
            _buildSettingsSection(tokens, provider),
            const SizedBox(height: ValenceSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ValenceTokens tokens, UserProfile profile) {
    final colors = tokens.colors;
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: colors.accentPrimary.withValues(alpha: 0.2),
          child: Text(
            profile.initials,
            style: tokens.typography.h1.copyWith(color: colors.accentPrimary),
          ),
        ),
        const SizedBox(height: ValenceSpacing.smMd),
        Text(profile.name, style: tokens.typography.h2),
        const SizedBox(height: ValenceSpacing.xs),
        Text(profile.email,
            style: tokens.typography.caption.copyWith(
                color: colors.textSecondary)),
        const SizedBox(height: ValenceSpacing.smMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RankBadge(rank: profile.rank),
            const SizedBox(width: ValenceSpacing.md),
            SparkBalance(sparks: profile.sparks),
          ],
        ),
        const SizedBox(height: ValenceSpacing.xs),
        Text(
          '${profile.xp} XP total  ·  Member since ${_formatDate(profile.memberSince)}',
          style: tokens.typography.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEquippedPreview(ValenceTokens tokens, UserProfile profile) {
    final colors = tokens.colors;
    return ValenceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.palette(), size: 18, color: colors.textSecondary),
              const SizedBox(width: ValenceSpacing.sm),
              Text('Equipped Customizations',
                  style: tokens.typography.h3.copyWith(fontSize: 16)),
              const Spacer(),
              Text('Customize',
                  style: tokens.typography.caption.copyWith(
                      color: colors.accentPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: ValenceSpacing.smMd),
          Wrap(
            spacing: ValenceSpacing.sm,
            runSpacing: ValenceSpacing.sm,
            children: [
              _equippedChip(tokens, 'Theme', profile.equipped.themeId),
              _equippedChip(tokens, 'Flame', profile.equipped.flameId),
              _equippedChip(tokens, 'Anim', profile.equipped.animationId),
              _equippedChip(tokens, 'Card', profile.equipped.cardStyleId),
              _equippedChip(tokens, 'Font', profile.equipped.fontId),
              _equippedChip(tokens, 'Pattern', profile.equipped.patternId),
            ],
          ),
        ],
      ),
    );
  }

  Widget _equippedChip(ValenceTokens tokens, String label, String value) {
    final colors = tokens.colors;
    final displayValue = value
        .replaceAll('_', ' ')
        .replaceFirst(RegExp(r'^(theme|flame|anim|card|font|pattern)\s'), '');
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: ValenceSpacing.sm, vertical: ValenceSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: ValenceRadii.roundAll,
      ),
      child: Text('$label: $displayValue',
          style: tokens.typography.caption.copyWith(color: colors.textSecondary)),
    );
  }

  Widget _buildStatsSection(ValenceTokens tokens, ProfileStats stats) {
    final colors = tokens.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Stats', style: tokens.typography.h3),
        const SizedBox(height: ValenceSpacing.smMd),
        Wrap(
          spacing: ValenceSpacing.sm,
          runSpacing: ValenceSpacing.sm,
          children: [
            _statTile(tokens, '${stats.totalHabits}', 'Total Habits', PhosphorIcons.list()),
            _statTile(tokens, '${stats.totalDaysCompleted}', 'Days Done', PhosphorIcons.calendarCheck()),
            _statTile(tokens, '${stats.longestStreak}', 'Best Streak', PhosphorIcons.fire()),
            _statTile(tokens, '${stats.perfectDays}', 'Perfect Days', PhosphorIcons.star()),
            _statTile(tokens, '${stats.habitsGraduated}', 'Graduated', PhosphorIcons.graduationCap()),
          ],
        ),
      ],
    );
  }

  Widget _statTile(ValenceTokens tokens, String value, String label, IconData icon) {
    final colors = tokens.colors;
    return Container(
      width: 100,
      padding: const EdgeInsets.all(ValenceSpacing.smMd),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: ValenceRadii.mediumAll,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: colors.accentPrimary),
          const SizedBox(height: ValenceSpacing.xs),
          Text(value, style: tokens.typography.numbersBody.copyWith(color: colors.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: tokens.typography.caption.copyWith(
                  color: colors.textSecondary, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildHabitSection(
    ValenceTokens tokens,
    String title,
    List<ProfileHabit> habits, {
    required bool isArchived,
    Function(String)? onArchive,
    Function(String)? onUnarchive,
  }) {
    final colors = tokens.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: tokens.typography.h3),
        const SizedBox(height: ValenceSpacing.sm),
        if (habits.isEmpty)
          Text(
            isArchived ? 'No archived habits.' : 'No active habits yet.',
            style: tokens.typography.body.copyWith(color: colors.textSecondary),
          )
        else
          ...habits.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: ValenceSpacing.sm),
                child: _habitRow(tokens, h,
                    onArchive: onArchive, onUnarchive: onUnarchive),
              )),
      ],
    );
  }

  Widget _habitRow(
    ValenceTokens tokens,
    ProfileHabit habit, {
    Function(String)? onArchive,
    Function(String)? onUnarchive,
  }) {
    final colors = tokens.colors;
    return Container(
      padding: const EdgeInsets.all(ValenceSpacing.smMd),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: ValenceRadii.mediumAll,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(IconResolver.resolve(habit.iconName), size: 20, color: colors.textSecondary),
          const SizedBox(width: ValenceSpacing.smMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.name,
                    style: tokens.typography.body.copyWith(fontWeight: FontWeight.w500)),
                Text(
                  habit.isArchived
                      ? '${habit.streakDays}d streak (paused)'
                      : '${habit.streakDays}d streak',
                  style: tokens.typography.caption.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          if (!habit.isArchived && onArchive != null)
            GestureDetector(
              onTap: () => onArchive(habit.id),
              child: Icon(PhosphorIcons.archive(), size: 20, color: colors.textSecondary),
            ),
          if (habit.isArchived && onUnarchive != null)
            GestureDetector(
              onTap: () => onUnarchive(habit.id),
              child: Icon(PhosphorIcons.arrowCounterClockwise(),
                  size: 20, color: colors.accentPrimary),
            ),
        ],
      ),
    );
  }

  Widget _buildArchivedSection(ValenceTokens tokens, ProfileProvider provider) {
    return ExpansionTile(
      title: Text('Archived Habits (${provider.archivedHabits.length})',
          style: tokens.typography.h3),
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      children: provider.archivedHabits
          .map((h) => Padding(
                padding: const EdgeInsets.only(bottom: ValenceSpacing.sm),
                child: _habitRow(tokens, h, onUnarchive: provider.unarchiveHabit),
              ))
          .toList(),
    );
  }

  Widget _buildPluginSection(ValenceTokens tokens, List<PluginConnection> plugins) {
    final colors = tokens.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Plugin Connections', style: tokens.typography.h3),
        const SizedBox(height: ValenceSpacing.sm),
        ...plugins.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: ValenceSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(ValenceSpacing.smMd),
                decoration: BoxDecoration(
                  color: colors.surfacePrimary,
                  borderRadius: ValenceRadii.mediumAll,
                  border: Border.all(color: colors.borderDefault),
                ),
                child: Row(
                  children: [
                    Icon(IconResolver.resolve(p.iconName), size: 20, color: colors.textSecondary),
                    const SizedBox(width: ValenceSpacing.smMd),
                    Expanded(
                      child: Text(p.name,
                          style: tokens.typography.body.copyWith(fontWeight: FontWeight.w500)),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.isExpired
                            ? colors.accentError
                            : p.isConnected
                                ? colors.accentSuccess
                                : colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: ValenceSpacing.sm),
                    Text(
                      p.isExpired ? 'Expired' : p.isConnected ? 'Connected' : 'Connect',
                      style: tokens.typography.caption.copyWith(
                        color: p.isExpired
                            ? colors.accentError
                            : p.isConnected
                                ? colors.accentSuccess
                                : colors.accentPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSettingsSection(ValenceTokens tokens, ProfileProvider provider) {
    final colors = tokens.colors;
    final prefs = provider.notificationPrefs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Settings', style: tokens.typography.h3),
        const SizedBox(height: ValenceSpacing.sm),
        _sectionLabel(tokens, 'Notifications'),
        _toggleRow(tokens, 'Morning activation', prefs.morning,
            () => provider.toggleNotification('morning')),
        _toggleRow(tokens, 'Friend nudges', prefs.nudges,
            () => provider.toggleNotification('nudges')),
        _toggleRow(tokens, 'Meme notifications', prefs.memes,
            () => provider.toggleNotification('memes')),
        _toggleRow(tokens, 'Evening reflection', prefs.reflection,
            () => provider.toggleNotification('reflection')),
        const SizedBox(height: ValenceSpacing.md),
        _sectionLabel(tokens, 'Persona Type'),
        Padding(
          padding: const EdgeInsets.only(bottom: ValenceSpacing.sm),
          child: Text(
            'Controls your home screen vibe. Socialisers see group pressure. '
            'Achievers see stats. General gets both.',
            style: tokens.typography.caption.copyWith(color: colors.textSecondary),
          ),
        ),
        Wrap(
          spacing: ValenceSpacing.sm,
          children: PersonaType.values.map((type) {
            final isActive = provider.profile.personaType == type;
            return ChoiceChip(
              label: Text(type.displayName),
              selected: isActive,
              onSelected: (_) => provider.setPersonaType(type),
              selectedColor: colors.accentPrimary,
              labelStyle: tokens.typography.caption.copyWith(
                color: isActive ? colors.textInverse : colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: colors.surfacePrimary,
              side: BorderSide(color: colors.borderDefault),
            );
          }).toList(),
        ),
        const SizedBox(height: ValenceSpacing.md),
        _sectionLabel(tokens, 'Personality Layer'),
        _toggleRow(tokens, 'Personality mode', provider.personalityOn,
            provider.togglePersonality),
        Padding(
          padding: const EdgeInsets.only(left: ValenceSpacing.md),
          child: Text(
            provider.personalityOn
                ? '"Deepan just crushed LeetCode. Respect. 🫡"'
                : '"Deepan completed LeetCode."',
            style: tokens.typography.caption.copyWith(
                color: colors.textSecondary, fontStyle: FontStyle.italic),
          ),
        ),
        const SizedBox(height: ValenceSpacing.md),
        _sectionLabel(tokens, 'Account'),
        _navRow(tokens, 'Privacy', PhosphorIcons.lock()),
        _navRow(tokens, 'About & Support', PhosphorIcons.info()),
        _navRow(tokens, 'Licenses', PhosphorIcons.fileText()),
        const SizedBox(height: ValenceSpacing.md),
        Center(
          child: TextButton(
            onPressed: () {},
            child: Text('Delete Account',
                style: tokens.typography.body.copyWith(
                    color: colors.accentError, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(ValenceTokens tokens, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ValenceSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: tokens.typography.overline.copyWith(color: tokens.colors.textSecondary),
      ),
    );
  }

  Widget _toggleRow(ValenceTokens tokens, String label, bool value, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ValenceSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: tokens.typography.body)),
          Switch.adaptive(
            value: value,
            onChanged: (_) => onToggle(),
            activeColor: tokens.colors.accentPrimary,
          ),
        ],
      ),
    );
  }

  Widget _navRow(ValenceTokens tokens, String label, IconData icon) {
    final colors = tokens.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: ValenceSpacing.xs),
      child: Container(
        padding: const EdgeInsets.all(ValenceSpacing.smMd),
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          borderRadius: ValenceRadii.mediumAll,
          border: Border.all(color: colors.borderDefault),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.textSecondary),
            const SizedBox(width: ValenceSpacing.smMd),
            Expanded(child: Text(label, style: tokens.typography.body)),
            Icon(PhosphorIcons.caretRight(), size: 16, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }
}
