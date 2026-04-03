# UX Principles

---

## 1. Design Philosophy

**"Would someone your age use this without hesitation?"**

Valence targets 18-30 year olds who have tried and abandoned habit apps. They are skeptical of corporate wellness language, allergic to guilt, and fluent in social app patterns. The app must feel like a group chat about getting better — not a clinical self-improvement tool.

---

## 2. Core UX Rules

### 2.1 One-Tap Everything
- Complete a habit: one tap
- Nudge a friend: one tap
- Congratulate: one tap
- Skip logging: optional, one tap from a pre-populated list
- If an action takes more than 2 taps, it must justify itself

### 2.2 Progressive Disclosure
- New user sees: habit list, add button, check-off
- After 3 days: social features appear (add friends prompt)
- After 7 days: groups/parties suggested
- After 14 days: community/leaderboard visible
- Sub-habits, integrations, reward pools: available from settings but not promoted until relevant

### 2.3 Information Hierarchy
- **Primary:** Did I do my habits today? (habit list with check states)
- **Secondary:** How is my group doing? (group status bar)
- **Tertiary:** What is happening socially? (feed)
- **Buried:** Leaderboard, detailed stats, settings

---

## 3. Tone of Voice

### Do
- "Morning run starts in 15 min — streak 12 is calling"
- "You completed 47 of the last 50 days. That is 94%."
- "Welcome back! Ready for day 48?"
- "3 friends saved your group streak today"
- "Your group is waiting for you — 4/5 completed"
- "Mondays are tough for gym — want a lighter sub-habit?"
- "No worries — understanding why helps us help you"

### Never
- "You missed your habit today"
- "Your streak is broken"
- "You are falling behind"
- "X is ahead of you — catch up!"
- "You failed to complete..."
- "Don't give up!"
- "You can do better"
- Generic motivational quotes

### Principles
- **Specific over generic.** "Streak 12" not "Keep going"
- **Forward-looking over retrospective.** "Ready for day 48?" not "You missed day 47"
- **Social proof over guilt.** "5 friends completed theirs" not "You haven't done yours"
- **Warm, not corporate.** Contractions allowed. Short sentences. No exclamation marks on failures
- **Data-driven, not preachy.** "94% completion rate" not "You're doing great!"

---

## 4. Visual Design Guidelines

### 4.1 Color Psychology
- **Success states:** Warm greens and teals (not aggressive bright green)
- **Streak counters:** Gradient that intensifies with streak length (amber → deep orange → gold)
- **Missed states:** Neutral gray, never red. Red = alarm = guilt
- **Social actions:** Soft blue (nudge), warm yellow (congratulate)
- **Negative habits:** Purple tones (distinct from positive, not alarming)

### 4.2 Animations
- Habit completion: satisfying micro-animation (check mark with ripple)
- Streak milestone: brief celebration (confetti, but not excessive)
- Group status: smooth progress bar fill
- No animation on failure/skip — silence is more respectful than a sad animation

### 4.3 Typography
- Clean, modern sans-serif
- Streak numbers: bold, large, unmistakable
- Body text: comfortable reading size
- No ALL CAPS except in achievement badges

---

## 5. Key Screens

### 5.1 Home (Daily View)
```
┌──────────────────────────────┐
│  Good morning, Arjun         │
│  ┌────────────────────────┐  │
│  │ Party: 3/5 completed   │  │
│  │ ████████░░  streak: 14 │  │
│  └────────────────────────┘  │
│                              │
│  Today's habits              │
│  ┌────────────────────────┐  │
│  │ ✓  Morning run  🔥12   │  │
│  │ ○  Read 30 min         │  │
│  │ ✓  No doomscrolling ▮  │  │
│  │ ○  Meditate     🔥5    │  │
│  │    └ Breathwork  ○     │  │
│  │    └ Body scan   ○     │  │
│  └────────────────────────┘  │
│                              │
│  ┌────────────────────────┐  │
│  │ + Add habit             │  │
│  └────────────────────────┘  │
│                              │
│  ━━━━━━━━━━━━━━━━━━━━━━━━  │
│  🏠 Home  👥 Social  📊 Me  │
└──────────────────────────────┘
```

### 5.2 Social Feed
```
┌──────────────────────────────┐
│  Social                      │
│                              │
│  Today                       │
│  ┌────────────────────────┐  │
│  │ Riya hit 30 days of    │  │
│  │ journaling!      [🎉]  │  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ Karan froze your       │  │
│  │ meditation streak      │  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ Party streak: 14 days! │  │
│  └────────────────────────┘  │
│                              │
│  Yesterday                   │
│  ┌────────────────────────┐  │
│  │ You nudged Arjun about │  │
│  │ morning run             │  │
│  └────────────────────────┘  │
│                              │
│  ━━━━━━━━━━━━━━━━━━━━━━━━  │
│  🏠 Home  👥 Social  📊 Me  │
└──────────────────────────────┘
```

### 5.3 Streak Break Screen (What NOT to do vs. What to do)

**Wrong:**
```
😢 Streak Broken!
Your 47-day meditation streak has ended.
[Start Over]
```

**Right:**
```
Welcome back!
You've meditated 47 of the last 50 days — that's 94%.
Ready for day 48?

[Continue]     [See tips]
```

---

## 6. Accessibility

- Minimum tap target: 48x48dp
- Color is never the only indicator (icons + color for status)
- Screen reader labels on all interactive elements
- Reduced motion setting respected (skip animations)
- Dark mode support from day one
- Font size respects system accessibility settings

---

## 7. Onboarding Flow

1. **Sign up** (Google/Apple/email — one tap)
2. **"What is one habit you want to build?"** (single text field + suggestions)
3. **Set time** ("When do you want to do this?")
4. **Done.** User lands on home screen with one habit
5. Day 2: "Want to add another?" prompt
6. Day 3: "Invite a friend?" prompt
7. Day 7: "Join a party?" prompt

No feature tour. No 5-screen walkthrough. The app teaches by doing.

---

## 8. Anti-Patterns We Explicitly Reject

| Anti-Pattern | Why It Fails | Our Alternative |
|---|---|---|
| Feature tour on first open | Users skip it, learn nothing | Contextual hints as features become relevant |
| Settings pages with 50 toggles | Cognitive overload | Smart defaults, minimal settings |
| Red badges on missed habits | Guilt, anxiety, app avoidance | Gray state, no badge |
| "Share to Twitter" on every milestone | Feels like growth hacking | In-app celebrations with friends |
| Daily reminder at fixed time | Becomes noise, gets muted | Anticipation-based, tied to habit schedule |
| Full-screen interstitials | Hostile UX | Inline cards, dismissible |
