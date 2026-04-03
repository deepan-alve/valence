# Valence — Complete Documentation

**Team:** Antichrist.exe | **Hackathon:** SNUC Hacks 2026 | **Track:** Social Tech

---

## Unified PRD

| Document | Description |
|----------|-------------|
| [PRD_HabitPact.md](./PRD_HabitPact.md) | Full product requirements — features, architecture, database schema, plugin SDK, gamification, privacy model, roadmap, competitor matrix, research citations |

---

## Pranaov's Spec (Valence)

| Document | Description |
|----------|-------------|
| [spec.md](./pranaov-spec/spec.md) | Product overview, core principles, scope, target users |
| [psychology.md](./pranaov-spec/psychology.md) | Behavioral science grounding — Habit Loop, SDT, Loss Aversion, Implementation Intentions, Fresh Start Effect, Cognitive Load, Relapse Prevention, Social Comparison, Positive Psychology |
| [features.md](./pranaov-spec/features.md) | Feature spec — habit CRUD, sub-habits, streaks, cue tracking, notifications, lookbacks, LLM integration points |
| [social-system.md](./pranaov-spec/social-system.md) | Social design — friends, party system, tiered communities (Spark/Ember/Flame/Blaze), social feed, failure recovery, anti-toxicity safeguards |
| [gamification.md](./pranaov-spec/gamification.md) | Points, streaks, reward pool, achievements, leaderboards, anti-patterns we avoid |
| [integrations.md](./pranaov-spec/integrations.md) | Third-party integrations — Google Fit, Wakatime, Strava, custom webhook receiver |
| [architecture.md](./pranaov-spec/architecture.md) | Technical architecture — Flutter + FastAPI + PostgreSQL + Redis + Celery, client/server module structure, real-time WebSocket, security |
| [data-model.md](./pranaov-spec/data-model.md) | Database schema — all tables, entity relationships, indexes |
| [api.md](./pranaov-spec/api.md) | REST API design — 50+ endpoints, rate limits, response patterns |
| [ux-principles.md](./pranaov-spec/ux-principles.md) | UX philosophy — tone of voice, visual design, key screen mockups, onboarding flow, anti-patterns |
| [flowcharts.md](./pranaov-spec/flowcharts.md) | 11 Mermaid flowcharts — daily completion, streak freeze, group evaluation, sub-habits, integrations, nudge, tiers, notifications, onboarding, negative habits, reward pool |

---

## Research

| Document | Description |
|----------|-------------|
| [RESEARCH_habit_psychology_deep_dive.md](./research/RESEARCH_habit_psychology_deep_dive.md) | Deep research — habit formation science, social accountability data, gamification evidence, nudge theory, loss aversion, SDT |
| [RESEARCH_market_intelligence_engine.md](./research/RESEARCH_market_intelligence_engine.md) | Market intelligence research — crawling, change detection, NLP extraction, dashboard design |

---

## What's In PRD But Not In Pranaov's Spec

- Plugin SDK + Community Marketplace architecture
- Group reward stakes (real-world rewards — biryani, coffee, movie)
- Notification priority stacking and anti-annoyance enforcement logic
- Competitor feature matrix (vs Habitica, Streaks, Coach.me, HabitShare, Squad, stickK, Beeminder)
- Exact point economy math (multipliers, freeze cost scaling)
- Firestore security rules
- 4 detailed user personas (Riya, Arjun, Karthik, Sneha)

## What's In Pranaov's Spec But Not In PRD

- Tiered community system (Spark → Ember → Flame → Blaze)
- Party damage hardcore mode (opt-in, cosmetic avatar HP)
- Achievement badges system with categories
- Personal reward pool with spin mechanic
- Full REST API with 50+ endpoint definitions
- 11 Mermaid flowcharts for every user flow
- Webhook receiver for custom integrations
- Fresh Start Effect (Milkman et al.) psychology principle
- Progressive disclosure onboarding (Day 1/2/3/7/14 staged reveals)
- FastAPI + PostgreSQL + Redis + Celery server architecture

## Where Both Align

- Zero streak toxicity / shame-free recovery
- Anticipation-based nudges (never guilt)
- Sub-habits with LLM decomposition
- Streak freeze gifting between friends
- Skip-reason tracking + pattern detection
- N-1 group streak threshold
- Max 3 notifications/day
- Private/public habit toggle
- Negative habits as first-class citizens
- Behavioral science grounding (Fogg, Deci & Ryan, Gollwitzer, Kahneman, Lally)
