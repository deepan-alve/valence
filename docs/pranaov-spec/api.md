# API Design

All endpoints are prefixed with `/api/v1`. Authentication is via Bearer token (JWT from Firebase Auth).

---

## 1. Authentication

| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/register` | Register with Firebase token, create user profile |
| POST | `/auth/login` | Exchange Firebase token for session |
| GET | `/auth/me` | Get current user profile |

---

## 2. Habits

| Method | Endpoint | Description |
|---|---|---|
| GET | `/habits` | List user's habits (active, optionally include archived) |
| POST | `/habits` | Create a new habit |
| GET | `/habits/{id}` | Get habit detail with streak info |
| PUT | `/habits/{id}` | Update habit |
| DELETE | `/habits/{id}` | Archive habit (soft delete) |
| POST | `/habits/{id}/complete` | Log completion for today |
| POST | `/habits/{id}/skip` | Log skip with optional cue |
| GET | `/habits/{id}/logs` | Get completion history |
| GET | `/habits/{id}/streak` | Get streak details |

### Sub-Habits

| Method | Endpoint | Description |
|---|---|---|
| GET | `/habits/{id}/subhabits` | List sub-habits |
| POST | `/habits/{id}/subhabits` | Create sub-habit manually |
| POST | `/habits/{id}/subhabits/generate` | LLM-generate sub-habits |
| PUT | `/habits/{id}/subhabits/{sub_id}` | Update sub-habit |
| DELETE | `/habits/{id}/subhabits/{sub_id}` | Remove sub-habit |

### Streak Freezes

| Method | Endpoint | Description |
|---|---|---|
| POST | `/habits/{id}/freeze` | Use a freeze on this habit |
| POST | `/habits/{id}/freeze/share` | Share a freeze with a friend's habit |

---

## 3. Social

### Friends

| Method | Endpoint | Description |
|---|---|---|
| GET | `/friends` | List friends |
| POST | `/friends/request` | Send friend request (by username or invite code) |
| POST | `/friends/{id}/accept` | Accept friend request |
| POST | `/friends/{id}/reject` | Reject friend request |
| DELETE | `/friends/{id}` | Remove friend |
| GET | `/friends/{id}/habits` | Get friend's public habit summaries |

### Interactions

| Method | Endpoint | Description |
|---|---|---|
| POST | `/social/nudge` | Nudge a friend about a habit |
| POST | `/social/congratulate` | Congratulate a friend on a milestone |

### Feed

| Method | Endpoint | Description |
|---|---|---|
| GET | `/feed` | Get social feed (paginated) |
| POST | `/feed/{id}/read` | Mark feed item as read |

---

## 4. Groups (Parties)

| Method | Endpoint | Description |
|---|---|---|
| GET | `/groups` | List user's groups |
| POST | `/groups` | Create a group |
| GET | `/groups/{id}` | Get group detail with streak and members |
| PUT | `/groups/{id}` | Update group settings |
| DELETE | `/groups/{id}` | Dissolve group (owner only) |
| POST | `/groups/{id}/join` | Join via invite code |
| POST | `/groups/{id}/leave` | Leave group |
| GET | `/groups/{id}/streak` | Get group streak history |
| GET | `/groups/{id}/daily` | Get today's group status |
| GET | `/groups/{id}/feed` | Get group activity feed |

---

## 5. Integrations

| Method | Endpoint | Description |
|---|---|---|
| GET | `/integrations` | List available integrations and connection status |
| POST | `/integrations/{provider}/connect` | Initiate OAuth flow |
| POST | `/integrations/{provider}/callback` | OAuth callback |
| DELETE | `/integrations/{provider}` | Disconnect integration |
| POST | `/integrations/{provider}/sync` | Force manual sync |
| GET | `/integrations/{provider}/status` | Get sync status |

### Webhook Receiver

| Method | Endpoint | Description |
|---|---|---|
| POST | `/webhooks/{user_token}/complete` | External webhook to mark habit complete |

---

## 6. Leaderboard

| Method | Endpoint | Description |
|---|---|---|
| GET | `/leaderboard` | Get tier-scoped leaderboard (7-day or 30-day) |
| GET | `/leaderboard/position` | Get current user's position |

Query params: `window=7d|30d`

---

## 7. Lookbacks

| Method | Endpoint | Description |
|---|---|---|
| GET | `/lookbacks/weekly` | Get weekly lookback report |
| GET | `/lookbacks/monthly` | Get monthly lookback report |
| GET | `/lookbacks/weekly/group/{id}` | Get group weekly lookback |

---

## 8. Points & Rewards

| Method | Endpoint | Description |
|---|---|---|
| GET | `/points` | Get point balance and history |
| GET | `/rewards` | List reward pool items |
| POST | `/rewards` | Add reward to pool |
| PUT | `/rewards/{id}` | Update reward |
| DELETE | `/rewards/{id}` | Remove reward |
| POST | `/rewards/spin` | Spend points to draw from reward pool |

---

## 9. Achievements

| Method | Endpoint | Description |
|---|---|---|
| GET | `/achievements` | List all achievements with earned status |
| GET | `/achievements/earned` | List only earned achievements |

---

## 10. Notifications

| Method | Endpoint | Description |
|---|---|---|
| GET | `/notifications` | List notifications (paginated) |
| POST | `/notifications/{id}/read` | Mark as read |
| PUT | `/notifications/settings` | Update notification preferences |

---

## 11. LLM Endpoints

| Method | Endpoint | Description |
|---|---|---|
| POST | `/llm/subhabits` | Generate sub-habits for a habit |
| POST | `/llm/tips` | Get tips for a missed/relapsed habit |
| POST | `/llm/effort` | Classify habit effort level |

---

## Common Response Patterns

### Success
```json
{
  "status": "ok",
  "data": { ... }
}
```

### Paginated
```json
{
  "status": "ok",
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 142,
    "has_next": true
  }
}
```

### Error
```json
{
  "status": "error",
  "error": {
    "code": "HABIT_NOT_FOUND",
    "message": "The requested habit does not exist"
  }
}
```

---

## Rate Limits

| Endpoint Group | Limit |
|---|---|
| General API | 100 req/min per user |
| Social actions (nudge, congratulate) | 30 req/min per user |
| LLM endpoints | 10 req/min per user |
| Integration sync | 5 req/min per user |
| Webhook receiver | 60 req/min per token |
