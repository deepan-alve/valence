# Third-Party Integrations

Automatic tracking is the single most impactful feature for reducing friction. Users should not have to manually log what another app already knows.

---

## 1. Integration Architecture

```
┌────────────────┐     ┌──────────────────┐     ┌────────────────┐
│  Third-Party   │────>│  Valence Server   │────>│  Habit Auto-   │
│  API / Webhook │     │  Integration Svc  │     │  Completion    │
└────────────────┘     └──────────────────┘     └────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │  User Mapping    │
                       │  (habit → metric)│
                       └──────────────────┘
```

### How It Works
1. User connects a third-party account via OAuth
2. User maps a habit to a metric (e.g., "Run 5km" → Google Fit distance ≥ 5km)
3. Valence server polls or receives webhooks for the metric
4. When the threshold is met, the habit is auto-completed for the day
5. User receives a confirmation notification (not a reminder — they already did the work)

---

## 2. Priority Integrations

### Tier 1 — Hackathon Demo

| Integration | Habits Supported | Data Source | Method |
|---|---|---|---|
| **Google Fit** | Steps, distance, workouts, sleep | Google Fit REST API | OAuth + polling |
| **WakaTime** | Coding time, languages, projects | WakaTime API | API key + polling |

### Tier 2 — Post-Hackathon

| Integration | Habits Supported | Data Source | Method |
|---|---|---|---|
| **Strava** | Running, cycling, swimming | Strava API | OAuth + webhooks |
| **Apple Health** | Steps, workouts, sleep, mindfulness | HealthKit (iOS only) | On-device SDK |
| **GitHub** | Commits, PRs, code reviews | GitHub API | OAuth + webhooks |
| **Duolingo** | Language learning streaks | Duolingo (unofficial) | Scraping / API |
| **LeetCode** | Problems solved | LeetCode API | API + polling |
| **Goodreads** | Books read, pages | Goodreads API | OAuth + polling |
| **Headspace / Calm** | Meditation minutes | Health integrations | Via Apple Health / Google Fit |

### Tier 3 — Future

| Integration | Habits Supported |
|---|---|
| **Spotify** | Practice instrument (detect music playing during scheduled time) |
| **Screen Time APIs** | Reduce phone usage habits |
| **Calendar APIs** | Time-blocked habit scheduling |

---

## 3. Integration Details

### 3.1 Google Fit

**Supported metrics:**
- `com.google.step_count.delta` → Steps
- `com.google.distance.delta` → Distance (km/mi)
- `com.google.activity.segment` → Workout type and duration
- `com.google.sleep.segment` → Sleep duration and quality

**Mapping examples:**
| Habit | Metric | Threshold |
|---|---|---|
| "Walk 10,000 steps" | step_count.delta | ≥ 10,000 |
| "Run 5km" | distance.delta (activity=running) | ≥ 5.0 km |
| "Sleep 7+ hours" | sleep.segment | ≥ 420 min |
| "Exercise 30 min" | activity.segment | ≥ 30 min |

**Negative habit mapping:**
| Habit | Metric | Threshold |
|---|---|---|
| "Don't oversleep" | sleep.segment | ≤ 540 min (9 hrs) |

### 3.2 WakaTime

**Supported metrics:**
- Daily coding time (total)
- Time per project
- Time per language

**Mapping examples:**
| Habit | Metric | Threshold |
|---|---|---|
| "Code for 2 hours" | daily total | ≥ 120 min |
| "Work on side project" | project-specific time | ≥ 30 min |

### 3.3 Strava

**Supported metrics:**
- Activity type, distance, duration, elevation
- Webhook-based real-time updates

**Mapping examples:**
| Habit | Metric | Threshold |
|---|---|---|
| "Cycle 20km" | distance (type=ride) | ≥ 20 km |
| "Swim 1km" | distance (type=swim) | ≥ 1 km |

---

## 4. Custom Integration Framework

For integrations not in the built-in list:

### 4.1 Webhook Receiver
- Valence exposes a per-user webhook URL
- Users can connect IFTTT, Zapier, or custom scripts
- Webhook payload marks a specific habit as completed
- Authentication via per-user token

### 4.2 Manual API Trigger
- Users can call a REST endpoint to mark habit completion
- Useful for power users with custom scripts or home automation

---

## 5. Integration UX

### 5.1 Connection Flow
1. User taps "Connect" on integration card
2. OAuth flow or API key entry
3. User selects which habits to auto-track
4. User configures thresholds per habit
5. Test verification: app checks if today's data is available

### 5.2 Conflict Resolution
- If a habit has both manual and automatic tracking, auto-completion takes priority
- User can override auto-completion (e.g., mark as incomplete if the data was wrong)
- Integration sync status visible in habit detail view

### 5.3 Failure Handling
- If an integration fails to sync, the habit reverts to manual tracking for the day
- User is notified: "Could not sync Google Fit today — you can manually log your run"
- No streak penalty for integration failures — the system assumes good faith
