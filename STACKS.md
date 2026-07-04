# STACKS.md — domain → technology-question options (interview Q7)
Curator-dated 2026-07-04. NOT a freshness oracle: when the mission touches a
fast-moving corner, the compiler adds a KNOWLEDGE-GAP research item instead of
trusting this map (the map itself is only refreshed by maintenance runs).

## §Firing rule (Q7) — CAPABILITY-level, not project-level (1.4-S6 redesign)
Q7 fires when the mission REQUIRES A CAPABILITY whose stack is NOT already
present. Three fire cases: (a) project greenfield (empty/no manifests);
(b) capability greenfield (project exists, but the needed capability — 3D,
charts, game, mobile… — has no stack in it, e.g. first Three.js section into
a static-HTML site); (c) migration/rewrite whose CORE is a tech choice.
SKIP cases: needed capability's stack already present (adding a page to
Next.js) → in-scope ASSUMPTION or decide-list; mission NAMES the tech
("Flutter ile...") → CONFIRM as prefilled default, never re-ask 4 options.
Boundary notes: tooling-only manifests (eslint/prettier) ≠ a stack — treat as
greenfield; in monorepos judge at the TARGET package but scan siblings for
house-stack; OFF-MAP domain (not in table) → compose 2-3 analogous candidates,
LABEL "off-map — curator unverified", and prefer "research decides".
HEADLESS/campaign compiles (no user available): Q7 defaults to "research
decides" (bakeoff) — never self-answer a preference. Light-mode: the bakeoff
counts toward the ≤3-item cap; if it does not fit, compile standard-mode or
record an ASSUMPTION with the trade-off line — never silently drop the choice.
AskUserQuestion mechanics: Q7 ships in a second batch (tool caps 4 questions);
options cap at 4 = 3 candidates + "research decides"; a scan-suggested extra
candidate REPLACES the weakest fit, never becomes a 5th option.

## Map — SEED EXAMPLES, not a whitelist (candidates + trade-off + when-to-pick)
Q7 is UNIVERSAL: EVERY theme/project gets a tech-question when §Firing says so.
Rows below are curated seeds for the commonest domains; any other domain
(bot, scraper, ML, plugin, IoT, AV…) gets 2-3 composed candidates from
scan+compiler knowledge, labeled "off-map — curator unverified", with
"research decides" recommended as the safest pick.
| Domain | Candidates + trade-off | Pick when |
|---|---|---|
| **Web animation / showcase** | **Three.js** (true 3D/WebGL; heaviest learning+bundle) · **GSAP** (timeline-grade 2D + CSS-3D transforms; no WebGL scenes) · **CSS-only** (zero-dep; fine for reveals — transforms/opacity is the PERF best-practice, not the capability limit) · combo note: showcase sites COMMONLY pair Three.js+GSAP — offer as variant, not either/or | 3D scene→Three.js(+GSAP) · rich 2D/scroll→GSAP · simple reveal→CSS |
| **Web app / SaaS** | **Next.js** (React ecosystem+Vercel-native; heavier mental model) · **SvelteKit** (less boilerplate, smaller bundles; smaller ecosystem) · **Rails/Django** (batteries+ORM+auth fast; JS-interactivity extra) | React-team/Vercel→Next · lean-front→SvelteKit · CRUD-heavy→Rails/Django |
| **Dashboard / data-viz** | **Chart.js** (fastest start, canned charts, animated defaults) · **ECharts** (richest built-ins incl. streaming/animated; bigger API) · **D3** (unlimited custom; most code) | standard→Chart.js · exotic/streaming→ECharts · bespoke→D3 |
| **Game** | **Unity (+MCP bridge)** (full engine, editor automation via MCP; heavy install; C#) · **Godot** (open-source, light; GDScript AND C#) · **Web-canvas/Phaser** (zero-install, ships in browser) | 3D/mobile-grade→Unity · indie 2D→Godot · jam/prototype→web |
| **Mobile app** | **React Native** (JS ecosystem, native modules) · **Flutter** (single codebase, strong UI kit; Dart) · **PWA** (instant ship, no store needed — though TWA can reach Play Store; limited device APIs) | team-JS→RN · polished cross-UI→Flutter · MVP/menu-style→PWA |
| **API / backend** | **Vercel functions** (zero-ops; vendor-tied) · **Express/Hono on Node** (portable; self-managed) · **FastAPI** (Python, typed, data-friendly) | on-Vercel→functions · portable-JS→Hono · Python/ML→FastAPI |
| **CLI / tool** | **bash+coreutils** (zero-dep; POSIX quirks) · **Python** (batteries; runtime discipline) · **Go/Rust** (single binary; compile step) | glue→bash · data/logic→Python · distribute→Go |
Rule: options are NEVER bare — each carries its trade-off so the user chooses
informed; "let research decide" is ALWAYS the last option and compiles a
stack-bakeoff deliverable (RECIPES.md §Stack-bakeoff).
