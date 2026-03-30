import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/providers/home_provider.dart';
import 'package:valence/providers/miss_log_provider.dart';
import 'package:valence/providers/profile_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/habit/day_selector.dart';
import 'package:valence/widgets/habit/habit_card.dart';
import 'package:valence/widgets/group/chain_strip.dart';
import 'package:valence/widgets/shared/valence_toast.dart';
import 'package:valence/widgets/social/recovery_card.dart';
import 'package:valence/screens/home/habit_form_screen.dart';

/// Home screen — greeting, daily progress, day selector, habits grid, chain strip.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<ProfileProvider, HomeProvider>(
      create: (_) => HomeProvider(),
      update: (_, profileProvider, homeProvider) {
        homeProvider!.setPersonaType(profileProvider.profile.personaType);
        return homeProvider;
      },
      child: const _HomeScreenBody(),
    );
  }
}

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.accentPrimary,
        foregroundColor: colors.textInverse,
        tooltip: 'Add habit',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HabitFormScreen()),
        ),
        child: PhosphorIcon(PhosphorIcons.plus(), color: colors.textInverse),
      ),
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context, home, _) {
            // Build day status map that DaySelector expects (keyed by midnight DateTime).
            final Map<DateTime, DayStatus> dayStatus = {
              for (final day in home.weekDays)
                DateTime(day.year, day.month, day.day):
                    home.dayStatusFor(day),
            };

            return CustomScrollView(
              slivers: [
                // --- Greeting section ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ValenceSpacing.md,
                      ValenceSpacing.mdLg,
                      ValenceSpacing.md,
                      ValenceSpacing.sm,
                    ),
                    child: _GreetingSection(home: home),
                  ),
                ),

                // --- Daily progress bar ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ValenceSpacing.md,
                      vertical: ValenceSpacing.sm,
                    ),
                    child: _ProgressSection(home: home),
                  ),
                ),

                // --- Day selector ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ValenceSpacing.sm,
                      vertical: ValenceSpacing.sm,
                    ),
                    child: DaySelector(
                      days: home.weekDays,
                      selectedDay: home.selectedDay,
                      dayStatus: dayStatus,
                      onDaySelected: home.selectDay,
                    ),
                  ),
                ),

                // Recovery card — appears the day after a miss (spec 2.29)
                Consumer<MissLogProvider>(
                  builder: (context, missLog, _) {
                    if (!missLog.showRecoveryCard) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ValenceSpacing.md,
                        ),
                        child: RecoveryCard(
                          consecutiveMissDays: missLog.consecutiveMissDays,
                          onDismiss: missLog.dismissRecoveryCard,
                          onLetSGo: missLog.dismissRecoveryCard,
                        ),
                      ),
                    );
                  },
                ),

                // --- Section label ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ValenceSpacing.md,
                      ValenceSpacing.md,
                      ValenceSpacing.md,
                      ValenceSpacing.sm,
                    ),
                    child: Text(
                      "Today's habits",
                      style: tokens.typography.h2.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),

                // --- Habits grid (2 columns) ---
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ValenceSpacing.md,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: ValenceSpacing.sm,
                      mainAxisSpacing: ValenceSpacing.sm,
                      childAspectRatio: 2.4,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final habit = home.habits[index];
                        return HabitCard(
                          habit: habit,
                          onTap: () {
                            // Phase 5 will add real navigation.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tap: ${habit.name}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          onComplete: () {
                            home.toggleHabit(habit.id);
                            final reward = home.lastReward;
                            if (reward != null) {
                              final msg = reward.isPerfectDayBonus
                                  ? '+${reward.xp} XP · +${reward.sparks} Sparks · Perfect day bonus!'
                                  : '+${reward.xp} XP · +${reward.sparks} Sparks';
                              ValenceToast.show(
                                context,
                                message: msg,
                                type: ToastType.success,
                              );
                              home.clearLastReward();
                            }
                          },
                          onToggleVisibility: () =>
                              home.toggleHabitVisibility(habit.id),
                          // Long-press: open edit form. Incomplete habits also show miss sheet via context menu.
                          onLongPress: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => HabitFormScreen(habit: habit),
                            ),
                          ),
                        );
                      },
                      childCount: home.habits.length,
                    ),
                  ),
                ),

                // --- Chain strip ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ValenceSpacing.md,
                      ValenceSpacing.lg,
                      ValenceSpacing.md,
                      ValenceSpacing.xxl,
                    ),
                    child: _ChainSection(home: home),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Greeting
// ---------------------------------------------------------------------------

class _GreetingSection extends StatelessWidget {
  final HomeProvider home;

  const _GreetingSection({required this.home});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: greeting text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                home.greeting,
                style: tokens.typography.h1.copyWith(
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: ValenceSpacing.xs),
              Text(
                home.subtitle,
                style: tokens.typography.bodyLarge.copyWith(
                  color: colors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: ValenceSpacing.md),

        // Right: notification bell + avatar
        Row(
          children: [
            IconButton(
              icon: PhosphorIcon(
                PhosphorIcons.bell(),
                color: colors.textSecondary,
                size: 24,
              ),
              tooltip: 'Notifications',
              onPressed: () {
                // Phase 5: open notifications panel.
              },
            ),
            const SizedBox(width: ValenceSpacing.xs),
            _AvatarCircle(colors: colors),
          ],
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final dynamic colors;

  const _AvatarCircle({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentPrimary.withValues(alpha: 0.2),
        border: Border.all(
          color: colors.accentPrimary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Center(
        child: PhosphorIcon(
          PhosphorIcons.user(),
          size: 22,
          color: colors.accentPrimary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress
// ---------------------------------------------------------------------------

class _ProgressSection extends StatelessWidget {
  final HomeProvider home;

  const _ProgressSection({required this.home});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${home.completedCount} of ${home.totalCount} habits done',
              style: tokens.typography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            if (home.isPerfectDay)
              Text(
                'Perfect day!',
                style: tokens.typography.caption.copyWith(
                  color: colors.accentSuccess,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: ValenceSpacing.xs),
        ClipRRect(
          borderRadius: ValenceRadii.roundAll,
          child: LinearProgressIndicator(
            value: home.progress,
            minHeight: 8,
            color: colors.accentSuccess,
            backgroundColor: colors.surfaceSunken,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chain strip wrapper
// ---------------------------------------------------------------------------

class _ChainSection extends StatelessWidget {
  final HomeProvider home;

  const _ChainSection({required this.home});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          'Group streak',
          style: tokens.typography.h2.copyWith(
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: ValenceSpacing.sm),

        // Chain strip card
        Container(
          padding: const EdgeInsets.all(ValenceSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfacePrimary,
            borderRadius: ValenceRadii.largeAll,
          ),
          child: ChainStrip(
            links: home.chainLinks,
            currentStreak: home.currentStreak,
            tier: home.groupTier,
            onTap: () {
              // Phase 5: switch to Group tab via MainShell.
              debugPrint('ChainStrip tapped — navigate to Group tab');
            },
          ),
        ),
      ],
    );
  }
}
