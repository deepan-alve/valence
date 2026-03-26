---
name: frontend-design
description: Build frontend interfaces that look handcrafted, not machine-generated. Triggers when user asks to build UI, pages, components, or web applications.
license: Complete terms in LICENSE.txt
---

# Build It Like a Human Designed It

You're building a frontend. Not generating one. The difference matters.

Before you write a single line — answer three questions silently:

1. **Who is this for?** A dashboard for stressed ops engineers is not the same as a landing page for a D2C skincare brand. The answer shapes everything.
2. **What's the one thing someone remembers?** Not three things. One. A single moment of "oh, that's nice." Maybe it's a transition. Maybe it's the typography. Maybe it's the way negative space breathes. Pick one and make it perfect.
3. **What's the mood?** Not "modern and clean" — that's nothing. Try: "late-night coding session", "sun-bleached newspaper", "Tokyo subway signage", "handwritten recipe card", "90s rave flyer", "Swiss watchmaker's catalog." A real vibe, not a buzzword.

## The Rules

**Typography is 80% of design.** Pick fonts that have character. Not Inter, not Roboto, not system-ui. Go find something on Google Fonts that makes you stop scrolling. Pair a display face with a body face that creates tension — a heavy serif title with a geometric sans body, or a monospace heading with a humanist body. The pairing IS the design.

**Color is a commitment.** Pick a dominant. One. Then an accent that creates friction against it. A muted olive with a sharp coral. A deep navy with a warm amber. Not "blue and white." Not "purple gradient." If your palette could belong to any website, it belongs to none.

**Space is a material.** Use it deliberately. Generous margins aren't "clean" — they're a power move. Tight, dense layouts aren't "cluttered" — they're editorial. Know which one you're doing and why.

**Motion earns attention.** One orchestrated entrance sequence > twenty hover effects. Stagger reveals with `animation-delay`. Use `cubic-bezier` curves that feel physical — things should accelerate and decelerate like real objects. CSS transitions first; reach for JS animation libraries only when CSS can't do it.

**Texture kills flatness.** Subtle noise overlays (`filter: url(#noise)`), gradient meshes, a single diagonal line, a dot grid pattern, an inset shadow that creates depth — these small touches separate "designed" from "generated." Use them sparingly and with intent.

## What to Never Do

- White background + card with `border-radius: 12px` + drop shadow + Inter font = the AI starter pack. Avoid.
- Rainbow gradients, glassmorphism for no reason, floating blobs — these are decoration without meaning.
- Centering everything. Asymmetry is interesting. Let things breathe unevenly.
- Using the same layout for every project. A portfolio, a SaaS dashboard, and a restaurant menu should look nothing alike.

## Execution

Write real, working, production-grade code. Not a wireframe. Not a prototype. The code IS the deliverable.

- Use CSS custom properties for the color system and type scale
- Semantic HTML — not div soup
- Responsive by default, not as an afterthought
- Accessible: contrast ratios, focus states, screen reader text where needed
- If using React: prefer CSS modules or styled-components over utility-first frameworks unless the user specifies otherwise

Match the code complexity to the vision. A brutally minimal design needs 50 lines of precise CSS, not 500 lines of overengineering. A maximalist editorial layout needs every animation and layering trick you know.

The goal: someone looks at what you built and thinks a designer made it, not a prompt.
