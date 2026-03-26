# Data Model

---

## Entity Relationship Diagram

```
┌──────────┐       ┌──────────────┐       ┌──────────────┐
│   User   │──1:N──│    Habit     │──1:N──│  HabitLog    │
│          │       │              │       │  (daily)     │
└──────────┘       └──────────────┘       └──────────────┘
     │                    │                      │
     │               1:N  │                      │
     │                    ▼                      │
     │             ┌──────────────┐              │
     │             │  SubHabit    │              │
     │             └──────────────┘              │
     │                                           │
     │──1:N──┌──────────────┐                   │
     │       │  Streak      │◄──────────────────┘
     │       └──────────────┘
     │
     │──M:N──┌──────────────┐
     │       │  Friendship  │
     │       └──────────────┘
     │
     │──M:N──┌──────────────┐       ┌──────────────┐
     │       │  GroupMember  │──N:1──│    Group      │
     │       └──────────────┘       │   (Party)     │
     │                              └──────────────┘
     │                                     │
     │                                1:N  │
     │                                     ▼
     │                              ┌──────────────┐
     │                              │ GroupStreak   │
     │                              └──────────────┘
     │
     │──1:N──┌──────────────┐
     │       │ Integration  │
     │       │  Connection  │
     │       └──────────────┘
     │
     │──1:N──┌──────────────┐
     │       │ Achievement  │
     │       │  (earned)    │
     │       └──────────────┘
     │
     │──1:N──┌──────────────┐
     │       │  Reward      │
     │       │  Pool Item   │
     │       └──────────────┘
     │
     │──1:N──┌──────────────┐
     │       │  Notification│
     │       └──────────────┘
     │
     │──1:N──┌──────────────┐
              │  FeedItem    │
              └──────────────┘
```

---

## Table Definitions

### User

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| firebase_uid | VARCHAR | Firebase Auth UID |
| username | VARCHAR (unique) | Display name, used for friend search |
| display_name | VARCHAR | Shown in UI |
| avatar_url | VARCHAR | Profile picture |
| tier | ENUM | spark, ember, flame, blaze |
| total_points | INT | Accumulated points (never decreases) |
| available_points | INT | Spendable points |
| timezone | VARCHAR | User's timezone for streak calculation |
| created_at | TIMESTAMP | |
| updated_at | TIMESTAMP | |

### Habit

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| user_id | UUID (FK → User) | |
| parent_habit_id | UUID (FK → Habit, nullable) | For sub-habits |
| name | VARCHAR | |
| description | TEXT | |
| type | ENUM | positive, negative |
| effort | ENUM | light, moderate, intense |
| frequency | ENUM | daily, weekly, custom |
| frequency_config | JSONB | Custom frequency details (e.g., specific days) |
| target_time | TIME | When the user intends to do this habit |
| visibility | ENUM | public, private |
| is_archived | BOOLEAN | Soft delete |
| integration_id | UUID (FK → IntegrationConnection, nullable) | Auto-tracking source |
| integration_threshold | JSONB | Auto-completion criteria |
| created_at | TIMESTAMP | |
| updated_at | TIMESTAMP | |

### SubHabit

Sub-habits are stored as Habit rows with `parent_habit_id` set. Additional metadata:

| Column | Type | Description |
|---|---|---|
| weight | FLOAT | Contribution weight to parent progress (0.0-1.0) |
| order | INT | Display order within parent |
| llm_generated | BOOLEAN | Whether this was auto-generated |

*(These columns are added to the Habit table, nullable for non-sub-habits)*

### HabitLog

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| habit_id | UUID (FK → Habit) | |
| user_id | UUID (FK → User) | |
| date | DATE | The day this log is for |
| status | ENUM | completed, partial, skipped, frozen, pending |
| completion_value | FLOAT | 0.0-1.0 for partial completion |
| source | ENUM | manual, integration, friend_freeze |
| skip_cue | VARCHAR (nullable) | Why it was skipped |
| skip_cue_custom | TEXT (nullable) | Custom skip reason |
| created_at | TIMESTAMP | |
| updated_at | TIMESTAMP | |

**Unique constraint:** (habit_id, date) — one log per habit per day.

### Streak

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| habit_id | UUID (FK → Habit) | |
| user_id | UUID (FK → User) | |
| current_streak | INT | Days in current streak |
| longest_streak | INT | All-time longest |
| total_completed | INT | Cumulative days completed (regardless of streaks) |
| freezes_available | INT | 0-2 |
| last_completed_date | DATE | |
| updated_at | TIMESTAMP | |

**Unique constraint:** (habit_id) — one streak record per habit.

### Friendship

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| user_id | UUID (FK → User) | |
| friend_id | UUID (FK → User) | |
| status | ENUM | pending, accepted, blocked |
| created_at | TIMESTAMP | |
| accepted_at | TIMESTAMP (nullable) | |

**Unique constraint:** (user_id, friend_id)

### Group (Party)

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| name | VARCHAR | Party name |
| created_by | UUID (FK → User) | |
| max_members | INT | 3-7 |
| hardcore_mode | BOOLEAN | Party damage system enabled |
| created_at | TIMESTAMP | |

### GroupMember

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| group_id | UUID (FK → Group) | |
| user_id | UUID (FK → User) | |
| role | ENUM | owner, member |
| avatar_hp | INT | For hardcore mode (default 100) |
| joined_at | TIMESTAMP | |

### GroupStreak

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| group_id | UUID (FK → Group) | |
| current_streak | INT | |
| longest_streak | INT | |
| last_evaluated_date | DATE | |
| updated_at | TIMESTAMP | |

### GroupDailyLog

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| group_id | UUID (FK → Group) | |
| date | DATE | |
| members_completed | INT | |
| members_total | INT | |
| outcome | ENUM | reward, maintain, reset |
| created_at | TIMESTAMP | |

### IntegrationConnection

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| user_id | UUID (FK → User) | |
| provider | ENUM | google_fit, wakatime, strava, github, etc. |
| access_token | TEXT (encrypted) | |
| refresh_token | TEXT (encrypted) | |
| token_expires_at | TIMESTAMP | |
| status | ENUM | active, expired, revoked |
| last_synced_at | TIMESTAMP | |
| created_at | TIMESTAMP | |

### Achievement

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| key | VARCHAR (unique) | e.g., "streak_7", "tier_ember" |
| name | VARCHAR | Display name |
| description | TEXT | |
| icon_url | VARCHAR | |
| category | ENUM | streak, consistency, social, growth, negative |

### UserAchievement

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| user_id | UUID (FK → User) | |
| achievement_id | UUID (FK → Achievement) | |
| earned_at | TIMESTAMP | |

### RewardPoolItem

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| user_id | UUID (FK → User) | |
| name | VARCHAR | e.g., "Buy a coffee" |
| point_cost | INT | |
| times_redeemed | INT | |
| is_active | BOOLEAN | |
| created_at | TIMESTAMP | |

### Notification

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| user_id | UUID (FK → User) | |
| type | ENUM | anticipation, social_save, group_waiting, milestone, nudge, lookback |
| title | VARCHAR | |
| body | TEXT | |
| data | JSONB | Action-specific payload |
| is_read | BOOLEAN | |
| sent_at | TIMESTAMP | |

### FeedItem

| Column | Type | Description |
|---|---|---|
| id | UUID (PK) | |
| user_id | UUID (FK → User) | Target user who sees this |
| actor_id | UUID (FK → User) | Who performed the action |
| type | ENUM | milestone, freeze_shared, nudge, congratulation, group_milestone, tier_promotion |
| data | JSONB | Type-specific payload |
| created_at | TIMESTAMP | |

---

## Indexes

| Table | Index | Purpose |
|---|---|---|
| HabitLog | (user_id, date) | Daily dashboard query |
| HabitLog | (habit_id, date) | Streak calculation |
| Streak | (user_id) | User's streak overview |
| Friendship | (user_id, status) | Friend list |
| GroupMember | (group_id) | Party membership |
| GroupMember | (user_id) | User's parties |
| FeedItem | (user_id, created_at DESC) | Feed query |
| Notification | (user_id, is_read, sent_at DESC) | Notification list |
| Habit | (user_id, is_archived) | Active habit list |
| Habit | (parent_habit_id) | Sub-habit lookup |
