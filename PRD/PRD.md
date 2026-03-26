# Product Requirements Document: Valance

**Version:** 2.0
**Date:** 2025-03-25
**Status:** Hackathon MVP

---

## 1. Overview & Core Philosophy

**Valance** is a social habit-tracking mobile application engineered to combat user churn through aggressive friction reduction, Behavioral Change Techniques (BCT), and Persuasive System Design (PSD).

Instead of relying on zero-sum competitive models ("GameFit"), Valance utilizes **Relative Effort Mapping** and group-based accountability among known friend circles. It leverages an LLM to provide context-aware nudging, parse friction points, and seamlessly guide users toward the ultimate goal of 66-day habit formation.

**Core thesis:** Individual willpower is a depleting resource; social expectation is a renewable one.

---

## 2. Problem Statement

Existing habit tracking apps fail at scale due to four systemic issues:

| Failure Vector | Example | Why It Kills Retention |
|---|---|---|
| **UX friction** | Habitica's RPG complexity | Tracking the habit becomes harder than the habit itself |
| **Psychological damage** | Duolingo's streak resets | The "what-the-hell" effect — one miss destroys months of investment |
| **Toxic social design** | Strava's global leaderboards | Anxiety, over-exertion, GPS spoofing, beginner alienation |
| **Authenticity void** | Streaks/Loop manual check-boxes | Users lie to preserve streaks, rendering all data fictional |

92% of habit tracking attempts fail within 60 days. No existing app addresses all four vectors simultaneously.

---

## 3. Target Users

- **Primary:** College students and young professionals (18–28) who already have friend groups they communicate with daily (WhatsApp, Discord, etc.)
- **Behavioral profile:** People who want to build habits (fitness, coding, reading, meditation) but lack sustained motivation when working alone
- **Key insight:** These users don't need a new social network — they need a habit layer on top of existing friendships

---

## 4. Design Principles

| Principle | Implementation |
|---|---|
| **Solo + Group** | Users can track habits solo, but the full experience unlocks when they join or create a group. The group is the core product. |
| **Friction Elimination** | Plugin-based automatic tracking wherever possible. Deep-linking to jump straight into the task. One-tap logging where automation isn't possible. Never more than 2 taps to complete a habit. |
| **Collaborative Over Competitive** | No global or inter-group leaderboards. Progress shown as % of personal baseline. Intra-group weekly leaderboard only, based on consistency, not raw output. |
| **Graceful Failure** | Missed days trigger recovery flows, not punishment. Altruistic streak freezes from friends. Streaks pause, never reset to zero. |
| **Personality** | The app has a voice — memes on loading screens, witty notifications, fun copy. It feels like a group chat, not a clinical tool. |

---

## 5. Core Features

### 5.1 Habit Definition & Tracking

**Multiple habits per user:**
Each user can define multiple habits they want to track simultaneously. Habits within a group do NOT need to be the same — one person can track LeetCode + gym, another can track reading + meditation.

**Habit metadata:**
- Name (e.g., "Solve 1 LeetCode problem")
- Intensity: Light / Moderate / Intense (affects XP/Sparks earned)
- Tracking method: Automatic (via plugin) or Manual (one-tap + optional proof)
- Redirect link (optional): A URL that deep-links into the target app when the user taps "Start" (e.g., LeetCode, Kindle, gym playlist). Collapses the steps from intent to action.
- Visibility: Full or Minimal (see 5.3.5)

**Multi-habit rules:**
- Users can add/remove/archive habits at any time.
- Each habit has its own streak, goal progression, and logs.
- "Perfect day" bonus requires ALL active habits to be completed.
- For group chain link calculation, a user counts as "done for the day" if they complete **all** their active habits. This prevents gaming by having one trivial habit carry the group.

**Evaluation:**
Each person is evaluated on whether they completed their own self-defined daily tasks. The system does not compare what habits people do — only whether they did them.

---

### 5.2 Groups (Friend Circles)

**Formation rules:**
- Groups are formed exclusively between known friends. No random/public matchmaking.
- Invite-only via share link or in-app invite.
- Group size: 3–7 members.
- Rationale: Known friends provide natural authenticity verification — they know if you're lying about going to the gym. This eliminates the need for complex AI fraud detection in MVP.

**Group Streak (Collaborative Chain Links):**
- Each day = one "link" in the group's chain.
- A link is forged if **75%+ of the group** completes all their habits that day.
- If 100% complete: **Gold link** (bonus XP/Sparks for all members).
- If 75–99% complete: **Silver link** (standard).
- Below 75%: **Broken link**. The chain pauses but does NOT reset to zero.
- The chain tracks: current streak, longest streak, total links forged.

**Group tiers (based on group streak length):**

| Tier | Streak Required | Perk |
|---|---|---|
| Spark | 0 days | Default |
| Ember | 7 days | Unlock group chat themes |
| Flame | 21 days | Unlock group milestones |
| Blaze | 66 days | Unlock group achievements + bragging badge |

Tiers reflect current consistency and CAN go down if the streak breaks.

---

### 5.3 Social Mechanics

#### 5.3.1 Conditional Nudging

**The rule:** A user must earn the right to nudge. They cannot send a nudge until they have completed their own habits for the day.

**How nudges work:**
1. User A completes all their tasks.
2. User A sees that User B hasn't completed theirs yet.
3. User A taps "Nudge."
4. The nudge request is routed through the LLM, which generates a personalized, context-aware message based on:
   - User B's habit type
   - User B's recent streak/miss pattern
   - Time of day
   - User B's past reflection data (if available)
   - Inferred stress levels (e.g., recognizing pattern fatigue on Thursday evenings)
5. User B receives the nudge as a push notification.

**Example nudge:** "You've mentioned feeling drained by Thursday evenings the last two weeks. Try knocking out your LeetCode problem right after lunch today before the fatigue hits."

**Constraints:** Rate-limited to prevent nudge spam. Sparks cannot buy additional nudges.

#### 5.3.2 Kudos

Group members can send kudos (quick positive reactions) to celebrate someone's completion. Lightweight — a single tap, no text required. Visible in the group feed.

#### 5.3.3 Status + Norm Sequence

Nudges are optimally sequenced to maximize behavioral compliance by pairing social status with normative pressure:

1. **Status (public praise):** When a user hits a milestone, the group sees:
   > "Nitil is on a 7-day streak!"

2. **Norm (peer comparison):** Immediately followed by:
   > "Most people in your group are staying consistent this week."

This specific ordering avoids the "crowding-out" effect and maximizes compliance without triggering resistance.

#### 5.3.4 Altruistic Streak Freezes

- Users accumulate "consistency points" through verified habit completion.
- These points can be spent to grant a **streak freeze for the group** — protecting the group chain when it's about to fail the daily threshold.
- This creates genuine social investment: you're spending earned currency to protect your friends.
- Prevents the "what-the-hell" effect by giving the group a tool to cushion bad days.

#### 5.3.5 Private Habit Sharing

Users can control visibility:
- **Full visibility:** Group sees habit name + completion status + proof
- **Minimal visibility:** Group sees only completion status (done/not done), not what the habit is
- This allows users with sensitive habits (e.g., therapy, medication) to participate without exposure

---

### 5.4 Failure Handling (Grace System)

**When a user misses a task:**

1. **No punitive reset.** The individual's personal streak pauses; it does not reset to zero.
2. **Reason recording:** The app prompts the user to briefly log why they missed (free text or quick-select: sick, busy, forgot, no energy, other).
3. **LLM analysis:** The reason is parsed by the LLM. Over time, the system:
   - Tracks frequency of each reason category
   - Identifies patterns (e.g., "You tend to miss on Thursday evenings")
   - Generates visual graphs of friction points
   - Sends preemptive reminders before predicted failure windows
4. **Recovery nudge:** The next day, the app sends a supportive message + "Ready to get back on track?" with a one-tap restart.
5. **Group notification:** The group sees that the user missed (unless minimal visibility mode) but the framing is supportive, not punitive.

**Evening Cognitive Reflection:**
- A frictionless, one-tap prompt at end of day: "How difficult was today's habit? (1–5)"
- Optional: one-line text reflection
- This data feeds the LLM nudge engine and provides self-monitoring insights over time (PSD: Self-monitoring; BCT: Feedback).

---

### 5.5 Motivation & Engagement

#### 5.5.1 Persona-Driven App Launch Experience

The opening UI adapts based on user behavior profile:

| Profile | Opening Screen Emphasis |
|---|---|
| **Socialiser** | "3 people in your group are relying on you to secure today's chain link." |
| **Achiever** | Stats-forward: streak length, XP progress to next rank, heatmap. |
| **General** | Amplified progress stat + group status. |

**Amplified progress stats:** Framed to make even small progress feel significant.
- Example: "95% of people quit after 12 days. You're on day 14. You are in the top 5%."
- Source: Predefined templates + LLM-generated variants based on user data.

**Quick-start buttons:** One tap per habit to either:
- Open the deep-link redirect (jump straight into the task app)
- Mark the habit as complete (if manual tracking)

**Personality layer:** Memes, motivational quotes, witty loading screens. Toggle-able per user preference.

#### 5.5.2 Notifications

| Type | Description |
|---|---|
| **Morning activation** | Context-aware prompt derived from group activity, not a generic alert. |
| **Friend nudges** | LLM-generated, post-completion only (see 5.3.1). |
| **Preemptive failure prevention** | "You usually miss on Thursdays. Want to knock it out now?" |
| **Meme-based** | Optional toggle. Fun, shareable notification formats. |
| **Motivational Quotes** | Motivational quotes based notification |
---

### 5.6 Plugin System (Automatic Tracking)

**Architecture:**
A generic plugin API that exposes a standard TypeScript interface. Integrations are coded on top of this interface to connect with external APIs.

**Plugin interface:**

```typescript
interface Plugin {
  name: string;
  description: string;
  authenticate(credentials: AuthCredentials): Promise<boolean>;
  fetchTodayStatus(userId: string): Promise<{ completed: boolean; metadata: Record<string, any> }>;
  getProgressData(userId: string, dateRange: DateRange): Promise<ProgressData[]>;
}
```

**MVP integrations (prioritized):**

| Plugin | Habit Type | Data Source |
|---|---|---|
| LeetCode | Coding practice | LeetCode API — check if problem solved today |
| GitHub/Wakapi | Coding time | Commit activity or Wakapi coding time |
| Google Fit | Exercise/steps | Google Fit API |
| Duolingo | Language learning | Duolingo API — daily lesson completion |
| Screen Time | Digital detox | Screen time APIs |
| Manual + Photo | Any | User uploads timestamped photo as proof |

**How it works:**
1. User selects a plugin when defining their habit.
2. User authenticates with the external service (OAuth where available).
3. The system polls the plugin periodically to check completion.
4. If auto-verified, the habit is marked complete with no user action needed.
5. Group members see verification source (e.g., "Verified via LeetCode API").

**Extensibility:** New integrations can be added without modifying core app logic.

---

### 5.7 Gamification & Economy

#### 5.7.1 Two-Currency System

| | **XP** | **Sparks** |
|---|---|---|
| What it is | Lifetime progress score | Spendable in-app currency |
| Earned from | Completing habits, streaks, group milestones | Same actions, same amounts |
| Goes down? | Never | Yes, when spent |
| Determines | Rank (Bronze → Diamond) | What you can purchase |
| Visible to | Everyone (shown on profile) | Only you |

#### 5.7.2 Earning Table

| Action | XP & Sparks |
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

#### 5.7.3 Ranks (Permanent)

| Rank | XP Required |
|---|---|
| Bronze | 0 (default) |
| Silver | 500 |
| Gold | 2,000 |
| Platinum | 5,000 |
| Diamond | 15,000 |

Ranks never decrease. They unlock access to items in the shop (still costs Sparks to buy).

#### 5.7.4 What Sparks Can NEVER Buy

- Streak days (cannot fake progress)
- Rank promotions (XP only)
- Tier promotions (consistency only)
- Social advantages (no pay-to-spam nudges)
- Core features (tracking, groups, feed — always free)

---

### 5.8 Intra-Group Leaderboard (Weekly)

- Ranks users **within** their friend group based on weekly **contribution score**.
- Contribution score = habits completed + bonus for group streak contributions + kudos received.
- Progress displayed as a **percentage of the user's personalized baseline** — a beginner and expert are compared on consistency, not raw output.
- **Resets every week** — fresh start, anyone can come back. Multiple users can tie.
- Week-wise and month-wise views available.
- **No inter-group or global leaderboards.** Groups are not ranked against each other. This avoids incentivizing cross-group cheating where verification is impossible.

---

### 5.9 Goals (Habit Graduation — 66-Day Framework)

Research shows ~66 days to solidify a habit into automaticity. Rather than one intimidating number, the system breaks it into incremental goals per habit:

| Goal | Days | Reward |
|---|---|---|
| Ignition | 3 days | Welcome message + small Spark bonus |
| Foundation | 10 days | Unlock evening reflection feature |
| Momentum | 21 days | Unlock streak flame customization |
| Habit Formed | 66 days | Major XP bonus + "Habit Master" badge + new feature unlocks |

Each goal completion triggers the Status + Norm sequence in the group feed.

---

## 6. Unlockable Shop

Features are unlocked using **Sparks** and gated by **Min Rank**.

### Themes (Full Visual Overhaul)

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

### App Icons (Home Screen)

| Icon | Sparks | Min Rank |
|---|---|---|
| Minimal (monochrome) | 200 | Silver |
| Neon (glowing) | 200 | Silver |
| Gold (gold-accented) | 200 | Gold |

### Streak Flame Styles

| Flame | Sparks | Min Rank |
|---|---|---|
| Default (orange) | — | — |
| Blue flame | 50 | Bronze |
| Purple flame | 50 | Bronze |
| Golden flame | 50 | Silver |
| Pixel fire | 50 | Silver |
| Lightning bolt | 50 | Gold |

### Check Animations (Plays on Habit Completion)

| Animation | Sparks | Min Rank |
|---|---|---|
| Default (ripple) | — | — |
| Water splash | 75 | Bronze |
| Confetti burst | 75 | Bronze |
| Sakura petals | 75 | Silver |
| Pixel explosion | 75 | Silver |
| Lightning strike | 75 | Gold |

### Habit Card Styles

| Style | Sparks | Min Rank |
|---|---|---|
| Default (solid) | — | — |
| Glassmorphic | 100 | Silver |
| Textured paper | 100 | Silver |
| Neon glow border | 100 | Gold |

### Font Packs

| Font | Sparks | Min Rank |
|---|---|---|
| Default (Plus Jakarta Sans) | — | — |
| Monospace | 150 | Silver |
| Handwritten | 150 | Silver |
| Serif | 150 | Gold |

### Background Patterns

| Pattern | Sparks | Min Rank |
|---|---|---|
| None | — | — |
| Dots | 50 | Bronze |
| Grid | 50 | Bronze |
| Waves | 50 | Silver |
| Topographic | 50 | Silver |

---

## 7. Information Architecture

### 7.1 Screen Map

```
App Open
├── Home (The Hub)
│   ├── Motivational stat banner (persona-driven)
│   ├── Daily summary bar (X/Y habits done today)
│   ├── Today's habits (scrollable cards, each with status + complete/deep-link button)
│   ├── Group streak chain visualization
│   └── Quick-start / complete buttons per habit
├── Group
│   ├── Group feed (completions, kudos, nudges, Status+Norm messages)
│   ├── Group streak chain & tier badge
│   ├── Member status grid (done / not done today per member)
│   ├── Weekly intra-group leaderboard
│   ├── Nudge button (enabled only after own completion)
│   └── Altruistic streak freeze button
├── Progress
│   ├── Per-habit streak & chain visualization
│   ├── Heatmap (GitHub-style contribution grid)
│   ├── Goal progress per habit (Ignition → Foundation → Momentum → Formed)
│   ├── Failure pattern insights (LLM-generated graphs)
│   └── Weekly/monthly summary
├── Shop
│   ├── Themes, flames, animations, cards, fonts, patterns, icons
│   ├── Filtered by rank eligibility
│   └── Spark balance
├── Profile
│   ├── XP, Rank badge, Sparks
│   ├── Equipped customizations preview
│   ├── Habit history & archived habits
│   └── Settings (notifications, privacy, plugin connections, meme toggle)
└── Onboarding
    ├── Sign up / login
    ├── Create or join group (invite link) — or start solo
    ├── Define habits (name, intensity, tracking method per habit)
    ├── Connect plugins (if automatic tracking)
    └── Set redirect links (optional, per habit)
```

### 7.2 Data Model

```
User
├── id, name, email, avatar
├── xp, sparks, rank
├── persona_type (socialiser | achiever | general)
├── equipped: { theme, flame, animation, card_style, font, pattern, icon }
├── notification_preferences: { morning, nudges, memes, reflection }
└── created_at

Habit
├── id, user_id
├── name, intensity (light | moderate | intense)
├── tracking_method (plugin | manual)
├── plugin_id (nullable)
├── redirect_url (nullable)
├── visibility (full | minimal)
├── is_active: boolean
├── current_streak, longest_streak
├── goal_stage (ignition | foundation | momentum | formed)
└── created_at

Group
├── id, name, invite_code
├── tier (spark | ember | flame | blaze)
├── current_streak, longest_streak, total_links
└── created_at

GroupMember
├── group_id, user_id
├── role (admin | member)
├── consistency_points
└── joined_at

HabitLog
├── id, habit_id, user_id, date
├── completed: boolean
├── verification_source (plugin_name | manual | photo)
├── reflection_difficulty (1-5, nullable)
├── reflection_text (nullable)
└── completed_at

MissLog
├── id, habit_id, user_id, date
├── reason_category (sick | busy | forgot | no_energy | other)
├── reason_text (nullable)
└── grace_freeze_used: boolean

GroupDayLink
├── id, group_id, date
├── completion_percentage
├── link_type (gold | silver | broken)

Nudge
├── id, sender_id, receiver_id, group_id
├── llm_generated_message
└── sent_at

Kudos
├── id, sender_id, receiver_id, group_id
├── habit_log_id
└── sent_at

ShopItem
├── id, category (theme | flame | animation | card_style | font | pattern | icon)
├── name, spark_cost, min_rank
└── asset_key

UserItem
├── user_id, item_id
├── purchased_at
└── equipped: boolean

WeeklyScore
├── id, user_id, group_id
├── week_start_date
├── contribution_score
└── rank_in_group
```

---

## 8. Technical Architecture

### 8.1 Stack

| Layer | Technology |
|---|---|
| Frontend | **Flutter** (Dart) — cross-platform mobile (iOS + Android) |
| Backend | **TypeScript** (Node.js with Express or Fastify) |
| Database | PostgreSQL |
| Cache | Redis (streaks, leaderboards, session data) |
| ORM |  Drizzle (TypeScript-native, type-safe) |
| LLM | Gemni 2.5 Flash API (nudge generation, reflection parsing, motivational messages, dashbaord message) |
| Auth | Firebase Auth (Flutter has first-class Firebase support) |
| Push Notifications | Firebase Cloud Messaging (FCM) with reddis and bull mq |
| Plugin Runtime | Server-side TypeScript plugin executor with standardized interface |
| Scheduled Jobs |  Bull queues  BULL MQ with reddis |
| Deployment | Backend on my vps docker based setup |

### 8.2 API Endpoints

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
  GET    /habits                          (all user's active habits)
  PATCH  /habits/:id                      (edit name, intensity, redirect_url, visibility)
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
  POST   /groups/:id/freeze              (altruistic streak freeze)

SOCIAL
  POST   /nudge                           (sender → receiver, triggers LLM)
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
  GET    /insights                        (LLM-generated failure patterns)
  GET    /insights/motivation             (persona-driven launch stat)
```

### 8.3 Scheduled Jobs

| Job | Schedule | Function |
|---|---|---|
| Daily streak calculator | 00:05 UTC | Evaluate all groups, forge/break chain links, update tiers, update per-habit streaks and goal stages |
| Plugin poller | Every 2 hours | Check connected plugins for auto-completion |
| Weekly leaderboard reset | Monday 00:00 UTC | Archive previous week scores, reset contribution counters |
| Preemptive nudge generator | 14:00 user-local | LLM analyzes miss patterns, generates preemptive nudges for at-risk users |
| Evening reflection prompt | 21:00 user-local | Push notification for daily reflection |

### 8.4 LLM Integration Points

| Feature | Input to LLM | Output |
|---|---|---|
| **Friend nudge** | Receiver's habit type, streak history, recent misses, time of day, past reflections | Personalized nudge message (1-2 sentences) |
| **Preemptive warning** | User's miss pattern data (day-of-week, time, reasons) | Predictive reminder timed before likely failure window |
| **Launch motivation** | User's streak, rank, group status, persona type | Amplified progress stat or social pressure message |
| **Miss reason parsing** | Free-text reason for missing | Categorized reason + pattern update |
| **Status + Norm** | User milestone data, group completion rates | Paired praise + norm message for group feed |

---

## 9. Behavioral Grounding Summary

Every major feature maps to established psychological research:

| Feature | Psychological Basis |
|---|---|
| Group-first architecture | Social expectation as renewable motivation (SDT: Relatedness) |
| Collaborative chain links (75% rule) | Diffused responsibility without diffused accountability |
| No global individual leaderboard | Avoids "GameFit" toxic comparison; uses "ExploreFit" instead |
| Relative effort mapping | Normalizes progress across skill levels (Fogg: Ability) |
| Altruistic streak freezes | Builds genuine social investment; prevents what-the-hell effect |
| Conditional nudging (earn-to-nudge) | Earned authority model; prevents nudge spam and resentment |
| LLM contextual nudges | MPT approach — personalized, contra-tailoring avoided |
| Status + Norm sequence | Empirically validated highest-compliance nudge ordering |
| Grace system (no reset) | Directly counters the what-the-hell effect |
| Reason tracking + LLM patterns | BCT: Associations and Antecedents; preemptive failure avoidance |
| Evening reflection | PSD: Self-monitoring; BCT: Feedback |
| Goal graduation (3→10→21→66) | Incremental identity building; avoids overwhelming targets |
| Deep-link redirect | Fogg: Maximize Ability by collapsing steps between intent and action |
| Plugin auto-tracking | Fogg: Ability maximization; eliminates manual self-report lying |
| Known-friend-only groups | Natural authenticity verification without AI surveillance |
| Cosmetic-only shop | Extrinsic rewards that don't crowd out intrinsic motivation |
| Persona-driven UI | MPT: Tailored persuasive strategies per user profile; avoids contra-tailoring |
| Meme/personality layer | Reduces perceived app seriousness; lowers psychological barrier to entry |

---

## 10. MVP Scope (Hackathon)

### Must Have (Demo-Ready)

- [ ] User auth + onboarding (Firebase Auth)
- [ ] Create/join group (invite link)
- [ ] Define multiple habits (name, intensity, manual tracking)
- [ ] One-tap habit completion per habit + deep-link redirect
- [ ] Group feed (who completed, who hasn't)
- [ ] Group chain link visualization (gold/silver/broken)
- [ ] Nudge button (post-completion, LLM-generated message via Claude API)
- [ ] XP/Sparks earning on completion
- [ ] Home screen with motivational stat banner + daily habit cards
- [ ] Miss logging with reason (quick-select + free text)
- [ ] At least 1 working plugin integration (LeetCode or GitHub)

### Should Have

- [ ] Weekly intra-group leaderboard with personalized baselines
- [ ] Evening reflection prompt (1-tap difficulty rating)
- [ ] Altruistic streak freeze
- [ ] Shop with 2-3 purchasable themes
- [ ] Rank display on profile
- [ ] Push notifications (morning activation + nudges via FCM)
- [ ] Heatmap progress view (GitHub-style)
- [ ] Goal graduation milestones (3→10→21→66 day)

### Nice to Have

- [ ] Full shop catalog (all themes, flames, animations, cards, fonts, patterns)
- [ ] Multiple plugin integrations (Google Fit, Duolingo, Wakapi)
- [ ] LLM failure pattern insights + graphs
- [ ] Preemptive nudge generation (cron-based)
- [ ] Persona-driven launch screen variants
- [ ] Meme-based notification toggle
- [ ] Solo mode (track habits without a group)

---

## 11. Success Metrics (Post-Hackathon)

| Metric | Target |
|---|---|
| Day-7 retention | > 60% (vs industry ~25%) |
| Habit completion rate within groups | > 70% daily |
| Nudge → completion conversion | > 30% |
| Median streak length | > 21 days |
| User-reported "felt accountable to group" | > 80% |

---

## 12. Open Questions

1. **Habit archival:** Can users archive a habit mid-streak? Does the streak freeze or reset? Does it affect group chain link calculation?
2. **Group member departure:** What happens when a member leaves or goes inactive? Auto-exclude from group % calculation after N days of inactivity?
3. **Max habits per user:** Should there be a cap to prevent XP farming with trivially easy habits?
4. **Plugin auth tokens:** Secure storage and refresh strategy for OAuth tokens from third-party services.
5. **LLM cost management:** Rate limiting and caching strategy for nudge generation at scale.
6. **Streak freeze economics:** How many consistency points to earn/spend? Can multiple freezes stack?
