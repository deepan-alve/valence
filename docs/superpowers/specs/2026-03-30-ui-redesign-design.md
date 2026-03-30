# Valence UI Redesign — Full Design Specification

**Date:** 2026-03-30
**Approach:** Adaptive Personality (Approach 3) — both light and dark as first-class themes, shared structure, theme token system
**Direction:** Mix of Haptive's structured layout + colorful playful personality from primary designs

---

## 1. Design System Foundation

### 1.1 Typography

| Role | Font | Weight | Size | Usage |
|------|------|--------|------|-------|
| Display | Obviously | Bold | 32px | App title on splash/onboarding |
| H1 | Obviously | Bold | 28px | Screen headers ("Good morning, Diana") |
| H2 | Obviously | Semi-Bold | 22px | Section headers ("Today's Habits", "Group Feed") |
| H3 | Obviously | Semi-Bold | 18px | Card titles, habit names, group names |
| Body Large | Plus Jakarta Sans | Medium | 16px | Primary body text, feed messages |
| Body | Plus Jakarta Sans | Regular | 14px | Descriptions, settings labels, secondary text |
| Caption | Plus Jakarta Sans | Medium | 12px | Timestamps, meta info, chip labels |
| Overline | Plus Jakarta Sans | Semi-Bold | 10px | Category labels, section dividers |
| Numbers Display | Obviously | Bold | 36px | XP counts, streak numbers, big stats |
| Numbers Body | Obviously | Semi-Bold | 16px | Leaderboard scores, small counters |

**Font loading:** Obviously bundled as asset. Plus Jakarta Sans via Google Fonts or bundled.

### 1.2 Color Architecture — Theme Token System

Every color reference in the UI uses a semantic token. Tokens resolve per active theme. This makes adding new themes (shop unlockables) trivial.

#### Token Definitions

| Token | Purpose |
|-------|---------|
| `surface.background` | Full screen background |
| `surface.primary` | Primary surface (cards, sheets) |
| `surface.elevated` | Elevated elements (modals, floating cards) |
| `surface.sunken` | Inset areas (input fields, inactive sections) |
| `accent.primary` | Primary action color (CTA buttons, active states) |
| `accent.secondary` | Secondary action color |
| `accent.success` | Completion, positive states |
| `accent.warning` | Caution, attention needed |
| `accent.error` | Errors, broken chain, destructive actions |
| `accent.social` | Social actions (nudge, kudos, group) |
| `text.primary` | Main readable text |
| `text.secondary` | Supporting/muted text |
| `text.inverse` | Text on accent-colored backgrounds |
| `text.link` | Tappable text links |
| `border.default` | Card borders, dividers |
| `border.focus` | Focused input borders |
| `chain.gold` | Gold chain link |
| `chain.silver` | Silver chain link |
| `chain.broken` | Broken chain link |
| `rank.bronze` | Bronze rank color |
| `rank.silver` | Silver rank color |
| `rank.gold` | Gold rank color |
| `rank.platinum` | Platinum rank color |
| `rank.diamond` | Diamond rank color |

#### Theme: Nocturnal Sanctuary (Dark — Default Dark Option)

| Token | Value | Description |
|-------|-------|-------------|
| `surface.background` | #121220 | Deep space navy |
| `surface.primary` | #1E1E35 | Dark card surface |
| `surface.elevated` | #2A2A48 | Floating elements |
| `surface.sunken` | #0D0D1A | Inset fields |
| `accent.primary` | #F4A261 | Warm amber (the "lamp in a dark room") |
| `accent.secondary` | #E07A5F | Muted terracotta |
| `accent.success` | #B8EB6C | Lime green |
| `accent.warning` | #F7CD63 | Amber |
| `accent.error` | #FF6B6B | Coral red |
| `accent.social` | #FC8FC6 | Pink |
| `text.primary` | #F0E6D3 | Warm parchment white |
| `text.secondary` | #8A8A9A | Muted gray |
| `text.inverse` | #121220 | Dark text on accent backgrounds |
| `text.link` | #F4A261 | Amber links |
| `border.default` | #2D2D4A | Subtle border |
| `border.focus` | #F4A261 | Amber focus ring |
| `chain.gold` | #FFD700 | Gold |
| `chain.silver` | #C0C0C0 | Silver |
| `chain.broken` | #FF6B6B | Red |
| `rank.bronze` | #CD7F32 | Bronze |
| `rank.silver` | #C0C0C0 | Silver |
| `rank.gold` | #FFD700 | Gold |
| `rank.platinum` | #E5E4E2 | Platinum |
| `rank.diamond` | #B9F2FF | Diamond ice blue |

**Dark theme specifics:**
- Cards use subtle 1px border (#2D2D4A) + slight inner glow instead of shadow
- Habit card colors are slightly desaturated for eye comfort but still vibrant
- Background subtle pattern: faint topographic lines at 3% opacity

#### Theme: Daybreak (Light — Default Light Option)

| Token | Value | Description |
|-------|-------|-------------|
| `surface.background` | #FFF8F0 | Warm cream |
| `surface.primary` | #FFFFFF | Clean white cards |
| `surface.elevated` | #FFFFFF | White with shadow |
| `surface.sunken` | #F5EDE3 | Peach-tinted inset |
| `accent.primary` | #4E55E0 | Blue (from primary designs) |
| `accent.secondary` | #7C5CFC | Purple-blue |
| `accent.success` | #4CAF50 | Green |
| `accent.warning` | #F7CD63 | Amber |
| `accent.error` | #FF6B6B | Coral red |
| `accent.social` | #FC8FC6 | Pink |
| `text.primary` | #1A1A2E | Near black |
| `text.secondary` | #6B6B7B | Gray |
| `text.inverse` | #FFFFFF | White text on accent backgrounds |
| `text.link` | #4E55E0 | Blue links |
| `border.default` | #E8E0D8 | Warm gray border |
| `border.focus` | #4E55E0 | Blue focus ring |
| `chain.gold` | #FFD700 | Gold |
| `chain.silver` | #A0A0A0 | Slightly darker silver for light bg |
| `chain.broken` | #FF6B6B | Red |
| `rank.bronze` | #CD7F32 | Bronze |
| `rank.silver` | #A0A0A0 | Silver |
| `rank.gold` | #FFD700 | Gold |
| `rank.platinum` | #8A8A9A | Darker platinum for readability |
| `rank.diamond` | #4FC3F7 | Diamond blue |

**Light theme specifics:**
- Cards use soft shadows (0 2px 8px rgba(26,26,46,0.08))
- Habit card colors are fully saturated and vibrant
- Background subtle pattern: faint dots at 3% opacity

### 1.3 Habit Card Colors (Theme-Independent)

Each habit gets one of these colors. They're vibrant in both themes. On dark theme, cards use these as a subtle gradient tint on the dark surface. On light theme, cards use these as a light wash background.

| Name | Hex | Usage example |
|------|-----|---------------|
| Blue | #4E55E0 | Coding, reading |
| Lime | #B8EB6C | Exercise, health |
| Amber | #F7CD63 | Learning, study |
| Pink | #FC8FC6 | Meditation, mindfulness |
| Orange | #FD6E20 | Financial, productivity |
| Teal | #2EC4B6 | Social, communication |
| Purple | #C9BEFA | Creative, arts |
| Coral | #FF6B6B | Fitness, sports |
| Mint | #6FEDD6 | Wellness, self-care |
| Slate | #64748B | Custom/other |

### 1.4 Spacing & Grid

- **Grid:** 4-column, stretch type, 16px margin, 16px gutter
- **Spacing scale:** 4, 8, 12, 16, 20, 24, 32, 40, 48, 64
- **Border radius:**
  - Small (chips, badges): 8px
  - Medium (buttons, inputs): 12px
  - Large (cards): 16px
  - XL (habit cards, modals): 20px
  - Round (avatars, FAB): 999px

### 1.5 Elevation System

| Level | Light Theme | Dark Theme |
|-------|-------------|------------|
| 0 (flat) | No shadow | No border |
| 1 (card) | 0 2px 8px rgba(0,0,0,0.06) | 1px border surface.border |
| 2 (elevated) | 0 4px 16px rgba(0,0,0,0.10) | 1px border + subtle inner glow |
| 3 (modal) | 0 8px 32px rgba(0,0,0,0.16) | 2px border + ambient glow |
| 4 (overlay) | 0 16px 48px rgba(0,0,0,0.24) | Background dim + card glow |

### 1.6 Icons

- Primary icon set: Phosphor Icons (consistent weight, good Flutter support, playful-yet-clean)
- Size scale: 16px (inline), 20px (list items), 24px (navigation, actions), 32px (feature icons), 48px (empty states)
- Habit category icons: Phosphor set covers coding, fitness, reading, meditation, etc.

### 1.7 Animations & Motion

| Element | Animation | Duration | Curve |
|---------|-----------|----------|-------|
| Page transition | Shared axis (horizontal) | 300ms | easeInOutCubic |
| Card appear | Fade + slide up | 200ms | easeOut |
| Habit completion | Check mark + ripple + color fill | 400ms | spring(damping: 0.6) |
| Chain link forge | Link slides in + flash (gold/silver) | 500ms | easeOutBack |
| Nudge sent | Pulse + fly-out | 350ms | easeOutCubic |
| Kudos | Heart/star burst | 300ms | spring |
| Tab switch | Crossfade + slide | 200ms | easeInOut |
| Pull to refresh | Custom — chain links pulling | 600ms | easeInOut |
| Streak flame | Lottie loop — ambient flame flicker | Loop | — |
| XP gain | Number count-up + sparkle | 500ms | easeOut |
| Theme switch | Crossfade entire surface | 400ms | easeInOut |

**Lottie animations needed:**
- Onboarding mascot scenes (3-4 poses)
- Streak flame variations (default, blue, purple, golden, pixel, lightning)
- Check animations (ripple, water, confetti, sakura, pixel, lightning)
- Chain link forging
- Empty states (no habits, no group, etc.)
- Loading/skeleton shimmer
- Celebration (habit formed at 66 days)

---

## 2. Screen-by-Screen Design

### 2.0 Onboarding (4 screens + setup flow)

**Screen 1 — Splash/Welcome:**
- Full-bleed accent.primary background (blue for light, amber for dark)
- Large Obviously "Valence" title
- Orange mascot illustration — sunglasses character with thumbs up
- Tagline: "Build habits with friends, not willpower"
- "Get Started" button (large, rounded, surface.primary text on accent)
- "I have an account" text link below

**Screen 2 — The Pitch (swipeable carousel, 3 pages):**
- Page A: "Track Together" — mascot with friends illustration. "Your group keeps you accountable. No guilt, just support."
- Page B: "Auto-Verify" — mascot with phone/plugin icons. "Connect LeetCode, GitHub, Duolingo — we track for you."
- Page C: "Never Reset" — mascot with shield. "Miss a day? Your streak pauses, never resets. Grace > guilt."
- Dot indicators at bottom, skip button top-right

**Screen 3 — Theme Picker:**
- "Pick your vibe"
- Two large preview cards side by side:
  - Left: Nocturnal Sanctuary preview (dark card with amber accents, shows mini habit card mock)
  - Right: Daybreak preview (light card with blue accents, shows mini habit card mock)
- Tapping a card selects it with a satisfying scale + border animation
- "You can always change this later" caption below
- Continue button

**Screen 4 — Auth:**
- Sign up with Google (Firebase Auth)
- Sign up with email
- Clean form: name, email, password
- Avatar selection (optional, default generated)
- Terms & privacy links at bottom

**Screen 5 — Habit Setup:**
- "What do you want to build?" header
- Suggested habit templates in a scrollable grid (2-col):
  - Coding (LeetCode icon), Exercise (dumbbell), Reading (book), Meditation (lotus), Language (globe), Custom (+)
- Tapping a template pre-fills name + suggests plugin
- Each selected habit shows: name field, intensity picker (Light/Moderate/Intense as chips), tracking method toggle (Auto via Plugin / Manual)
- "Add another habit" button
- Can add 1-5 habits here, more later

**Screen 6 — Group Setup:**
- "Better with friends" header with mascot holding a chain
- Two paths:
  - "Create a Group" → name input + generates invite link/QR
  - "Join a Group" → paste invite link or scan QR
  - "Go Solo for Now" → subtle text link (not a button, de-emphasized)
- If creating: share sheet opens with invite link after creation

### 2.1 Home Screen (Tab 1)

**Top section:**
- Greeting: "Good morning, [Name]" in H1 Obviously Bold
- Subtitle: persona-driven motivational line
  - Socialiser: "3 friends completed today. Your turn."
  - Achiever: "Day 14 — top 5% of habit builders."
  - General: "4/6 habits done. Almost there."
- Right side: notification bell (with badge count) + avatar (taps to Profile)

**Daily progress bar:**
- Horizontal bar showing X/Y habits completed today
- Fills with accent.success color as habits complete
- "Perfect day" sparkle animation when 100%

**Week day selector:**
- Horizontal scroll of 7 days (Mon-Sun)
- Current day highlighted with accent.primary circle fill
- Past days show: green dot (all done), amber dot (partial), red dot (missed), gray (future)
- Tapping a past day shows that day's completion status

**Habit cards (main content — scrollable):**
- 2-column grid of cards (matching your primary designs layout)
- Each card:
  - Habit color as left border (dark) or light wash background (light)
  - Habit icon (from Phosphor set) top-left
  - Completion circle/checkbox top-right
  - Habit name (H3 Obviously)
  - Subtitle: goal text ("Read 20 pages", "Solve 1 problem")
  - If plugin-tracked: small "Auto" badge with plugin icon
  - If completed: checkmark animation plays, card fades to success state
  - If has redirect link: tapping the card opens the deep link, long-press marks complete
  - If manual: tapping the card marks complete

**Group streak chain (below habits):**
- Horizontal chain visualization
- Last 7 days as chain links: gold (glowing), silver (matte), broken (gap with red X)
- Current streak count: "🔥 12-day streak" with flame Lottie
- Group tier badge (Spark/Ember/Flame/Blaze) next to streak
- Tapping opens Group tab

**Bottom navigation bar:**
- 5 tabs: Home, Group, Progress, Shop, Profile
- Icons from Phosphor set
- Active tab: accent.primary color + label visible
- Inactive: text.secondary color, label hidden
- Center tab (Progress) slightly larger or differentiated
- Subtle top border on light theme, subtle glow on dark theme

### 2.2 Group Screen (Tab 2)

**Header:**
- Group name (H1) + tier badge (Spark/Ember/Flame/Blaze with icon)
- Group streak: chain link count + flame animation
- "Invite" button (share icon) top-right

**Member status grid:**
- Horizontal scrollable row of member avatars
- Each avatar:
  - Green ring = all habits done today
  - Amber ring = partial
  - Gray ring = not started
  - Small number badge showing X/Y habits done
- Tapping a member shows their habit list (respecting visibility settings — minimal shows only done/not done)

**Action buttons (below member grid):**
- "Nudge" button — enabled only when user has completed all their habits. Disabled state shows "Complete your habits first"
- "Streak Freeze" button — shows consistency points balance. Tapping confirms spending points.
- "Kudos" — contextual, appears next to completed member's entry in feed

**Group feed (main scrollable content):**
- Reverse chronological timeline
- Feed item types:
  - Completion: "[Avatar] [Name] completed [Habit Name] ✓" + "Verified via LeetCode" badge if plugin + kudos button
  - Nudge: "[Name] nudged [Name]: '[LLM message]'"
  - Kudos: "[Name] sent kudos to [Name]"
  - Status+Norm: "🔥 Nitil is on a 7-day streak!" followed by "Most of your group is staying consistent this week."
  - Chain link: "Today's link: 🥇 Gold! Everyone showed up." or "Silver link — 4/5 completed." or "Broken link today."
  - Milestone: "[Name]'s [Habit] reached Foundation (10 days)!"
  - Streak freeze: "[Name] used a streak freeze to protect the chain."
- Minimal visibility habits show: "[Name] completed a habit ✓" (no habit name)

**Weekly leaderboard (collapsible section):**
- Rank | Avatar | Name | Contribution Score | Bar chart
- "Based on your personal consistency, not raw output" caption
- Week/Month toggle tabs
- Tied ranks allowed, shown equally

### 2.3 Progress Screen (Tab 3)

**Tab bar at top:** Per-Habit | Overview

**Per-Habit tab:**
- Habit selector: horizontal scroll of habit chips (colored by habit color)
- Selected habit shows:

  **Streak section:**
  - Large streak number (Numbers Display) + flame Lottie
  - Current streak / Longest streak / Total days completed

  **Goal graduation:**
  - Visual progress bar: Ignition (3d) → Foundation (10d) → Momentum (21d) → Formed (66d)
  - Current stage highlighted, upcoming stages grayed
  - Days remaining to next milestone

  **Heatmap (GitHub-style):**
  - 12-week grid, each cell = one day
  - Color intensity based on completion (empty = missed, light = partial, full = completed)
  - Uses habit's assigned color
  - Scrollable horizontally for history

  **Frequency chart:**
  - Bar chart: completion rate by day-of-week (Mon-Sun)
  - Highlights strongest and weakest days

  **Failure insights (LLM-generated):**
  - Card: "You tend to miss on Thursday evenings"
  - Card: "Most common reason: No energy (45%)"
  - Pie chart: reason category breakdown
  - Only shows after enough data (>14 days)

**Overview tab:**
- Overall completion rate (large % number)
- All habits as a stacked bar chart (weekly view)
- Weekly/monthly summary cards
- Total XP earned, current rank progress bar
- "Best week" and "Current week" comparison

### 2.4 Shop Screen (Tab 4)

**Header:**
- Sparks balance (large number + spark icon)
- Current rank badge + progress to next rank

**Category tabs (horizontal scroll):**
Themes | Flames | Animations | Card Styles | Fonts | Patterns | App Icons

**Each category shows a grid/list of items:**
- Item card:
  - Preview thumbnail (visual preview of the item)
  - Item name
  - Spark cost + rank requirement badge
  - If owned: "Equip" / "Equipped" toggle
  - If locked by rank: grayed out with "Requires [Rank]" label
  - If affordable: "Buy" button with spark cost
  - If too expensive: spark cost in red

**Theme previews:**
- Full-screen preview when tapping a theme card
- Shows a mock Home screen in that theme's colors
- "Buy & Apply" or "Equip" button at bottom

**Font previews:**
- Shows sample text in each font: "The quick brown fox" + numbers "1,234 XP"
- Currently equipped font highlighted

### 2.5 Profile Screen (Tab 5)

**Profile header:**
- Large avatar (editable)
- Username
- Rank badge (Bronze/Silver/Gold/Platinum/Diamond) with progress bar to next
- XP total | Sparks balance
- Member since date

**Equipped customizations preview:**
- Visual card showing current theme + flame + card style + font
- "Customize" button → links to Shop

**Stats summary:**
- Total habits tracked
- Total days completed
- Longest streak (any habit)
- Perfect days count
- Habits graduated (reached 66 days)

**Habit management:**
- Active habits list with edit/archive actions
- Archived habits list (collapsible)

**Plugin connections:**
- Connected plugins with status (green = active, red = auth expired)
- "Connect Plugin" button → plugin list

**Settings:**
- Notification preferences (morning, nudges, memes, reflection — toggles)
- Privacy (habit visibility defaults)
- Persona type (Socialiser/Achiever/General — affects Home screen)
- Theme switcher (quick toggle, or go to Shop for more)
- Meme/personality layer toggle
- Account (email, password, delete account)
- About / Support / Licenses

### 2.6 Habit Detail (Modal / Full Screen from Home)

Opened by long-pressing a habit card or tapping "details."

- Habit name (H1) + color indicator
- Edit button (pencil icon)
- Intensity badge (Light/Moderate/Intense)
- Tracking method: Plugin name + status or "Manual"
- Redirect link (if set): "Open [App Name]" button
- Visibility toggle (Full/Minimal)

**Stats section (mini version of Progress per-habit):**
- Streak + flame
- Goal graduation progress
- Mini heatmap (last 4 weeks)
- Completion rate %

**Recent logs:**
- Last 7 days: date + completed/missed + verification source
- If missed: reason shown

**Actions:**
- Archive habit
- Delete habit (with confirmation)
- Share habit stats

### 2.7 Habit Create/Edit (Bottom Sheet / Full Screen)

- "New Habit" / "Edit Habit" header
- Fields:
  - Name (text input, required)
  - Description (text input, optional)
  - Icon picker (grid of Phosphor icons, colored circles — matching your Haptive icon grid design)
  - Color picker (horizontal scroll of 10 color options as circles)
  - Intensity: Light / Moderate / Intense (segmented control)
  - Tracking: Manual / Auto (toggle)
    - If Auto: plugin selector dropdown → auth flow
  - Redirect URL (optional text input, with "Test Link" button)
  - Frequency: Every day / Custom days (day-of-week checkboxes)
  - Visibility: Full / Minimal (toggle with explanation text)
  - Reminder time (time picker, optional)
- Save button (accent.primary, full width)
- Cancel / Delete (if editing)

### 2.8 Nudge Flow (Within Group Screen)

1. User taps "Nudge" button next to an incomplete member
2. Bottom sheet appears: "Nudge [Name]?"
3. Shows LLM-generated preview message (editable? or fixed — PRD says LLM generates it)
4. "Send Nudge" button
5. Sent confirmation: brief toast + fly-out animation
6. Rate limited: if already nudged this person today, button shows "Already nudged today"

### 2.9 Evening Reflection (Push Notification → In-App)

- Push notification at 21:00 local: "How was today? Quick check-in."
- Opens a minimal bottom sheet:
  - "How difficult were today's habits?" — 5 emoji faces (1=easy to 5=very hard)
  - One-line text input: "Anything on your mind?" (optional)
  - "Done" button
- Frictionless: one tap + optional text, < 10 seconds

### 2.10 Miss Logging (Triggered when day ends incomplete)

- Gentle notification: "Missed [Habit Name] today. Want to log why?"
- Opens bottom sheet:
  - Quick-select chips: Sick | Busy | Forgot | No Energy | Other
  - Optional text: "Tell us more" (free text)
  - "Log" button
  - "Skip" text link (de-emphasized)
- Supportive copy: "No judgment. This helps us help you."

### 2.11 Notifications (Various)

All notifications use the personality layer (if enabled):
- **Morning activation:** "Rise and grind — or at least rise. [Name] already knocked out 2 habits."
- **Friend nudge:** "[Name] says: [LLM message]"
- **Preemptive:** "Thursday evening — your kryptonite. Knock out [Habit] now?"
- **Meme-based (optional):** Fun image + motivational text
- **Chain update:** "Gold link forged! Everyone showed up today 🥇"

---

## 3. Component Library

### 3.1 Core Components Needed

| Component | Variants | Notes |
|-----------|----------|-------|
| `ValenceButton` | Primary, Secondary, Ghost, Danger | Respects theme tokens |
| `ValenceCard` | Flat, Elevated, Habit (colored) | Theme-aware elevation |
| `HabitCard` | Default, Completed, Missed, Locked | 2-col grid item with color + icon + checkbox |
| `ChainLink` | Gold, Silver, Broken | Lottie-powered, used in chain visualization |
| `ChainStrip` | — | Horizontal row of 7 ChainLinks |
| `MemberAvatar` | Default, Completed, Partial, Inactive | Ring color indicates status |
| `MemberGrid` | — | Horizontal scroll of MemberAvatars |
| `FeedItem` | Completion, Nudge, Kudos, StatusNorm, ChainUpdate, Milestone, Freeze | Timeline card variants |
| `StreakFlame` | Default + unlockable variants | Lottie animation |
| `GoalProgress` | — | 4-stage progress bar (Ignition→Formed) |
| `Heatmap` | — | GitHub-style grid, uses habit color |
| `DaySelector` | — | Horizontal week scroll with status dots |
| `ThemePreview` | — | Mini mock screen in theme colors |
| `ShopItemCard` | Available, Locked, Owned, Equipped | Preview + price + action |
| `RankBadge` | Bronze, Silver, Gold, Platinum, Diamond | Icon + label |
| `TierBadge` | Spark, Ember, Flame, Blaze | Group tier indicator |
| `SparkBalance` | — | Spark icon + animated count |
| `XPProgress` | — | Rank progress bar with current/next rank |
| `IntensityChip` | Light, Moderate, Intense | Segmented selector |
| `PluginBadge` | Connected, Expired, Available | Status indicator |
| `NudgeButton` | Enabled, Disabled, Sent | Context-aware states |
| `ReflectionSheet` | — | Bottom sheet with emoji scale + text input |
| `MissLogSheet` | — | Bottom sheet with reason chips + text |
| `TabBar` | — | 5-tab bottom nav with theme awareness |
| `EmptyState` | No Habits, No Group, No Data | Illustration + CTA |
| `SkeletonLoader` | Card, List, Chart | Shimmer effect per theme |
| `Toast` | Success, Info, Warning, Error | Brief overlay messages |

### 3.2 Theme-Aware Architecture

```
AppTheme (Provider)
├── ThemeData (Flutter Material theme generated from tokens)
├── ValenceTokens (custom ThemeExtension)
│   ├── colors: ValenceColors (all semantic tokens)
│   ├── typography: ValenceTypography (all text styles)
│   ├── spacing: ValenceSpacing (spacing scale)
│   ├── radii: ValenceRadii (border radius scale)
│   └── elevation: ValenceElevation (shadow/glow per level)
├── ActiveThemeId (string — "nocturnal_sanctuary", "daybreak", etc.)
└── UserEquipped (flame, animation, card_style, font, pattern)
```

Every widget reads from `ValenceTokens` via `Theme.of(context).extension<ValenceTokens>()`. No hardcoded colors anywhere.

---

## 4. Navigation Architecture

```
MaterialApp
├── SplashScreen (→ Onboarding if new user, → MainShell if logged in)
├── OnboardingFlow (PageView with 6 screens)
│   ├── WelcomeScreen
│   ├── PitchCarousel (3 pages)
│   ├── ThemePicker
│   ├── AuthScreen (signup/login)
│   ├── HabitSetup
│   └── GroupSetup
└── MainShell (Scaffold with BottomNavigationBar)
    ├── HomeScreen (Tab 0)
    ├── GroupScreen (Tab 1)
    ├── ProgressScreen (Tab 2)
    ├── ShopScreen (Tab 3)
    └── ProfileScreen (Tab 4)

Modal routes (pushed on top):
├── HabitDetailScreen
├── HabitCreateEditSheet
├── NudgeSheet
├── ReflectionSheet
├── MissLogSheet
├── PluginConnectSheet
├── GroupInviteSheet
└── SettingsScreen
```

**State management:** Keep Provider (existing codebase uses it). Add new ViewModels for:
- `ThemeViewModel` — manages active theme, token resolution, equipped customizations
- `GroupViewModel` — group feed, member status, chain, leaderboard
- `ShopViewModel` — items, purchase flow, equip flow
- `OnboardingViewModel` — flow state, selections
- `NudgeViewModel` — nudge state, rate limiting
- `ReflectionViewModel` — reflection state

---

## 5. Asset Requirements

### 5.1 Illustrations (AI-generated or commissioned)
- Mascot: Welcome pose (thumbs up), Teaching pose (pointing), Shield pose (protecting), Celebrating pose (confetti), Meditating pose
- Empty states: No habits yet, No group yet, No data yet, All done today (celebration)

### 5.2 Lottie Animations
- Streak flames: 6 variants (default orange, blue, purple, golden, pixel, lightning)
- Check animations: 6 variants (ripple, water, confetti, sakura, pixel, lightning)
- Chain link forging: gold flash, silver matte, broken crack
- Loading shimmer
- XP count-up sparkle
- Celebration (66-day graduation)
- Pull-to-refresh chain pull

### 5.3 Fonts
- Obviously (Bold, Semi-Bold) — bundled
- Plus Jakarta Sans (Regular, Medium, Semi-Bold, Bold) — bundled
- Shop fonts: Monospace, Handwritten, Serif — bundled but locked

### 5.4 Icons
- Phosphor Icons Flutter package
- Custom: Valence logo, Spark currency icon, chain link icon

---

## 6. Accessibility

- All text meets WCAG 2.1 AA contrast ratios in both themes
- Touch targets minimum 44x44px
- Screen reader labels on all interactive elements
- Reduced motion mode: disable Lottie, use simple crossfades
- Font scaling support (up to 1.5x)
- Semantic colors — don't rely on color alone for status (use icons + labels)
