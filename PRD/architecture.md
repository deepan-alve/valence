# Valance — Backend Architecture & System Flow

---

## 1. Stack

| Layer | Technology |
|---|---|
| Language | TypeScript |
| Framework | Hono |
| ORM | Drizzle |
| Database | PostgreSQL 16 |
| Cache / PubSub | Redis 7 |
| Job Queue | BullMQ |
| Auth | Firebase Auth |
| LLM | Gemini 2.5 Flash |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Plugin Runtime | Server-side TypeScript plugin executor |
| Deployment | Docker Compose on VPS |

---

## 2. System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         FLUTTER CLIENT                          │
│                                                                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐ ┌────────┐│
│  │  Home    │ │  Group   │ │ Progress │ │  Shop  │ │Profile ││
│  │(persona) │ │(feed,    │ │(heatmap, │ │        │ │        ││
│  │          │ │ chain,   │ │ goals,   │ │        │ │        ││
│  │          │ │ leaderbd)│ │ insights)│ │        │ │        ││
│  └──────────┘ └──────────┘ └──────────┘ └────────┘ └────────┘│
│                           │                                    │
│                    Firebase Auth SDK + FCM                      │
└───────────────────────────┬────────────────────────────────────┘
                            │ HTTPS (JWT Bearer)
                            ▼
┌───────────────────────────────────────────────────────────────┐
│                     DOCKER COMPOSE                             │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    HONO API SERVER                       │ │
│  │                                                         │ │
│  │  Routes: auth, habits, groups, social, shop,            │ │
│  │          plugins, insights, reflections                  │ │
│  │                                                         │ │
│  │  Services: streak, group, points, feed, llm, plugin     │ │
│  │                                                         │ │
│  │  Middleware: Firebase JWT verify, error handler          │ │
│  └──────────────────────────┬──────────────────────────────┘ │
│                              │                                │
│  ┌───────────────────────────┴─────────────────────────────┐ │
│  │                    BULLMQ WORKER                         │ │
│  │                                                         │ │
│  │  Jobs:                                                  │ │
│  │  - Daily streak calculator        (00:05 UTC)           │ │
│  │  - Plugin poller                  (every 2 hours)       │ │
│  │  - Preemptive nudge generator     (14:00 user-local)    │ │
│  │  - Evening reflection prompt      (21:00 user-local)    │ │
│  │  - Weekly leaderboard reset       (Monday 00:00 UTC)    │ │
│  │  - Morning activation             (07:00 user-local)    │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              │                                │
│  ┌──────────┐  ┌─────────┐  │  ┌───────────────────────────┐│
│  │PostgreSQL│  │ Redis   │  │  │    External Services      ││
│  │          │  │(cache + │  │  │                           ││
│  │          │  │ BullMQ) │  │  │  Gemini 2.5 Flash API    ││
│  │          │  │         │  │  │  Firebase Auth + FCM      ││
│  │          │  │         │  │  │  Plugin APIs (LeetCode,   ││
│  │          │  │         │  │  │   GitHub, Google Fit,     ││
│  │          │  │         │  │  │   Duolingo, Wakapi)       ││
│  └──────────┘  └─────────┘  │  └───────────────────────────┘│
└───────────────────────────────────────────────────────────────┘
```

Single Dockerfile. API server and worker use the same image with different `command` overrides in docker-compose.

---

## 3. API Endpoints

```
AUTH
  POST   /auth/register
  POST   /auth/login
  POST   /auth/refresh

USERS
  GET    /users/me
  PATCH  /users/me/settings
  PATCH  /users/me/equip
  GET    /users/:id/profile

HABITS
  POST   /habits
  GET    /habits
  PATCH  /habits/:id
  DELETE /habits/:id                      (archive)
  POST   /habits/:id/complete
  POST   /habits/:id/miss
  GET    /habits/:id/logs?range=week|month

GROUPS
  POST   /groups
  GET    /groups/:id
  POST   /groups/:id/join
  DELETE /groups/:id/leave
  GET    /groups/:id/feed
  GET    /groups/:id/streak
  GET    /groups/:id/leaderboard?period=week|month
  GET    /groups/:id/members
  POST   /groups/:id/freeze              (altruistic, costs 100 Sparks)

SOCIAL
  POST   /nudge                           (sender → receiver, LLM-generated)
  POST   /kudos

SHOP
  GET    /shop/items
  POST   /shop/purchase/:itemId

PLUGINS
  GET    /plugins
  POST   /plugins/:id/connect
  GET    /plugins/:id/status

INSIGHTS
  POST   /reflections
  GET    /insights                        (LLM failure patterns)
  GET    /insights/motivation             (persona-driven launch stat)
```

---

## 4. Scheduled Jobs

| Job | Schedule | Function |
|---|---|---|
| Morning activation | 07:00 user-local | Persona-driven LLM notification via FCM |
| Daily streak calculator | 00:05 UTC | Evaluate groups (gold/silver/broken links), update tiers, update per-habit streaks and goal stages |
| Plugin poller | Every 2 hours | Check connected plugins for auto-completion |
| Preemptive nudge generator | 14:00 user-local | LLM analyzes miss patterns, sends warnings for at-risk users |
| Evening reflection prompt | 21:00 user-local | FCM push for daily reflection (1-5 difficulty + optional text) |
| Weekly leaderboard reset | Monday 00:00 UTC | Archive scores, reset contribution counters, announce winners |

---

## 5. Data Flow — A Day in the Life

### Morning (07:00 user-local)

```
BullMQ Worker
  ├─ Load user → check persona_type
  ├─ Load group (who completed yesterday, chain length)
  ├─ Call Gemini 2.5 Flash → persona-driven message
  │    Socialiser: "3 people in your group already started. Don't break the 14-day chain."
  │    Achiever: "Day 15. 780 XP. You're 61% to Gold rank."
  │    General: "67 habits completed. 3.7 per day average."
  └─ Send FCM push
```

### App Open (Home Screen)

```
Flutter → GET /users/me + GET /habits + GET /groups/:id + GET /insights/motivation
  ├─ Render: persona-driven stat banner
  ├─ Render: daily habit cards (status + complete/deep-link button per habit)
  ├─ Render: group chain visualization (last 30 days of gold/silver/broken links)
  └─ Nudge button: LOCKED until user completes all own habits
```

### Habit Completion (Manual)

```
Flutter → POST /habits/:id/complete
  │
  Server:
  ├─ Verify ownership + not already completed today
  ├─ INSERT HabitLog (completed=true, source="manual")
  ├─ Update streak: increment current, update longest
  ├─ Check goal_stage transitions (3→10→21→66 days)
  ├─ Award XP + Sparks (light=5, moderate=10, intense=20)
  ├─ If ALL habits done → "Perfect day" bonus (+25 XP/Sparks)
  ├─ If ALL habits done → unlock nudge button for this user
  ├─ Check streak milestones (7/30/100) → bonus + feed item
  ├─ Insert group feed item
  └─ If milestone → trigger Status+Norm sequence via Gemini
```

### Habit Completion (Plugin Auto-Detect)

```
BullMQ Worker (every 2 hours)
  ├─ Load all active plugin connections
  ├─ For each user+plugin:
  │    ├─ Call plugin.fetchTodayStatus()
  │    ├─ If completed AND no HabitLog today:
  │    │    ├─ Auto-complete habit (same flow as manual)
  │    │    ├─ HabitLog.verification_source = plugin name
  │    │    ├─ Group feed: "Verified via LeetCode API"
  │    │    └─ Send FCM: "Your LeetCode problem was auto-verified! ✓"
  │    └─ If not completed → skip, check in 2 hours
```

### Nudge (Conditional — Must Earn the Right)

```
Flutter → POST /nudge { receiver_id, group_id }
  │
  Server:
  ├─ ENFORCE: sender completed ALL habits today
  ├─ ENFORCE: rate limit
  ├─ Load receiver context:
  │    habits, streaks, miss patterns, reflections, time of day
  ├─ Call Gemini 2.5 Flash → personalized nudge message
  │    "Riya, it's Thursday and you mentioned work drains you by evening.
  │     Try reading during lunch before the fatigue hits."
  ├─ INSERT Nudge
  ├─ Send FCM push
  └─ Insert feed item
```

### Miss Logging

```
Flutter → POST /habits/:id/miss { reason_category, reason_text }
  │
  Server:
  ├─ INSERT MissLog
  ├─ Call Gemini (async): parse reason → categorize + update pattern profile
  ├─ Streak PAUSES (does NOT reset to zero)
  └─ Return supportive message
```

### Evening Reflection (21:00 user-local)

```
BullMQ → FCM push: "How did today go?"
  │
Flutter → POST /reflections
  ├─ Body: [{ habit_id, difficulty: 1-5, text: "..." }, ...]
  │
  Server:
  ├─ Update HabitLogs with reflection data
  └─ Feeds: LLM nudge context, pattern analysis, insights dashboard
```

### Midnight Streak Calculator (00:05 UTC)

```
BullMQ Worker
  │
  FOR EACH GROUP:
  ├─ Load members (exclude inactive ≥ 3 days)
  ├─ For each eligible member:
  │    done = (completed_habits == active_habit_count)
  ├─ completion_% = done_members / eligible_members
  │
  ├─ Evaluate chain link:
  │    100%     → GOLD   (streak++, bonus XP split among members)
  │    75-99%   → SILVER (streak++)
  │    <75%     → Check group freeze used?
  │               YES → treat as SILVER
  │               NO  → BROKEN (streak PAUSES, does NOT reset to 0)
  │
  ├─ Update group tier:
  │    streak ≥ 66 → Blaze
  │    streak ≥ 21 → Flame
  │    streak ≥ 7  → Ember
  │    else        → Spark
  │
  ├─ Update per-habit streaks (pause for missed, increment for completed)
  ├─ Update goal stages (3→10→21→66)
  ├─ Generate Status+Norm for milestones via Gemini
  └─ Update weekly contribution scores
```

### Monday 00:00 UTC — Weekly Leaderboard Reset

```
BullMQ Worker
  ├─ Archive WeeklyScore rows
  ├─ Calculate final rank_in_group per member
  ├─ Reset counters
  └─ Feed items for weekly winners
```

---

## 6. LLM Pipeline (Gemini 2.5 Flash)

### Five Integration Points

| Feature | Trigger | Input | Output |
|---|---|---|---|
| **Friend nudge** | User taps nudge (on-demand) | Receiver's habits, streaks, misses, reflections, time of day | Personalized 1-2 sentence nudge |
| **Preemptive warning** | 14:00 cron for at-risk users | User's miss patterns (day, time, reasons) | Timed reminder before predicted failure window |
| **Launch motivation** | App open | Streak, rank, group status, persona type | Amplified progress stat or social pressure message |
| **Miss reason parsing** | User logs a miss | Free-text reason | Categorized reason + pattern update (JSON) |
| **Status + Norm** | Milestone reached | User milestone data, group completion rate | Paired praise + norm message for group feed |

### Prompt Examples

**Friend Nudge:**
```
System: Generate a SHORT (1-2 sentence) supportive nudge from one friend
to another. Be specific — reference their patterns, time of day, and
reflections. Sound like a friend texting, not an app.

Input: {
  sender: "Deepan", receiver: "Riya",
  incomplete: ["Read 30 pages"],
  pattern: "missed reading 3/4 Thursdays",
  reflection: "felt drained after work",
  time: "12:30 PM Thursday",
  group: "4/5 done"
}

→ "Riya, it's Thursday and you mentioned work drains you by evening.
   Try reading during lunch — 4 of us are already done 📚"
```

**Launch Motivation (persona-driven):**
```
Input: { persona: "achiever", streak: 15, xp: 780, next_rank: 2000 }
→ Achiever: "Day 15. 780 XP. You're 61% to Gold rank."

Input: { persona: "socialiser", group_streak: 14, members_done: 3 }
→ Socialiser: "3 people in your group already started. The chain is at 14."
```

**Status + Norm Sequence:**
```
Input: { user: "Deepan", milestone: "21-day meditation", group_rate: "82%" }
→ Status: "Deepan hit 21 days of meditation — Momentum milestone."
→ Norm: "Most people in your group are staying consistent — 82% this week."
```

### Cost Management

| Strategy | Implementation |
|---|---|
| Cache similar requests | Redis, 1-hour TTL |
| Batch cron-based calls | Group 10-20 users per prompt for preemptive nudges |
| Template fallbacks | If Gemini rate-limited or down, use predefined templates |
| Rate limit | Max 10 LLM calls/min per user |
| Use Flash model | Cheapest Gemini model. Simple text generation, not reasoning. |

---

## 7. Plugin System

### Interface

```typescript
interface Plugin {
  name: string;
  description: string;
  authenticate(credentials: AuthCredentials): Promise<boolean>;
  fetchTodayStatus(userId: string): Promise<{
    completed: boolean;
    metadata: Record<string, any>;
  }>;
  getProgressData(userId: string, dateRange: DateRange): Promise<ProgressData[]>;
}
```

### MVP Plugins

| Plugin | Auth | fetchTodayStatus() |
|---|---|---|
| **LeetCode** | Public username | GraphQL: check recentSubmissions for accepted today |
| **GitHub/Wakapi** | API key or username | Contribution graph today / Wakapi coding time |
| **Google Fit** | OAuth2 | Aggregate steps/exercise minutes for today |
| **Duolingo** | Public username | Check daily lesson completion |
| **Screen Time** | On-device | Flutter reads data, POSTs to webhook |
| **Manual + Photo** | N/A | User uploads timestamped photo |

### Polling Flow

```
BullMQ (every 2 hours):
  ├─ Load active plugin connections
  ├─ For each user+plugin:
  │    ├─ Call plugin.fetchTodayStatus()
  │    ├─ If completed AND no HabitLog today → auto-complete
  │    └─ If error → mark connection status as "error", retry next cycle
  └─ Extensible: new plugins implement the interface, no core changes needed
```

---

## 8. Resolved Design Decisions

| Question | Decision |
|---|---|
| Habit archival mid-streak | Streak freezes (preserved). Habit excluded from group % calculation. |
| Group member departure / inactivity | Auto-excluded from group % after 3 days of zero completions. Auto-included when they return. |
| Max habits per user | 7 active habits max. Prevents XP farming. Forces prioritization. |
| Altruistic group freeze | Costs 100 Sparks. Protects group chain for 1 day. Max 1 per group per day. |
| Group streak threshold | 75% of eligible members = silver link. 100% = gold link. <75% = broken (pauses, never resets). |
| Nudge permission | Conditional — must complete ALL own habits before nudging. Server-enforced. |
| Framework | Hono over Express/Fastify. Built-in JWT, CORS, WebSocket. Native TypeScript. |
