# Social System Design

This document covers all group mechanics, social interactions, and failure recovery systems. The core question: *Are group mechanics creating genuine shared stakes with thoughtful failure recovery?*

---

## 1. Friends

### 1.1 Adding Friends
- Invite via shareable link or username search
- Mutual acceptance required (no one-sided following)
- Friends see each other's: public habit names, completion percentages, current streaks
- Private habits: only percentage and streak visible, not the habit name or details

### 1.2 Friend Interactions

| Action | Description | Points? |
|---|---|---|
| **Nudge** | Remind a friend to complete a habit. One nudge per friend per habit per day. | No |
| **Congratulate** | Celebrate a friend's milestone. Appears in their feed. | No |
| **Freeze share** | Spend one of your streak freezes to save a friend's streak. | No |

**Critical design decision:** Friends are never correlated with earning points. Social interactions are intrinsically motivated — adding point incentives would commodify relationships and create perverse incentives (spam nudging for points, hollow congratulations for rewards).

---

## 2. Party System

### 2.1 Concept
A party is a small group (3-7 people) with shared accountability. Each member brings their own habits, but the group shares a collective streak.

### 2.2 Group Streak Mechanics

The group streak uses a **threshold system**, not all-or-nothing:

| Completion Level | Outcome |
|---|---|
| **All members** complete at least one habit | **Reward:** Bonus points for the whole party |
| **N-1 members** complete at least one habit | **Maintain:** Group streak continues, no bonus |
| **Fewer than N-1** | **Penalty:** Group streak resets (but individual streaks are unaffected) |

Where N = party size.

**Why N-1 threshold:**
- All-or-nothing creates single-point-of-failure anxiety and resentment toward the weakest member
- Too-low thresholds enable social loafing
- N-1 provides genuine shared stakes while allowing one person to have a bad day

### 2.3 Party Features
- Party chat (lightweight, in-app)
- Shared activity feed (who completed what, who nudged whom)
- Party streak counter and milestone celebrations
- Party-level weekly lookback
- Party leaderboard (internal ranking within the party by completion %)

### 2.4 Party Damage System (Optional Hardcore Mode)
- Opt-in mode for competitive parties
- A member's failure to complete their daily habits inflicts "virtual damage" on teammates' avatars
- Avatars have HP that regenerates with group completion
- Purely cosmetic/fun — no actual penalty to streaks or points
- Must be unanimously opted into by all party members

---

## 3. Tiered Communities

### 3.1 Problem
Ranking systems are double-edged swords. Beginners get overwhelmed seeing power users. Advanced users get bored competing with beginners. Social comparison (Festinger) works best among similar peers.

### 3.2 Tier Design

| Tier | Name | Entry Criteria | Community Size |
|---|---|---|---|
| 1 | Spark | Default for new users | Largest pool |
| 2 | Ember | 70%+ completion rate over 2 weeks | Medium |
| 3 | Flame | 80%+ completion rate over 4 weeks | Smaller |
| 4 | Blaze | 90%+ completion rate over 8 weeks | Smallest, most committed |

### 3.3 Mechanics
- Users can only see and be compared to others in their tier
- Leaderboards, community challenges, and matchmaking are all tier-scoped
- Promotion happens automatically when criteria are met for the sustained period
- Demotion happens if completion rate drops below the tier threshold for 2 consecutive weeks — but with a grace notification first
- Demotion messaging: "Your tier will adjust next week if your pace continues — no pressure, just a heads up." Never punitive

### 3.4 Community Features
- Tier-scoped leaderboard (percentage-based, not absolute)
- Community challenges (e.g., "Ember tier: 500 collective workouts this week")
- Option to join the community or stay in parties only — community is never forced

---

## 4. Social Feed

### 4.1 Feed Items
- Friend completed a milestone ("Priya hit 30 days of journaling!")
- Friend used a freeze on your streak ("Riya saved your meditation streak!")
- Party streak milestone ("Your party hit a 21-day group streak!")
- Nudge received
- Congratulation received
- Tier promotion ("You have been promoted to Flame tier!")

### 4.2 Feed Rules
- **Celebrations are public, failures are private.** The feed never shows "X missed their habit"
- Feed is chronological, not algorithmic
- No infinite scroll — shows today's events and yesterday's highlights
- Mute individual friends without unfriending

---

## 5. Failure Recovery in Social Context

### 5.1 Individual Failure Within a Group
- Other members are NOT notified that someone specifically failed
- Group streak status shows "4/5 completed" without naming who is missing
- The missing member sees: "Your group is waiting for you — 4/5 completed" (if there is still time) or "3 friends saved your group streak today" (if N-1 threshold met)

### 5.2 Group Streak Reset
- When a group streak resets, messaging is collective: "Fresh start — your party is at day 1 again. Last run: 14 days!"
- No blame attribution
- Party chat may naturally surface who struggles, but the system never points fingers

### 5.3 Social Safety Nets
- Streak freeze sharing (friends spend their freeze for you)
- Group threshold (N-1) absorbs one member's bad day
- Nudges serve as gentle reminders without consequences
- Community tier adjustment has a grace period and advance notice

---

## 6. Anti-Toxicity Safeguards

| Risk | Safeguard |
|---|---|
| Nudge spam | 1 nudge per friend per habit per day. No points for nudging. |
| Public shaming | Failures never appear in social feed. Group incomplete status is anonymous. |
| Comparison anxiety | Tiered communities. Percentage-based rankings. Private habits excluded. |
| Streak toxicity | Freezes, friend-shared freezes, "continue" framing, cumulative stats. |
| Obligation fatigue | Maximum 3 notifications/day. All notifications are opt-in by category. |
| Forced sociality | Private habits exist. Community is optional. Parties are opt-in. Solo mode is fully functional. |
