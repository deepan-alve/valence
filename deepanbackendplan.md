# Valence Backend — 1-Day Build Plan

## Context

Building the backend for Valence (group-first social habit app) in a single hackathon day with 4 devs. Frontend is Flutter (separate work). Backend needs to be fully functional for demo day.

## Stack

| Component | Choice |
|---|---|
| Framework | **Hono** (TypeScript) |
| ORM | **Drizzle** (PostgreSQL) |
| Database | **PostgreSQL 16** |
| Cache/PubSub | **Redis 7** |
| Job Queue | **BullMQ** (TypeScript Celery equivalent) |
| Auth | **Firebase Auth** (Flutter SDK → JWT → backend verifies) |
| LLM | **Google Gemini API** |
| Deploy | **Docker Compose** on own VPS |

## Project Structure

```
server/
├── docker-compose.yml
├── Dockerfile
├── package.json / tsconfig.json / drizzle.config.ts
├── .env.example
├── src/
│   ├── index.ts                 # Hono app entry
│   ├── worker.ts                # BullMQ worker entry
│   ├── db/
│   │   ├── client.ts            # Drizzle + pg pool
│   │   ├── schema.ts            # Re-exports all schema
│   │   └── schema/
│   │       ├── enums.ts
│   │       ├── users.ts
│   │       ├── habits.ts
│   │       ├── habit-logs.ts
│   │       ├── streaks.ts
│   │       ├── friendships.ts
│   │       ├── groups.ts
│   │       ├── group-members.ts
│   │       ├── group-streaks.ts
│   │       ├── group-daily-logs.ts
│   │       ├── feed-items.ts
│   │       ├── notifications.ts
│   │       └── relations.ts
│   ├── routes/
│   │   ├── auth.ts
│   │   ├── habits.ts
│   │   ├── social.ts
│   │   ├── groups.ts
│   │   ├── feed.ts
│   │   ├── notifications.ts
│   │   ├── llm.ts
│   │   └── integrations.ts
│   ├── services/
│   │   ├── streak.service.ts
│   │   ├── group-streak.service.ts
│   │   ├── points.service.ts
│   │   ├── feed.service.ts
│   │   ├── notification.service.ts
│   │   ├── llm.service.ts
│   │   └── integration.service.ts
│   ├── middleware/
│   │   ├── auth.ts              # Firebase JWT verify
│   │   └── error-handler.ts
│   ├── jobs/
│   │   ├── queues.ts            # BullMQ queue defs
│   │   ├── streak-evaluator.ts  # Midnight: eval streaks + auto-freeze
│   │   ├── group-evaluator.ts   # After streaks: N-1 threshold
│   │   ├── notification-sender.ts
│   │   └── integration-poller.ts
│   ├── lib/
│   │   ├── firebase.ts
│   │   ├── redis.ts
│   │   ├── gemini.ts
│   │   └── response.ts          # ok(), error(), paginated() helpers
│   └── types/
│       └── index.ts             # Zod schemas + TS types
```

Single Dockerfile, both `api` and `worker` use the same image with different `command` overrides.

---

## Scope: Build vs Cut

### BUILD (Demo Day)

| Feature | Owner |
|---|---|
| Auth (Firebase JWT verify + user CRUD) | Dev 1 |
| Habit CRUD (positive + negative, effort field) | Dev 2 |
| Habit completion + skip (with cue logging) | Dev 2 |
| Streak tracking (current, longest, total) | Dev 2 |
| Streak freeze (auto-apply, buy with points, friend share) | Dev 2 |
| Sub-habit CRUD + Gemini generation | Dev 2 + Dev 4 |
| Points (award on completion, spend on freezes) | Dev 2 |
| Friends (request, accept, reject, list) | Dev 3 |
| Nudge + Congratulate | Dev 3 |
| Social feed (celebrations only, chronological) | Dev 3 |
| Groups/Parties (CRUD, join via invite code, leave) | Dev 3 |
| Group streak (N-1 threshold evaluation) | Dev 3 |
| Notifications (store + list via REST) | Dev 3 |
| Gemini: sub-habit generation + effort classification | Dev 4 |
| WakaTime integration (API key auth + polling) | Dev 4 |
| BullMQ jobs (streak eval, group eval, integration poll) | Dev 2 + Dev 3 + Dev 4 |
| Docker Compose + deployment | Dev 1 |

### CUT (Not for demo day)

- Tiered communities (Spark/Ember/Flame/Blaze) — needs sustained data
- Leaderboard — needs tier system + enough users
- Weekly/Monthly lookback reports — nice but not core
- LLM failure tips — sub-habit generation is the better demo
- Reward pool / spin mechanic — points balance is enough
- Achievements system — no time for unlock detection logic
- Push notifications (FCM) — store in DB, serve via REST
- WebSocket real-time — REST polling is fine for demo
- Party damage system (hardcore mode) — cosmetic, skip
- Rate limiting — not needed for demo
- Google Fit integration — WakaTime is simpler + more relevant for dev audience

---

## Dev Assignments (4 Devs, 12 Hours)

### Dev 1: Foundation (THE BLOCKER)

Everyone is blocked until Dev 1 delivers schema + auth by **Hour 3**.

| Hours | Task |
|---|---|
| H0-H1 | Project scaffold: npm init, install deps, tsconfig, drizzle.config, docker-compose, Dockerfile, .env.example |
| H1-H3 | ALL Drizzle schema files + enums + relations. Run `drizzle-kit push`. Auth middleware (Firebase JWT verify). Auth routes (register, login, me). Response helpers. Dev bypass header for testing. |
| H3-H5 | BullMQ queue definitions + worker bootstrap. Verify `docker-compose up` brings up all 4 services (postgres, redis, api, worker). |
| H5-H6 | Pre-wire all route mounts in `index.ts` (so other devs just fill in handlers, no merge conflicts). |
| H6-H8 | Seed data script (demo users, habits, streaks). Help unblock others. |
| H8-H12 | Deploy to VPS. Docker Compose production tuning. Integration testing. |

**Critical:** Push partial schema (users + habits + streaks) by H2 so Dev 2 can start early.

### Dev 2: Habits + Streaks + Points (THE ENGINE)

| Hours | Task |
|---|---|
| H0-H3 | **(Pre-work, no DB needed)** Write Zod validation schemas for all habit request bodies. Write TypeScript types. Pseudocode streak calculation. |
| H3-H5 | Habit CRUD routes: GET/POST/PUT/DELETE `/habits`, GET `/habits/:id` |
| H5-H7 | Completion + skip: POST `/habits/:id/complete`, POST `/habits/:id/skip`, GET `/habits/:id/logs`, GET `/habits/:id/streak` |
| H7-H8 | `streak.service.ts` — core logic. `points.service.ts` — award on completion. |
| H8-H9 | Sub-habit CRUD: GET/POST/PUT/DELETE `/habits/:id/subhabits` |
| H9-H10 | Freeze logic: buy with points, friend share. `streak-evaluator.ts` BullMQ midnight job. |
| H10-H12 | Test all flows. Edge cases. |

### Dev 3: Social + Groups (THE GLUE)

| Hours | Task |
|---|---|
| H0-H3 | **(Pre-work)** Design feed generation logic. Zod schemas. Map N-1 threshold algorithm. |
| H3-H5 | Friends: GET/POST/DELETE `/friends`, accept/reject. |
| H5-H7 | Nudge + Congratulate routes. `feed.service.ts`. GET `/feed`. |
| H7-H9 | Groups: full CRUD, join via invite code (nanoid 8 chars), leave. |
| H9-H11 | `group-streak.service.ts` — N-1 threshold. Group daily status. Group feed. `group-evaluator.ts` BullMQ job. Notifications routes. |
| H11-H12 | Test group streak scenarios. |

### Dev 4: LLM + Integration (THE SPARKLE)

| Hours | Task |
|---|---|
| H0-H3 | **(Pre-work, no server needed)** Write and test Gemini prompts locally. Set up WakaTime dev account. Understand WakaTime API. |
| H3-H5 | `gemini.ts` client wrapper. `llm.service.ts`: generateSubHabits(), classifyEffort(). LLM routes. |
| H5-H6 | Wire sub-habit generation into POST `/habits/:id/subhabits/generate`. |
| H6-H8 | WakaTime integration: connect (API key auth), disconnect, manual sync. |
| H8-H10 | `integration-poller.ts` BullMQ repeatable job (every 15 min). `notification-sender.ts` job. |
| H10-H12 | Polish Gemini prompts. Test WakaTime e2e. Bug fixes. |

### Merge Conflict Prevention

Each dev owns distinct files. The only shared file is `src/index.ts` — Dev 1 pre-wires all route mounts early:

```typescript
import { authRoutes } from './routes/auth'       // Dev 1
import { habitRoutes } from './routes/habits'     // Dev 2
import { socialRoutes } from './routes/social'    // Dev 3
import { groupRoutes } from './routes/groups'     // Dev 3
import { feedRoutes } from './routes/feed'        // Dev 3
import { llmRoutes } from './routes/llm'          // Dev 4
import { integrationRoutes } from './routes/integrations' // Dev 4

app.route('/api/v1', authRoutes)
app.route('/api/v1', habitRoutes)
app.route('/api/v1', socialRoutes)
app.route('/api/v1', groupRoutes)
app.route('/api/v1', feedRoutes)
app.route('/api/v1', llmRoutes)
app.route('/api/v1', integrationRoutes)
```

Each dev fills in their own route file. Zero conflicts.

---

## Key Business Logic

### Streak Calculation (on habit completion)

```
1. UPSERT habit_log: (habit_id, today, status='completed')
2. Load streak for this habit
3. If last_completed_date == yesterday → current_streak += 1
   If last_completed_date == today → no-op (already counted)
   Else → current_streak = 1 (fresh start)
4. total_completed += 1
5. longest_streak = max(longest, current)
6. last_completed_date = today
7. Award points: light=5, moderate=10, intense=20
8. If current_streak ∈ {7,14,30,60,100,365} → milestone bonus + feed item
```

### Midnight Job (streak-evaluator)

```
For each active habit:
  If no completed/frozen log for today:
    If freezes_available > 0 → auto-freeze, decrement freezes
    Else → current_streak = 0
  For negative habits: no log = success → auto-complete + increment streak
```

### Group Streak — N-1 Threshold

```
For each group:
  N = member count
  completed = members with ≥1 completed habit today

  If completed == N → outcome=reward, streak++, bonus points
  If completed == N-1 → outcome=maintain, streak++
  If completed < N-1 → outcome=reset, streak=0

  Update longest_streak. Log to group_daily_logs.
  Milestone check → feed items for all members.
```

### Freeze Sharing

```
1. Verify caller owns the source habit + has freezes > 0
2. Verify friendship exists (status=accepted)
3. Verify friend's habit has freezes < 2
4. Decrement caller's freezes, increment friend's freezes
5. Create feed item + notification
```

### Points

```
Award: light=5, moderate=10, intense=20 per completion
Milestones: 7d=15pts, 30d=50pts, 100d=200pts
Spend: freeze costs 50pts
Never lose points. total_points only goes up. available_points goes down on spend.
```

---

## Dependencies

```json
{
  "dependencies": {
    "hono": "^4.x",
    "@hono/node-server": "^1.x",
    "drizzle-orm": "^0.30.x",
    "pg": "^8.x",
    "firebase-admin": "^12.x",
    "ioredis": "^5.x",
    "bullmq": "^5.x",
    "@google/generative-ai": "^0.x",
    "zod": "^3.x",
    "nanoid": "^5.x",
    "dotenv": "^16.x"
  },
  "devDependencies": {
    "typescript": "^5.x",
    "drizzle-kit": "^0.21.x",
    "@types/pg": "^8.x",
    "@types/node": "^20.x",
    "tsx": "^4.x"
  }
}
```

Dev: `tsx watch src/index.ts`. Prod: `tsc` build → `node dist/index.js`.

---

## Verification

### Smoke Test Script

A bash script (`test/smoke.sh`) that:
1. Register 3 users (Alice, Bob, Charlie)
2. Alice creates 2 habits (positive + negative)
3. Alice completes positive habit → verify streak=1, points awarded
4. Bob sends friend request → Alice accepts
5. Bob nudges Alice → verify feed item created
6. All three create a group
7. Alice + Bob complete a habit, Charlie doesn't
8. Trigger group evaluation manually → verify outcome=maintain (2/3 ≥ N-1=2)
9. Verify feed shows nudge + group maintained

### Demo Day Dry Run (H11-H12)

1. Flutter signup → Firebase Auth → backend registration
2. Create "Code 2 hours" with WakaTime integration
3. Create "Morning meditation" manually
4. "Break into steps" → Gemini generates sub-habits
5. Complete meditation → streak increments
6. Add friend → nudge them
7. Create party → show group daily status
8. Show social feed with celebrations

---

## Open Integration Protocol (Valence Connectors)

### Vision

The integration system is an **open protocol** — Valence defines the data format, anyone can build a connector. As community grows, the app grows. Only this module is open-source.

### Architecture

```
┌──────────────┐      ┌───────────────────┐      ┌──────────────────┐
│  Third-Party │ ───> │ Valence Connector  │ ───> │  Valence Server  │
│  (Strava,    │      │ (community-built   │      │  Webhook Endpoint│
│   LeetCode)  │      │  or official)      │      │                  │
└──────────────┘      └───────────────────┘      └──────────────────┘
                       Fetches activity,            Receives Metric
                       transforms to                Events, matches
                       Metric Event format          against habits,
                                                    auto-completes
```

### The Metric Event Spec (the contract)

Every connector sends data in this format:

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

| Type | Unit | Examples |
|---|---|---|
| `duration` | minutes | Coding, meditation, exercise, sleep, reading |
| `count` | count | LeetCode problems, commits, lessons, pages |
| `distance` | km / miles | Running, cycling, swimming, walking |
| `boolean` | true/false | Journaled today?, took meds? |

### Connector Interface

```typescript
interface ValenceConnector {
  id: string
  name: string
  version: string
  authType: 'api_key' | 'oauth2' | 'public_profile' | 'webhook'
  availableMetrics: MetricDefinition[]
  connect(credentials: ConnectorCredentials): Promise<{ valid: boolean }>
  fetchMetrics(credentials: ConnectorCredentials, date: string): Promise<MetricEvent[]>
}

interface HabitMapping {
  habitId: string
  connectorId: string
  metricType: string
  metricCategory: string
  operator: 'gte' | 'lte' | 'eq'
  threshold: number
}
```

### Threshold Matching Engine

When a Metric Event arrives:
1. Look up all HabitMappings for this user + connector
2. For each mapping, check: `metric.value <operator> threshold`
3. If met → auto-complete the habit (create HabitLog, run streak logic)
4. If already completed today → no-op

Example mappings:
```
"Code 2 hours"     → wakatime  / duration:coding          / gte 120
"Solve 2 problems" → leetcode  / count:problems_solved    / gte 2
"Run 5km"          → strava    / distance:running         / gte 5
"Don't oversleep"  → google_fit / duration:sleep           / lte 540
```

### How Connectors Run

| Mode | Description | Used by |
|---|---|---|
| Server-polled | BullMQ job polls every 15 min | WakaTime, LeetCode, Duolingo, Google Fit |
| Webhook-push | Third-party pushes to Valence | Strava |
| On-device | Flutter reads local data, sends Metric Events | Apple Health (Flutter-side) |
| User-triggered | Manual POST / IFTTT / Zapier | Custom integrations |

### Built-in Connectors

#### Demo Day (8 backend + 1 Flutter-side)

| # | Connector | Auth | Key Metrics | API | Run Mode |
|---|---|---|---|---|---|
| 1 | **WakaTime** | API key | `duration:coding`, `duration:coding_by_project` | REST `GET /api/v1/users/current/summaries` | Server-polled |
| 2 | **LeetCode** | Public profile (username) | `count:problems_solved`, `count:problems_by_difficulty` | GraphQL `leetcode.com/graphql` | Server-polled |
| 3 | **Strava** | OAuth2 | `distance:running`, `distance:cycling`, `duration:exercise` | REST + webhook subscription | Webhook-push + polling fallback |
| 4 | **Duolingo** | Public profile (username) | `count:lessons_completed`, `boolean:streak_maintained` | Unofficial REST | Server-polled |
| 5 | **Google Fit** | OAuth2 (Google) | `count:steps`, `distance:walking`, `duration:exercise`, `duration:sleep` | Google Fit REST `dataset:aggregate` | Server-polled |
| 6 | **GitHub** | Public profile / OAuth2 | `count:commits`, `count:prs`, `boolean:contributed_today` | REST + GraphQL (contribution graph) | Server-polled |
| 7 | **Chess.com** | Public profile (username) | `count:games_played`, `count:puzzles_solved`, `count:rating_change` | REST `api.chess.com/pub/player/{username}` | Server-polled |
| 8 | **Todoist** | OAuth2 | `count:tasks_completed`, `boolean:inbox_zero` | REST `api.todoist.com/rest/v2` | Server-polled |
| 9 | **Apple Health** | On-device HealthKit | `count:steps`, `duration:exercise`, `duration:sleep`, `duration:mindfulness` | Flutter `health` package → POST to webhook | On-device (Flutter) |

**Nike Run Club:** No public API. Users sync Nike → Strava, then Strava connector covers them.

#### Post-Hackathon (5 more, designed + documented)

| # | Connector | Auth | Key Metrics | API | Notes |
|---|---|---|---|---|---|
| 10 | **Fitbit** | OAuth2 | `count:steps`, `duration:sleep`, `duration:exercise`, `count:heart_rate` | Fitbit Web API | Overlaps Google Fit but large user base |
| 11 | **Spotify** | OAuth2 | `duration:listening`, `duration:podcast`, `count:tracks_played` | Spotify Web API | "Listen to 1hr podcasts", "Practice guitar" |
| 12 | **Goodreads** | OAuth2 | `count:pages_read`, `count:books_finished` | Goodreads API | "Read 30 pages daily" |
| 13 | **RescueTime** | API key | `duration:productive_time`, `duration:distraction_time`, `count:app_switches` | RescueTime API | Gold for negative habits: "< 1hr social media" |
| 14 | **Oura Ring** | OAuth2 | `duration:sleep`, `count:sleep_score`, `count:readiness_score`, `duration:activity` | Oura Cloud API | Premium health tracking crowd |

### Connector Registry

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
      "auth_fields": [{ "key": "api_key", "label": "WakaTime API Key", "type": "password" }],
      "metrics": [
        { "type": "duration", "category": "coding", "unit": "minutes", "description": "Total daily coding time" }
      ],
      "setup_url": "https://wakatime.com/settings/api-key"
    }
  ]
}
```

### API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/integrations/registry` | List all available connectors |
| POST | `/integrations/:connectorId/connect` | Connect (validate + store credentials) |
| DELETE | `/integrations/:connectorId` | Disconnect |
| GET | `/integrations/:connectorId/status` | Sync status |
| POST | `/integrations/:connectorId/sync` | Force manual sync |
| POST | `/integrations/:connectorId/mappings` | Create habit→metric mapping |
| GET | `/integrations/:connectorId/mappings` | List mappings |
| DELETE | `/integrations/:connectorId/mappings/:id` | Remove mapping |
| POST | `/webhooks/:userToken/metrics` | Generic webhook receiver |
| POST | `/webhooks/strava` | Strava webhook receiver |

### DB Schema Additions

```typescript
// Connector credentials per user
export const integrationConnections = pgTable('integration_connections', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').references(() => users.id),
  connectorId: varchar('connector_id', { length: 50 }),
  credentials: jsonb('credentials'),
  status: integrationStatusEnum('status').default('active'),
  lastSyncedAt: timestamp('last_synced_at'),
  lastError: text('last_error'),
  createdAt: timestamp('created_at').defaultNow(),
})

// Habit→metric mappings
export const habitMappings = pgTable('habit_mappings', {
  id: uuid('id').primaryKey().defaultRandom(),
  habitId: uuid('habit_id').references(() => habits.id),
  userId: uuid('user_id').references(() => users.id),
  connectorId: varchar('connector_id', { length: 50 }),
  metricType: varchar('metric_type', { length: 20 }),
  metricCategory: varchar('metric_category', { length: 50 }),
  operator: varchar('operator', { length: 5 }),
  threshold: real('threshold'),
  createdAt: timestamp('created_at').defaultNow(),
})

// Per-user webhook tokens
export const webhookTokens = pgTable('webhook_tokens', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').references(() => users.id),
  token: varchar('token', { length: 64 }).unique(),
  isActive: boolean('is_active').default(true),
  createdAt: timestamp('created_at').defaultNow(),
})
```

### Open-Source Module Structure

```
valence-connectors/              # Separate repo, MIT license
├── README.md                    # "Build a Valence connector in 30 min"
├── protocol/
│   ├── spec.md                  # The Metric Event specification
│   ├── metric-event.schema.json # JSON Schema for validation
│   └── examples/
├── sdk/
│   └── typescript/              # @valence/connector-sdk
│       ├── types.ts
│       ├── connector.ts         # Base ValenceConnector class
│       ├── validator.ts
│       └── client.ts            # HTTP client for Valence webhook
├── connectors/
│   ├── wakatime/
│   ├── leetcode/
│   ├── strava/
│   ├── duolingo/
│   └── google-fit/
├── templates/
│   └── new-connector/           # Scaffold for community devs
└── registry.json
```

---

## Progression System & Unlockables

### Two-Currency System

| | XP | Sparks |
|---|---|---|
| **Purpose** | Lifetime progress, determines Rank | Spendable currency |
| **Earned by** | Same actions | Same actions (mirrored) |
| **Goes down?** | Never | Yes (when spent) |
| **Determines** | Rank (Bronze→Diamond) | What you can buy |
| **Visible to** | Everyone (on profile) | Only you |

When you complete a moderate habit: **+10 XP** (permanent) AND **+10 Sparks** (spendable).

### Earning

| Action | XP / Sparks |
|---|---|
| Complete a light habit | 5 |
| Complete a moderate habit | 10 |
| Complete an intense habit | 20 |
| Perfect day (all habits done) | 25 bonus |
| 7-day streak milestone | 30 |
| 30-day streak milestone | 100 |
| 100-day streak milestone | 500 |
| Full party completion (all members) | 15 (split) |
| First habit ever | 50 (welcome bonus) |

### Ranks

| Rank | XP Required | What unlocks (available to BUY with Sparks) |
|---|---|---|
| **Bronze** | 0 | Default theme, basic check animation, default streak flame |
| **Silver** | 500 | Custom status, habit categories/folders, data export, 2 new themes |
| **Gold** | 2,000 | Custom reminder messages, premium themes, party chat name colors, animated streak counter |
| **Platinum** | 5,000 | Exclusive "Platinum Noir" theme, profile frames, early access to new connectors |
| **Diamond** | 15,000 | Exclusive "Diamond Aurora" theme, animated profile badge, unlimited parties |

**Ranks NEVER go down.** Separate from community tiers (Spark/Ember/Flame/Blaze) which reflect current performance.

### Unlockable Items — Full Catalog

#### Cosmetic / Visual

| Item | Cost | Min Rank | Description |
|---|---|---|---|
| Theme: Daybreak | 100 | Bronze | Light mode. Warm whites, soft peach, golden hour. |
| Theme: Deep Focus | 100 | Bronze | Near-monochrome. Muted everything. Just habits and numbers. |
| Theme: Neon Terminal | 200 | Silver | Black + green/cyan monospace. Hacker aesthetic. |
| Theme: Forest | 200 | Silver | Deep greens, earth tones, organic. |
| Theme: Sakura | 200 | Silver | Soft pinks, lavender, cherry blossom. |
| Theme: Ocean Depth | 300 | Gold | Deep blues, bioluminescent accents. |
| Theme: Platinum Noir | 300 | Platinum | Dark silver, metallic, premium feel. |
| Theme: Diamond Aurora | 300 | Diamond | Northern lights gradient, animated subtle shimmer. |
| App icon: Minimal | 200 | Silver | Clean, monochrome app icon for home screen. |
| App icon: Neon | 200 | Silver | Glowing neon variant. |
| App icon: Gold | 200 | Gold | Gold-accented icon. |
| Streak flame: Blue flame | 50 | Bronze | |
| Streak flame: Purple flame | 50 | Bronze | |
| Streak flame: Golden flame | 50 | Silver | |
| Streak flame: Pixel fire | 50 | Silver | |
| Streak flame: Lightning bolt | 50 | Gold | |
| Check animation: Confetti burst | 75 | Bronze | |
| Check animation: Sakura petals | 75 | Silver | |
| Check animation: Pixel explosion | 75 | Silver | |
| Check animation: Lightning strike | 75 | Gold | |
| Check animation: Water splash | 75 | Bronze | |
| Habit card style: Glassmorphic | 100 | Silver | |
| Habit card style: Neon glow border | 100 | Gold | |
| Habit card style: Textured paper | 100 | Silver | |
| Font pack: Monospace | 150 | Silver | |
| Font pack: Handwritten | 150 | Silver | |
| Font pack: Serif | 150 | Gold | |
| Background: Dots | 50 | Bronze | |
| Background: Grid | 50 | Bronze | |
| Background: Waves | 50 | Silver | |
| Background: Topographic | 50 | Silver | |

#### Profile & Social Flex

| Item | Cost | Min Rank | Description |
|---|---|---|---|
| Profile frame: Bronze ring | 150 | Bronze | |
| Profile frame: Gold ring | 300 | Gold | |
| Profile frame: Flame ring | 400 | Gold | Animated fire ring around avatar. |
| Profile frame: Diamond ring | 500 | Diamond | |
| Profile banner: Mountain | 200 | Silver | Illustrated banner on profile page. |
| Profile banner: Ocean | 200 | Silver | |
| Profile banner: Cityscape | 200 | Gold | |
| Profile banner: Space | 200 | Platinum | |
| Name color in party chat | 250 | Gold | Custom color for your name in group. |
| Custom status | Free | Silver | Text under your name. |
| Celebration style: Fireworks | 100 | Bronze | How YOUR wins look to friends. |
| Celebration style: Aurora | 100 | Gold | |
| Celebration style: Sparkles | 100 | Silver | |
| Milestone card: Minimalist | 150 | Silver | Shareable streak milestone design. |
| Milestone card: Retro | 150 | Silver | |
| Milestone card: Neon | 150 | Gold | |
| Milestone card: Watercolor | 150 | Gold | |
| Party badge: Crown | 75 | Silver | Icon next to name in party. |
| Party badge: Sword | 75 | Silver | |
| Party badge: Rocket | 75 | Gold | |
| Party badge: Coffee | 75 | Bronze | |

#### Sounds & Haptics

| Item | Cost | Min Rank | Description |
|---|---|---|---|
| Completion sound: Coin collect | 50 | Bronze | |
| Completion sound: Level up | 50 | Bronze | |
| Completion sound: Typewriter click | 50 | Silver | |
| Completion sound: Sword slash | 50 | Silver | |
| Completion sound: Zen bell | 50 | Bronze | |
| Notification tone: Custom chime | 75 | Silver | Unique Valence notification sound. |

#### Fun / Personality

| Item | Cost | Min Rank | Description |
|---|---|---|---|
| Full emoji picker for habits | 50 | Bronze | Unlock full emoji set for habit icons. |
| Freeze animation: Ice crystal | 100 | Silver | Custom animation when freeze saves streak. |
| Freeze animation: Shield bubble | 100 | Silver | |
| Freeze animation: Time rewind | 100 | Gold | |
| Freeze animation: Angel wings | 100 | Gold | |
| End-of-day summary: Newspaper | 150 | Silver | Daily recap styled as newspaper headline. |
| End-of-day summary: Game stats | 150 | Silver | RPG stat screen style. |
| End-of-day summary: Receipt | 150 | Gold | Receipt/bill style. |
| Party entrance: Flame entrance | 75 | Gold | Your avatar entrance animation in party view. |
| Party entrance: Teleport | 75 | Silver | |
| Party entrance: Drop from top | 75 | Bronze | |

#### Quality of Life (unlockable, not core)

| Item | Cost | Min Rank | Description |
|---|---|---|---|
| Habit categories/folders | Free | Silver | Organize habits into groups. |
| Custom reminder messages | Free | Gold | Write your own notification text. |
| Data export (CSV/JSON) | Free | Silver | Export all habit data. |
| Multi-day freeze pack (3 days) | 200 Sparks | Gold | For vacations. |
| Secret habit mode | 100 Sparks | Silver | Habit invisible to ALL social context, not even percentage. |

#### Seasonal / Limited Time

| Item | How to get | Description |
|---|---|---|
| Seasonal themes | Available only during season, costs Sparks | New Year's gold, Summer sunset, Halloween dark, Diwali lights |
| Event badges | Complete time-limited challenge | "Hackathon Survivor", "New Year Grinder", "100 Days of Code" |
| Collab themes | Special partnerships | Spotify green, GitHub dark, etc. |

### What Sparks can NEVER buy

- Streak days (can't fake progress)
- Tier promotion (earned through consistency only)
- Rank promotion (earned through XP only)
- Extra notifications for friends (no pay-to-spam)
- Core features (habit tracking, groups, feed always free)

### Backend Schema

```typescript
// User table additions
xp: integer('xp').default(0),
sparks: integer('sparks').default(0),
rank: rankEnum('rank').default('bronze'),
activeThemeId: varchar('active_theme_id', { length: 50 }).default('nocturnal'),
activeFlameId: varchar('active_flame_id', { length: 50 }).default('default'),
activeCheckAnimId: varchar('active_check_anim_id', { length: 50 }).default('default'),
activeCompletionSoundId: varchar('active_completion_sound_id', { length: 50 }).default('default'),

// Shop items catalog
export const shopItems = pgTable('shop_items', {
  id: varchar('id', { length: 50 }).primaryKey(),
  name: varchar('name', { length: 100 }),
  description: text('description'),
  category: shopCategoryEnum('category'), // theme, flame, animation, sound, profile, qol, seasonal
  sparksCost: integer('sparks_cost'),
  requiredRank: rankEnum('required_rank'),
  metadata: jsonb('metadata'),            // theme colors, asset URLs, etc.
  isSeasonal: boolean('is_seasonal').default(false),
  availableFrom: timestamp('available_from'),
  availableUntil: timestamp('available_until'),
})

// User purchases
export const userPurchases = pgTable('user_purchases', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').references(() => users.id),
  itemId: varchar('item_id').references(() => shopItems.id),
  purchasedAt: timestamp('purchased_at').defaultNow(),
})

// Active cosmetic selections (what user has equipped)
export const userCosmetics = pgTable('user_cosmetics', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').references(() => users.id).unique(),
  themeId: varchar('theme_id', { length: 50 }).default('nocturnal'),
  flameId: varchar('flame_id', { length: 50 }).default('default'),
  checkAnimId: varchar('check_anim_id', { length: 50 }).default('default'),
  completionSoundId: varchar('completion_sound_id', { length: 50 }).default('default'),
  cardStyleId: varchar('card_style_id', { length: 50 }).default('default'),
  fontPackId: varchar('font_pack_id', { length: 50 }).default('default'),
  backgroundId: varchar('background_id', { length: 50 }).default('default'),
  profileFrameId: varchar('profile_frame_id', { length: 50 }),
  profileBannerId: varchar('profile_banner_id', { length: 50 }),
  partyBadgeId: varchar('party_badge_id', { length: 50 }),
  celebrationStyleId: varchar('celebration_style_id', { length: 50 }).default('default'),
  milestoneCardId: varchar('milestone_card_id', { length: 50 }).default('default'),
  freezeAnimId: varchar('freeze_anim_id', { length: 50 }).default('default'),
  summaryStyleId: varchar('summary_style_id', { length: 50 }).default('default'),
  partyEntranceId: varchar('party_entrance_id', { length: 50 }).default('default'),
  updatedAt: timestamp('updated_at').defaultNow(),
})
```

### API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/shop` | List all items (filtered by user's rank, shows locked/unlocked/purchased) |
| GET | `/shop/:category` | List items by category |
| POST | `/shop/:itemId/purchase` | Buy item with Sparks |
| GET | `/me/cosmetics` | Get user's active cosmetic selections |
| PUT | `/me/cosmetics` | Update equipped cosmetics |
| GET | `/me/purchases` | List all purchased items |
| GET | `/me/progression` | Get XP, Sparks, rank, next rank threshold |

---

## Risks

| Risk | Mitigation |
|---|---|
| Dev 1 schema takes >3 hours | Push partial schema (users+habits+streaks) by H2 so Dev 2 can start |
| Gemini rate limits | Cache responses in Redis. Prepare 3-4 hardcoded fallback sub-habit templates |
| WakaTime API issues | Fall back to manual webhook endpoint for demo |
| Streak timezone bugs | Ignore timezones for hackathon — everything in UTC. Add manual trigger endpoint for demo |
| Merge conflicts | Each dev owns distinct files. Route mounts pre-wired by Dev 1 |
| LeetCode/Duolingo unofficial APIs break | Public profile APIs, low risk. Cache aggressively. Hardcoded demo data as fallback. |
| Strava OAuth complexity | Start with polling, add webhook as enhancement. OAuth flow is well-documented. |
| Google Fit OAuth setup | Needs Google Cloud project + OAuth consent screen. Set up BEFORE hackathon day. |
