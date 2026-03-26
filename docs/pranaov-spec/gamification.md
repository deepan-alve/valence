# Gamification & Rewards

Gamification in Valence is designed as a *tool for motivation*, not as the core experience. Too much gamification creates cognitive friction. Every game mechanic must justify itself against the question: "Does this help the user build the habit, or does this just make the app stickier?"

---

## 1. Points System

### 1.1 Earning Points

| Action | Points | Notes |
|---|---|---|
| Complete a light habit | 5 | Per day |
| Complete a moderate habit | 10 | Per day |
| Complete an intense habit | 20 | Per day |
| Complete all sub-habits of a parent | 5 bonus | On top of individual sub-habit points |
| Maintain a 7-day streak | 15 bonus | One-time per streak milestone |
| Maintain a 30-day streak | 50 bonus | One-time per streak milestone |
| Maintain a 100-day streak | 200 bonus | One-time per streak milestone |
| Full party completion (all members) | 10 | Split equally among members |

### 1.2 What Points Cannot Do
- Points are **never** earned through social actions (nudging, congratulating, adding friends)
- Points are **never** lost as punishment
- Points are **never** displayed on public leaderboards (leaderboards show completion %, not points)

### 1.3 Spending Points

| Item | Cost | Description |
|---|---|---|
| Streak freeze | 50 points | Protects one habit for one day |
| Reward pool spin | 30 points | Draws from user's custom reward pool |
| Custom theme unlock | 100 points | Cosmetic app theme |
| Avatar accessory | 50 points | For party damage mode avatars |

---

## 2. Streak System (detailed)

### 2.1 Streak Display
- Current streak: prominent, animated counter
- Longest streak: shown alongside, smaller
- Total days: cumulative counter below
- On break: current streak resets but UI leads with total days and percentage

### 2.2 Streak Milestones
- Visual celebrations at 7, 14, 30, 60, 100, 365 days
- Shareable milestone cards (to social feed and external sharing)
- Milestone notifications to friends in the social feed

### 2.3 Streak Freeze Rules
- Maximum 2 freezes stored per habit
- Freeze activates automatically if a day is missed (no action needed)
- Manual freeze: user can pre-activate for a known absence (vacation, sick day)
- Friend-shared freeze: costs the friend 1 freeze, saves your streak
- Freeze usage appears in activity log

---

## 3. Reward Pool System

### 3.1 Concept
Users define their own rewards — real-world treats they allow themselves upon earning enough points. This aligns the app's incentive structure with the user's personal motivation.

### 3.2 How It Works
1. User creates a **reward pool** — a list of rewards they want (e.g., "Buy a coffee", "Watch an episode", "Sleep in on Saturday")
2. Each reward has a point cost (set by user or suggested by app)
3. When the user spends points on a "reward spin", a reward is randomly selected from their pool
4. User marks the reward as "redeemed" or "saved for later"

### 3.3 Pre-Set Reward Suggestions
- For users who do not want to create their own pool, the app suggests generic rewards:
  - "Take a guilt-free break"
  - "Treat yourself to a snack"
  - "Share your win with a friend"
- These are starting points — users are encouraged to personalize

---

## 4. Achievements

### 4.1 Achievement Types

| Category | Examples |
|---|---|
| **Streak** | "Week Warrior" (7-day streak), "Month Master" (30-day), "Century Club" (100-day) |
| **Consistency** | "Perfect Week" (all habits completed for 7 days), "90% Month" |
| **Social** | "First Party" (join a party), "Streak Saver" (freeze a friend's streak), "Nudge Master" (nudge 10 different friends) |
| **Growth** | "Tier Up" (promoted to a new tier), "Sub-Habit Builder" (create 5 sub-habits) |
| **Negative Habits** | "Clean Week" (no relapses for 7 days), "Pattern Breaker" (avoid a predicted relapse) |

### 4.2 Achievement Display
- Achievement badges shown on user profile
- Visible to friends
- No achievement-based ranking — achievements are personal milestones

---

## 5. Leaderboard

### 5.1 Design
- **Metric:** Percentage of habits completed (not absolute count, not points)
- **Scope:** Tier-specific. A Spark user never sees a Blaze user's ranking
- **Time window:** Rolling 7-day and 30-day views
- **Effort weighting:** Intense habits contribute more to the percentage than light habits
- **Private habits:** Contribute to personal % but are excluded from leaderboard calculation

### 5.2 Anti-Toxicity
- Leaderboard is opt-in — users can hide themselves from rankings
- Leaderboard is never pushed via notifications
- No "you dropped X places" messaging
- Leaderboard shows top 10 + your position, not the full ranking

---

## 6. What We Explicitly Avoid

| Anti-Pattern | Why | What We Do Instead |
|---|---|---|
| Loss of points on failure | Amplifies loss aversion, creates anxiety | Points only accumulate |
| Daily login bonuses | Rewards opening the app, not building habits | Reward habit completion |
| Loot boxes / randomized high-value rewards | Dopamine manipulation, not habit support | Transparent reward pools |
| Public failure displays | Shame-driven, causes app abandonment | Failures are private |
| Streak-based gating | "Complete 30-day streak to unlock feature X" punishes breaks | Features unlock via cumulative progress |
| Competitive push notifications | "X is ahead of you!" is anxiety-inducing | Leaderboard is pull, not push |
