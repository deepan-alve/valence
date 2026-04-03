# Psychology & Behavioral Grounding

This document maps every major feature decision to established psychological research. The evaluation criterion is: *Does the solution apply psychological principles based on real-world scenarios?*

---

## 1. The Habit Loop (Duhigg / Clear)

**Principle:** Every habit follows a Cue → Routine → Reward loop. Sustainable habit apps must support all three stages — not just logging the routine.

**Application in Valence:**
- **Cue:** Anticipation-based notifications act as cues ("Running starts in 15 mins — streak 12 is waiting")
- **Routine:** Low-friction tracking via integrations (auto-log from Google Fit, WakaTime) reduces the gap between doing and recording
- **Sub-habits:** Break ambitious habits into smaller routines. Completing sub-habits gives intermediate reward signals, maintaining the loop even when the full habit feels overwhelming
- **Reward:** Points, congratulations from friends, visual streak growth, unlockable rewards from user-defined reward pools

---

## 2. Self-Determination Theory (Deci & Ryan)

**Principle:** Intrinsic motivation requires three things — autonomy, competence, and relatedness.

| Need | How Valence addresses it |
|---|---|
| **Autonomy** | Users define their own habits, choose which to share, set their own reward pools. Private habits exist. No forced social exposure. |
| **Competence** | Tiered progression system. Users are matched with peers at similar levels. Sub-habits make large goals feel achievable. Weekly lookbacks highlight growth. |
| **Relatedness** | Party system, group streaks, nudges, congratulations. Habits become shared experiences, not isolated checkboxes. |

---

## 3. Social Facilitation & Social Loafing

**Principle:** People perform better on simple/practiced tasks when observed (social facilitation), but may slack off in groups where individual contribution is hidden (social loafing).

**Application in Valence:**
- Individual contributions within group streaks are visible (percentage completed, personal streak)
- Group streak thresholds require "at least N-1" members — not all, not just one. This prevents both free-riding and single-point-of-failure anxiety
- Full group completion earns a bonus reward, creating positive pressure without punishing partial effort

---

## 4. Loss Aversion & Streak Toxicity (Kahneman & Tversky)

**Principle:** Losses are felt ~2x more intensely than equivalent gains. Long streaks create massive loss aversion — users feel devastated when they break, leading to app abandonment.

**Application in Valence:**
- **Streak freezes** act as insurance. Earned through consistent engagement, shareable by friends
- **Friends can freeze your streak** — social safety net
- **On streak break:** Show the days succeeded, not the gap. "You completed 47 of the last 50 days — that is 94%." Never "You broke your 47-day streak."
- **Continue button** after a break — no reset-to-zero psychology. The streak counter shows both "current" and "longest" without emphasizing the delta

---

## 5. Implementation Intentions (Gollwitzer)

**Principle:** "I will do X at time Y in location Z" is significantly more effective than "I will do X."

**Application in Valence:**
- Habit creation prompts for when and where, not just what
- Notifications fire relative to the user's stated schedule
- Sub-habits inherit scheduling from parent habits by default
- LLM-generated sub-habits include suggested timing

---

## 6. The Fresh Start Effect (Milkman et al.)

**Principle:** People are more likely to pursue goals at temporal landmarks (new week, new month, birthday).

**Application in Valence:**
- Weekly and monthly lookbacks create natural reset points
- Tier promotions serve as fresh starts with new peer groups
- After a streak break, the "continue" framing creates a mini fresh start without penalizing history

---

## 7. Cognitive Load Theory (Sweller)

**Principle:** Excessive information and choices degrade decision-making and engagement. The TU Wien Habits Network study confirmed that complexity is the primary barrier to sustained self-tracking.

**Application in Valence:**
- **Earned complexity:** New users see only core habit tracking. Social features, sub-habits, integrations, and advanced gamification reveal progressively
- **Sub-habit interface:** Parent habit shows a single progress bar. Sub-habits are expandable, not always visible
- **Group mechanics:** Simple "did my group survive today?" status. Detailed contribution breakdowns are one tap deeper
- **Notifications:** Maximum 3 per day. Quality over quantity

---

## 8. Negative Habit Psychology (Marlatt & Gordon — Relapse Prevention)

**Principle:** Relapse in negative habits (smoking, oversleeping, drinking) follows predictable patterns. The "abstinence violation effect" — a single slip leads to full relapse because the person catastrophizes the failure.

**Application in Valence:**
- Negative habits (e.g., "avoid oversleeping", "no alcohol") are first-class citizens
- On a slip: LLM provides tips specific to the relapse pattern, not generic advice
- Cue tracking: When a negative habit is triggered, the app asks what led to it (optional, low-friction). Over time, patterns surface and the app can preemptively nudge
- No binary "failed/succeeded" for negative habits — track reduction, not perfection

---

## 9. Social Comparison Theory (Festinger)

**Principle:** People evaluate themselves by comparing to others. Upward comparison (against better performers) can motivate or demoralize. Downward comparison provides comfort but not growth.

**Application in Valence:**
- **Tiered communities** ensure comparison happens among peers of similar level
- **Leaderboards show percentage completion**, not absolute counts — normalizing across different habit difficulties
- **Private habits** contribute to personal stats but are excluded from social comparison
- **Promotion to higher tiers** happens when a user is consistently above their current peer group — they graduate to a more challenging cohort
- Rankings are visible but never pushed via notifications. Users seek them out; the app does not weaponize them

---

## 10. Positive Psychology — Broaden-and-Build (Fredrickson)

**Principle:** Positive emotions broaden awareness and encourage novel actions. Negative emotions narrow focus to survival behaviors (like uninstalling the app).

**Application in Valence:**
- End-of-day check-in: If habits are incomplete, show "3 of your friends saved your group streak" or "5 friends completed theirs — your group is waiting for you." Never "You failed today."
- Congratulations are pushed to social feeds — celebrations are public, failures are private
- Monthly lookbacks emphasize trends and wins, not individual missed days
- Tone of all copy is warm, specific, and forward-looking
