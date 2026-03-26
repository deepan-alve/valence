# Valence — Product Specification

**Version:** 0.1.0-draft
**Date:** 2026-03-25
**Status:** Hackathon Spec

---

## What is Valence?

Valence is a group-first, socially aware habit system that transforms habits from private tasks into a shared, social experience. It prioritizes low-friction tracking, psychologically grounded feedback, and genuine social accountability — without guilt, toxicity, or overwhelming gamification.

The name "Valence" refers to emotional valence — the intrinsic attractiveness (positive) or aversiveness (negative) of an event or situation. The app is designed to make habit formation feel positively valenced, even when users struggle.

---

## Documents

| Document | Description |
|---|---|
| [Psychology & Behavioral Grounding](./psychology.md) | Research-backed principles driving every design decision |
| [Feature Specification](./features.md) | Complete feature list with detailed descriptions |
| [Social System Design](./social-system.md) | Group mechanics, party system, nudges, and failure recovery |
| [Gamification & Rewards](./gamification.md) | Points, streaks, streak freezes, rewards — without toxicity |
| [Integrations](./integrations.md) | Third-party app integrations for automatic tracking |
| [Technical Architecture](./architecture.md) | System architecture, tech stack, and deployment |
| [Data Model](./data-model.md) | Database schema and entity relationships |
| [API Design](./api.md) | REST API endpoints and contracts |
| [UX Principles](./ux-principles.md) | Design philosophy, anti-patterns, and tone of voice |
| [Flowcharts](./flowcharts.md) | Key user flows in Mermaid diagram format |

---

## Core Principles

1. **Low friction above all.** Complexity is the primary barrier to sustained engagement (TU Wien Habits Network). Every interaction must justify its existence.
2. **Social without shame.** Peer accountability works, but social comparison must never overwhelm or demotivate. Comparisons are opt-in and tiered.
3. **Anticipation over guilt.** Never "Did you do X?" — always "X starts in 10 minutes — ready to hit streak 7?"
4. **Failure is normal.** Missed days are met with reassurance, not punishment. Show what succeeded. Remind users it is not entirely within their control.
5. **Streaks are tools, not chains.** Streak freezes, group saves, and graceful degradation prevent streak toxicity.
6. **Earned complexity.** Start simple. Features unlock as the user progresses through tiers. New users never see the full system at once.

---

## Target Users

- Age 18-30, digitally native
- Want to build habits but struggle with consistency
- Motivated by peers more than by apps
- Tired of guilt-driven reminder systems
- Likely tried and abandoned 1-2 habit apps before

---

## Scope for Hackathon

### Must Have (Demo Day)
- Core habit CRUD (positive and negative habits)
- Streak tracking with freeze mechanic
- Group/party system with shared accountability
- Anticipation-based notification system
- Basic social feed (congratulate, nudge)
- Sub-habit decomposition (LLM-assisted)
- At least one third-party integration (Google Fit or WakaTime)

### Should Have
- Tiered community system
- Weekly/monthly lookback reports
- LLM-powered tips on missed/relapsed habits
- Reward pool system

### Could Have
- Full integration suite (Strava, Duolingo, etc.)
- Advanced analytics dashboard
- Group habit builder with threshold mechanics
