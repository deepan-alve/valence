# Backend Stack & Systems

---

## 1. Stack

| Layer | Technology | Why |
|---|---|---|
| **Language** | TypeScript | Single language across frontend (Dart/Flutter) and backend. Type safety catches bugs before runtime. |
| **Framework** | Hono | Modern Express successor. Built-in JWT, CORS, validation, WebSocket. Native TypeScript. 4x faster than Express. Same routing mental model so zero learning curve. |
| **ORM** | Drizzle | Pure TypeScript, no binary engine (unlike Prisma's Rust binary). Schema defined in TypeScript, not a separate DSL. SQL-like query syntax gives full control for complex queries (group streak N-1 threshold, tier-scoped leaderboards, metric threshold matching). |
| **Database** | PostgreSQL 16 | Deeply relational data — users → habits → streaks → freezes → groups → group streaks. ACID transactions for concurrent freeze-sharing. Foreign keys and UNIQUE constraints enforce business rules at the DB level. |
| **Cache & PubSub** | Redis 7 | Three roles: (1) Cache for leaderboard data and LLM responses. (2) Pub/sub for real-time notification delivery. (3) Backing store for BullMQ job queue. One dependency, three use cases. |
| **Job Queue** | BullMQ | TypeScript-native job queue (Redis-backed). Handles midnight streak evaluation with exactly-once processing and automatic retries. Manages integration polling across 8+ APIs × N users with per-job failure isolation. Cron scheduling for recurring jobs. |
| **Auth** | Firebase Auth | Flutter SDK handles entire login flow (Google, Apple, email) in 10 lines. Backend just verifies JWT tokens in middleware. Zero time spent on auth UI or token management. |
| **LLM** | Google Gemini API | Free tier (15 req/min). Two use cases: sub-habit generation ("Run a marathon" → 5 actionable steps) and effort classification (light/moderate/intense). Simple structured output, doesn't need frontier-model reasoning. |
| **Deploy** | Docker Compose on VPS | Single `docker-compose up` runs PostgreSQL, Redis, API server, and BullMQ worker. Full control — no cold starts, no free tier limits, no surprise billing. Integration poller runs 24/7 without serverless timeout constraints. |

---

## 2. Open Integration Protocol (Valence Connectors)

### What It Is

An open, community-extensible system for automatic habit tracking. Valence defines a standard data format (the **Metric Event spec**). Anyone — our team, third-party developers, or users with scripts — can build a **connector** that fetches activity data from any service and sends it to Valence in that format. Valence handles the rest: matching metrics against habit thresholds, auto-completing habits, updating streaks.

The integration module is designed to be open-sourced separately. As the community grows, the number of supported services grows — without any changes to Valence core.

### How It Works

```
┌──────────────┐      ┌───────────────────┐      ┌──────────────────┐
│  Third-Party │ ───> │ Valence Connector  │ ───> │  Valence Server  │
│  Service     │      │                   │      │                  │
│  (Strava,    │      │  Fetches activity  │      │  Receives Metric │
│   LeetCode,  │      │  data, transforms  │      │  Event, matches  │
│   WakaTime)  │      │  to Metric Event   │      │  against habit   │
│              │      │  format            │      │  thresholds,     │
└──────────────┘      └───────────────────┘      │  auto-completes  │
                                                  └──────────────────┘
```

### The Metric Event Spec

Every connector, official or community-built, sends data in this format:

```json
{
  "source": "wakatime",
  "source_version": "1.2.0",
  "metrics": [
    {
      "type": "duration",
      "category": "coding",
      "value": 145,
      "unit": "minutes",
      "metadata": {
        "project": "valence-api",
        "language": "typescript"
      },
      "timestamp": "2026-03-25T18:30:00Z",
      "date": "2026-03-25"
    }
  ]
}
```

### Metric Types

Every activity in the world fits into one of four types:

| Type | Unit | Covers |
|---|---|---|
| `duration` | minutes | Coding time, meditation, exercise, sleep, reading, listening |
| `count` | count | Problems solved, commits, lessons completed, pages read, tasks done |
| `distance` | km or miles | Running, cycling, swimming, walking |
| `boolean` | true/false | Did you journal?, took meds?, maintained streak? |

### Connector Interface

Every connector implements this contract:

```typescript
interface ValenceConnector {
  id: string                    // "wakatime", "leetcode", "strava"
  name: string                  // "WakaTime"
  version: string               // "1.0.0"
  authType: 'api_key' | 'oauth2' | 'public_profile' | 'webhook'
  availableMetrics: MetricDefinition[]

  connect(credentials: ConnectorCredentials): Promise<{ valid: boolean }>
  fetchMetrics(credentials: ConnectorCredentials, date: string): Promise<MetricEvent[]>
}
```

### Habit-to-Metric Mapping

Users map their habits to specific metrics with a threshold:

```
"Code 2 hours"       → wakatime   / duration:coding          / ≥ 120 min
"Solve 3 problems"   → leetcode   / count:problems_solved    / ≥ 3
"Run 5km"            → strava     / distance:running         / ≥ 5 km
"Complete a lesson"  → duolingo   / count:lessons_completed  / ≥ 1
"10,000 steps"       → google_fit / count:steps              / ≥ 10000
"Commit daily"       → github     / boolean:contributed_today / = true
"Solve a puzzle"     → chess_com  / count:puzzles_solved     / ≥ 1
"Clear 5 tasks"      → todoist    / count:tasks_completed    / ≥ 5
"Don't oversleep"    → google_fit / duration:sleep           / ≤ 540 min
```

When Valence receives a Metric Event, it checks all mappings for that user and connector. If the threshold is met and no log exists for that day, the habit is auto-completed.

### How Connectors Run

| Mode | Description | Used by |
|---|---|---|
| **Server-polled** | BullMQ job polls the connector every 15 min | WakaTime, LeetCode, Duolingo, Google Fit, GitHub, Chess.com, Todoist |
| **Webhook-push** | Third-party sends events to Valence directly | Strava (native webhook support) |
| **On-device** | Flutter app reads local data, POSTs Metric Events | Apple Health (HealthKit data never leaves phone) |
| **User-triggered** | Manual POST via IFTTT, Zapier, Shortcuts, or custom scripts | Any custom integration |

### Built-in Connectors

#### Ships at Launch (8 backend + 1 Flutter-side)

| Connector | Auth | Key Metrics | API |
|---|---|---|---|
| **WakaTime** | API key | `duration:coding`, `duration:coding_by_project` | REST — `/api/v1/users/current/summaries` |
| **LeetCode** | Public profile (username) | `count:problems_solved`, `count:problems_by_difficulty` | GraphQL — `leetcode.com/graphql` |
| **Strava** | OAuth2 | `distance:running`, `distance:cycling`, `duration:exercise` | REST + webhook subscription |
| **Duolingo** | Public profile (username) | `count:lessons_completed`, `boolean:streak_maintained` | Unofficial REST |
| **Google Fit** | OAuth2 (Google) | `count:steps`, `distance:walking`, `duration:exercise`, `duration:sleep` | Google Fit REST — `dataset:aggregate` |
| **GitHub** | Public profile / OAuth2 | `count:commits`, `count:prs`, `boolean:contributed_today` | REST + GraphQL (contribution graph) |
| **Chess.com** | Public profile (username) | `count:games_played`, `count:puzzles_solved` | REST — `api.chess.com/pub/player/{username}` |
| **Todoist** | OAuth2 | `count:tasks_completed`, `boolean:inbox_zero` | REST — `api.todoist.com/rest/v2` |
| **Apple Health** | On-device HealthKit | `count:steps`, `duration:exercise`, `duration:sleep` | Flutter `health` package → POST to webhook |

#### Post-Launch (designed, documented, ready to build)

| Connector | Auth | Key Metrics | Use Case |
|---|---|---|---|
| **Fitbit** | OAuth2 | `count:steps`, `duration:sleep`, `duration:exercise` | Large wearable user base |
| **Spotify** | OAuth2 | `duration:listening`, `duration:podcast` | "Listen to 1hr podcasts", "Practice guitar" |
| **Goodreads** | OAuth2 | `count:pages_read`, `count:books_finished` | "Read 30 pages daily" |
| **RescueTime** | API key | `duration:productive_time`, `duration:distraction_time` | Negative habits: "< 1hr social media" |
| **Oura Ring** | OAuth2 | `duration:sleep`, `count:readiness_score` | Premium health tracking |

### Connector Registry

A JSON file that lists all known connectors with metadata. The Flutter app reads this to display the integration marketplace:

```json
{
  "connectors": [
    {
      "id": "wakatime",
      "name": "WakaTime",
      "icon": "wakatime.svg",
      "author": "valence-team",
      "official": true,
      "auth_type": "api_key",
      "auth_fields": [
        { "key": "api_key", "label": "WakaTime API Key", "type": "password" }
      ],
      "metrics": [
        { "type": "duration", "category": "coding", "unit": "minutes", "description": "Total daily coding time" }
      ],
      "setup_url": "https://wakatime.com/settings/api-key"
    },
    {
      "id": "leetcode",
      "name": "LeetCode",
      "icon": "leetcode.svg",
      "author": "valence-team",
      "official": true,
      "auth_type": "public_profile",
      "auth_fields": [
        { "key": "username", "label": "LeetCode Username", "type": "text" }
      ],
      "metrics": [
        { "type": "count", "category": "problems_solved", "unit": "count", "description": "Problems solved today" }
      ]
    }
  ]
}
```

### Open-Source Module

The connector system ships as a separate repository:

```
valence-connectors/
├── README.md                    # "Build a Valence connector in 30 minutes"
├── LICENSE                      # MIT
├── protocol/
│   ├── spec.md                  # The Metric Event specification
│   ├── metric-event.schema.json # JSON Schema for validation
│   └── examples/                # Example payloads per connector type
├── sdk/
│   └── typescript/
│       ├── types.ts             # MetricEvent, ConnectorCredentials, HabitMapping
│       ├── connector.ts         # Base ValenceConnector class
│       ├── validator.ts         # Validate Metric Events against JSON Schema
│       └── client.ts            # HTTP client for posting to Valence webhook
├── connectors/
│   ├── wakatime/
│   ├── leetcode/
│   ├── strava/
│   ├── duolingo/
│   ├── google-fit/
│   ├── github/
│   ├── chess-com/
│   └── todoist/
├── templates/
│   └── new-connector/           # Scaffold for community developers
└── registry.json                # Index of all known connectors
```

A community developer building a new connector (e.g., Goodreads) implements the `ValenceConnector` interface, tests it against the JSON Schema, and submits a PR. The SDK handles auth token management, retry logic, and posting to Valence's webhook.

---

## 3. Progression System & Unlockables

### Two-Currency Economy

| | XP | Sparks |
|---|---|---|
| **What it is** | Lifetime progress score | Spendable in-app currency |
| **Earned from** | Completing habits, streaks, group milestones | Same actions, same amounts |
| **Goes down?** | Never | Yes, when spent |
| **Determines** | Your Rank (Bronze → Diamond) | What you can purchase |
| **Visible to** | Everyone (shown on profile) | Only you |

Completing a moderate habit gives you **+10 XP** (permanent, counts toward rank) and **+10 Sparks** (spendable on items).

### Earning XP & Sparks

| Action | Amount |
|---|---|
| Complete a light habit | 5 |
| Complete a moderate habit | 10 |
| Complete an intense habit | 20 |
| Perfect day (all habits completed) | 25 bonus |
| 7-day streak milestone | 30 |
| 30-day streak milestone | 100 |
| 100-day streak milestone | 500 |
| Full party completion (all members complete) | 15 (split among members) |
| First habit completion ever | 50 (one-time welcome bonus) |

### Ranks

Ranks are permanent. Once you reach Gold, you're Gold forever. Ranks unlock access to items in the shop — you still spend Sparks to buy them.

| Rank | XP Required |
|---|---|
| **Bronze** | 0 (default) |
| **Silver** | 500 |
| **Gold** | 2,000 |
| **Platinum** | 5,000 |
| **Diamond** | 15,000 |

Ranks are separate from community tiers (Spark/Ember/Flame/Blaze). Tiers reflect current consistency and can go down. Ranks reflect cumulative achievement and never go down.

### What Sparks Can Never Buy

- Streak days (cannot fake progress)
- Rank promotions (earned through XP only)
- Tier promotions (earned through consistency only)
- Social advantages (no pay-to-spam nudges)
- Core features (habit tracking, groups, social feed are always free)

### Unlockable Catalog

#### Themes (full visual overhaul of the app)

| Theme | Sparks | Min Rank | Description |
|---|---|---|---|
| Nocturnal Sanctuary | — | — | Default. Warm amber on deep dark. Cozy lamp-in-a-dark-room. |
| Daybreak | 100 | Bronze | Light mode. Warm whites, soft peach, golden hour. |
| Deep Focus | 100 | Bronze | Near-monochrome. Muted everything. Just habits and numbers. |
| Neon Terminal | 200 | Silver | Black background, green/cyan monospace. Hacker aesthetic. |
| Forest | 200 | Silver | Deep greens, earth tones, organic shapes. |
| Sakura | 200 | Silver | Soft pinks, lavender, cherry blossom. |
| Ocean Depth | 300 | Gold | Deep blues, bioluminescent accents. |
| Platinum Noir | 300 | Platinum | Dark silver, metallic, premium. |
| Diamond Aurora | 300 | Diamond | Northern lights gradient, animated shimmer. |

Each theme changes: color palette, typography weight, shape language, animation intensity, background texture, icon style.

#### App Icons (home screen icon)

| Icon | Sparks | Min Rank |
|---|---|---|
| Minimal (monochrome) | 200 | Silver |
| Neon (glowing) | 200 | Silver |
| Gold (gold-accented) | 200 | Gold |

#### Streak Flame Styles (icon next to streak count)

| Flame | Sparks | Min Rank |
|---|---|---|
| Default (orange) | — | — |
| Blue flame | 50 | Bronze |
| Purple flame | 50 | Bronze |
| Golden flame | 50 | Silver |
| Pixel fire | 50 | Silver |
| Lightning bolt | 50 | Gold |

#### Check Animations (plays when completing a habit)

| Animation | Sparks | Min Rank |
|---|---|---|
| Default (ripple) | — | — |
| Confetti burst | 75 | Bronze |
| Sakura petals | 75 | Silver |
| Pixel explosion | 75 | Silver |
| Lightning strike | 75 | Gold |
| Water splash | 75 | Bronze |

#### Habit Card Styles (visual style of habit cards on home screen)

| Style | Sparks | Min Rank |
|---|---|---|
| Default (solid) | — | — |
| Glassmorphic | 100 | Silver |
| Neon glow border | 100 | Gold |
| Textured paper | 100 | Silver |

#### Font Packs (change the app's body font)

| Font | Sparks | Min Rank |
|---|---|---|
| Default (Plus Jakarta Sans) | — | — |
| Monospace | 150 | Silver |
| Handwritten | 150 | Silver |
| Serif | 150 | Gold |

#### Background Patterns (subtle texture behind habit list)

| Pattern | Sparks | Min Rank |
|---|---|---|
| None | — | — |
| Dots | 50 | Bronze |
| Grid | 50 | Bronze |
| Waves | 50 | Silver |
| Topographic | 50 | Silver |

#### Profile Frames (ring around avatar, visible to everyone)

| Frame | Sparks | Min Rank |
|---|---|---|
| Bronze ring | 150 | Bronze |
| Gold ring | 300 | Gold |
| Flame ring (animated) | 400 | Gold |
| Diamond ring | 500 | Diamond |

#### Profile Banners (illustrated banner on profile page)

| Banner | Sparks | Min Rank |
|---|---|---|
| Mountain | 200 | Silver |
| Ocean | 200 | Silver |
| Cityscape | 200 | Gold |
| Space | 200 | Platinum |

#### Social Customization

| Item | Sparks | Min Rank | Description |
|---|---|---|---|
| Name color in party chat | 250 | Gold | Custom color for your name in group chat. |
| Custom status | Free | Silver | Short text under your name on profile. |
| Celebration style: Fireworks | 100 | Bronze | How YOUR milestones look to friends. |
| Celebration style: Sparkles | 100 | Silver | |
| Celebration style: Aurora | 100 | Gold | |
| Milestone card: Minimalist | 150 | Silver | Design of shareable streak milestone cards. |
| Milestone card: Retro | 150 | Silver | |
| Milestone card: Neon | 150 | Gold | |
| Milestone card: Watercolor | 150 | Gold | |
| Party badge: Coffee | 75 | Bronze | Small icon next to name in party. |
| Party badge: Crown | 75 | Silver | |
| Party badge: Sword | 75 | Silver | |
| Party badge: Rocket | 75 | Gold | |

#### Completion Sounds (plays on habit check-off)

| Sound | Sparks | Min Rank |
|---|---|---|
| Default (chime) | — | — |
| Coin collect | 50 | Bronze |
| Level up | 50 | Bronze |
| Typewriter click | 50 | Silver |
| Sword slash | 50 | Silver |
| Zen bell | 50 | Bronze |
| Custom notification tone | 75 | Silver |

#### Freeze Animations (plays when a freeze saves your streak)

| Animation | Sparks | Min Rank |
|---|---|---|
| Default | — | — |
| Ice crystal | 100 | Silver |
| Shield bubble | 100 | Silver |
| Time rewind | 100 | Gold |
| Angel wings | 100 | Gold |

#### End-of-Day Summary Styles (visual style of daily recap)

| Style | Sparks | Min Rank |
|---|---|---|
| Default | — | — |
| Newspaper headline | 150 | Silver |
| Game stats screen | 150 | Silver |
| Receipt | 150 | Gold |

#### Party Entrance Animations (your avatar's entrance in party view)

| Animation | Sparks | Min Rank |
|---|---|---|
| Default (none) | — | — |
| Drop from top | 75 | Bronze |
| Teleport | 75 | Silver |
| Flame entrance | 75 | Gold |

#### Quality of Life Unlocks

| Item | Sparks | Min Rank | Description |
|---|---|---|---|
| Habit categories/folders | Free | Silver | Organize habits into custom groups. |
| Custom reminder messages | Free | Gold | Write your own notification text. |
| Data export (CSV/JSON) | Free | Silver | Export all habit history. |
| Multi-day freeze pack (3 days) | 200 | Gold | For vacations. Three freezes at once. |
| Secret habit mode | 100 | Silver | Habit invisible to ALL social context — not even percentage or streak visible to anyone. |
| Full emoji picker for habits | 50 | Bronze | Use any emoji as habit icon (default is limited set). |

#### Seasonal / Limited-Time Items

| Type | How to get | Description |
|---|---|---|
| Seasonal themes | Available only during season, purchased with Sparks | New Year's gold, Summer sunset, Halloween dark, Diwali lights. Gone when season ends. |
| Event badges | Complete a time-limited challenge | "Hackathon Survivor", "New Year Grinder", "100 Days of Code". |
| Collab themes | Special partnerships | Spotify green theme, GitHub dark theme. |
