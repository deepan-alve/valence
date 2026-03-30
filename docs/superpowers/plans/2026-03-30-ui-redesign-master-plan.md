# Valence UI Redesign — Master Implementation Plan

> **For agentic workers:** This is a MASTER PLAN that decomposes into 8 phase-specific plans. Each phase is an independent implementation plan with its own spec, tasks, and commits. Execute phases in order — each builds on the previous.

**Goal:** Complete UI redesign of the Valence Flutter app — from a local-only habit tracker to a social, group-first habit platform with dual-theme support, gamification, and plugin-verified tracking.

**Architecture:** Clean architecture with Provider state management, theme token system via ThemeExtension, 5-tab bottom navigation shell, and API service layer connecting to the existing Node.js/Express backend.

**Tech Stack:** Flutter/Dart, Provider, Phosphor Icons, Lottie, Google Fonts (Plus Jakarta Sans), Obviously font (bundled), fl_chart, Firebase Auth, HTTP/Dio for API calls.

**Design Spec:** `docs/superpowers/specs/2026-03-30-ui-redesign-design.md` (1,186 lines)
**PRD:** `PRD/PRD.md`

---

## Phase Overview

| Phase | Name | Description | Depends On | Est. Tasks |
|-------|------|-------------|------------|------------|
| 1 | **Design System Foundation** | Theme tokens, typography, colors, spacing, elevation, ValenceTokens ThemeExtension, base components (ValenceButton, ValenceCard, etc.) | Nothing | ~15 |
| 2 | **Navigation Shell & Auth** | 5-tab bottom nav, routing, splash screen, onboarding flow (7 screens), Firebase Auth integration | Phase 1 |  ~12 |
| 3 | **Home Screen** | Habit cards with gesture matrix, day selector, daily progress bar, group streak chain preview, persona-driven greeting | Phase 2 | ~14 |
| 4 | **Group Screen** | Member grid, group feed (7 item types), weekly leaderboard, nudge/kudos per-member actions, streak freeze, group management | Phase 3 | ~16 |
| 5 | **Progress Screen** | Per-habit tab (streak, goal graduation, heatmap, frequency chart, failure insights), overview tab, reflection flow | Phase 3 | ~12 |
| 6 | **Shop & Profile** | Shop categories (themes/flames/animations/cards/fonts/patterns/icons), purchase/equip flow, profile screen, settings, plugin connections | Phase 1 | ~14 |
| 7 | **Social Flows & Notifications** | Nudge generation flow, miss logging, evening reflection (Foundation-gated), recovery nudge, morning activation, push notifications via FCM | Phase 4 | ~10 |
| 8 | **Celebrations & Polish** | Lottie animations, rank-up ceremony, tier-up moment, 66-day graduation, perfect day banner, streak milestones, XP/Sparks earning overlay, offline mode, loading skeletons | Phase 3 | ~12 |

**Total estimated tasks:** ~105
**Total estimated implementation time (CC+gstack):** ~8-12 hours across sessions

---

## Phase 1 Plan: `docs/superpowers/plans/2026-03-30-phase1-design-system.md`

## Phase 2 Plan: `docs/superpowers/plans/2026-03-30-phase2-navigation-auth.md`

## Phase 3 Plan: `docs/superpowers/plans/2026-03-30-phase3-home-screen.md`

## Phase 4 Plan: `docs/superpowers/plans/2026-03-30-phase4-group-screen.md`

## Phase 5 Plan: `docs/superpowers/plans/2026-03-30-phase5-progress-screen.md`

## Phase 6 Plan: `docs/superpowers/plans/2026-03-30-phase6-shop-profile.md`

## Phase 7 Plan: `docs/superpowers/plans/2026-03-30-phase7-social-notifications.md`

## Phase 8 Plan: `docs/superpowers/plans/2026-03-30-phase8-celebrations-polish.md`

---

## Key Decisions for All Phases

### State Management
- Keep **Provider** (existing codebase pattern)
- Each screen gets its own ViewModel extending ChangeNotifier
- API calls go through a service layer (`lib/services/`) — ViewModels never call HTTP directly

### API Service Layer
- `lib/services/api_client.dart` — Dio-based HTTP client with auth token injection
- `lib/services/auth_service.dart` — Firebase Auth wrapper
- `lib/services/habit_service.dart` — CRUD for habits
- `lib/services/group_service.dart` — Group operations, feed, leaderboard
- `lib/services/shop_service.dart` — Shop items, purchase, equip
- `lib/services/user_service.dart` — Profile, settings, persona
- `lib/services/plugin_service.dart` — Plugin connections
- `lib/services/insight_service.dart` — LLM-generated insights, motivation

### Folder Structure (New)
```
client/lib/
├── main.dart
├── app.dart                          (MaterialApp with theme + routing)
├── theme/
│   ├── valence_tokens.dart           (ThemeExtension — colors, typography, spacing, radii, elevation)
│   ├── valence_colors.dart           (Semantic color tokens class)
│   ├── valence_typography.dart       (Text style definitions)
│   ├── themes/
│   │   ├── nocturnal_sanctuary.dart  (Dark theme token values)
│   │   └── daybreak.dart             (Light theme token values)
│   └── theme_provider.dart           (ThemeViewModel — active theme, equipped customizations)
├── models/
│   ├── user.dart
│   ├── habit.dart
│   ├── group.dart
│   ├── habit_log.dart
│   ├── miss_log.dart
│   ├── feed_item.dart
│   ├── shop_item.dart
│   ├── weekly_score.dart
│   └── nudge.dart
├── services/                         (API layer — see above)
├── providers/                        (ViewModels per screen)
│   ├── auth_provider.dart
│   ├── home_provider.dart
│   ├── group_provider.dart
│   ├── progress_provider.dart
│   ├── shop_provider.dart
│   ├── profile_provider.dart
│   ├── onboarding_provider.dart
│   ├── celebration_provider.dart
│   └── offline_provider.dart
├── screens/
│   ├── splash/
│   ├── onboarding/
│   ├── home/
│   ├── group/
│   ├── progress/
│   ├── shop/
│   ├── profile/
│   └── settings/
├── widgets/                          (Reusable components)
│   ├── core/                         (ValenceButton, ValenceCard, etc.)
│   ├── habit/                        (HabitCard, HabitForm, etc.)
│   ├── group/                        (MemberAvatar, FeedItem, ChainStrip, etc.)
│   ├── progress/                     (Heatmap, GoalProgress, StreakFlame, etc.)
│   ├── shop/                         (ShopItemCard, ThemePreview, etc.)
│   ├── gamification/                 (RankBadge, TierBadge, SparkBalance, XPProgress, etc.)
│   ├── shared/                       (EmptyState, SkeletonLoader, Toast, OfflineBanner, etc.)
│   └── celebrations/                 (RankUpModal, GraduationScreen, etc.)
└── utils/
    ├── constants.dart
    ├── extensions.dart
    └── formatters.dart
```

### Testing Strategy
- Unit tests for: ViewModels, Services (mocked HTTP), Models
- Widget tests for: Core components (ValenceButton, HabitCard, etc.)
- Integration tests deferred to Phase 8 (after all screens built)
- Test location mirrors source: `test/theme/`, `test/models/`, `test/widgets/`, etc.

### Commit Strategy
- One commit per task completion
- Conventional commit format: `feat:`, `test:`, `refactor:`, `style:`
- Each phase ends with a working, navigable state
