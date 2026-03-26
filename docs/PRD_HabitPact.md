# HabitPact — Product Requirements Document

**Version:** 1.0
**Date:** 2026-03-25
**Team:** Antichrist.exe

---

## Table of Contents

1. [Vision & Problem Statement](#1-vision--problem-statement)
2. [Research Foundation](#2-research-foundation)
3. [Core Design Principles](#3-core-design-principles)
4. [User Personas](#4-user-personas)
5. [Feature Specification](#5-feature-specification)
6. [Plugin & Integration Architecture](#6-plugin--integration-architecture)
7. [Technical Architecture](#7-technical-architecture)
8. [Database Schema](#8-database-schema)
9. [User Flows](#9-user-flows)
10. [Notification & Nudge Engine](#10-notification--nudge-engine)
11. [Gamification System](#11-gamification-system)
12. [Privacy & Data Model](#12-privacy--data-model)
13. [UI/UX Guidelines](#13-uiux-guidelines)
14. [API Design](#14-api-design)
15. [Community Marketplace](#15-community-marketplace)
16. [Metrics & Success Criteria](#16-metrics--success-criteria)
17. [Roadmap](#17-roadmap)

---

## 1. Vision & Problem Statement

### The Problem

90% of habit tracker users quit within 30 days (MooreMonentum 2025). The average health app retains just 3-4% of users at Day 30. Noom — the most well-funded habit app in history — retained only 0.36% of users beyond 6 months.

**Why every habit app fails:**

| Root Cause | Evidence | What Apps Do Wrong |
|------------|----------|-------------------|
| **Streak Toxicity** | One missed day triggers abandonment, not recovery | Binary pass/fail — streak breaks feel 2x worse than completions feel good (Kahneman loss aversion) |
| **Solo Experience** | Solo goal completion: 42%. With accountability partner: 95% (Matthews, n=267) | No social layer, or social-with-strangers that feels "dull" (Coach.me CEO's own words) |
| **Guilt-Based Reminders** | "Did you complete X?" triggers psychological reactance — users rebel against perceived nagging | Apps model themselves as drill sergeants, not supportive friends |
| **Manual Logging Friction** | 77% of users abandon apps within 3 days of install | Every check-in is a decision point where the user can choose to disengage |
| **Complexity Overload** | TU Wien Habits Network: complexity is the #1 barrier to sustained engagement | Habitica has XP, gold, gems, mana, quests, guilds, parties, challenges — new users bounce |
| **Wrong Timeline** | Habit formation takes 66 days median, range 18-254 (Lally et al.) | Apps designed around the "21-day myth" lose users before habits can form |
| **Extrinsic-Only Motivation** | Intrinsic motivation is 3x more effective than extrinsic (Self-Determination Theory) | Points and badges without personal meaning create short-term dopamine, not lasting change |

### The Insight

The problem isn't tracking. Tracking is solved. The problem is that **habits are inherently social** but every app treats them as private tasks.

- Humans are social creatures. Peer pressure, communal accountability, and social comparison modulate habit formation at a neurological level.
- The most effective "habit app" in existence is a WhatsApp group where 5 friends say "did everyone go to the gym today?" — but it has zero structure, zero tracking, zero persistence.

### The Vision

**HabitPact** is a group-first, socially aware habit system that:
- Works fully solo on Day 1 (no cold-start problem)
- Naturally evolves into shared accountability as friends join
- Replaces guilt with anticipation, punishment with support, isolation with community
- Ships a plugin SDK so the ecosystem grows with its users — we don't decide what habits matter, the community does

---

## 2. Research Foundation

Every feature in HabitPact maps to published behavioral science. This is not a "we think this works" product — it is a "research proves this works" product.

### 2.1 Habit Formation Science

| Principle | Researcher | Finding | How We Apply It |
|-----------|-----------|---------|----------------|
| **Habit formation timeline** | Phillippa Lally, UCL, 2010 | Median 66 days to automaticity (range 18-254). Missing one day does NOT reset progress. | Streaks don't break on a single miss. Recovery is built in. We design for 66+ day journeys, not 21-day sprints. |
| **B = MAP** (Behavior = Motivation × Ability × Prompt) | BJ Fogg, Stanford | Behavior happens when motivation, ability, and prompt converge simultaneously | Every feature maps to M, A, or P. Auto-tracking raises Ability. Social proof raises Motivation. Smart nudges are Prompts. |
| **Implementation Intentions** | Peter Gollwitzer, NYU | "If-then" plans have effect size d=0.65 across 94 studies (642-test meta-analysis: d=0.27-0.66) | Habit creation includes "When I [cue], I will [habit]" templates. Notifications reference the cue, not just the habit. |
| **Tiny Habits** | BJ Fogg, Stanford | Start with behaviors so small you can't say no. Scale up after automaticity. | LLM decomposes ambitious habits into sub-habits. "Run 5km" becomes "Put on shoes → Walk to door → Jog 1 block." |
| **Habit Loop** | Charles Duhigg / Wolfram Schultz | Cue → Routine → Reward. The cue triggers the behavior, the reward reinforces it. | Skip-reason tracking identifies cues that lead to failure. The app learns your failure patterns and pre-empts them. |

### 2.2 Social Accountability Science

| Principle | Researcher | Finding | How We Apply It |
|-----------|-----------|---------|----------------|
| **Accountability effect** | Dr. Gail Matthews, Dominican University (n=267) | Weekly progress reports to a friend: 70% success. Solo: 35%. With specific accountability partner: up to 95%. | Pact system with real friends, weekly group lookbacks |
| **Structured accountability** | 2025 meta-analysis (42 studies) | 2.8x more likely to maintain habits with structured accountability systems | Pacts have structure — shared habits, thresholds, scheduled check-ins |
| **Optimal group composition** | Stanford Behavior Lab | Best results with 1-2 close friends + 3-5 supportive acquaintances | Pact size: 3-7 people. Mix of close friends encouraged. |
| **Leader modeling** | Organizational behavior research | 3.4x adoption rate when leaders visibly practice the habit | Top performer highlighted in group — not to shame others, but to model behavior |
| **Social proof** | Robert Cialdini | People follow what others around them are doing, especially when uncertain | "5 of your friends completed their habits today" — normative pressure without shame |

### 2.3 Gamification Science

| Principle | Researcher | Finding | How We Apply It |
|-----------|-----------|---------|----------------|
| **Variable-ratio reinforcement** | B.F. Skinner / modern neuroscience | Random rewards produce sustained engagement. Fixed rewards produce tolerance. | Group "loot drops" on random milestones, not predictable reward schedules |
| **Loss aversion** | Kahneman & Tversky | Losses psychologically weigh ~2x equivalent gains | Streak freeze gifting — friends prevent the loss, which feels 2x more impactful than any reward |
| **Overjustification effect** | Deci, 1971 / Lepper et al., 1973 | External rewards can undermine intrinsic motivation if they feel controlling | One gamification loop only. Points serve the user (freeze streaks), not the app (retention hacking). |
| **Self-Determination Theory** | Deci & Ryan | Sustained motivation requires Autonomy, Competence, and Relatedness | Autonomy: choose your pact, habits, privacy level. Competence: score curves show growth. Relatedness: friend-group bonds. |
| **Commitment devices** | stickK / Karlan et al. | Financial stakes: +60 percentage points success. Anti-charity stakes: additional +6pp. | Group reward stakes — real-world rewards (meal, coffee) decided by the group before challenge starts |

### 2.4 Why Existing Apps Fail (Competitive Analysis)

| App | What They Tried | Why It Failed |
|-----|----------------|---------------|
| **Habitica** | RPG gamification — parties, quests, guilds, XP, gold, gems, mana | Complexity overload. Removed social spaces. Gamification novelty wears off in ~2 weeks. Pixel art alienates professional/college users. |
| **Streaks** | Clean solo streak tracking | Zero social features. Streak anxiety causes abandonment. "Extremely unintuitive" UI. |
| **Coach.me / Lift** | Social feed of strangers doing habits | Stranger feeds were "kind of dull — just a lot of strangers without any context" (CEO). Pivoted to paid 1:1 coaching to survive. |
| **HabitShare** | Passive sharing — let friends see your habits | No engagement hooks. You share data but nothing happens. No group dynamics, no stakes, no accountability loop. |
| **Squad** | Small group challenges with strangers | Right concept, terrible execution. App crashes when nudging/giving kudos. Matched with strangers (no friend-group integration). |
| **stickK** | Financial commitment contracts | Only 33% of users set monetary stakes (most chicken out). No sustained behavior change after contract ends. No social/group features. |
| **Beeminder** | Financial self-punishment + data tracking | Niche (data nerds/developers only). No peer-to-peer social features. Punitive model feels stressful. |
| **Fabulous** | Science-backed routines + community forums | Social is a bolted-on forum, not core to habit loop. Aggressive subscription billing. Community is sidecar, not engine. |
| **Noom** | AI coaching + educational content | 0.36% retention at 6 months. Misleading marketing. Subscription fatigue. |

**The pattern:** Apps that bolt social onto solo tracking fail. Apps that do social-with-strangers get "dull." The sweet spot — **real friend groups with active accountability loops and graceful failure recovery** — has been identified by research but never executed well.

---

## 3. Core Design Principles

These are non-negotiable. Every feature, UI decision, and architecture choice must satisfy all seven.

### Principle 1: Solo-First, Social-Ready
The app works completely standalone. No forced sign-ups, no empty friend lists on Day 1. Social features unlock naturally as you invite friends. You start alone, you grow into a group at your own pace.

### Principle 2: Zero Streak Toxicity
Missing a day never destroys progress. Streaks freeze gracefully. Friends can save you. The app shows your wins, never your failures. Recovery mechanics exist for every failure state.

### Principle 3: Anticipation Over Guilt
Every notification, message, and UI element is forward-looking. "Your streak hits 7 in 20 min" — not "You missed your habit yesterday." We build excitement about what's ahead, not shame about what's behind.

### Principle 4: One Gamification Loop
Single currency (streak points). Single use (streak freezes). Single social mechanic (gift to friends). No XP tiers, no gem shops, no mana bars. Complexity kills engagement. Simplicity sustains it.

### Principle 5: Real Stakes, Not Fake Points
Group reward stakes are real-world — a meal, a coffee, movie tickets. Decided by friends, not algorithms. A biryani your friends owe you hits different than 500 virtual coins.

### Principle 6: Radical Simplicity (The MAP Filter)
Every feature must answer: Does this increase **Motivation**, **Ability**, or **Prompt** quality? If it doesn't clearly serve one of the three, it doesn't ship.

### Principle 7: Community-Driven Extensibility
We don't decide what habits matter. The plugin SDK lets developers and users build integrations for their world — coding, fitness, language learning, studying. The platform grows with its community.

---

## 4. User Personas

### Persona 1: Riya — The Solo Starter
- **Who:** 20-year-old college student, wants to build a reading habit
- **Current tool:** Notes app reminder that she ignores
- **Journey:** Downloads HabitPact → creates "Read 20 pages" habit → uses solo for 2 weeks → invites her hostel roommates → forms a "Study Pact" → her completion rate jumps from ~40% to ~85%
- **Key need:** Zero friction to start. Social should feel like an upgrade, not a requirement.

### Persona 2: Arjun — The Group Organizer
- **Who:** 22-year-old final-year student, gym regular, wants his friend group to join
- **Current tool:** WhatsApp group "GYM ACCOUNTABILITY" with 6 friends — chaotic, no tracking, messages get buried
- **Journey:** Creates a Pact → invites 5 friends → sets group reward (losers buy dinner at mess) → Google Fit auto-tracks workouts → group streak dashboard replaces WhatsApp chaos
- **Key need:** Easy group creation. Auto-tracking. Real stakes.

### Persona 3: Karthik — The Developer
- **Who:** 21-year-old CS student, wants to track LeetCode and GitHub contributions
- **Current tool:** Nothing — no habit app integrates with coding platforms
- **Journey:** Discovers HabitPact → finds LeetCode plugin in marketplace → installs it → his daily problem-solving auto-syncs → builds a Wakatime plugin himself → publishes to marketplace
- **Key need:** Plugin SDK. Developer documentation. Marketplace visibility.

### Persona 4: Sneha — The Private Tracker
- **Who:** 19-year-old dealing with anxiety, tracking meditation and journaling
- **Current tool:** Paper journal
- **Journey:** Uses HabitPact solo → marks meditation as "private" → joins a wellness Pact but only shares streak % (not habit names) → gets support without exposing vulnerable habits
- **Key need:** Granular privacy controls. No forced sharing. Dignity preserved.

---

## 5. Feature Specification

### 5.1 Core Habit Engine

#### 5.1.1 Habit CRUD
- Create habits with: name, description, frequency (daily/weekly/custom), target value, unit, color, icon
- Support both **positive habits** (do something) and **negative habits** (avoid something — e.g., no oversleeping, no smoking, limit screen time)
- Each habit has a **privacy level**: Public (visible to pact) / Partial (only streak % and streak count visible) / Private (invisible to others)
- Habits can be archived (not deleted) to preserve historical data

#### 5.1.2 Habit Scoring System
- Continuous scoring model — not binary pass/fail
- Score curves that show growth over time (visual proof of improvement)
- Partial completion counts (did 15 of 20 pages = 75%, not 0%)
- Score formula accounts for consistency, not just daily completion

#### 5.1.3 Sub-Habit Decomposition (LLM-Powered)
- When creating an ambitious habit, user can tap "Break this down"
- LLM generates 3-5 tiny sub-habits that ladder up to the main goal
- Example: "Exercise daily" → "Put on workout clothes" → "Do 5 pushups" → "Walk around the block" → "15-min workout"
- Sub-habits follow BJ Fogg's Tiny Habits principle: start so small you can't say no
- Users can edit, reorder, or remove generated sub-habits
- Sub-habit completion rolls up into parent habit score

#### 5.1.4 Habit Frequency Options
- Daily
- Specific days of week (MWF, weekdays only, etc.)
- X times per week (e.g., 3 times any day)
- X times per month
- Custom interval (every N days)
- For negative habits: limit to X times per week/month

#### 5.1.5 Habit Effort Classification
- Each habit tagged as **Low / Medium / High** effort
- Auto-suggested based on frequency + target value, user can override
- Effort level affects point earning rate (high effort = more points per completion)
- Used in group leaderboards to normalize across different habit difficulties

### 5.2 Social System — Pacts

#### 5.2.1 Pact Creation
- Creator names the Pact, sets a shared habit or theme
- Invites friends via link, QR code, or username
- Pact size: 2-7 members (research-optimal range)
- Each Pact has a duration: 7 / 14 / 30 / 66 / custom days
- Members can track different habits within the same Pact (e.g., "Fitness Pact" — one does gym, another does yoga, another does running)

#### 5.2.2 Group Streak Mechanics
- **Group streak threshold:** Configurable. Default: n-1 members must complete for group streak to hold.
  - **All members complete:** Group streak advances + **bonus reward** (extra points, group loot drop)
  - **Threshold met (n-1):** Group streak holds. Members who completed get individual points.
  - **Below threshold:** Group streak **freezes** (NOT breaks). Triggers a "Comeback Challenge" — next day, the group can recover by all completing.
- **Never punish. Never break. Always offer recovery.**

#### 5.2.3 Group Reward Stakes
- Before a Pact begins, the group sets a **real-world reward**
- Examples: "Losers buy winner biryani," "Bottom performer treats everyone coffee," "Winner picks the next movie"
- Reward is displayed prominently in the Pact dashboard as ongoing motivation
- At Pact end: top performer (by completion %) is crowned. Group honor system for reward delivery.
- Optional: photo proof of reward delivery, posted to Pact feed

#### 5.2.4 Pact Feed
- Lightweight activity stream within each Pact
- Shows: completions, streak milestones, freeze gifts, comeback challenges, congratulations
- Members can react (quick emoji reactions, not full comments — keeps it lightweight)
- No algorithmic ranking — chronological only

### 5.3 Streak Freeze System

#### 5.3.1 Earning Points
- Complete a habit → earn **streak points** based on effort level and consecutive days
- Base rate: Low effort = 1 pt, Medium = 2 pt, High = 3 pt
- Streak multiplier: consecutive days multiply points (Day 1 = 1x, Day 7 = 1.5x, Day 30 = 2x, Day 66 = 3x)
- Group bonus: if entire Pact completes, everyone gets +50% bonus points

#### 5.3.2 Spending Points
- **Buy Streak Freeze:** Costs N points (scales with streak length — longer streaks cost more to freeze, creating natural tension)
- **Gift Streak Freeze:** Send a freeze to any friend in your Pact. They receive a notification: "[Name] saved your streak today"
- Freeze usage is visible in Pact feed (social reinforcement for generous behavior)

#### 5.3.3 Freeze Mechanics
- A frozen day appears as a special icon (not blank, not failed) — acknowledges the miss without shame
- Maximum 2 freezes per week per habit (prevents abuse)
- Gifted freezes show the giver's name — builds reciprocity

### 5.4 Nudge & Notification Engine

#### 5.4.1 Anticipation-Based Personal Nudges
- **Pre-habit:** "Your streak hits [N] if you [habit] in the next [time] — you're [X]% through your goal"
- **Cue-based:** If user set "When I [cue], I will [habit]" → notification fires at cue time: "[Cue] is happening — time for [habit]?"
- **Never guilt-based.** No "You missed X." No red warning icons. No disappointed emoji.

#### 5.4.2 Social Nudges
- Friends can send **one nudge per day per person** (rate-limited to prevent harassment)
- Nudge messages are pre-written positive templates: "Hey, your group is rooting for you today!" / "Your streak is impressive — keep it alive?"
- Custom nudge messages allowed but filtered for negativity (basic sentiment check)
- Receiving a nudge shows in-app as a supportive tap, not a demand

#### 5.4.3 Group-Context Notifications
- "5 of your 6 Pact members completed today — you're the last one standing!"
- "Your group streak is at 14 days. One more day and you unlock [reward]"
- "3 friends saved the group streak today. Your turn to return the favor?"
- "[Friend name] just gifted you a streak freeze — you're covered for today"

#### 5.4.4 End-of-Day Wrap
- If habits incomplete: "Did you stick to your habits today?" → If no, show: "Your [N] friends saved your group streak. Tomorrow's a new day."
- If all complete: "[streak count] days strong. Your group is [X]% through the challenge. [top performer] is leading — can you catch up?"
- Weekly mini-recap pushed as a notification: "[X] habits completed this week. [Best streak]. [Group highlight]."

### 5.5 Failure Recovery System

#### 5.5.1 Skip-Reason Tracking
- When a user misses a habit, optional prompt (never forced): "What got in the way?"
- Pre-set options: "Too tired" / "Too busy" / "Forgot" / "Not feeling well" / "Traveled" / "Other"
- Data aggregated over time to identify **failure patterns**
- If pattern detected (e.g., "Too tired" every Monday): proactive nudge on next Monday morning: "Mondays are tough for [habit] — want to do a lighter version today?"

#### 5.5.2 Comeback Challenges
- After a miss, the next day offers a "Comeback Challenge": slightly elevated target (1.2x, not 2x — achievable, not punishing)
- Completing the comeback earns bonus points
- In group context: "Your group is doing a Comeback Challenge today — everyone in?"

#### 5.5.3 Positive Framing
- App NEVER shows: "You missed 3 days this week"
- App ALWAYS shows: "You completed 4 out of 7 days this week — that's 57%! Last week was 43% — you're improving."
- Calendar view highlights completed days in color, missed days are neutral (not red, not crossed out)
- Streak display: "Current: 5 days | Best: 12 days | Total: 45 days" — every number is a win

### 5.6 LLM Integration

#### 5.6.1 Sub-Habit Generation
- Input: ambitious habit description + user context (available time, experience level)
- Output: 3-5 ordered sub-habits following Tiny Habits methodology
- Model: lightweight API call (Claude Haiku or equivalent for cost efficiency)
- Cached: similar habits return cached decompositions to reduce API calls

#### 5.6.2 Tips on Missed/Relapsed Habits
- When a user has a negative habit relapse (e.g., smoked after 10 days clean), offer: "Want some tips for next time?"
- LLM generates personalized, non-judgmental advice based on the habit type and skip-reason history
- Tone: supportive coach, never disappointed parent

#### 5.6.3 Weekly Insight Generation
- End-of-week: LLM summarizes the user's patterns: "You're strongest on Tue/Thu, struggle on weekends. Your skip reasons cluster around 'too tired' — consider shifting [habit] to morning?"
- Group level: "Your Pact is 78% consistent. [Name] had a breakthrough week. [Name] might appreciate a nudge."

### 5.7 Auto-Tracking

#### 5.7.1 Built-In Integrations (Ship with App)
| Platform | Data | Habit Auto-Fill |
|----------|------|----------------|
| **Google Fit / Health Connect** | Steps, distance, active minutes, sleep duration | Walking, running, exercise, sleep habits |
| **Apple HealthKit** | Steps, workouts, sleep, mindful minutes | Same as above + meditation |
| **Screen Time API (Android/iOS)** | App usage duration, unlocks | "Limit screen time" negative habits, "Read for 30 min" (Kindle usage) |

#### 5.7.2 Plugin-Based Integrations (Community Marketplace)
| Platform | Data | Habit Auto-Fill |
|----------|------|----------------|
| **Wakatime** | Coding hours, languages, projects | "Code for 2 hours" habit |
| **LeetCode** | Problems solved, contest rating | "Solve 1 DSA problem" habit |
| **Strava** | Runs, rides, swims with GPS data | Fitness habits with distance/time |
| **Duolingo** | Lessons completed, XP earned, streak | Language learning habits |
| **GitHub** | Commits, PRs, contributions | "Contribute to open source" habit |
| **Goodreads** | Pages read, books finished | Reading habits |
| **Spotify** | Listening time (for music practice habits) | "Practice instrument 30 min" |
| **Google Calendar** | Events attended | "Attend all classes" habit |

### 5.8 Analytics & Lookbacks

#### 5.8.1 Personal Analytics
- **Daily:** Simple completion checklist with score
- **Weekly:** Bar chart of daily scores, best day, improvement vs last week
- **Monthly:** Heatmap calendar (green shades for completion %), trend line
- **All-time:** Total habits completed, longest streak, total points earned, consistency %

#### 5.8.2 Group Analytics
- **Pact Dashboard:** Group streak count, individual completion bars, top performer highlight
- **Weekly Group Lookback:** Automated summary — who crushed it, who improved, group consistency %
- **Monthly Group Report:** Trends, individual growth curves overlaid, group milestones celebrated

#### 5.8.3 Habit-Specific Analytics
- Completion rate by day of week (find your weak days)
- Skip-reason distribution (identify your barriers)
- Score curve over time (visualize automaticity forming)
- Sub-habit completion breakdown

---

## 6. Plugin & Integration Architecture

### 6.1 Design Philosophy

HabitPact ships as a habit platform, not just a habit app. The plugin system ensures:
- We don't have to predict every possible habit type
- The community builds what they need
- The ecosystem grows organically
- Third-party developers have a clear, documented integration path

### 6.2 Plugin SDK

#### 6.2.1 Plugin Interface

```
┌─────────────────────────────────────────┐
│              HabitPact App              │
│  ┌──────────────────────────────────┐   │
│  │         Plugin Manager           │   │
│  │  ┌──────────┐  ┌──────────────┐  │   │
│  │  │ Registry │  │ Lifecycle    │  │   │
│  │  │ (install,│  │ (init, sync, │  │   │
│  │  │  update, │  │  dispose)    │  │   │
│  │  │  remove) │  │              │  │   │
│  │  └──────────┘  └──────────────┘  │   │
│  └──────────────────────────────────┘   │
│                   │                      │
│  ┌────────────────┼─────────────────┐   │
│  │     Plugin Sandbox (Isolate)     │   │
│  │                                   │   │
│  │  ┌─────────┐  ┌──────────────┐   │   │
│  │  │ Plugin  │  │ Permitted    │   │   │
│  │  │ Code    │  │ APIs:        │   │   │
│  │  │         │  │ - readHabit  │   │   │
│  │  │         │  │ - writeRecord│   │   │
│  │  │         │  │ - httpFetch  │   │   │
│  │  │         │  │ - showUI     │   │   │
│  │  └─────────┘  └──────────────┘   │   │
│  └───────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

#### 6.2.2 Plugin Manifest (plugin.yaml)

```yaml
name: wakatime-integration
version: 1.0.0
author: community-dev
description: Auto-track coding hours from Wakatime
permissions:
  - habit.write_record    # Write completion data to habits
  - habit.read            # Read habit configuration
  - network.fetch         # Make HTTP requests to Wakatime API
  - ui.settings_page      # Show a settings page for API key input
triggers:
  - type: periodic
    interval: 30m         # Sync every 30 minutes
  - type: app_open        # Also sync when app opens
data_source:
  name: Wakatime
  auth_type: api_key
  base_url: https://wakatime.com/api/v1
habit_types:
  - coding_hours
  - coding_streak
```

#### 6.2.3 Plugin API Surface

```
HabitPactPlugin {
  // Lifecycle
  onInstall()          → Setup wizard, auth flow
  onSync()             → Fetch data from external source, write to habits
  onUninstall()        → Cleanup

  // Habit APIs (sandboxed)
  getHabits()          → List habits this plugin manages
  writeRecord(habitId, date, value)  → Submit a completion record
  readRecords(habitId, dateRange)    → Read existing records

  // UI APIs
  renderSettingsPage() → Custom settings UI for the plugin
  renderWidget()       → Optional home screen widget contribution

  // Network APIs (sandboxed, only to declared domains)
  httpGet(url, headers)
  httpPost(url, body, headers)
}
```

#### 6.2.4 Security Model
- Plugins run in **Dart isolates** (sandboxed execution, no access to main app memory)
- Network access restricted to domains declared in manifest
- No access to other users' data, other habits, or device sensors
- All plugin data writes are tagged with plugin source (auditable)
- Users must explicitly grant permissions on install
- Plugin code is open-source (mandatory for marketplace listing)

### 6.3 Built-In Integrations (First-Party Plugins)

Ship with the app, maintained by the core team:

| Integration | Priority | Data Flow |
|------------|----------|-----------|
| Google Fit / Health Connect | P0 | Steps, distance, active mins, sleep → habit auto-fill |
| Apple HealthKit | P0 | Same as above for iOS |
| Screen Time (Android Digital Wellbeing / iOS Screen Time) | P1 | App usage → negative habit tracking |

### 6.4 Community Marketplace

See [Section 15](#15-community-marketplace) for full marketplace design.

---

## 7. Technical Architecture

### 7.1 High-Level Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        CLIENT (Flutter)                       │
│                                                               │
│  ┌─────────┐ ┌──────────┐ ┌─────────┐ ┌──────────────────┐  │
│  │ Habit   │ │ Social   │ │ Plugin  │ │ Notification     │  │
│  │ Engine  │ │ Engine   │ │ Manager │ │ Engine           │  │
│  └────┬────┘ └────┬─────┘ └────┬────┘ └────────┬─────────┘  │
│       │           │            │                │             │
│  ┌────┴───────────┴────────────┴────────────────┴─────────┐  │
│  │              State Management (Provider + RxDart)       │  │
│  └────────────────────────┬───────────────────────────────┘  │
│                           │                                   │
│  ┌────────────────────────┴───────────────────────────────┐  │
│  │              Local Database (SQLite via sqflite)        │  │
│  └────────────────────────┬───────────────────────────────┘  │
│                           │                                   │
│  ┌────────────────────────┴───────────────────────────────┐  │
│  │              Sync Layer (Online/Offline aware)          │  │
│  └────────────────────────┬───────────────────────────────┘  │
└───────────────────────────┼───────────────────────────────────┘
                            │
                   ┌────────┴────────┐
                   │    NETWORK      │
                   └────────┬────────┘
                            │
┌───────────────────────────┼───────────────────────────────────┐
│                      BACKEND (Firebase)                        │
│                                                                │
│  ┌──────────────┐ ┌──────────────┐ ┌────────────────────────┐ │
│  │ Auth         │ │ Firestore    │ │ Cloud Functions        │ │
│  │ (Firebase    │ │ (Social data,│ │ (Nudge orchestration,  │ │
│  │  Auth)       │ │  Pacts,      │ │  group streak calc,    │ │
│  │              │ │  profiles)   │ │  reward notifications, │ │
│  │              │ │              │ │  LLM proxy)            │ │
│  └──────────────┘ └──────────────┘ └────────────────────────┘ │
│                                                                │
│  ┌──────────────┐ ┌──────────────┐ ┌────────────────────────┐ │
│  │ FCM          │ │ Storage      │ │ Plugin Marketplace     │ │
│  │ (Push        │ │ (Proof       │ │ (Plugin registry,      │ │
│  │  notifs)     │ │  photos)     │ │  downloads, ratings)   │ │
│  └──────────────┘ └──────────────┘ └────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘
                            │
                   ┌────────┴────────┐
                   │ EXTERNAL APIs   │
                   │ (Google Fit,    │
                   │  Wakatime,      │
                   │  Strava, etc.)  │
                   └─────────────────┘
```

### 7.2 Technology Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| **Framework** | Flutter 3.35+ / Dart | Cross-platform (Android, iOS, Web). Single codebase. Rich widget ecosystem. |
| **State Management** | Provider + RxDart | Provider for dependency injection and simple state. RxDart for reactive streams (real-time social updates). |
| **Local Database** | SQLite via sqflite | Proven, fast, offline-first. Complex queries for analytics. |
| **Backend** | Firebase (Auth + Firestore + Cloud Functions + FCM + Storage) | Free tier covers hackathon. Real-time sync for social features. Serverless = no infra management. |
| **Authentication** | Firebase Auth (Google Sign-In + Apple Sign-In + Email) | Zero-friction social login. Required for social features. Optional for solo users. |
| **Real-Time Sync** | Firestore real-time listeners | Pact feed, group streaks, and nudges update instantly across devices |
| **Push Notifications** | Firebase Cloud Messaging (FCM) | Cross-platform push. Scheduled via Cloud Functions. |
| **LLM** | Claude Haiku API (via Cloud Function proxy) | Sub-habit generation, weekly insights, relapse tips. Haiku for cost efficiency. |
| **Charts** | fl_chart + custom heatmap widget | Lightweight, customizable, no heavy dependencies |
| **Secure Storage** | flutter_secure_storage | API keys, auth tokens |
| **Code Gen** | build_runner + json_serializable + freezed | Type-safe models, immutable data classes, JSON serialization |
| **Testing** | flutter_test + mockito + integration_test | Unit, widget, and integration tests |
| **CI/CD** | GitHub Actions | Automated builds, tests, releases |

### 7.3 Offline-First Architecture

```
User Action (e.g., complete habit)
        │
        ▼
┌──────────────────┐
│ Write to local    │  ← Always succeeds, even offline
│ SQLite instantly  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Queue sync event │────▶│ Sync worker      │
│ (pending_sync    │     │ (runs when       │
│  table)          │     │  online)         │
└──────────────────┘     └────────┬─────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │ Firestore write  │
                         │ + conflict       │
                         │   resolution     │
                         └──────────────────┘
```

- All habit data lives locally first (SQLite)
- Social data syncs to Firestore when online
- Sync queue handles offline → online transitions
- Conflict resolution: last-write-wins for records, merge for profiles
- Solo mode works 100% offline, indefinitely

### 7.4 Module Structure

```
lib/
├── core/                    # Shared foundation
│   ├── models/              # Data models (habit, record, user, pact, etc.)
│   ├── database/            # SQLite schema, migrations, DAOs
│   ├── providers/           # State management providers
│   ├── extensions/          # Dart extension methods
│   ├── utils/               # Utility functions
│   ├── constants/           # App-wide constants
│   └── theme/               # Material3 theming
│
├── features/
│   ├── habit/               # Core habit engine
│   │   ├── pages/           # Create, edit, detail, list screens
│   │   ├── widgets/         # Habit card, check-in button, score chart
│   │   ├── providers/       # Habit state management
│   │   └── services/        # Habit business logic
│   │
│   ├── social/              # Pact & group system
│   │   ├── pages/           # Pact creation, dashboard, feed, invite
│   │   ├── widgets/         # Group streak bar, member list, reward display
│   │   ├── providers/       # Social state management
│   │   └── services/        # Pact logic, group streak calculation
│   │
│   ├── streak/              # Points, freezes, gifting
│   │   ├── pages/           # Points dashboard, freeze shop, gift flow
│   │   ├── widgets/         # Point counter, freeze indicator
│   │   ├── providers/       # Streak/point state
│   │   └── services/        # Point calculation, freeze logic
│   │
│   ├── nudge/               # Notification & nudge engine
│   │   ├── services/        # Nudge scheduling, template selection
│   │   ├── providers/       # Notification state
│   │   └── templates/       # Pre-written nudge messages
│   │
│   ├── analytics/           # Charts, lookbacks, insights
│   │   ├── pages/           # Personal analytics, group analytics, weekly lookback
│   │   ├── widgets/         # Charts, heatmaps, score curves
│   │   └── providers/       # Analytics data aggregation
│   │
│   ├── llm/                 # AI features
│   │   ├── services/        # Sub-habit gen, tips, weekly insights
│   │   └── providers/       # LLM state, caching
│   │
│   ├── plugins/             # Plugin system
│   │   ├── sdk/             # Plugin interface, manifest parser
│   │   ├── manager/         # Install, update, remove, sandbox
│   │   ├── marketplace/     # Browse, search, install plugins
│   │   └── builtin/         # First-party integrations (Google Fit, HealthKit)
│   │
│   └── settings/            # App settings, profile, data export
│       ├── pages/           # Settings screens
│       └── providers/       # Settings state
│
├── sync/                    # Online/offline sync layer
│   ├── services/            # Sync queue, conflict resolution
│   ├── firebase/            # Firestore interactions
│   └── providers/           # Sync state
│
├── auth/                    # Authentication (optional for solo)
│   ├── pages/               # Login, signup, profile
│   ├── services/            # Firebase Auth wrapper
│   └── providers/           # Auth state
│
├── routes/                  # Navigation & routing
├── l10n/                    # Localization (.arb files)
└── main.dart                # App entry point
```

---

## 8. Database Schema

### 8.1 Local Database (SQLite)

```sql
-- ============================================
-- CORE HABIT TABLES
-- ============================================

CREATE TABLE habits (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid            TEXT NOT NULL UNIQUE,
    name            TEXT NOT NULL,
    description     TEXT,
    type            INTEGER NOT NULL DEFAULT 0,  -- 0=positive, 1=negative
    effort_level    INTEGER NOT NULL DEFAULT 1,  -- 0=low, 1=medium, 2=high
    daily_goal      REAL NOT NULL DEFAULT 1.0,
    goal_unit       TEXT,
    color           INTEGER NOT NULL,
    icon            TEXT,
    frequency_type  INTEGER NOT NULL DEFAULT 0,  -- 0=daily, 1=weekly, 2=custom
    frequency_data  TEXT,                         -- JSON for custom frequency
    privacy_level   INTEGER NOT NULL DEFAULT 0,  -- 0=public, 1=partial, 2=private
    start_date      INTEGER NOT NULL,
    target_days     INTEGER DEFAULT 66,           -- Default to research-backed 66 days
    archived        INTEGER NOT NULL DEFAULT 0,
    sort_position   REAL NOT NULL DEFAULT 0,
    parent_habit_id INTEGER,                      -- NULL if top-level, FK if sub-habit
    created_at      INTEGER NOT NULL,
    updated_at      INTEGER NOT NULL,

    FOREIGN KEY (parent_habit_id) REFERENCES habits(id) ON DELETE CASCADE
);

CREATE TABLE records (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid            TEXT NOT NULL UNIQUE,
    habit_id        INTEGER NOT NULL,
    record_date     INTEGER NOT NULL,             -- Date as YYYYMMDD integer
    record_type     INTEGER NOT NULL DEFAULT 0,   -- 0=completed, 1=skipped, 2=frozen
    record_value    REAL NOT NULL DEFAULT 0,       -- Actual value (e.g., 15 pages)
    skip_reason     INTEGER,                       -- 0=tired, 1=busy, 2=forgot, 3=sick, 4=travel, 5=other
    skip_note       TEXT,                          -- Optional free-text skip reason
    frozen_by       TEXT,                          -- UUID of friend who gifted freeze (NULL if self)
    source          TEXT DEFAULT 'manual',         -- 'manual', 'google_fit', 'plugin:wakatime', etc.
    created_at      INTEGER NOT NULL,

    FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
    UNIQUE(habit_id, record_date)
);

-- ============================================
-- STREAK & POINTS
-- ============================================

CREATE TABLE streak_points (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    user_uuid       TEXT NOT NULL,
    balance         INTEGER NOT NULL DEFAULT 0,
    total_earned    INTEGER NOT NULL DEFAULT 0,
    total_spent     INTEGER NOT NULL DEFAULT 0,
    updated_at      INTEGER NOT NULL
);

CREATE TABLE point_transactions (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    user_uuid       TEXT NOT NULL,
    amount          INTEGER NOT NULL,             -- Positive = earn, negative = spend
    type            INTEGER NOT NULL,             -- 0=habit_complete, 1=freeze_purchase, 2=freeze_gift_sent, 3=freeze_gift_received, 4=group_bonus, 5=comeback_bonus
    habit_id        INTEGER,
    pact_id         TEXT,
    related_user    TEXT,                          -- UUID of friend (for gifts)
    created_at      INTEGER NOT NULL
);

CREATE TABLE streak_freezes (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    owner_uuid      TEXT NOT NULL,
    gifted_by       TEXT,                          -- NULL if self-purchased
    used            INTEGER NOT NULL DEFAULT 0,
    used_on_date    INTEGER,
    used_on_habit   INTEGER,
    created_at      INTEGER NOT NULL
);

-- ============================================
-- SOCIAL / PACT TABLES (synced to Firestore)
-- ============================================

CREATE TABLE pacts (
    id              TEXT PRIMARY KEY,              -- Firestore document ID
    name            TEXT NOT NULL,
    description     TEXT,
    habit_theme     TEXT,                          -- e.g., "Fitness", "Study", "Wellness"
    creator_uuid    TEXT NOT NULL,
    streak_threshold INTEGER NOT NULL DEFAULT -1,  -- -1 means n-1 auto-calculated
    reward_description TEXT,                       -- "Losers buy winner biryani"
    start_date      INTEGER NOT NULL,
    end_date        INTEGER,
    duration_days   INTEGER NOT NULL DEFAULT 30,
    status          INTEGER NOT NULL DEFAULT 0,   -- 0=active, 1=completed, 2=archived
    created_at      INTEGER NOT NULL
);

CREATE TABLE pact_members (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    pact_id         TEXT NOT NULL,
    user_uuid       TEXT NOT NULL,
    habit_id        INTEGER,                       -- Which local habit they track in this pact
    role            INTEGER NOT NULL DEFAULT 0,   -- 0=member, 1=admin
    joined_at       INTEGER NOT NULL,

    FOREIGN KEY (pact_id) REFERENCES pacts(id) ON DELETE CASCADE,
    UNIQUE(pact_id, user_uuid)
);

CREATE TABLE pact_streaks (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    pact_id         TEXT NOT NULL,
    streak_date     INTEGER NOT NULL,
    members_completed INTEGER NOT NULL DEFAULT 0,
    members_total   INTEGER NOT NULL,
    status          INTEGER NOT NULL DEFAULT 0,   -- 0=maintained, 1=bonus (all completed), 2=frozen, 3=comeback
    created_at      INTEGER NOT NULL,

    FOREIGN KEY (pact_id) REFERENCES pacts(id) ON DELETE CASCADE,
    UNIQUE(pact_id, streak_date)
);

CREATE TABLE pact_feed (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    pact_id         TEXT NOT NULL,
    user_uuid       TEXT NOT NULL,
    event_type      INTEGER NOT NULL,             -- 0=completion, 1=streak_milestone, 2=freeze_gift, 3=nudge, 4=comeback, 5=reward_photo, 6=congratulation
    event_data      TEXT,                          -- JSON payload
    created_at      INTEGER NOT NULL,

    FOREIGN KEY (pact_id) REFERENCES pacts(id) ON DELETE CASCADE
);

-- ============================================
-- SYNC MANAGEMENT
-- ============================================

CREATE TABLE sync_queue (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    table_name      TEXT NOT NULL,
    record_uuid     TEXT NOT NULL,
    operation       INTEGER NOT NULL,             -- 0=create, 1=update, 2=delete
    payload         TEXT NOT NULL,                 -- JSON of the data to sync
    status          INTEGER NOT NULL DEFAULT 0,   -- 0=pending, 1=syncing, 2=synced, 3=failed
    retry_count     INTEGER NOT NULL DEFAULT 0,
    created_at      INTEGER NOT NULL,
    synced_at       INTEGER
);

-- ============================================
-- PLUGINS
-- ============================================

CREATE TABLE installed_plugins (
    id              TEXT PRIMARY KEY,              -- Plugin identifier (e.g., "wakatime-integration")
    version         TEXT NOT NULL,
    manifest        TEXT NOT NULL,                 -- Full plugin.yaml as JSON
    settings        TEXT,                          -- Plugin-specific settings JSON
    enabled         INTEGER NOT NULL DEFAULT 1,
    installed_at    INTEGER NOT NULL,
    updated_at      INTEGER NOT NULL
);

CREATE TABLE plugin_sync_log (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    plugin_id       TEXT NOT NULL,
    sync_time       INTEGER NOT NULL,
    records_synced  INTEGER NOT NULL DEFAULT 0,
    status          INTEGER NOT NULL,             -- 0=success, 1=partial, 2=failed
    error_message   TEXT,

    FOREIGN KEY (plugin_id) REFERENCES installed_plugins(id) ON DELETE CASCADE
);

-- ============================================
-- USER PROFILE (local + synced)
-- ============================================

CREATE TABLE user_profile (
    uuid            TEXT PRIMARY KEY,
    display_name    TEXT,
    avatar_url      TEXT,
    auth_provider   TEXT,                          -- 'google', 'apple', 'email', NULL for solo
    created_at      INTEGER NOT NULL,
    updated_at      INTEGER NOT NULL
);

-- ============================================
-- REMINDERS
-- ============================================

CREATE TABLE reminders (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    habit_id        INTEGER NOT NULL,
    time            TEXT NOT NULL,                 -- HH:MM format
    days            TEXT NOT NULL,                 -- JSON array of day numbers [0-6]
    enabled         INTEGER NOT NULL DEFAULT 1,
    message_type    INTEGER NOT NULL DEFAULT 0,   -- 0=anticipation, 1=cue_based
    cue_description TEXT,                          -- "When I finish dinner" (for implementation intentions)

    FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
);
```

### 8.2 Firestore Schema (Cloud)

```
firestore/
├── users/
│   └── {userId}/
│       ├── displayName: string
│       ├── avatarUrl: string
│       ├── totalPoints: number
│       ├── currentStreak: number
│       ├── longestStreak: number
│       └── joinedAt: timestamp
│
├── pacts/
│   └── {pactId}/
│       ├── name: string
│       ├── description: string
│       ├── habitTheme: string
│       ├── creatorId: string
│       ├── streakThreshold: number
│       ├── rewardDescription: string
│       ├── startDate: timestamp
│       ├── endDate: timestamp
│       ├── status: string
│       ├── currentStreak: number
│       ├── members/
│       │   └── {userId}/
│       │       ├── habitName: string
│       │       ├── completionRate: number
│       │       ├── currentStreak: number
│       │       ├── role: string
│       │       └── todayCompleted: boolean
│       ├── streaks/
│       │   └── {date}/
│       │       ├── membersCompleted: number
│       │       ├── membersTotal: number
│       │       └── status: string
│       └── feed/
│           └── {feedId}/
│               ├── userId: string
│               ├── eventType: string
│               ├── eventData: map
│               └── createdAt: timestamp
│
├── nudges/
│   └── {nudgeId}/
│       ├── fromUser: string
│       ├── toUser: string
│       ├── pactId: string
│       ├── message: string
│       ├── read: boolean
│       └── createdAt: timestamp
│
├── plugins/
│   └── {pluginId}/
│       ├── name: string
│       ├── version: string
│       ├── author: string
│       ├── description: string
│       ├── downloadCount: number
│       ├── rating: number
│       ├── ratingCount: number
│       ├── manifest: map
│       ├── sourceUrl: string
│       └── publishedAt: timestamp
│
└── freeze_gifts/
    └── {giftId}/
        ├── fromUser: string
        ├── toUser: string
        ├── pactId: string
        ├── accepted: boolean
        └── createdAt: timestamp
```

---

## 9. User Flows

### 9.1 First-Time User (Solo Path)

```
Download App
    │
    ▼
Welcome Screen
"Track habits your way. Solo or with friends."
    │
    ├──▶ [Skip Sign-In] ──▶ Solo Mode (no account, all local)
    │
    └──▶ [Sign In] ──▶ Google/Apple/Email ──▶ Full Mode
    │
    ▼
Create First Habit
    │
    ├── Name: "Read 20 pages"
    ├── Type: Positive
    ├── Frequency: Daily
    ├── Goal: 20 pages
    ├── Effort: Low
    ├── [Optional] "Break this down" → LLM sub-habits
    ├── [Optional] Set reminder with cue: "After dinner"
    └── Privacy: Public (default)
    │
    ▼
Home Dashboard (Solo View)
    │
    ├── Today's habits (check-in buttons)
    ├── Current streaks
    ├── Points earned
    └── [Soft prompt] "Invite friends to start a Pact →"
```

### 9.2 Creating a Pact

```
User taps "Create Pact"
    │
    ▼
Pact Setup
    │
    ├── Name: "Gym Bros"
    ├── Theme: Fitness
    ├── Duration: 30 days
    ├── Group Reward: "Losers buy winner dinner"
    ├── Streak Threshold: Default (n-1)
    │
    ▼
Invite Friends
    │
    ├── Share link (WhatsApp, Instagram, etc.)
    ├── QR code
    └── Search by username
    │
    ▼
Friends Join
    │
    ├── Each member picks/creates their habit for this Pact
    │   (e.g., one picks "Gym 1hr", another "Run 3km")
    │
    ▼
Pact Goes Live
    │
    ▼
Pact Dashboard
    ├── Group streak counter
    ├── Member completion status (today)
    ├── Reward reminder at top
    ├── Activity feed
    └── [Nudge] button per member (1/day limit)
```

### 9.3 Daily Check-In Flow

```
User opens app (or receives anticipation nudge)
    │
    ▼
Home Dashboard
    │
    ├── Habits listed with today's status
    │   ├── [Tap to complete] → Value input (if applicable) → Done ✓
    │   ├── [Auto-completed] → "Google Fit synced 8,432 steps ✓"
    │   └── [Sub-habits] → Expandable checklist
    │
    ▼
On Completion:
    ├── +Points animation (small, satisfying, not overwhelming)
    ├── Streak counter increments
    ├── If in Pact: completion pushed to group feed
    │   └── "[Name] just completed [habit]!"
    │
    ▼
End of Day:
    │
    ├── ALL DONE → "🔥 [streak] days strong. [Pact name] is [X]% through!"
    │
    └── MISSED → No guilt screen. Instead:
        ├── "What got in the way?" (optional, pre-set options)
        ├── Auto-use streak freeze (if available)
        │   └── "Your streak is safe. [Friend] covered you." (if gifted)
        └── Show: "You completed [N] of [total] this week — that's [X]%!"
```

### 9.4 Streak Freeze Gift Flow

```
Friend [A] notices Friend [B] missed today
    │
    ▼
[A] taps [B]'s profile in Pact
    │
    ▼
"Gift a Streak Freeze to [B]?"
Cost: [N] points | Your balance: [M] points
    │
    ├── [Gift It] → Points deducted → Freeze gifted
    │   │
    │   ▼
    │   [B] receives notification:
    │   "[A] saved your streak today! 💪"
    │   │
    │   ▼
    │   Pact feed: "[A] gifted a streak freeze to [B]"
    │   (Social reinforcement — generosity is visible)
    │
    └── [Not Now]
```

### 9.5 Plugin Installation Flow

```
User navigates to Marketplace tab
    │
    ▼
Browse/Search plugins
    │
    ├── Featured: Google Fit, Strava, Wakatime, LeetCode
    ├── Categories: Fitness, Coding, Language, Productivity
    ├── Community: User-submitted plugins with ratings
    │
    ▼
User taps "Wakatime Integration"
    │
    ▼
Plugin Detail Page
    ├── Description, screenshots, reviews, rating
    ├── Permissions requested: habit.write_record, network.fetch
    ├── Author, source code link
    │
    ▼
[Install] → Permission grant dialog → Download → Setup wizard
    │
    ▼
Setup: Enter Wakatime API key
    │
    ▼
Link to habit: "Which habit should Wakatime track?"
    ├── Existing habit: "Code for 2 hours"
    └── Create new: Auto-suggested "Daily Coding" habit
    │
    ▼
Plugin active — syncs every 30 min
    │
    ▼
Next day: "Wakatime synced 2h 34m coding ✓"
```

---

## 10. Notification & Nudge Engine

### 10.1 Notification Types & Timing

| Type | Trigger | Message Style | Frequency |
|------|---------|--------------|-----------|
| **Anticipation Nudge** | X minutes before usual habit time | "Your streak hits [N] in 20 min" | 1/day per habit |
| **Cue-Based Prompt** | At the time of user-defined cue | "[Cue] is happening — time for [habit]?" | 1/day per habit |
| **Social Proof** | When >50% of Pact completes | "[X] of your [N] friends completed today" | Max 1/day per Pact |
| **Friend Nudge** | When a friend sends a nudge | "[Friend]: Your group is rooting for you!" | Rate-limited to 1/friend/day |
| **Freeze Gift** | When someone gifts you a freeze | "[Friend] saved your streak today!" | On event |
| **Group Milestone** | Pact streak hits 7/14/30/66 days | "Your group hit [N] days! [Reward] is getting closer!" | On event |
| **Weekly Lookback** | Sunday evening | "This week: [X] habits, [best streak], [group highlight]" | 1/week |
| **Comeback Challenge** | Morning after a group miss | "Comeback day! Full group completion = bonus points" | On event |

### 10.2 Anti-Annoyance Rules

- Maximum **3 notifications per day** total (across all types)
- Never send between 10 PM and 7 AM (user-configurable quiet hours)
- If user dismisses 3 nudges in a row without opening app, reduce frequency for 1 week
- Friend nudge rate: 1 nudge per friend per day maximum
- No notification ever contains negative framing ("you missed," "you failed," "don't forget")

### 10.3 Notification Priority Stack

When multiple notifications compete for the 3/day limit:
1. **Freeze gifts** (always delivered — someone spent points on you)
2. **Group milestones** (rare, high emotional value)
3. **Anticipation nudges** (core engagement mechanic)
4. **Social proof** (effective but lower urgency)
5. **Weekly lookbacks** (scheduled, can be delayed)

---

## 11. Gamification System

### 11.1 The One Loop

```
Complete Habit → Earn Points → Buy/Gift Freeze → Save Streaks → Complete More
     ▲                                                              │
     └──────────────────────────────────────────────────────────────┘
```

**That's it.** One currency. One spending mechanism. One social action. No complexity.

### 11.2 Point Economy

| Action | Points | Multiplier |
|--------|--------|-----------|
| Complete low-effort habit | 1 | × streak multiplier |
| Complete medium-effort habit | 2 | × streak multiplier |
| Complete high-effort habit | 3 | × streak multiplier |
| Full Pact completion bonus | +50% on base | — |
| Comeback Challenge completion | +2 bonus | — |

**Streak Multipliers:**
| Consecutive Days | Multiplier |
|-----------------|-----------|
| 1-6 | 1.0x |
| 7-13 | 1.5x |
| 14-29 | 1.75x |
| 30-65 | 2.0x |
| 66+ | 3.0x (automaticity milestone!) |

**Freeze Costs:**
| Current Streak Length | Freeze Cost |
|----------------------|-------------|
| 1-7 days | 5 points |
| 8-14 days | 10 points |
| 15-30 days | 15 points |
| 31-66 days | 20 points |
| 67+ days | 25 points |

The scaling creates natural tension: longer streaks are more valuable AND more expensive to protect.

### 11.3 Group Reward Stakes

- Set before Pact starts. Displayed prominently throughout.
- No in-app currency for rewards — real-world only.
- At Pact end:
  - **Winner:** Highest completion % (ties broken by total points earned in Pact)
  - **Celebration:** Winner highlighted in group feed with confetti animation
  - **Reward:** Honor system. Optional: photo proof of reward delivery posted to feed.

### 11.4 Variable-Ratio Surprises

- At random milestones (not predictable intervals), the group gets a "Group Loot Drop"
- Examples: "Everyone in [Pact] gets +10 bonus points!", "Double points for [Pact] tomorrow!"
- Probability: ~15% chance per day when full group completes (variable ratio schedule)
- Based on reward prediction error neuroscience — unexpected rewards produce stronger dopamine responses than expected ones

---

## 12. Privacy & Data Model

### 12.1 Privacy Levels

| Level | What Others See | Use Case |
|-------|----------------|----------|
| **Public** | Habit name, daily completion, streak, score | Default for most habits |
| **Partial** | Only completion %, streak count (not habit name or details) | Sensitive habits (meditation, therapy exercises) |
| **Private** | Nothing — completely hidden from all social features | Personal tracking that shouldn't be shared |

### 12.2 Data Principles

1. **Local-first:** All habit data stored on device. Cloud sync is opt-in (required for social features).
2. **Minimal cloud data:** Only social-relevant data syncs to Firestore (completion status, streak count, not habit details for partial/private habits).
3. **No ads. No tracking. No selling data.** Revenue model is open-source + optional premium plugins.
4. **Export anytime:** Full data export in JSON format. Your data is yours.
5. **Delete anytime:** Account deletion removes all cloud data. Local data remains on device.

### 12.3 Social Data Visibility Matrix

| Data Point | Public Habit | Partial Habit | Private Habit | Solo (No Auth) |
|------------|-------------|---------------|---------------|----------------|
| Habit name | ✓ Pact members | ✗ | ✗ | N/A |
| Daily completion | ✓ Pact members | ✗ | ✗ | N/A |
| Completion % | ✓ Pact members | ✓ Pact members | ✗ | N/A |
| Streak count | ✓ Pact members | ✓ Pact members | ✗ | N/A |
| Score/charts | ✓ Pact members | ✗ | ✗ | N/A |
| Skip reasons | ✗ (always private) | ✗ | ✗ | N/A |
| Sub-habits | ✗ (always private) | ✗ | ✗ | N/A |

---

## 13. UI/UX Guidelines

### 13.1 Design Philosophy

- **Warm, not clinical.** Soft colors, rounded corners, gentle animations. This is a friend group app, not a hospital dashboard.
- **Celebration over data.** When you complete a habit, the dominant element is a satisfying animation, not a data table.
- **Progressive disclosure.** New users see 3 things: their habits, a check-in button, and their streak. Everything else reveals as needed.
- **Material3 with Dynamic Color.** Matches device theme on Android 12+. Feels native, not foreign.

### 13.2 Core Screens

| Screen | Primary Action | Key Elements |
|--------|---------------|-------------|
| **Home (Solo)** | Check-in today's habits | Habit list with tap-to-complete, streak counter, points balance |
| **Home (Social)** | Check-in + see group status | Same as solo + Pact summary card at top ("4/6 completed today") |
| **Pact Dashboard** | View group progress | Group streak, member completion bars, reward reminder, activity feed |
| **Habit Detail** | Review habit analytics | Score curve, heatmap calendar, completion by day-of-week, skip reasons |
| **Create Habit** | Define a new habit | Name, frequency, goal, effort level, privacy, optional sub-habit generation |
| **Pact Creation** | Start a group challenge | Name, theme, duration, reward, invite method |
| **Freeze Shop** | Buy/gift streak freezes | Point balance, freeze cost, gift-to-friend selector |
| **Marketplace** | Browse/install plugins | Featured, categories, search, plugin detail + install flow |
| **Weekly Lookback** | Reflect on the week | Personal summary + group summary, highlights, improvement areas |
| **Settings** | Configure app behavior | Notifications, quiet hours, data export, integrations, account |

### 13.3 Color Language

| Color | Meaning |
|-------|---------|
| **Green shades** | Completion, success, active streaks |
| **Neutral/gray** | Missed days (NOT red — red implies failure/danger) |
| **Blue** | Social elements (Pact, friends, nudges) |
| **Gold/amber** | Points, rewards, milestones |
| **Purple** | Freeze-related (purchased, gifted, used) |

### 13.4 Animation Guidelines

- **Check-in:** Satisfying "pop" animation + brief particle effect. Under 300ms.
- **Streak milestone:** Confetti burst at 7/14/30/66 days. Auto-dismisses.
- **Freeze gift received:** Gentle glow + friend avatar animation.
- **Group loot drop:** Surprise chest opening animation (variable-ratio reward).
- **No animation on miss.** The app does nothing. No sad face, no red flash, nothing.

---

## 14. API Design

### 14.1 Cloud Functions API

```
Functions:
├── auth/
│   ├── onUserCreate          → Initialize user profile in Firestore
│   └── onUserDelete          → Cleanup all user data
│
├── pacts/
│   ├── createPact            → Validate, create Pact document, notify invited members
│   ├── joinPact              → Add member, validate Pact isn't full
│   ├── leavePact             → Remove member, recalculate threshold
│   ├── calculateDailyStreak  → Scheduled: 11:59 PM daily, compute group streak status
│   └── endPact               → Determine winner, send notifications, archive
│
├── nudges/
│   ├── sendNudge             → Validate rate limit, create nudge, send push notification
│   └── cleanupOldNudges      → Scheduled: Delete nudges older than 7 days
│
├── streaks/
│   ├── giftFreeze            → Validate balance, transfer points, create freeze, notify
│   └── autoFreezeCheck       → Scheduled: Auto-use available freeze if user missed today
│
├── llm/
│   ├── generateSubHabits     → Proxy to Claude Haiku, cache result, return sub-habits
│   ├── generateWeeklyInsight → Compute user stats, send to LLM, return insight
│   └── generateRelapseTip    → Context-aware tip for negative habit relapse
│
├── notifications/
│   ├── sendAnticipationNudge → Scheduled per-user based on habit timing
│   ├── sendSocialProof       → Triggered when >50% of Pact completes
│   └── sendWeeklyLookback    → Scheduled: Sunday 6 PM
│
├── plugins/
│   ├── publishPlugin         → Validate manifest, store in registry
│   ├── getPluginCatalog      → Return marketplace listings
│   └── reportPlugin          → Flag inappropriate plugins for review
│
└── lootDrops/
    └── checkGroupLootDrop    → 15% chance trigger when full group completes
```

### 14.2 Firestore Security Rules (Simplified)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can read/write own profile
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // Pact members can read Pact data; only creator can write core fields
    match /pacts/{pactId} {
      allow read: if request.auth != null
        && exists(/databases/$(database)/documents/pacts/$(pactId)/members/$(request.auth.uid));
      allow create: if request.auth != null;
      allow update: if request.auth != null
        && get(/databases/$(database)/documents/pacts/$(pactId)/members/$(request.auth.uid)).data.role == 'admin';

      // Members subcollection
      match /members/{memberId} {
        allow read: if request.auth != null
          && exists(/databases/$(database)/documents/pacts/$(pactId)/members/$(request.auth.uid));
        allow write: if request.auth.uid == memberId || request.auth != null;
      }

      // Feed subcollection
      match /feed/{feedId} {
        allow read: if request.auth != null
          && exists(/databases/$(database)/documents/pacts/$(pactId)/members/$(request.auth.uid));
        allow create: if request.auth != null
          && exists(/databases/$(database)/documents/pacts/$(pactId)/members/$(request.auth.uid));
      }
    }

    // Nudges: sender can create, recipient can read/update
    match /nudges/{nudgeId} {
      allow create: if request.auth != null && request.resource.data.fromUser == request.auth.uid;
      allow read: if request.auth != null
        && (resource.data.toUser == request.auth.uid || resource.data.fromUser == request.auth.uid);
      allow update: if request.auth != null && resource.data.toUser == request.auth.uid;
    }

    // Plugins: anyone can read, only author can write
    match /plugins/{pluginId} {
      allow read: if true;
      allow write: if request.auth != null && request.resource.data.author == request.auth.uid;
    }
  }
}
```

---

## 15. Community Marketplace

### 15.1 Marketplace Structure

```
┌─────────────────────────────────────────────────┐
│                  MARKETPLACE                     │
│                                                  │
│  ┌────────────────────────────────────────────┐  │
│  │  🔍 Search plugins...                      │  │
│  └────────────────────────────────────────────┘  │
│                                                  │
│  ── Featured ──────────────────────────────────  │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐           │
│  │Google│ │Strava│ │Waka- │ │Leet- │           │
│  │ Fit  │ │      │ │time  │ │Code  │           │
│  │ ⭐4.8│ │ ⭐4.6│ │ ⭐4.7│ │ ⭐4.5│           │
│  └──────┘ └──────┘ └──────┘ └──────┘           │
│                                                  │
│  ── Categories ───────────────────────────────   │
│  [🏃 Fitness] [💻 Coding] [📚 Learning]        │
│  [🧘 Wellness] [📊 Productivity] [🎮 Gaming]   │
│                                                  │
│  ── Community Picks ──────────────────────────   │
│  ┌──────────────────────────────────────────┐   │
│  │ 📦 Duolingo Sync         ⭐4.3  1.2K ↓  │   │
│  │ by @languagedev · Auto-track lessons     │   │
│  ├──────────────────────────────────────────┤   │
│  │ 📦 GitHub Contributions   ⭐4.1  890 ↓   │   │
│  │ by @devtools · Track daily commits       │   │
│  ├──────────────────────────────────────────┤   │
│  │ 📦 Goodreads Sync        ⭐4.0  650 ↓   │   │
│  │ by @bookworm · Auto-log reading pages    │   │
│  └──────────────────────────────────────────┘   │
│                                                  │
│  ── Build Your Own ───────────────────────────   │
│  [📖 Plugin SDK Docs] [🚀 Submit a Plugin]     │
│                                                  │
└─────────────────────────────────────────────────┘
```

### 15.2 Plugin Submission Process

1. Developer builds plugin following SDK spec
2. Submits via "Submit a Plugin" with:
   - Source code URL (GitHub — must be open-source)
   - Plugin manifest (plugin.yaml)
   - Description, screenshots, category
3. Automated checks:
   - Manifest validation
   - Permission scope review (no over-requesting)
   - Basic security scan (no eval, no arbitrary code execution)
4. Community review period (7 days)
5. Listed in marketplace with "New" badge

### 15.3 Plugin Rating System

- 1-5 star rating after 7 days of use (can't rate on install day)
- Written reviews optional
- Sorted by: rating × sqrt(download_count) — balances quality and popularity
- "Verified" badge for plugins that pass extended security review

---

## 16. Metrics & Success Criteria

### 16.1 North Star Metrics

| Metric | Target | Why It Matters |
|--------|--------|---------------|
| **Day-30 Retention** | >15% (vs 3-4% industry avg) | Proves we solve the 30-day wall |
| **Pact Join Rate** | >40% of users join a Pact within 14 days | Proves social features are compelling, not forced |
| **Streak Freeze Gift Rate** | >20% of freezes are gifted (not self-used) | Proves genuine social bonding |

### 16.2 Feature-Level Metrics

| Feature | Metric | Target |
|---------|--------|--------|
| Solo habit tracking | Daily check-in rate | >60% of active days |
| Pact system | Average Pact duration completed | >70% of Pact duration |
| Streak freeze gifting | Gifts per active Pact per week | >2 |
| Nudge system | Nudge-to-completion conversion | >30% |
| Auto-tracking plugins | Plugin adoption rate | >25% of users install ≥1 plugin |
| Sub-habit generation | Sub-habit creation rate | >15% of habits have sub-habits |
| Comeback challenges | Comeback completion rate | >50% |
| Weekly lookbacks | Lookback open rate | >40% |

### 16.3 Anti-Metrics (Things We Actively Avoid)

| Anti-Metric | Threshold | Action |
|-------------|-----------|--------|
| Notification dismiss rate | >70% | Reduce notification frequency |
| Streak anxiety complaints | Any reported | Review and fix messaging |
| Pact dropout rate | >30% before Pact end | Investigate and improve recovery mechanics |
| Fake check-ins (gaming the system) | >5% of records | Improve verification options |

---

## 17. Roadmap

### Phase 1: Hackathon MVP (Week 1-2)

**Goal:** Demonstrable core loop — solo habits + Pact creation + group streaks + streak freeze gifting

| Person | Deliverable |
|--------|------------|
| **Dev 1 — Habit Engine** | Habit CRUD, scoring, check-in, local SQLite, basic charts |
| **Dev 2 — Social System** | Firebase setup, Pact creation, invite link, group streak dashboard, feed |
| **Dev 3 — Gamification + Notifications** | Points system, streak freezes, gift flow, anticipation nudges, end-of-day wrap |
| **Dev 4 — Integrations + Polish** | Google Fit auto-tracking, plugin SDK scaffold, marketplace UI mockup, LLM sub-habit generation |

**MVP Demo Script (5 minutes):**
1. Create a habit solo → show anticipation nudge
2. Create a Pact → invite demo friend (second phone)
3. Both complete habit → show group streak advance + bonus points
4. One misses → friend gifts streak freeze → saved
5. Show Google Fit auto-tracking a step habit
6. Show LLM breaking "Exercise daily" into tiny sub-habits
7. Show marketplace with plugin listings

### Phase 2: Post-Hackathon Polish (Week 3-4)

- Sub-habit full implementation
- Skip-reason tracking + pattern detection
- Weekly/monthly lookback screens
- Full plugin SDK documentation
- 2-3 community plugins (Wakatime, LeetCode, Strava)
- Comeback challenge system
- Negative habit support
- Privacy level granular controls

### Phase 3: Growth (Month 2-3)

- Public marketplace launch
- Apple HealthKit integration
- LLM weekly insights
- Pact templates (pre-built Pacts: "30-Day Fitness", "DSA Grind", "Reading Challenge")
- Onboarding optimization
- Localization (Hindi, Tamil, Telugu)
- Web companion dashboard (Flutter Web)

### Phase 4: Scale (Month 3-6)

- Plugin SDK v2 (richer UI capabilities, widget contributions)
- Advanced analytics (correlation between habits, group vs solo comparison)
- Pact discovery (opt-in public Pacts for strangers who want accountability)
- API for third-party developers
- Accessibility audit (screen readers, color blindness)

---

## Appendix A: Competitor Feature Matrix

| Feature | HabitPact | Habitica | Streaks | HabitShare | Squad | stickK | Beeminder |
|---------|-----------|----------|---------|------------|-------|--------|-----------|
| Solo habit tracking | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ |
| Real friend groups | ✓ | Partial | ✗ | ✓ | Strangers | ✗ | ✗ |
| Group streaks | ✓ | Partial (quests) | ✗ | ✗ | ✓ | ✗ | ✗ |
| Streak freeze gifting | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Real-world reward stakes | ✓ | ✗ | ✗ | ✗ | ✗ | Financial only | Financial only |
| Shame-free recovery | ✓ | ✗ (party damage) | ✗ (streak breaks) | N/A | Partial | ✗ (charges money) | ✗ (charges money) |
| Auto-tracking | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ (limited) |
| Plugin ecosystem | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ (integrations) |
| LLM sub-habits | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Negative habits | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ |
| Skip-reason analytics | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Anticipation nudges | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Privacy levels per habit | ✓ | ✗ | N/A | ✓ | ✗ | N/A | N/A |
| Open source | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |

## Appendix B: Research Citations

1. **Lally, P. et al. (2010).** "How are habits formed: Modelling habit formation in the real world." European Journal of Social Psychology, 40(6), 998-1009. *Median 66 days to automaticity.*
2. **Matthews, G. (2015).** Goal Research Summary, Dominican University. *Accountability partner raises success from 35% to 70%.*
3. **Gollwitzer, P.M. (1999).** "Implementation intentions: Strong effects of simple plans." American Psychologist, 54(7), 493-503. *d=0.65 effect size.*
4. **Fogg, B.J. (2019).** Tiny Habits: The Small Changes That Change Everything. *B=MAP model.*
5. **Kahneman, D. & Tversky, A. (1979).** "Prospect Theory: An Analysis of Decision under Risk." Econometrica. *Loss aversion ~2x.*
6. **Deci, E.L. & Ryan, R.M. (2000).** "Self-Determination Theory and the Facilitation of Intrinsic Motivation." American Psychologist. *Autonomy, competence, relatedness.*
7. **Cialdini, R.B. (2006).** Influence: The Psychology of Persuasion. *Social proof.*
8. **MooreMonentum (2025).** "Why Do 90% of People Quit Habit Trackers Within 30 Days?"
9. **TU Wien Habits Network Study.** Complexity as primary barrier to sustained self-tracking engagement.
10. **2025 Meta-Analysis (42 studies).** Structured accountability systems → 2.8x habit maintenance.
11. **Schultz, W. (2016).** "Dopamine reward prediction error signalling." Nature Reviews Neuroscience. *Variable-ratio reinforcement.*
12. **stickK user analysis.** Financial stakes → +60 percentage points goal completion.

---

*Built by Team Antichrist.exe for SNUC Hacks 2026 — Track 1: Social Tech*
