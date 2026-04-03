# Technical Architecture

---

## 1. System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENT                               │
│                  Flutter (iOS + Android)                     │
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐ │
│  │  Habits   │  │  Social   │  │  Groups   │  │  Profile   │ │
│  │  Module   │  │  Feed     │  │  /Party   │  │  /Settings │ │
│  └──────────┘  └──────────┘  └──────────┘  └────────────┘ │
│         │              │             │              │        │
│         └──────────────┴─────────────┴──────────────┘        │
│                           │                                  │
│                    State Management                          │
│                      (Riverpod)                              │
└───────────────────────────┬──────────────────────────────────┘
                            │ HTTPS / WSS
                            ▼
┌───────────────────────────────────────────────────────────────┐
│                        SERVER                                 │
│                                                               │
│  ┌──────────────────────────────────────────────────────────┐│
│  │                    API Gateway                            ││
│  │               (REST + WebSocket)                          ││
│  └──────────────────────────────────────────────────────────┘│
│         │           │            │            │               │
│  ┌──────┴───┐ ┌─────┴────┐ ┌────┴─────┐ ┌───┴──────┐       │
│  │  Habit   │ │  Social  │ │  Group   │ │Integration│       │
│  │  Service │ │  Service │ │  Service │ │  Service  │       │
│  └──────┬───┘ └─────┬────┘ └────┬─────┘ └───┬──────┘       │
│         │           │            │            │               │
│  ┌──────┴───────────┴────────────┴────────────┴──────┐      │
│  │                  Database Layer                     │      │
│  │              PostgreSQL + Redis                     │      │
│  └───────────────────────────────────────────────────┘      │
│         │                                                    │
│  ┌──────┴──────────────────────────────┐                    │
│  │         External Services           │                    │
│  │  ┌───────┐ ┌────────┐ ┌──────────┐ │                    │
│  │  │  LLM  │ │  FCM   │ │  OAuth   │ │                    │
│  │  │  API  │ │ (Push) │ │Providers │ │                    │
│  │  └───────┘ └────────┘ └──────────┘ │                    │
│  └─────────────────────────────────────┘                    │
└───────────────────────────────────────────────────────────────┘
```

---

## 2. Tech Stack

### Client
| Component | Technology | Rationale |
|---|---|---|
| Framework | Flutter 3.x | Cross-platform, existing codebase |
| Language | Dart | Flutter's native language |
| State Management | Riverpod | Compile-safe, testable, scalable |
| Local Storage | Hive / Isar | Offline-first habit tracking |
| HTTP Client | Dio | Interceptors, retry logic |
| WebSocket | web_socket_channel | Real-time social feed updates |
| Notifications | firebase_messaging | FCM for push notifications |
| Charts | fl_chart | Lookback visualizations |

### Server
| Component | Technology | Rationale |
|---|---|---|
| Runtime | Python (FastAPI) | Rapid development, LLM ecosystem, hackathon speed |
| Database | PostgreSQL | Relational data with complex queries (groups, leaderboards) |
| Cache | Redis | Session management, real-time pub/sub, leaderboard caching |
| Auth | Firebase Auth / JWT | Quick setup, social login support |
| Push Notifications | Firebase Cloud Messaging | Cross-platform push |
| WebSocket | FastAPI WebSocket | Real-time social feed, nudges |
| Task Queue | Celery + Redis | Background jobs: integration polling, notification scheduling, lookback generation |
| LLM | Claude API | Sub-habit generation, failure tips, lookback summaries |
| Object Storage | S3-compatible | Avatar images, achievement badges |

### Infrastructure (Hackathon)
| Component | Technology |
|---|---|
| Hosting | Railway / Render / Fly.io |
| Database hosting | Managed PostgreSQL (Railway / Supabase) |
| Redis | Managed Redis (Upstash / Railway) |
| CI/CD | GitHub Actions (already configured) |

---

## 3. Client Architecture

### 3.1 Module Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
├── core/
│   ├── api/              # API client, interceptors
│   ├── auth/             # Authentication
│   ├── storage/          # Local database
│   ├── notifications/    # Push notification handling
│   └── di/               # Dependency injection
├── features/
│   ├── habits/
│   │   ├── data/         # Repositories, data sources
│   │   ├── domain/       # Models, use cases
│   │   └── presentation/ # Screens, widgets, providers
│   ├── social/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── groups/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── integrations/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── lookbacks/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    ├── widgets/          # Reusable UI components
    ├── utils/            # Helpers
    └── constants/
```

### 3.2 Offline-First Strategy
- All habit data is cached locally (Hive/Isar)
- Habit completion works offline — syncs when connection is restored
- Social features require connectivity (graceful degradation with cached feed)
- Conflict resolution: last-write-wins with server timestamp authority

---

## 4. Server Architecture

### 4.1 Service Structure

```
server/
├── main.py
├── api/
│   ├── routes/
│   │   ├── auth.py
│   │   ├── habits.py
│   │   ├── social.py
│   │   ├── groups.py
│   │   ├── integrations.py
│   │   ├── lookbacks.py
│   │   └── leaderboard.py
│   ├── middleware/
│   │   ├── auth.py
│   │   └── rate_limit.py
│   └── websocket/
│       └── feed.py
├── services/
│   ├── habit_service.py
│   ├── streak_service.py
│   ├── social_service.py
│   ├── group_service.py
│   ├── integration_service.py
│   ├── notification_service.py
│   ├── llm_service.py
│   ├── leaderboard_service.py
│   └── lookback_service.py
├── models/
│   ├── user.py
│   ├── habit.py
│   ├── streak.py
│   ├── group.py
│   ├── friendship.py
│   ├── integration.py
│   └── achievement.py
├── tasks/
│   ├── integration_poller.py
│   ├── notification_scheduler.py
│   ├── streak_calculator.py
│   ├── lookback_generator.py
│   └── leaderboard_updater.py
├── db/
│   ├── database.py
│   └── migrations/
└── config/
    └── settings.py
```

### 4.2 Key Background Jobs

| Job | Frequency | Description |
|---|---|---|
| Integration poller | Every 15 min | Poll Google Fit, WakaTime, etc. for new data |
| Streak calculator | Daily at midnight (per timezone) | Evaluate daily completions, apply freezes, update streaks |
| Group streak evaluator | Daily after streak calculator | Evaluate group thresholds, apply group streak logic |
| Notification scheduler | Continuous | Queue anticipation and social notifications |
| Lookback generator | Weekly (Sunday) / Monthly (1st) | Generate lookback reports using LLM |
| Leaderboard updater | Every hour | Recalculate tier-scoped leaderboards |
| Tier evaluator | Weekly | Check promotion/demotion criteria |

---

## 5. Real-Time Communication

### 5.1 WebSocket Events

| Event | Direction | Payload |
|---|---|---|
| `nudge.received` | Server → Client | `{from_user, habit_name}` |
| `congratulation.received` | Server → Client | `{from_user, milestone}` |
| `streak.frozen` | Server → Client | `{by_user, habit_name}` |
| `group.status_update` | Server → Client | `{completed_count, total, streak}` |
| `feed.new_item` | Server → Client | `{feed_item}` |

### 5.2 Connection Strategy
- WebSocket connection opened on app foreground
- Graceful fallback to polling if WebSocket fails
- Redis pub/sub for cross-instance event distribution

---

## 6. Security

| Concern | Approach |
|---|---|
| Authentication | Firebase Auth (Google, Apple, email) → JWT tokens |
| Authorization | Row-level access control. Users can only access their own data and data shared with them via friendships/groups |
| API rate limiting | Per-user rate limits on social actions (nudge, congratulate) |
| Data privacy | Habit details for private habits are never sent to other users' clients. Only aggregated stats |
| Integration tokens | OAuth tokens stored encrypted. Refresh tokens rotated automatically |
| LLM data | Only habit names and anonymized patterns sent to LLM. No user identifiers |

---

## 7. Scalability Considerations (Post-Hackathon)

- Leaderboard computation moves to materialized views or Redis sorted sets
- WebSocket connections handled by dedicated service with horizontal scaling
- Integration polling moves to event-driven architecture with webhooks where supported
- Database read replicas for leaderboard and feed queries
- CDN for static assets (avatars, achievement images)
