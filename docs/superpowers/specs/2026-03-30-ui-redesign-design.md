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
| 1 (card) | 0 2px 8px rgba(0,0,0,0.06) | 1px border border.default |
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

### 2.0 Onboarding (7 screens)

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

**Screen 7 — Notification Permission:**
- Mascot with bell illustration
- "Stay in the loop"
- Bullet points: Friend nudges, Morning motivation, Streak milestones
- "Enable Notifications" primary button → system permission dialog
- "Maybe Later" text link

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
- Past days show status via color AND icon (never color alone for accessibility):
  - All done: green dot + small ✓ icon
  - Partial: amber dot + small "~" icon
  - Missed: red dot + small ✗ icon
  - Future: gray, no icon
- Tapping a past day shows that day's completion status

**Habit cards (main content — scrollable):**
- 2-column grid of cards (matching your primary designs layout)
- Each card:
  - Habit color as left border (dark) or light wash background (light)
  - Habit icon (from Phosphor set) top-left
  - Completion circle/checkbox top-right (always tappable — this is THE completion action)
  - Habit name (H3 Obviously)
  - Subtitle: goal text ("Read 20 pages", "Solve 1 problem")
  - If plugin-tracked: small "Auto" badge with plugin icon
  - If completed: checkmark animation plays, card fades to success state

**Gesture matrix (consistent across all habit types):**

| Gesture | Manual | Manual+Photo | Plugin | Redirect |
|---------|--------|-------------|--------|----------|
| Tap checkbox (top-right) | Marks complete | Opens photo proof sheet | Disabled ("Auto-tracked") | Marks complete |
| Tap card body | Opens habit detail | Opens habit detail | Opens habit detail | Opens redirect URL (deep link) |
| Long-press card | Opens habit detail | Opens habit detail | Opens habit detail | Opens habit detail |
| Swipe left | Quick archive | Quick archive | Quick archive | Quick archive |

- The **checkbox** is always the completion action. The **card body** is always navigation (detail or redirect).
- Plugin-tracked habits: checkbox shows a lock icon with "Auto" label — not tappable. Completion happens via plugin poll.
- Redirect habits: card body opens the external URL. Checkbox is separate and always visible for manual override.
- After returning from a redirect URL: no "Did you complete it?" prompt. User taps the checkbox when ready.

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
- Each avatar (color + icon for accessibility — never color alone):
  - Green ring + ✓ badge = all habits done today
  - Amber ring + number badge (e.g., "3/5") = partial
  - Gray ring + "–" badge = not started
  - 💤 badge = inactive (3+ days no activity)
- Tapping a member shows their habit list (respecting visibility settings — minimal shows only done/not done)

**Per-member actions (on each member avatar or in member detail):**
- "Nudge" icon-button — appears on incomplete members only. Enabled only when user has completed all their own habits. Disabled state tooltip: "Complete your habits first."
- "Kudos" icon-button — appears on completed members only. One-tap, no text required.
- Nudge and Kudos are **per-member**, not global buttons.

**Group-level actions (below member grid):**
- "Streak Freeze" button — shows consistency points balance. Tapping confirms spending points.
- "Invite" button — share invite link/QR

**Group feed (main scrollable content):**
- Reverse chronological timeline
- Feed item types:
  - Completion: "[Avatar] [Name] completed [Habit Name] ✓" + "Verified via LeetCode" badge if plugin + kudos button
  - Miss (supportive): "[Name] had a tough day. Send them some support?" + kudos button. (Framing is supportive, not punitive. Only shown if habit visibility is Full.)
  - Nudge: "[Name] nudged [Name] 💪" (LLM-generated message is private — only the receiver sees the full text via push notification. Feed shows only that the nudge happened, to protect privacy since nudges are built from personal reflection/stress data.)
  - Kudos: "[Name] sent kudos to [Name]"
  - Status+Norm: "🔥 Nitil is on a 7-day streak!" followed by "Most of your group is staying consistent this week."
  - Chain link: "Today's link: 🥇 Gold! Everyone showed up." or "Silver link — 4/5 completed." or "Broken link today."
  - Milestone: "[Name]'s [Habit] reached Foundation (10 days)!"
  - Streak freeze: "[Name] used a streak freeze to protect the chain."
- Minimal visibility habits show: "[Name] completed a habit ✓" (no habit name)

**Weekly leaderboard (collapsible section):**
- Primary metric: **% of personal baseline** (not raw score). Each member's progress is normalized against their own historical average — a beginner completing 3/3 habits at 100% ranks equally with an expert completing 8/8 at 100%.
- Display: Rank | Avatar | Name | Consistency % (large) | Bar chart (% fill)
- Tapping a row expands to show raw contribution breakdown (see 2.30)
- Week/Month toggle tabs
- Previous weeks viewable via horizontal swipe (archived scores)
- Tied ranks allowed, shown equally
- Monday morning: brief "Last week's MVP" card at top showing #1 from previous week

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
- Archive habit (with confirmation: "Archive [Habit]? Your streak will be preserved but paused. You can unarchive later." This answers PRD open question 12.1.)
- Share habit stats (generates shareable card — see 2.16 streak milestone format)

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
  - Visibility: Full / Minimal (toggle with explanation text: "Minimal: group only sees done/not done, not the habit name")
- Save button (accent.primary, full width)
- Cancel / Archive (if editing — no hard delete, only archive per PRD)

**Note:** Habits are always daily. No custom frequency — PRD defines "perfect day" and group chain as "all active habits today." Custom days would break this math.

### 2.8 Nudge Flow (Within Group Screen)

1. User taps "Nudge" icon on an incomplete member's avatar in the member grid
2. Bottom sheet appears: "Nudge [Name]?"
3. Shows LLM-generated preview message (read-only — user cannot edit. PRD specifies LLM generates context-aware messages from private data; allowing edits would defeat the purpose.)
4. "Send Nudge" button
5. Sent confirmation: brief toast + fly-out animation
6. Rate limited: if already nudged this person today, button shows "Already nudged today"

### 2.9 Evening Reflection (Push Notification → In-App)

**Unlocks at Foundation stage (10 days) per habit.** Habits that haven't reached Foundation don't prompt reflection. This is a PRD-defined unlock — not available from day 1.

- Push notification at 21:00 local: "Quick reflection on today's habits?"
- Opens a minimal bottom sheet with **per-habit reflection** (stored per HabitLog, not per day):
  - For each Foundation+ habit completed today:
    - Habit name + color chip
    - "How difficult?" — 5 labeled faces: Easy (1), Okay (2), Moderate (3), Hard (4), Brutal (5). Labels visible for accessibility (not emoji-only).
    - One-line text input: "Anything on your mind?" (optional)
  - If multiple habits: vertically stacked, scrollable. Each habit is independent.
  - "Done" button at bottom
- Frictionless: one tap per habit + optional text, < 15 seconds total
- If no habits have reached Foundation yet: no reflection prompt sent

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

### 2.12 Solo Mode UX (No Group)

When a user has no group, the app still works fully for individual habit tracking:

**Home screen changes:**
- Group streak chain section replaced with a personal streak chain (tracks consecutive perfect days)
- Below the personal chain: a persistent banner — "Better with friends" card with mascot illustration + "Create a Group" / "Join a Group" buttons
- Banner is dismissible but reappears weekly

**Group tab (Tab 2) — Empty state:**
- Full-screen illustration: mascot looking at an empty chain, slightly sad
- Headline: "Habits stick better together"
- Body: "Create a group with 2-6 friends. You'll hold each other accountable."
- "Create a Group" primary button
- "Join with Invite Link" secondary button
- Social proof line: "Groups with 4+ members have 3x better retention"

**Progress screen:**
- Works identically — all per-habit stats are available
- Overview tab shows individual data only, no group comparison

**Nudge/Kudos:**
- Not available in solo mode. These features only appear when user is in a group.

**Leaderboard:**
- Hidden entirely in solo mode

### 2.13 Plugin Connection Flow

**Entry points:** Habit Create/Edit screen (Auto toggle), Profile → Plugin Connections

**Plugin list screen:**
- Grid of available plugins, each as a card:
  - Plugin icon + name (LeetCode, GitHub, Duolingo, etc.)
  - One-line description: "Track daily problem solving"
  - Status: "Connect" button / "Connected" green badge / "Reconnect" amber badge (expired)

**Connection flow (per plugin):**
1. Tap "Connect" → bottom sheet explains what data will be accessed
2. "Authorize" button → opens in-app browser for OAuth flow (or credential form for non-OAuth plugins like LeetCode)
3. Loading state: "Connecting to [Plugin]..." with spinner
4. Success: green check animation + "Connected! We'll automatically track your [habit type]."
5. Failure: error message + "Try Again" button + "Connect Manually" fallback link

**Auth expired state:**
- Plugin badge turns amber with "!" icon
- Notification: "[Plugin] connection expired. Tap to reconnect."
- Tapping opens a simplified re-auth flow (remembers previous credentials where possible)

**Disconnection:**
- In Profile → Plugin Connections, swipe left on a connected plugin → "Disconnect" red button
- Confirmation: "Disconnect [Plugin]? Your habit will switch to manual tracking."

### 2.14 Photo Proof Upload (Manual + Photo Tracking)

When a habit uses "Manual + Photo" tracking method:

**Completion flow:**
1. Tap habit card → bottom sheet: "Mark as complete"
2. Camera/gallery buttons: "Take Photo" (opens camera) or "Choose from Gallery"
3. Photo preview with crop option
4. Timestamp auto-stamped on photo (bottom-right overlay, semi-transparent)
5. Optional: one-line caption ("Post-gym selfie")
6. "Submit" button → uploads photo + marks habit complete

**In group feed:**
- Completion shows photo as an expandable thumbnail
- "[Name] completed Gym ✓ 📸" — tapping photo opens full-screen viewer
- Photo visible only if habit visibility is "Full" — Minimal visibility hides photo

**Photo storage:**
- Compressed to max 500KB before upload
- Stored on server, referenced by habit_log_id
- Retained for 90 days, then auto-deleted (storage management)

### 2.15 Deep-Link Redirect UX

When a habit has a redirect URL configured:

**Home screen habit card:**
- Shows a small "→" arrow badge on the card body (distinguished from the checkbox)
- Follows the gesture matrix from 2.1: card body tap opens the redirect URL, checkbox marks complete

**Redirect flow:**
1. Tap card body → brief loading indicator (200ms)
2. App launches external URL (LeetCode, Kindle, Spotify, etc.)
3. When user returns to Valence: no prompt. The checkbox is always available on the Home screen for when the user is ready to mark complete.
4. If plugin-tracked: the plugin poller handles completion automatically — no user action needed.
5. If user doesn't return within 2 hours and habit is still incomplete: gentle push notification "Still working on [Habit]? Mark it done when you're ready."

### 2.16 XP/Sparks Earning Feedback

**On habit completion:**
- Floating "+X XP  +X Sparks" text animates upward from the completed habit card
- Text uses Numbers Body (Obviously Semi-Bold 16px) in accent.primary color
- Fades out after 1.5s
- XP/Spark values based on intensity: Light (+5), Moderate (+10), Intense (+20)

**On perfect day (all habits completed):**
- Full-width celebration banner slides down from top:
  - "Perfect Day! +25 bonus XP" with confetti Lottie animation
  - Banner auto-dismisses after 3s or tap to dismiss
  - Background briefly flashes accent.success at 10% opacity

**On streak milestone (7/30/100 days):**
- Modal overlay:
  - Large streak number with flame Lottie (scaled up)
  - "[Habit Name] — 7-day streak!" in Display font
  - "+30 XP  +30 Sparks" below
  - Confetti/sparkle animation background
  - "Keep going!" button dismisses
  - Share button: generates a shareable streak card image

### 2.17 Rank-Up Ceremony

When user's total XP crosses a rank threshold (500/2000/5000/15000):

- Full-screen modal with dim background
- New rank badge animates in (scale from 0 → 1.2 → 1.0 with spring)
- "Rank Up!" in Display font
- Old rank → New rank transition animation (badge morphs)
- Unlocked perks listed: "You can now access [items] in the Shop"
- Sparkle/glow Lottie animation around the badge
- "Awesome!" button to dismiss
- Share button for social media

### 2.18 Group Tier-Up Moment

When group streak reaches a tier milestone (7d Ember, 21d Flame, 66d Blaze):

- Appears in group feed as a special full-width card:
  - Tier badge (large, animated — fire gets bigger with each tier)
  - "Your group reached Flame! 🔥" in H1
  - "21-day streak. You're building something real."
  - Perk unlocked: "Group chat themes unlocked" / "Group milestones unlocked" / etc.
  - All members see this simultaneously
- Push notification to all members: "Your group just hit [Tier]! 🔥🔥🔥"

### 2.19 66-Day Graduation Ceremony (Habit Formed)

The biggest celebration in the app — this is THE moment:

- Full-screen takeover (not a modal — a dedicated screen)
- Mascot in celebration pose (confetti, party hat)
- Large animated badge: "Habit Master" with shimmer effect
- Habit name in Display font
- Stats recap card:
  - Total days completed
  - Longest streak
  - Total XP earned from this habit
  - Times friends nudged you
- "This habit is now part of who you are." — personality copy
- Major XP bonus animation (+500 XP counting up)
- "Share Your Achievement" button → generates shareable card with stats
- "Archive" / "Keep Tracking" buttons below
- Status+Norm message sent to group feed

### 2.20 Streak Freeze Confirmation Flow

**Entry:** "Streak Freeze" button on Group screen

1. Button shows current consistency points balance (e.g., "❄️ Freeze (42 pts)")
2. Tap → bottom sheet:
   - "Use a Streak Freeze?"
   - "This will protect today's group chain link if the group falls below 75%."
   - Cost: "[X] consistency points" (exact cost TBD from PRD open questions)
   - Current balance shown
   - "Use Freeze" primary button + "Cancel" ghost button
3. On confirm:
   - Points deducted with count-down animation
   - Toast: "Streak freeze activated! Your group is protected today."
   - Feed notification: "[Name] used a streak freeze to protect the chain ❄️"
4. If already used today: button shows "Freeze Active Today ❄️" (disabled)
5. If insufficient points: button shows balance in red, tapping shows "You need [X] more points. Keep completing habits to earn them."

### 2.21 Group Management

**Admin actions (group creator):**
- Settings gear icon in Group screen header → Group Settings sheet:
  - Edit group name
  - View/copy invite link
  - Regenerate invite link
  - Member list with roles:
    - Tap member → "Remove from Group" (with confirmation: "Remove [Name]? Their data stays but they'll need a new invite to rejoin.")
    - Transfer admin role
  - "Disband Group" (destructive, red button, double confirmation: "This cannot be undone. All group streaks and chain data will be lost.")

**Member leaving:**
- Profile → Settings → "Leave Group" (or swipe in group list if multi-group)
- Confirmation: "Leave [Group Name]? Your personal habit data is preserved, but you'll lose access to group features."
- After leaving: Group tab shows empty state (same as solo mode)
- Group feed shows: "[Name] left the group."
- Group % calculation adjusts immediately (denominator decreases)

**Inactive member handling:**
- After 3 consecutive days of zero completions with no miss logs:
  - Member's avatar gets a "💤" badge in member grid
  - Group % calculation auto-excludes inactive members
  - Feed message: "[Name] seems to be taking a break."
  - After 7 days: admin gets a prompt "Remove inactive member?"
  - Member can return anytime by simply completing a habit — inactive flag clears

### 2.22 QR Code Group Join

**Creating a group (QR generation):**
- Group Setup screen (onboarding) and Group Settings both have "Share Invite"
- Tapping shows a sheet with:
  - QR code (large, centered, using accent.primary color instead of black)
  - Invite link text (tappable to copy)
  - "Share" button → native share sheet with link
  - QR code has Valence logo watermark in center

**Joining a group (QR scanning):**
- "Join a Group" → two options:
  - "Paste Invite Link" — text input
  - "Scan QR Code" — opens camera
- Camera permission request (first time): "Valence needs camera access to scan group invite QR codes"
- Scanner screen: camera viewfinder with rounded-corner overlay frame
- On successful scan: shows group preview card (group name, member count, tier) + "Join" button
- On invalid QR: "This doesn't look like a Valence invite. Try again or paste the link."

### 2.23 Permission Requests

**Notification permission (during onboarding, after Group Setup):**
- Dedicated screen (not a system popup alone):
  - Mascot with a bell illustration
  - "Stay in the loop"
  - "Get nudges from friends, streak reminders, and celebration alerts"
  - Bullet points: "Friend nudges", "Morning motivation", "Streak milestones"
  - "Enable Notifications" primary button → triggers system permission dialog
  - "Maybe Later" text link → skips, can enable in Settings later

**Camera permission (on first QR scan or photo proof):**
- System dialog with context already provided by the UI text above it

### 2.24 Personality Layer (Meme Toggle)

**When ON (default):**
- Loading screens: random motivational meme/quote with mascot illustration
- Notifications: witty copy ("Rise and grind — or at least rise")
- Empty states: playful copy ("Your habits are lonely. Give them friends.")
- Feed messages: fun framing ("Nitil is COOKING 🔥 7-day streak!")
- Completion toast: randomized fun messages ("Beast mode activated", "One more in the bag")

**When OFF:**
- Loading screens: clean spinner only
- Notifications: factual copy ("You have 3 habits to complete today")
- Empty states: straightforward copy ("No habits tracked yet. Create one to get started.")
- Feed messages: neutral framing ("Nitil reached a 7-day streak")
- Completion toast: simple "Habit completed"

**Toggle location:** Profile → Settings → "Personality & Fun" toggle
**Visual indicator:** When personality is ON, the app icon on splash screen wears the mascot sunglasses. When OFF, plain logo.

### 2.25 Loading & Error States

**Per-screen skeleton loaders:**
- **Home:** 2-col grid of shimmer cards (match habit card dimensions) + shimmer bar for progress + shimmer circles for day selector
- **Group:** Shimmer avatar row + shimmer feed items (3 placeholder cards)
- **Progress:** Shimmer chart area + shimmer stat numbers
- **Shop:** Shimmer category tabs + shimmer grid items
- **Profile:** Shimmer avatar circle + shimmer stat row + shimmer list items

**Error states:**
- **Network error:** Full-screen: sad mascot illustration + "Can't reach the server" + "Retry" button + "You can still view cached data" link (if cache available)
- **API error:** Inline error card within the screen: "Something went wrong loading [section]" + "Retry" + collapse to not block other content
- **Empty data:** Contextual illustration + actionable CTA (see EmptyState component)

**Pull-to-refresh:** Available on Home, Group, Progress screens. Custom animation: chain links pulling apart and snapping back.

### 2.26 Offline Behavior

- **Cached data:** Last-fetched home screen, habit list, group feed cached in SQLite
- **Offline indicator:** Subtle banner at top of screen: "You're offline. Changes will sync when connected." (accent.warning background)
- **Offline actions allowed:**
  - Mark habits as complete (queued for sync)
  - View cached progress/stats
  - View cached group feed
  - Log miss reasons
- **Offline actions blocked (with explanation):**
  - Send nudges ("Nudges need an internet connection")
  - Purchase shop items
  - Connect plugins
  - Create/join groups
- **Sync on reconnect:**
  - Queued completions sent in order
  - Brief toast: "Synced! [X] updates sent."
  - If conflict (e.g., plugin already marked complete while offline): server wins, no duplicate

### 2.27 Multi-Group Support

The PRD doesn't limit users to one group. UI handles multiple groups:

**Group tab with multiple groups:**
- Top of Group screen: horizontal scroll of group chips (group name + tier badge)
- Active group highlighted, others muted
- Tapping a chip switches the displayed group feed/leaderboard/member grid
- "+" chip at end → "Create New Group" / "Join a Group"

**Home screen with multiple groups:**
- Group streak chain section shows the primary group's chain (user can set primary in settings)
- Small "2 groups" badge → tapping shows group switcher

**Notifications:**
- Group-specific notifications are prefixed with group name: "[Study Squad] Gold link forged!"

**Limits:**
- Max 3 groups per user (prevents XP farming across many groups)
- Each group independently tracks its own chain, tier, leaderboard

### 2.28 Amplified Progress Stats

Persona-driven motivational stats on the Home screen subtitle:

**Rendering:**
- Below the greeting, in Body Large (Plus Jakarta Sans Medium 16px), text.secondary color
- Stat number itself in accent.primary color and Obviously Semi-Bold for emphasis

**Examples by persona:**

Socialiser:
- "3 of 5 friends completed today. Don't let them down."
- "Your group has a 12-day chain. You're the link today."
- "You nudged 3 friends this week. Social MVP."

Achiever:
- "Day 14 — only 8% of users make it this far."
- "Your completion rate: 94%. Top 3% of Valence."
- "12 XP from Silver rank. One good day."

General:
- "4/6 habits done. Two more for a perfect day."
- "3-day streak. 4 more to Ember tier."
- "You've completed 89 habits total. That's not nothing."

**Rotation:** LLM generates 3-5 variants daily at the preemptive nudge generation cron job (14:00 local). App cycles through them across the day. Fallback to predefined templates if LLM unavailable.

### 2.29 Recovery Nudge UX

The day after a miss:

**Push notification (morning):**
- Personality ON: "Yesterday was rough. Today's a fresh page. 📖"
- Personality OFF: "Ready to get back on track? Your habits are waiting."
- Tapping opens the app to Home screen

**In-app (Home screen):**
- A soft card appears above the habit grid (dismissible):
  - Warm accent.warning background at 10% opacity
  - Mascot in encouraging pose (arms open)
  - "Yesterday didn't go as planned. That's okay."
  - "Your streak is paused, not lost. Pick up where you left off."
  - "Let's go" button (accent.primary) → scrolls to habit cards
  - "×" to dismiss

**If missed 3+ consecutive days:**
- Recovery card becomes more prominent:
  - "It's been [X] days. Your group still has your back."
  - "Start with just one habit today. Small wins."
  - Shows the easiest (Light intensity) habit as a single large card with prominent complete button

### 2.30 Contribution Score Breakdown (Leaderboard Detail)

In the weekly leaderboard, tapping a member's score row expands it:

**Expanded view:**
| Category | Points | Breakdown |
|----------|--------|-----------|
| Habits Completed | 45 | 9 habits × 5 days |
| Group Streak Contributions | 15 | Present for 5 gold/silver links |
| Kudos Received | 8 | Received 8 kudos from friends |
| Perfect Days | 10 | 2 perfect days × 5 bonus |
| **Total** | **78** | |

- Bar chart showing this week vs. last week comparison
- "Based on your personal baseline" caption
- Collapse by tapping again

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
| `XPGainOverlay` | — | Floating "+X XP +X Sparks" animation |
| `PerfectDayBanner` | — | Celebration banner with confetti |
| `RankUpModal` | — | Full-screen rank-up ceremony |
| `TierUpCard` | — | Group tier milestone feed card |
| `GraduationScreen` | — | Full-screen 66-day celebration |
| `StreakMilestoneModal` | — | 7/30/100 day streak celebration |
| `RecoveryCard` | — | Post-miss encouragement card |
| `OfflineBanner` | — | "You're offline" indicator |
| `PermissionRequest` | Notification, Camera | Pre-permission explanation screen |
| `QRScanner` | — | Camera viewfinder with overlay frame |
| `QRDisplay` | — | QR code with Valence branding |
| `PhotoProofSheet` | — | Camera/gallery picker + preview + submit |
| `DeepLinkReturn` | — | "Did you complete it?" bottom sheet |
| `GroupChip` | Active, Inactive | Group switcher chip for multi-group |
| `GroupSettingsSheet` | — | Admin management (rename, remove, disband) |
| `ContributionBreakdown` | — | Expandable leaderboard score detail |
| `PersonalityToggle` | — | On/off with preview of copy style change |
| `PluginConnectSheet` | — | OAuth flow + status display |
| `InviteShareSheet` | — | QR + link + share button |

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
└── UserEquipped (flame, animation, card_style, font, pattern, app_icon)
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
├── PluginConnectSheet (OAuth browser + status)
├── PluginListScreen
├── GroupInviteSheet (QR display + share)
├── GroupSettingsSheet (admin management)
├── QRScannerScreen (camera viewfinder)
├── PhotoProofSheet (camera/gallery + preview)
├── DeepLinkReturnSheet ("Did you complete it?")
├── SettingsScreen
├── RankUpModal (full-screen ceremony)
├── StreakMilestoneModal (7/30/100 day celebration)
├── GraduationScreen (66-day full takeover)
├── NotificationPermissionScreen
└── StreakFreezeSheet (confirmation + points)
```

**State management:** Keep Provider (existing codebase uses it). Add new ViewModels for:
- `ThemeViewModel` — manages active theme, token resolution, equipped customizations
- `GroupViewModel` — group feed, member status, chain, leaderboard, multi-group switcher
- `ShopViewModel` — items, purchase flow, equip flow
- `OnboardingViewModel` — flow state, selections
- `NudgeViewModel` — nudge state, rate limiting
- `ReflectionViewModel` — reflection state
- `PluginViewModel` — plugin list, connection states, OAuth flows
- `OfflineViewModel` — connectivity state, sync queue, cached data management
- `CelebrationViewModel` — rank-ups, tier-ups, milestones, graduation (queues celebrations so they don't stack)
- `PersonaViewModel` — persona type, amplified progress stat rotation, personality toggle

---

## 5. Asset Requirements

### 5.1 Illustrations (AI-generated or commissioned)

**Mascot poses (orange character with sunglasses):**
- Welcome pose (thumbs up) — onboarding splash
- Teaching pose (pointing) — onboarding carousel
- Shield pose (protecting) — "Never Reset" onboarding page
- Celebrating pose (confetti, party hat) — 66-day graduation
- Meditating pose — reflection/mindfulness context
- Encouraging pose (arms open) — recovery nudge card
- Sad/lonely pose — empty group state
- Holding chain pose — group setup onboarding
- Bell pose — notification permission screen
- Sunglasses off pose — personality layer OFF indicator

**Empty states:**
- No habits yet — mascot looking at blank checklist
- No group yet — mascot looking at empty chain, slightly sad
- No data yet — mascot with magnifying glass
- All done today — mascot doing a victory dance
- No results (search) — mascot shrugging
- Offline — mascot with unplugged cable

### 5.2 Lottie Animations
- Streak flames: 6 variants (default orange, blue, purple, golden, pixel, lightning)
- Check animations: 6 variants (ripple, water, confetti, sakura, pixel, lightning)
- Chain link forging: gold flash, silver matte, broken crack
- Loading shimmer (theme-aware: warm shimmer for dark, cool for light)
- XP count-up sparkle (floating numbers + particles)
- Celebration — 66-day graduation (confetti rain + badge reveal)
- Celebration — rank-up (badge morph + glow burst)
- Celebration — perfect day (brief confetti across top of screen)
- Celebration — streak milestone (flame scale-up + sparkle)
- Group tier-up (fire gets progressively bigger: Spark→Ember→Flame→Blaze)
- Pull-to-refresh chain pull
- Nudge sent fly-out (pulse + arrow)
- Kudos heart burst
- Sync indicator (two arrows rotating)
- QR scan success (green check in viewfinder)

### 5.3 Fonts
- Obviously (Bold, Semi-Bold) — bundled
- Plus Jakarta Sans (Regular, Medium, Semi-Bold, Bold) — bundled
- Shop fonts: Monospace, Handwritten, Serif — bundled but locked

### 5.4 Icons
- Phosphor Icons Flutter package
- Custom: Valence logo, Spark currency icon, chain link icon

---

## 6. Resolved Open Questions & Audit Fixes

### 6.1 Product Name
The product name is **Valence** (not "Valance" as misspelled in PRD v2.0). All UI copy uses "Valence."

### 6.2 Consistency Points (The "Third Currency")
Consistency points are NOT a third currency — they are a subset of the group accountability system, earned automatically:
- **Earning:** +1 point for each day you complete all your habits while in a group. Tracked per group membership.
- **Spending:** Points are spent on altruistic streak freezes (cost: 5 points per freeze).
- **Stacking:** Max 1 freeze per group per day. If two members try to freeze the same day, the first one wins; the second gets "Freeze already active today."
- **Visibility:** Points balance shown on the Streak Freeze button in Group screen (e.g., "❄️ 12 pts") and in Profile → Stats section.
- **No earning animation** — points accrue silently. Users discover them when they need a freeze.

### 6.3 Habit Archival (PRD Open Question 1)
- Users CAN archive a habit mid-streak.
- The streak is **preserved but paused** — it doesn't reset, and it doesn't increment.
- Archived habits are **excluded** from perfect-day and group chain calculations immediately.
- Archived habits appear in Profile → Archived Habits (collapsible) with their frozen streak visible.
- Habits can be unarchived, and the streak resumes from where it paused.

### 6.4 Max Habits Per User (PRD Open Question 3)
- Cap: **10 active habits** per user. Prevents XP farming with trivial habits.
- When user hits the cap: "Add Habit" shows "You've reached the maximum of 10 active habits. Archive one to add a new one."
- Archived habits don't count against the cap.

### 6.5 Group Timezone (Chain Calculation)
- Each group has a **home timezone**, set to the admin's timezone at group creation.
- The daily chain link calculation runs at 00:05 in the **group's home timezone**, not UTC.
- Group screen shows: "Day resets at midnight [timezone]" in small caption below the chain.
- Admin can change the group timezone in Group Settings.

### 6.6 Tier Demotion
When a group's streak breaks and falls below a tier threshold:
- Feed item: "Your group dropped to [Tier]. Build the streak back to regain [lost perk]."
- Tier badge updates immediately with a brief "deflate" animation (badge shrinks → re-appears at new tier).
- Push notification to all members: "Your group's streak broke. You're back to [Tier]."
- Lost perks are re-locked immediately.

### 6.7 Flame Customization Gate
Per PRD: flame styles unlock at the **Momentum** goal stage (21 days on a specific habit), NOT just by rank/sparks.
- Shop flame items show an additional gate: "Requires: Any habit at Momentum (21 days)"
- If no habit has reached Momentum: flames are grayed out with this label, even if user has enough Sparks and rank.
- Once any habit hits Momentum, all flame styles become purchasable (the gate opens permanently).

### 6.8 Group Below Minimum (3 Members)
- If a group drops below 3 members (via leaving or removal):
  - Group enters "Paused" state. Chain doesn't break but doesn't progress.
  - Group screen shows banner: "Your group needs at least 3 members to track together. Invite friends to resume."
  - Existing chain/streak data is preserved.
  - Individual habit tracking continues normally.
  - When 3rd member joins, group resumes automatically.

### 6.9 LLM Fallback
When the LLM is unavailable (rate limited, API down):
- Nudge flow: shows a predefined template message instead of LLM-generated. Template pool of ~20 generic-but-supportive nudges. User sees: "Auto-generated nudge (AI is busy)" label.
- Motivational stats: falls back to predefined template pool (already specified in 2.28).
- Preemptive nudges: skipped silently — not critical enough to warrant a fallback notification.

---

## 7. Accessibility

- All text meets WCAG 2.1 AA contrast ratios in both themes
- Touch targets minimum 44x44px
- Screen reader labels on all interactive elements
- Reduced motion mode: disable Lottie, use simple crossfades
- Font scaling support (up to 1.5x)
- Semantic colors — don't rely on color alone for status (use icons + labels)
