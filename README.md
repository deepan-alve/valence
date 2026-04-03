# Valence

A group-first social habit tracker built for accountability. Track habits, compete with friends on leaderboards, send nudges, and build streaks together. Uses a 66-day habit formation framework backed by behavioral psychology research.

## Tech Stack

**Client** -- Flutter (Dart), Provider state management, Firebase Auth, Google Sign-In

**Server** -- Hono (TypeScript), Drizzle ORM, PostgreSQL, BullMQ job queue, Gemini 2.5 Flash for LLM nudges

**Infra** -- Docker, Firebase, local notification scheduling

## Features

- Custom habit tracking with daily/weekly frequency and intensity levels
- Group system with shared streaks, leaderboard, nudge and kudos interactions
- 66-day mastery journey with 4 graduation stages (Ignition, Foundation, Momentum, Formed)
- XP and rank progression system with shop cosmetics
- Miss logging with recovery prompts and streak freeze mechanic
- LLM-powered personality nudges via Gemini API
- Plugin architecture for external habit verification (LeetCode, GitHub, Strava)
- Morning/evening/recovery notification scheduling
- Dark (Nocturnal Sanctuary) and light (Daybreak) theme support

## Project Structure

```
valence/
  client/           Flutter app
    lib/
      models/       Data classes (Habit, FeedItem, GroupMember, etc.)
      providers/    ChangeNotifier state (Home, Group, Progress, Profile, Shop)
      screens/      Full screen widgets (Home, Group, Progress, Profile)
      services/     API client, auth, notifications, LLM
      theme/        Design tokens, colors, typography, spacing
      widgets/      Reusable UI components
  server/           Hono API server
    src/
      db/           Drizzle schema and seed
      routes/       REST endpoints (habits, groups, social, users)
      services/     Business logic layer
      middleware/   Auth, rate limiting
      plugins/      External service integrations
      jobs/         BullMQ background workers
  PRD/              Product requirements
  docs/             Specs and research notes
```

## Getting Started

### Prerequisites

- Flutter SDK 3.8+
- Node.js 18+
- Docker (for PostgreSQL and Redis)
- Firebase project with Auth enabled

### Client

```bash
cd client
flutter pub get
flutter run
```

### Server

```bash
cd server
cp .env.example .env   # fill in your DB and Firebase credentials
npm install
docker compose up -d   # starts postgres + redis
npm run db:push
npm run db:seed
npm run dev
```

## Architecture Notes

The client uses Provider with ChangeNotifier for state. Each major screen has its own provider (HomeProvider, GroupProvider, ProgressProvider, etc.) scoped via ChangeNotifierProvider at the screen level. API calls use optimistic UI updates -- the UI changes immediately and reconciles with the server response asynchronously.

The server exposes a REST API via Hono with Firebase token auth middleware. Background jobs (streak calculations, notification triggers) run through BullMQ workers connected to Redis.

## Screenshots

_Coming soon -- the app supports both Daybreak (light) and Nocturnal Sanctuary (dark) themes._

## License

MIT
