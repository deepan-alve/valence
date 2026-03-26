# Flowcharts

All diagrams are in Mermaid format. Render with any Mermaid-compatible viewer.

---

## 1. Daily Habit Completion Flow

```mermaid
flowchart TD
    A[User opens app] --> B{Habits for today?}
    B -->|Yes| C[Show habit list]
    B -->|No| D[Show rest day message]

    C --> E{User taps habit}
    E -->|Complete| F[Mark completed]
    F --> G[Award points based on effort]
    G --> H{Streak milestone?}
    H -->|Yes| I[Show milestone celebration]
    H -->|No| J[Update streak counter]
    I --> J
    J --> K{All habits done?}
    K -->|Yes| L[Show perfect day message]
    K -->|No| C

    E -->|Skip| M[Show optional cue picker]
    M --> N{User selects cue?}
    N -->|Yes| O[Log cue]
    N -->|No| P[Log skip without cue]
    O --> Q[Show reassurance message]
    P --> Q
    Q --> C

    E -->|Auto-completed| R[Show integration badge]
    R --> J
```

---

## 2. Streak Freeze Flow

```mermaid
flowchart TD
    A[End of day midnight job] --> B{Habit completed today?}
    B -->|Yes| C[Increment streak]
    B -->|No| D{Freeze available?}
    D -->|Yes| E[Auto-apply freeze]
    E --> F[Decrement freeze count]
    F --> G[Log as frozen day]
    G --> H[Streak maintained]
    D -->|No| I{Friend shared freeze?}
    I -->|Yes| J[Apply friend freeze]
    J --> K[Notify user: friend saved streak]
    K --> H
    I -->|No| L[Streak resets to 0]
    L --> M[Show welcome back message]
    M --> N[Display total days + percentage]

    C --> O{Streak milestone reached?}
    O -->|Yes| P[Award bonus points]
    P --> Q[Post to social feed]
    O -->|No| R[Update streak record]
    Q --> R
```

---

## 3. Group Streak Evaluation

```mermaid
flowchart TD
    A[Daily group evaluation job] --> B[Count members who completed at least 1 habit]
    B --> C{Completed count}

    C -->|All members| D[REWARD: Bonus points to all]
    D --> E[Increment group streak]
    E --> F[Post group milestone if applicable]

    C -->|N-1 members| G[MAINTAIN: No bonus]
    G --> E

    C -->|Less than N-1| H[RESET: Group streak to 0]
    H --> I[Post fresh start message]
    I --> J[Individual streaks unaffected]

    F --> K[Notify all members]
    J --> K
    K --> L{Hardcore mode?}
    L -->|Yes| M[Apply avatar damage to incomplete members]
    L -->|No| N[Done]
    M --> N
```

---

## 4. Sub-Habit Generation Flow

```mermaid
flowchart TD
    A[User creates ambitious habit] --> B[User taps 'Break into steps']
    B --> C[Send habit name + description to LLM]
    C --> D[LLM generates sub-habit tree]
    D --> E[Display suggested sub-habits]
    E --> F{User review}
    F -->|Accept all| G[Create sub-habits]
    F -->|Edit some| H[User modifies names/order/weights]
    H --> G
    F -->|Regenerate| C
    G --> I[Sub-habits inherit parent schedule]
    I --> J[Parent progress = weighted sub-habit completion]
```

---

## 5. Integration Auto-Tracking Flow

```mermaid
flowchart TD
    A[Integration poller runs every 15 min] --> B[Fetch data from provider API]
    B --> C{API call successful?}
    C -->|No| D[Log error, retry next cycle]
    C -->|Yes| E[Parse metrics]
    E --> F[Match against user habit thresholds]
    F --> G{Threshold met?}
    G -->|Yes| H{Already completed today?}
    H -->|No| I[Auto-complete habit]
    I --> J[Notify user: habit auto-logged]
    H -->|Yes| K[Skip, already done]
    G -->|No| L[No action]

    D --> M{Token expired?}
    M -->|Yes| N[Attempt token refresh]
    N --> O{Refresh successful?}
    O -->|Yes| B
    O -->|No| P[Mark integration as expired]
    P --> Q[Notify user to reconnect]
    M -->|No| R[Wait for next cycle]
```

---

## 6. Nudge Flow

```mermaid
flowchart TD
    A[User views friend's habits] --> B{Friend has incomplete habit today?}
    B -->|No| C[Nudge button disabled]
    B -->|Yes| D{Already nudged this habit today?}
    D -->|Yes| E[Nudge button disabled with tooltip]
    D -->|No| F[User taps Nudge]
    F --> G[Create nudge record]
    G --> H[Send push notification to friend]
    H --> I[Post to friend's feed]
    I --> J[No points awarded to either party]
```

---

## 7. Tier Promotion/Demotion Flow

```mermaid
flowchart TD
    A[Weekly tier evaluation job] --> B[Calculate user completion rate]
    B --> C{Current tier?}

    C -->|Spark| D{Rate >= 70% for 2 weeks?}
    D -->|Yes| E[Promote to Ember]
    D -->|No| F[Stay in Spark]

    C -->|Ember| G{Rate >= 80% for 4 weeks?}
    G -->|Yes| H[Promote to Flame]
    G -->|No| I{Rate < 70% for 2 weeks?}
    I -->|Yes| J[Grace warning this week]
    I -->|No| K[Stay in Ember]
    J --> L{Was warned last week?}
    L -->|Yes| M[Demote to Spark]
    L -->|No| N[Stay with warning]

    C -->|Flame| O{Rate >= 90% for 8 weeks?}
    O -->|Yes| P[Promote to Blaze]
    O -->|No| Q{Rate < 80% for 2 weeks?}
    Q -->|Yes| R[Grace warning]
    Q -->|No| S[Stay in Flame]

    E --> T[Notify: promoted!]
    H --> T
    P --> T
    M --> U[Notify: tier adjusted gently]
    T --> V[Post to social feed]
```

---

## 8. End-of-Day Notification Flow

```mermaid
flowchart TD
    A[Evening check - 2 hours before user's bedtime] --> B{All habits completed?}
    B -->|Yes| C[Send celebration notification]
    C --> D["Perfect day! Party streak at 14"]

    B -->|No| E{Group threshold at risk?}
    E -->|Yes| F{How many group members completed?}
    F -->|N-1 already done| G["Your group is waiting - 4/5 completed"]
    F -->|Less than N-1| H["5 friends completed theirs today"]
    E -->|No| I[Send gentle anticipation nudge]
    I --> J["Evening meditation in 30 min - streak 5 awaits"]

    K[End of day - midnight] --> L{Habits still incomplete?}
    L -->|Yes| M{Group streak saved by others?}
    M -->|Yes| N["3 friends saved your group streak today"]
    M -->|No| O[Show reassurance + total days completed]
    L -->|No| P[No notification needed]
```

---

## 9. Onboarding Flow

```mermaid
flowchart TD
    A[App installed] --> B[Sign up: Google / Apple / Email]
    B --> C["What's one habit you want to build?"]
    C --> D[User enters habit or picks suggestion]
    D --> E["When do you want to do this?"]
    E --> F[User picks time]
    F --> G[Land on home screen with 1 habit]

    G --> H{Day 2}
    H --> I["Want to add another habit?"]

    G --> J{Day 3}
    J --> K["Invite a friend to keep each other on track?"]

    G --> L{Day 7}
    L --> M["Join a party for shared accountability?"]

    G --> N{Day 14}
    N --> O[Community / leaderboard becomes visible]
```

---

## 10. Negative Habit Tracking Flow

```mermaid
flowchart TD
    A[Negative habit: default state is SUCCESS] --> B{User reports a slip?}
    B -->|No, day passes| C[Auto-mark as succeeded]
    C --> D[Increment streak]

    B -->|Yes| E[User taps 'I slipped']
    E --> F[Show empathetic message]
    F --> G["No worries. What triggered it?"]
    G --> H{User logs cue?}
    H -->|Yes| I[Store cue for pattern analysis]
    H -->|No| J[Skip cue logging]
    I --> K[LLM generates contextual tip]
    J --> K
    K --> L[Show tip in habit detail]
    L --> M[Update streak - partial credit if partial slip]
    M --> N{Pattern detected?}
    N -->|Yes| O[Show insight in next weekly lookback]
    N -->|No| P[Continue tracking]
```

---

## 11. Reward Pool Flow

```mermaid
flowchart TD
    A[User has accumulated points] --> B[User navigates to Rewards]
    B --> C{Reward pool has items?}
    C -->|No| D[Prompt to add rewards]
    D --> E[User adds reward items with point costs]
    C -->|Yes| F{User has enough points?}
    F -->|No| G[Show points needed for cheapest reward]
    F -->|Yes| H[User taps 'Spin']
    H --> I[Deduct points]
    I --> J[Random selection from pool]
    J --> K[Reveal reward with animation]
    K --> L{User response}
    L -->|Redeem now| M[Mark as redeemed]
    L -->|Save for later| N[Add to saved rewards]
```
