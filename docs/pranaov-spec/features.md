# Feature Specification

---

## 1. Habit Management

### 1.1 Habit CRUD
- Create habits with: name, description, frequency (daily/weekly/custom), target time, category
- Positive habits: things to do (exercise, read, code)
- Negative habits: things to avoid (oversleeping, alcohol, doomscrolling)
- Each habit has a visibility toggle: **public** (shared with groups) or **private** (only percentage and streak visible to others)
- Edit and archive habits (never hard-delete — preserve history)

### 1.2 Sub-Habits
- Any habit can be decomposed into sub-habits
- **LLM-assisted generation:** User enters an ambitious habit (e.g., "Run a marathon"), LLM generates a tree of progressively easier sub-habits (e.g., "Run 1km", "Stretch for 10 min", "Walk 5km")
- Sub-habits inherit the parent's schedule by default but can be customized
- Parent habit progress = weighted completion of sub-habits
- **UI:** Parent shows a single progress bar. Tap to expand sub-habit checklist. Collapse by default to minimize cognitive load

### 1.3 Habit Tracking
- Manual check-in: one-tap completion
- Automatic tracking via integrations (see [Integrations](./integrations.md))
- For negative habits: default state is "succeeded" (not triggered). User logs a slip, not a success
- Partial completion supported (e.g., "did 3 of 5 sets")

### 1.4 Habit Effort Classification
- Habits are tagged as **light**, **moderate**, or **intense** effort
- Classification is suggested by LLM based on habit description and adjusted by user
- Effort level affects point calculations — intense habits earn proportionally more
- Effort level is shown on leaderboards to contextualize rankings

---

## 2. Streak System

### 2.1 Streak Tracking
- Current streak counter per habit
- Longest streak counter per habit (never resets)
- Total days completed counter (cumulative, regardless of streaks)
- On streak break: display pivots to "X of last Y days completed (Z%)" instead of "streak broken"

### 2.2 Streak Freezes
- Freeze = skip one day without breaking the streak
- Earned through accumulated streak points (see [Gamification](./gamification.md))
- A friend can use their freeze on your streak (costs them a freeze, saves your streak)
- Maximum 2 freezes stored per habit at any time
- Freeze usage is logged and visible in the social feed ("Riya froze Arjun's meditation streak")

### 2.3 Streak Recovery
- After a break, user can "Continue" — the streak restarts but the app highlights total history
- No "streak broken" modal. Instead: "Welcome back! You have completed this habit 94 times. Ready for day 95?"
- LLM provides a personalized tip for the specific habit that was missed

---

## 3. Cue Tracking & Failure Analysis

### 3.1 Skip Logging
- When a habit is skipped (either manually or by day-end timeout), the app offers an optional one-tap cue log
- Pre-populated cue categories: Too tired, Forgot, No time, Social conflict, Travel, Illness, Not motivated, Other
- Custom cues can be added
- Logging is never mandatory and never guilt-inducing ("No worries — understanding why helps us help you")

### 3.2 Pattern Detection
- After 2+ weeks of data, the app identifies patterns (e.g., "You tend to skip workouts on Mondays")
- Patterns surface as gentle insights in weekly lookbacks, not as real-time callouts
- For avoidable patterns, the app offers a preemptive nudge on predicted skip days ("Mondays are tough for gym — want to try a lighter sub-habit instead?")

### 3.3 LLM-Powered Failure Tips
- When a habit is missed or a negative habit relapses, the LLM generates contextual advice
- Tips are specific to the habit and the user's logged cues, not generic motivation quotes
- Tips appear in the habit detail view, not as push notifications

---

## 4. Social Features

Detailed in [Social System Design](./social-system.md). Summary:

- **Friends:** Add by username/invite link. See shared habit percentages and streaks
- **Nudge:** Tap to nudge a friend who has not completed a habit today. No points earned — purely social
- **Congratulate:** Tap to send a congratulation on a friend's milestone. Appears in their feed
- **Streak freeze sharing:** Use your freeze to save a friend's streak
- **Group/Party system:** Shared accountability with threshold-based group streaks
- **Tiered communities:** Progress through levels to match with similarly committed peers

---

## 5. Notification System

### 5.1 Design Philosophy
- **Anticipation, not guilt.** All notifications are forward-looking
- Maximum 3 notifications per day per user
- No "Did you complete X today?" messages ever

### 5.2 Notification Types

| Type | Example | Trigger |
|---|---|---|
| Anticipation | "Morning run starts in 15 min — streak 12 is calling" | Scheduled time minus buffer |
| Social save | "3 friends saved your group streak today" | End of day, group streak preserved |
| Group waiting | "Your group is waiting for you — 4/5 completed" | Late in day, group nearly complete |
| Milestone | "You hit 30 days of reading!" | Streak milestone reached |
| Nudge received | "Arjun nudged you about meditation" | Friend sends nudge |
| Weekly lookback | "Your week in review is ready" | Weekly schedule |

### 5.3 End-of-Day Check-In
- If habits are incomplete: show social context ("5 friends completed theirs — join them?")
- If habits are complete: celebrate ("Perfect day! Your group streak is at 14")
- If habits are missed and day is over: reassurance message, never disappointment

---

## 6. Lookbacks & Reports

### 6.1 Weekly Lookback
- Summary of habits completed vs. attempted
- Highlight: best streak of the week, most consistent habit
- Cue pattern insights (if enough data)
- Group performance summary
- Tone: appreciative and evaluative, not judgmental

### 6.2 Monthly Lookback
- Trend graphs: completion rate over time
- Comparison to previous month (personal only, not vs. others)
- Tier progression status
- Suggested habit adjustments based on data
- Both individual and group-level views

---

## 7. LLM Integration Points

| Feature | LLM Role |
|---|---|
| Sub-habit generation | Break ambitious habits into actionable sub-habits with suggested timing |
| Failure tips | Context-aware advice on missed habits and relapsed negative habits |
| Cue analysis | Identify patterns in skip reasons and suggest interventions |
| Lookback summaries | Generate natural-language summaries for weekly/monthly reviews |
| Effort classification | Suggest effort level for new habits based on description |
