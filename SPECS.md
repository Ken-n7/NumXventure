# NumXventure — Client Specification & Roadmap

> **Source of truth.** Derived from the three client documents in this repo:
> - `NumXventure-Game.pdf` — research paper (ADDIE), 2026-09-17. Pedagogy, scoring rules, item counts.
> - `NumXventure-Draft-Layout.pdf` — Canva screen mockups, 20 screens, 2026-06-13.
> - `NumXventure Game App Details.pdf` — annotated mockups + client narration (Waray), 2026-09-21. **Newest; wins on conflicts.**
>
> Change log at the bottom. Edit this file, not the PDFs.

---

## 1. What the app is

A **landscape mobile** (Android) gamified math app for **Grade 8** learners in Mayorga, Leyte.
Team-based, teacher-proctored, **live session**: one teacher (admin) starts/pauses a timed adventure, 5–6 students per team play simultaneously on their own phones, answering fixed math items across 3 stations. Gems = points. Highest combined team gems wins.

Tagline: *Explore. Solve. Conquer.*

**Art direction — decided 2026-09-21:** we keep **our own visual style** (pixel-art top-down, Tiny Swords terrain/towers, SuperRetroWorld heroes, Pixelify font). The client PDFs are treated as a **mechanics and layout contract, not a skin**: every screen, button, label, field, state and rule in them must exist and be worded the same, but rendered in our style. The flat-green Canva look is *not* a deliverable.

---

## 2. Roles

| | Player (student) | Admin (teacher, or any student) |
|---|---|---|
| Creates account | yes | yes — **anyone can register as admin**, no approval |
| Dashboard tabs | Home · Start Adventure · Leaderboard · Learn | Home · Game Controls · Leaderboard · Question Management · Feedback |
| Controls clock | no | yes (start / pause / resume / duration) |
| Pause button | **none** | yes — pauses *every* player at once |

Registration: **Username** (globally unique) + **Password** (min 8 chars, with Show toggle) + **Select Role** dropdown.
After registering, the player **picks a character**; that character appears beside their username on Home.

---

## 3. Player flow

```
Loading  →  Login  →  (Register → Character select)  →  Home
Home → Start Adventure → enter Team Name → Adventure Map (far/aerial POV, frozen)
      → [admin presses Start] → camera swoops in, joystick appears, timer runs
      → walk base → Tower 1 → "Enter Station 1" → intro card → Continue
      → walk to circle 1 → "Answer Quest!" → question screen → result → Continue
      → circle 2 … circle N → Tower 2 → … → Tower 3 → … → Victory Gate
```

**Team Name doubles as a join code.** The admin generates team names in Game Controls; each player types the one they were given. That is how membership is resolved — the winner is a *team*, never a player.

### Map
One continuous path: base camp → Station 1 → 8 circles → Station 2 → 3 circles → Station 3 → 3 circles → Victory Gate. Circle colour per station (blue / orange / red).

Each station's keep is its own building — **Blue Monastery**, **Yellow Archery**, **Red Barracks** — with two houses of the same livery either side. Every walk-up circle is a **Tower** in that station's livery, so a stop always reads as a stop and never as a keep.

The base camp sits on its own small island at the map's right, joined to Station 1's island by a **land bridge**. Station 1's monastery stands on island 1's own ground where that bridge lands, and a **line of boulders** runs from shore to shore across the island just west of it, with a giant knight filling its one gap — so the walk cannot begin before the first station has been entered. Island 1 reaches Station 2's island by a second land bridge, held the same way: a boulder line filling the crossing with a giant guard in its gap, who stands aside once Station 1 has no circles left. Only the last crossing, on to Station 3's island, is still a causeway that rises.

**One circle = one item.** Strictly sequential — a player cannot reach circle *n+1* before resolving circle *n*. Item counts are fixed per station.

### Question screen
Header: `Station N` · `Remaining Time mm:ss` · `Gems: NN 💎` · `Rescue ▾`
Body card: `Question` label, the expression, **Hint** and **Skip** buttons, free-text answer input, **Submit Answer**.

Result overlay:
- correct → **CORRECT! / YOU GOT IT!** · `+10 💎` · "You applied the correct rule!" · the answer · Continue
- wrong → **Almost There! / Keep trying!** · `-5 💎` · the admin-authored feedback/rule reminder · the correct answer · Continue

Either way the player advances to the next circle. Answers are free-text, not multiple choice.

---

## 4. Gems (scoring)

Every player starts each adventure with **50 gems**.

| Event | Δ |
|---|---|
| Correct answer | **+10** |
| Incorrect answer | **−5** |
| Use Hint | **−5** |
| Skip item | **−15** |
| Perfect station (all items correct) | **+10 bonus** |
| Rescue: teammate transfers to one member | **−10 sender / +10 receiver** |
| Player eliminated (hits 0 gems) | **−50** team |
| Player doesn't finish all stations in time | **−25** team |

**Team final score = sum of all members' gems.** Highest total wins.

Rationale (from the paper, Operant Conditioning): +10 reinforces mastery; −5 discourages guessing; −5 keeps help-seeking available but costly; −15 punishes avoidance; bonus rewards consistency; team penalties enforce accountability and pace.

---

## 5. Stations & content

| # | Title (mockups) | Competency | Items |
|---|---|---|---|
| 1 | **Master the Basics!** | +, −, ×, ÷ of integers, incl. negative signs | **8** |
| 2 | **Follow the Right Order!** | PEMDAS / GEMDAS order of operations | **3** |
| 3 | **Power Up with Exponents!** | exponential notation, base & exponent | **3** |

> **Resolved 2026-09-21:** the research paper orders these S1 Basics · S2 *Exponential Notation* · S3 *Order of Operations*. **The mockups win** — use the table above. The paper's prose should be corrected to match before publication.
>
> **Done (Phase 0).** `QuestionGen.STATIONS` and `item_for_station()` now map index 1 → Order of Operations, index 2 → Exponents.
>
> **Changed 2026-09-22:** client cut item counts to 8/3/3 (14 total, was 20/10/10). `Game.ITEMS_PER_STATION = [8, 3, 3]`, `Game.TOTAL_ITEMS = 14`. Everything downstream — map circle count, tower/causeway spacing, the perfect-station bonus — reads off these two constants, so nothing else needed a code change.

Each station opens with an intro card: welcome paragraph + **Mission:** line + `Continue`.

### Learn (player tab)
Review hub with three sections, each a heading + paragraph + gallery of instructional images:
1. Basic Operations on Integers
2. Understanding Numbers Expressed in Exponential Notation
3. Order of Operations on Integers (GEMDAS)

Per the paper, Learn is **pre-gameplay only** — not reachable during an adventure (Cognitive Load Theory).

---

## 6. Timer

One shared countdown for the **whole adventure**, set by the admin in `hr` + `min`, applied with **Apply Time**. Same clock for every player so answering is simultaneous. Shown on the map header and on every question screen. Only the admin can pause; pausing freezes all players at once.

---

## 7. Admin dashboard

### Game Controls
- **Set Adventure Duration** — `− [hr] + − [min] +` → **Apply Time**
- **Start Game** / **Pause Game** / **Resume**
- *(draft only: **Randomize Questions** — see Q4)*
- **Teams** panel: per-team card with editable Team Name + live "Joined Members:" list, plus **Add Team** to create more

### Live Leaderboard
Podium graphic, two tabs:
- **Team Ranking** — Rank · Team · Gems
- **Player Ranking** — Rank · Username · Gems · Correct Responses

Player-facing Leaderboard shows **Team Ranking only**.

### Question Management
Grouped by station. Each row: question text + `(Ans: …)` and **Set** · **Edit** · **Delete**.
**Add Question** form: `Enter Question` · `Enter Hint` · `Enter Answer` → **Add**.

### Feedback and Rule Reminder
"Set specific feedback or rule reminders that will appear on the player's point screen when they answer a question incorrectly."
1. **Select Question** (dropdown) → 2. **Feedback Message** textarea, **300 char** limit with counter → **SAVE FEEDBACK**

---

## 8. Non-negotiables the client stated explicitly

- Landscape orientation.
- A loading/splash screen.
- **Text must be large and legible** — called out twice.
- Usernames unique; password ≥ 8 chars.
- No pause button on the player side.
- Sequential items, no skipping ahead.
- Team-based winner, never individual.

### Project settings

The durable record of the settings `game/project.godot` depends on. It lives here
because Godot rewrites that file whenever any setting changes, and **its writer drops
every comment**, so anything explained only in the file itself is lost the first time
someone touches Project Settings.

| Setting | Value | Why |
|---|---|---|
| `application/config/quit_on_go_back` | `false` | Android's back button opens the pause menu (`Main._notification`) instead of killing a run in progress. |
| `display/window/handheld/orientation` | `4` | Sensor Landscape — both landscape rotations, portrait locked out. |
| `display/window/size/viewport_width/height` | `640` × `360` | The canvas every screen is laid out against; `window_*_override` is 2× that for desktop runs. |
| `display/window/stretch/mode` | `canvas_items` | Scales the UI with the window instead of the viewport, so text stays crisp. |
| `display/window/stretch/aspect` † | `keep` | The world is deliberately 96×54 tiles = 3072×1728, exactly 16:9, so `_aerial_zoom()` frames the whole board in one screen. `expand` would hand wider devices extra viewport the aerial framing and the HUD anchors do not expect; `keep` letterboxes instead. |
| `input_devices/pointing/emulate_mouse_from_touch` † | `true` | Every menu, quiz and pause button is a Godot `Button` (`Ui.button()`), and Controls do not handle `InputEventScreenTouch` themselves — without emulation they are dead on a phone. The joystick and GO/MENU deliberately read *raw* touch instead (`Joystick.gd`, `TouchScreenButton`) so steering and pressing GO work on separate fingers, so turning this off would leave those two working and silently kill everything else. |
| `rendering/.../default_texture_filter` | `0` (nearest) | Pixel art — bilinear filtering blurs every sprite. |
| `renderer/rendering_method(.mobile)` | `gl_compatibility` | Target devices are low-end Android; Forward+ is not an option. |
| `gui/theme/custom_font` | `PixelifySans.ttf` | Project-wide font. `Art.apply_font_fallback()` attaches DejaVu for the glyphs it lacks. |

† These two already match Godot's defaults, so the writer omits them and they will
vanish from `project.godot` the next time a setting changes. That is harmless — the
behaviour is unchanged — but they are load-bearing, so they are recorded here. If a
future Godot release changes either default, set them explicitly again.

> **Never use `#` for comments in `project.godot`.** Godot's config parser does not
> recognise it: it folds the `#` line *and the key beneath it* into a single garbage
> quoted key, so that setting silently stops applying while still looking correct in
> the file. This is not hypothetical — `config/quit_on_go_back=false` sat under two
> `#` lines and read back as `true` the whole time, meaning the Android back button
> was quitting mid-run. Fixed 2026-09-22 by switching those two lines to `;`.

---

### Dev tools

Two of them, both debug-build only and neither loaded by the game:

- **`scripts/DevDrawer.gd`** — a drawer on the left edge of the Adventure map: a
  handle, a parchment panel, and one button per row of its `TOOLS` table
  (adding a tool is a line there plus a method). **Skip Station** resolves the
  current station's remaining circles, briefs its tower and banks it, which is
  what opens the next island — that is the one the later islands are tested
  through, and `test_collisions.gd` proves it leaves the board exactly where
  playing the questions would. The rest: **Teleport** to the next stop,
  **Aerial** for the whole-board POV, **Open Gates**, **Fast Walk**, **Freeze**,
  **+1:00**, **Show Walls** (draws every `_solid` rect), **End Run**.
  `AdventureScreen` only builds it under `OS.is_debug_build()`, so the
  `--export-debug` APK keeps it and a release export drops it with nothing to
  strip by hand. The floating joystick owns the left half of the canvas and marks
  those touches handled, so the drawer hands `Joystick.zone` back exactly the
  strip it is using.
- **`tools/map_shot.gd`** — `godot --path game --script res://tools/map_shot.gd
  -- <out dir>` writes a PNG per entry in its `SHOTS` table. Windowed, not
  headless: it needs a GL context. A shot can ask for `dismiss` (stand every
  guard down), `drawer` (slide the dev drawer out) and `hold` (wait N frames),
  which is how the *after* state of anything that animates gets photographed.

## 9. Current implementation vs. spec

Engine: **Godot 4.6.3**, GL Compatibility, 640×360 landscape canvas, Android export preset already wired to `build/NumXventure.apk` (arm64, no keystore yet). Every screen is built in code; `scenes/Main.tscn` is a stub. Router: `scripts/Main.gd` with seven screens (`splash, title, hero, adventure, learn, board, summary`).

### Already correct — do not rebuild

| Spec item | Where |
|---|---|
| Whole gem economy, exact values | `scripts/Game.gd:12-18`, `mark_correct/mark_wrong/spend_hint/mark_skipped/finish_station` `:190-232` |
| 50 start gems, +10/−5/−5/−15, perfect-station +10, −25 unfinished | same |
| One hint per item | `Game.spend_hint()` + `item_used_hint`, reset in `begin_item()` |
| Item counts 8/3/3 | `Game.ITEMS_PER_STATION:21` |
| Shared countdown timer, auto-end at zero | `Game.gd:113-118` |
| Station intro card with Mission line | `QuizOverlay._show_intro():139-151` |
| Question screen: prompt, Hint, Skip, answer input, Submit | `QuizOverlay.gd:56-136`, `_submit():184-198` |
| CORRECT / Almost There result overlays with gem delta + rule text | `QuizOverlay._show_result():200-218` |
| Strict sequential station gating | `AdventureScreen._try_enter_station():430-444` |
| Character select (32 heroes) | `HeroSelectScreen.gd:80-152` |
| Learn hub, 3 topics | `LearnScreen.gd` |
| Leaderboard screen + summary screen | `LeaderboardScreen.gd`, `SummaryScreen.gd` |
| Landscape, Android export, touch controls | `project.godot`, `export_presets.cfg`, `AdventureScreen._build_touch_pad():551-589` |
| Headless test suite (rules, collisions, smoke, e2e, touch) | `test_rules.gd`, `test_collisions.gd`, `scripts/tests/*` |

### Missing or wrong

| # | Spec item | State | Note |
|---|---|---|---|
| G1 | Accounts: username + password (≥8) + role | **absent** | No auth code at all |
| G2 | Admin role & entire admin dashboard | **absent** | No route, no screens |
| G3 | Multi-device play, shared session | **absent** | Zero networking; no `rpc`, no HTTP, no INTERNET permission |
| G4 | Teams & team-name-as-join-code | **absent** | `Game.team_name` is a cosmetic string on the leaderboard row |
| G5 | Live leaderboard (team + player tabs, correct-response count) | **absent** | Local only; rivals are hardcoded fakes at `Game.gd:36-41` |
| G6 | Admin-set duration, Start/Pause/Resume for everyone | **wrong owner** | Player picks from `DURATION_CHOICES` at hero select; pause menu is player-side (`AdventureScreen.gd:646-681`) — spec says players have **no** pause |
| G7 | Question bank CRUD + per-question hint + per-question feedback | **absent** | All generated at call time from consts |
| G8 | Rescue (transfer 10 gems) | **stubbed** | Button exists but `disabled = true`, `QuizOverlay.gd:114-116` |
| G9 | Elimination at 0 gems → −50 team | **absent** | Gems merely clamp at 0 (`Game._apply():184-186`) |
| G10 | Circles on the map = one per item | **done** | 14 `PathCircle` nodes on the path, locked / current / done; progress is `Game.items_done` |
| G11 | Tower-then-circles walk order, Victory Gate | **done** | `AdventureScreen._build_path()`: base camp → T1 → 20 → T2 → 10 → T3 → 10 → gate; `_can_enter_tower/_can_answer/_can_enter_gate` |
| G12 | Station 2/3 content order | **done** | Swapped in Phase 0; asserted in `test_rules.gd` |
| G13 | Loading/splash screen | **done** | `scripts/SplashScreen.gd`, routed first from `Main._ready()` |
| G14 | Login screen, register screen | **absent** | `HeroSelectScreen.gd:4-5` explicitly waves this off as "a web concern" |
| G15 | Home dashboard with 4 tabs + username + character + Log Out | **partial** | `TitleScreen.gd` is a main menu, not a tabbed dashboard |
| G16 | Team-name entry as its own screen after Start Adventure | **partial** | One optional `LineEdit` on hero select |
| G17 | Aerial map POV → admin starts → camera swoop transition | **done** (offline) | `AdventureScreen._start_intro()` holds the board frozen with **no joystick** until a tap, click or interact press fires `_swoop()`; `Game.clock_paused` means the wait is free. That's the offline stand-in — Phase 3 routes the admin's Start Game into the same `_swoop()` call instead. The world is exactly 16:9 so `_aerial_zoom()` frames the whole board with no bars; what it cannot do is text — circle numbers and station signs are world-space and illegible at 0.208 |
| G18 | Learn locked during gameplay | **absent** | Reachable from the pause menu |
| G19 | Answer input allows negatives on desktop | **done** | `±` button now built on every platform (`QuizOverlay.gd`) |
| G20 | Release signing | **absent** | `export_presets.cfg` keystore paths empty |

---

## 10. Roadmap

### Transport decision (answers "will both LAN and cloud work?")

**Yes — build LAN first, cloud second, behind one interface.** The game must not know which is in use.

Create a single autoload `scripts/Net.gd` exposing exactly what the session needs:

```
signal session_state(state)      # lobby / running / paused / ended
signal roster(teams)             # [{name, members:[username]}]
signal scores(rows)              # live gems + correct counts
signal clock(seconds_left)
signal rescue_received(amount)

func host(config) -> void
func join(team_name, username) -> void
func submit(item_id, answer, gems_delta) -> void
func rescue(target_username) -> void
func admin_start() / admin_pause() / admin_resume() / admin_set_duration(sec)
```

- **Backend A — LAN (`NetEnet.gd`)**: Godot's built-in `ENetMultiplayerPeer` + `@rpc`. Admin device hosts; students join by IP or auto-discover over UDP broadcast. Accounts and question bank live in a `ConfigFile`/SQLite on the host. No internet, no hosting bill, survives a dead school WiFi via a phone hotspot. **Ship this first.**
- **Backend B — Cloud (`NetCloud.gd`)**: PocketBase or Supabase behind `HTTPRequest` + a realtime subscription. Same signals, same methods. Needs `INTERNET` permission in `export_presets.cfg` and a deployed instance.

A runtime toggle on the login screen (`Server: LAN / Online`) picks the backend. This is the one abstraction worth having — there are genuinely two implementations, both requested.

> ⚠️ The paper calls the app "online". If the research write-up must literally be online, Backend B becomes Phase 8-blocking rather than optional. See Q3.

---

### Phase 0 — Correctness fixes ✅ *done 2026-09-21*

- ✅ Swapped S2/S3 in `QuestionGen.STATIONS` and `item_for_station()`: S2 = Order of Operations, S3 = Exponents. Accents are now Blue / Orange / Red per §3. `test_rules.gd` and `smoke_test.gd` assert the order.
- ✅ Loading/splash screen: `scripts/SplashScreen.gd` (logo, tagline, 1.8 s progress bar, tap-to-skip), registered as `"splash"` and opened first by `Main._ready()`. `e2e_test.gd` step 1 drives it.
- ✅ Legibility floor: `Art.MIN_FONT = 14`, applied in `Art.label()`, `Ui.button()` and `Ui.line_edit()`. Raises everything that sat at 11–13. **Still owed: a read on a real phone** — raise `MIN_FONT` there, it is the single knob.
- ✅ Orientation locked: `display/window/handheld/orientation=4` (Sensor Landscape — both landscape rotations, portrait refused). Note `project.godot` comments must start with `;`, not `#` followed by an `=`.
- ✅ `±` sign toggle now built on every platform, not just touch.
- ✅ Side fix found by the swap: `QuestionGen._exponent()` mode 2 was locked to base 2, i.e. two possible questions, so a 10-item exponent station repeated itself. Bases widened (mode 1 → 2–9, mode 2 → 2–4 with exp 3–4); worst answer is 256, still inside the ≤400 sanity bound.

**Verified:** all five suites pass — `test_rules.gd`, `test_collisions.gd`, `smoke_test.tscn` (142 checks), `e2e_test.tscn` (321 checks), `touch_test.tscn` (8 checks).

### Phase 1 — Map rework ✅ *done 2026-09-21*

- ✅ Authored path over the island: `AdventureScreen.PATH_WAY` is a four-lane serpentine, `_path_anchors()` spaces **45 stops** along it — base camp, Tower 1, its 20 circles, Tower 2, 10, Tower 3, 10, Victory Gate. `_stamp_path()` forces land (and a pad under each tower) before the autotile pass, so the authored walk survives whatever the island generator produced. **Decided: the island stays** — the generator, terrain, decor and the tested building walls were all working; only the board is authored on top.
- ✅ `scripts/PathCircle.gd`: one node per item, station accent (blue / orange / red), states locked / current / done. The disc is a generated white texture tinted by `modulate` — the pack has no circle in three colours, so `Art.cell()` had nothing to crop.
- ✅ Walk order is tower-then-circles. `_try_enter_station()` is now the **briefing only** (the station intro card), `_try_answer_circle()` asks one item, `_try_enter_gate()` ends the run; `_nearest_target()` picks which, and `_interact()` dispatches. Gating: `_can_enter_tower()` / `_can_answer()` / `_can_enter_gate()`.
- ✅ Progress moved out of the overlay into `Game.items_done` (0..40) + `Game.towers_entered`, decoded by `Game.station_of_item()` / `item_in_station()`. `QuizOverlay` is now one briefing **or** one item; its last item still raises the completion ribbon that pays the perfect-station bonus, so the whole gem economy is untouched.
- ✅ Victory Gate (two boulders + a ribbon) at the last anchor → `Game.end_adventure()` → summary. Clearing all 40 circles no longer ends the run on its own; walking to the gate does.
- ✅ Aerial frozen POV → swoop: the camera moved from the hero to the world, `_start_intro()` frames the whole board at `AERIAL_ZOOM`, then `_swoop()` tweens zoom and position onto the hero over 0.9s. `Game.clock_paused` keeps the timer at a standstill while the board is frozen, and `skip_intro()` collapses it instantly (what the tests call).
- ✅ **Fixed 2026-09-22:** the POV used to swoop off a 1.2s timer, so the one screen that answers the client's `Adventure Map` mockup was unviewable, and the touch pad stayed up through it — against *"Waray pa joystick, or anything if di pa start ang adventure"*, twice stated. The board now holds indefinitely, pad hidden, until a **tap anywhere** (or a click, or the interact key) fires `_swoop()` — no button sitting on top of the board it's asking you to look at. A first pass used a corner button instead; removed once tap-anywhere covered the same need without obstructing the view. Desktop has no pad, which is why no headless suite caught the original bug; `touch_test.gd` now simulates a real tap and asserts pad-hidden-while-frozen, the hint offered, and both restored after the swoop.
- ✅ **Two bugs the real-tap test surfaced, both fixed:** `AdventureScreen`'s root `Control` defaulted to `MOUSE_FILTER_STOP`, silently swallowing every tap/click before `_unhandled_input()` ever saw it — the circle-inspect card (below) had never actually fired from a real click, only from a script calling it directly. And `_exit_tree()` unconditionally cleared `Game.clock_paused`; since `Main.open()` frees the old screen with a deferred `queue_free()`, restarting mid-adventure ran the old screen's cleanup *after* the new screen's fresh intro had already set the flag, silently un-pausing a board that still looked frozen. Now it only clears the flag if that dying screen was itself still frozen.
- ✅ Towers step off the path via `_tower_lift()` — up on a lane, outward on a bend. Their walls are up to 150px wide and would otherwise swallow the next circle, 68px along. Found by the new test, not by eye.

**Verified:** all five suites pass — `test_rules.gd`, `test_collisions.gd` (walls + 40 circles + sequential gating + the gate), `smoke_test.tscn` (142 checks), `e2e_test.tscn` (393 checks: briefing → 40 circles one at a time → gate → summary, gems land on 480), `touch_test.tscn` (9 checks).

> **Still owed:** a look on a real device — the circles' 14px numbers and the swoop timing are the two things a headless suite cannot judge.

#### Phase 1b — map redesign ✅ *done 2026-09-22*

The first pass satisfied the contract but did not read as a game map: forty circles
crammed 68px apart into one serpentine, a station that was one building and two
labels, and one undifferentiated blob of grass. Nothing in the geography expressed
progression either — the sequential rule lived only in `_can_answer()`.

- ✅ **The camp is its own island** (`ISLANDS[0]`), bottom **right**, joined to
  Station 1's island by a **land bridge**: the camp trail runs over open water to
  reach Station 1, so `_stamp_path()` lays the crossing under the walk. Because
  Station 1 and its circles sit on different trails, `_station_island(st) = st` is
  gone; `_island_of_anchor(k)` derives the trail from the anchor index off
  `_stops_on()`, correct for keeps and circles alike. The flattened walk order is
  unchanged, so `_tower_anchors()`, `_build_path()` and every gating predicate were
  untouched. Station 1 itself stands well inside island 1 — its footprint and its
  roof are checked against `_island_index()`, not against stamped ground, so no part
  of the monastery hangs over the sea.
- ✅ **Two of the three gates are a body in a wall, not terrain.** `BARRICADES` is
  the list, one entry per gate: the station it belongs to (its livery, the tower
  its guard steps aside toward, and what stands him down — that station's own
  `brief`ing, or the station before it running out of circles), and where along the
  stretch between two stops the line stands. `_build_barricade()` lays a
  **line of boulders** there, land's end to land's end:
  one `Rock%d.png` and one `_solid` rect per cell, stepping out from the road to the
  sea on both sides, so there is no way round. A **giant knight** (the guards' own
  `Warrior_Idle` sheet at 3× their scale) fills the two-cell gap the road runs
  through. The Station 1 briefing calls `_dismiss_knight()`: his plug drops at once
  so the player can walk on, and he **walks out of the gap** to `_knight_stand` —
  open ground in the yard between the line and the monastery, found by
  `_knight_rest()`. The **gap, the walk and the spot** are all reserved before the
  decor pass, with extra headroom above, since he is base-anchored and ~90px tall
  and a trunk a clear cell above him still draws over his head. He does not fade:
  the gate was a man, and a man who has let you past is still standing there — and
  he **walks**, on `Warrior_Run` (`KNIGHT_WALK_SHEET`), idle and walk on the one
  `AnimatedSprite2D` so standing him down is a change of animation while the tween
  carries him. The rocks stay too — laid on every build, briefed or not, and
  only the gap ever opens. A restart that had already briefed posts him at that
  same spot as scenery, never as `_knight`, which means "the blocker".
  **Why a knight and not a causeway here:** the crossing has to be walkable for the
  station on the far side to be reachable at all, so the choke sits *between*
  Station 1 and the rest of the island. `test_collisions.gd` proves it both ways —
  with him posted no circle is reachable from camp; dismissed, Station 1's eight
  are — and separately that both ends of every line run into water. Gate 1 stands
  mid-bridge on the crossing to Station 2's island; its sign, `Clear Station 1 to
  pass`, is the causeway signage it replaces, and a guard waiting on a station
  being cleared gets one because the player meets him a whole island away from the
  circles that open him.
- ✅ **Four islands** (`AdventureScreen.ISLANDS`), on a world grown
  from 44×30 to **96×54** — 3072×1728, deliberately 16:9 so the whole-board view
  fills the screen exactly.
- ✅ **Causeways as the gate**, on the one seam that is not bridged. `BRIDGED_SEAMS`
  lists the crossings that are land bridges instead, and each causeway carries its
  own `seam` so the rest of the file stays right however many are skipped.
  `_find_causeways()` takes the water along the line between two island centres:
  the shortest crossing, and the *only* one, since everything either side is sea. Stepping stones and a sign mark it early;
  `open_causeway()` stamps the cells into `_land`, repaints the shoreline with
  `_retile()`, dries the same stones out and puffs dust. It fires from
  `_refresh_causeways()` the moment that station runs out of circles.
  **Why islands and not a boulder:** *one* boulder on open ground can be walked
  around. This is enforced by the terrain, and `test_collisions.gd` proves it by
  flood-filling from the base camp rather than trusting a flag. (A whole line of
  them, shore to shore, cannot be walked around either — that is the gate on island
  1, where there is no channel to use.)
- ✅ **~270px between stops at the tightest** (was 68), one authored trail per
  island (`TRAILS`).
  ~65s of walking in a 600s adventure; `PLAYER_SPEED` is the knob if that is long.
- ✅ **Stations are outposts**: the keep, two houses in its livery, two idle guards.
  Houses step outward until their footprint is clear of every anchor and are
  dropped if the island has no room — a wide keep plus a house otherwise reaches
  the next circle 200px along, which is exactly what it did on Station 3 the first
  time. Found by the test, not by eye.
- ✅ **Props per island** (`ISLAND_PROPS`): wooded valley, stony quarry, bare
  highland. The three tilemap colours are near-identical greens, so there is no
  free biome swap — the dressing carries the difference. The rubber duck is gone:
  scaled up to a world this size it put half a dozen bath toys on dry grass.
- ✅ **Props arrive in patches, not as noise.** One roll picks *what* grows at a
  spot, then a handful of that one kind grows around it (`_plant_patch()` out to
  two rings, ~45% of the cells skipped so a wood is not a hedge). `_plantable()`
  is the single rule for where anything may stand: this island's ground, inland of
  `_beach`, off `_trail` (the three-cell corridor `_stamp_path()` records, which is
  what makes the walk read as a *road* through the trees), off `_station_rects`,
  and not on a cell another prop already took. Counts went up because they now
  count props rather than rolls. One fixed seed — the board is the same every run,
  which is the point: there is nothing to win from a different mess each time.
- ✅ **Tap a circle** for a card: which item, which station, its state, an X, and
  **Answer Quest!** only within `INTERACT_RADIUS` — so "walk to the circle" holds.
  E / GO still goes straight to the question, the fast path for forty items.
- ✅ `PLAY_ZOOM = 0.75` while walking, and a computed `_aerial_zoom()` with the
  camera limits lifted (a visible rect wider than the limits gets shoved
  off-centre, it is not letterboxed).
- ✅ Side fix: the map prompt and the controls crib were anchored `CENTER_BOTTOM`
  and then given a 640 width, so each box started at mid-screen and its centred
  text hung off the right edge. Both are `*_WIDE` now. Only visible in a
  screenshot, which is how it was found.

**Verified:** all five suites pass — `test_rules`, `test_collisions` (walls, 40
circles, sequential gating, **flood-fill reachability per island**, causeways shut
then open), `smoke_test` (142), `e2e_test` (393), `touch_test` (14). Plus eleven
screenshots off a real GL context: aerial, camp, each outpost, both causeway
states, the card, the gate.

> **Still owed:** region gating is a *visual* expression of the sequential rule the
> PDFs already specify, not a new rule, so nothing is owed the client here. Next is
> the stylized overview — the camera aerial frames the board correctly now, but
> world-space text is unreadable at that zoom.

### Phase 2 — Accounts & roles (local, offline)
- `scripts/AuthStore.gd`: usernames unique, password ≥8 chars, hashed (`Crypto`/SHA-256 + salt — do not store plaintext), role `player|admin`. Backed by `user://accounts.cfg` for now; moves to the host in Phase 4.
- New screens: `LoginScreen.gd`, `RegisterScreen.gd` (Username · Password + Show · Select Role · Register). Register → character select → Home.
- Rework `TitleScreen.gd` into `HomeScreen.gd`: username + character portrait top-left, **Log Out** top-right, welcome banner, bottom tab bar **Home · Start Adventure · Leaderboard · Learn**.
- `TeamNameScreen.gd` — the "Start Adventure → Enter Team Name → Ready!" step, split out of `HeroSelectScreen.gd:58-65`.
- Lock Learn during an active adventure (remove it from the pause menu).

**Verify:** new `test_auth.gd` — duplicate username rejected, <8-char password rejected, wrong password rejected, role round-trips, password never appears in the save file.

### Phase 3 — Admin dashboard (local first)
Build the screens against local data; they light up for real in Phase 4.

- `AdminHomeScreen.gd` — tabs **Home · Game Controls · Leaderboard · Question Management · Feedback**.
- `GameControlsScreen.gd` — duration `hr`/`min` steppers + **Apply Time**; **Start Game** / **Pause Game** / **Resume**; Teams panel with editable team names, live "Joined Members:" lists, **Add Team**. (Draft-only **Randomize Questions** — see Q4.)
- `QuestionMgmtScreen.gd` — per-station list, each row `prompt (Ans: x)` + **Set** / **Edit** / **Delete**; Add form `Enter Question` · `Enter Hint` · `Enter Answer` → **Add**.
- `FeedbackScreen.gd` — Select Question dropdown → 300-char feedback textarea with counter → **SAVE FEEDBACK**.
- `scripts/QuestionStore.gd` — persisted bank: `{station, prompt, answer, hint, feedback, active}`. **Generator stays as fallback**: `QuestionStore.item(station, i)` returns the authored item if the station has enough *active* ones, else tops up from `QuestionGen`. Seed the bank on first run by generating a starter set.
- Remove the player-side pause button; `AdventureScreen.gd:646-681` becomes admin-driven only.
- Move duration out of `HeroSelectScreen.gd:92-102` — admin owns it now.

**Verify:** `test_questions.gd` — CRUD round-trips, a station with 3 active authored items still yields 20 items via fallback, feedback >300 chars rejected, deleting a question clears its feedback.

### Phase 4 — LAN session (the big one)
- `Net.gd` + `NetEnet.gd` per the interface above. Admin hosts on `admin_start()`; students `join(team_name, username)`.
- Team name is the join code — it must match a team the admin created, or the join is refused.
- Host authoritative: shared clock, one pause pauses everyone, gem deltas validated server-side (never trust the client's arithmetic).
- Live leaderboard streamed to both dashboards: **Team Ranking** (Rank · Team · Gems) and **Player Ranking** (Rank · Username · Gems · Correct Responses). Player-facing board shows the team tab only. Delete the hardcoded rivals at `Game.gd:36-41`.
- Accounts + question bank move to the host so every player gets identical items.

**Verify:** headless two-instance test — launch a host and two clients, join a team, admin starts, both clocks agree within 1s, admin pause freezes both, scores aggregate per team.

### Phase 5 — Rescue & elimination
- Enable the Rescue dropdown (`QuizOverlay.gd:114-116`): lists teammates, transfers **10 gems** (−10 sender, +10 receiver), **one assist per sender per adventure**.
- Elimination: a player hitting 0 gems is eliminated and the team takes **−50**. Remove the `maxi(gems+delta, 0)` clamp at `Game._apply():184-186` — it currently makes elimination unreachable.
- `−25` for any member who doesn't finish all stations before time-up (already at `Game.gd:161-164`, needs to feed the team total).

**Verify:** extend `test_rules.gd` — elimination fires at exactly 0, team total reflects −50, rescue can't be used twice by one sender, rescue can't target a non-teammate.

### Phase 6 — Polish & release
- Match every label, button caption and copy string to the PDFs verbatim.
- Real teacher-facing content in Learn (the mockup's instructional images).
- Android: generate a release keystore, fill `export_presets.cfg`, add `INTERNET` permission if the cloud backend ships.
- Pilot-test build, per the paper's Develop phase.

### Phase 7 — Cloud backend *(optional / if "online" is required)*
`NetCloud.gd` against PocketBase or Supabase, same `Net.gd` surface. Adds cross-network play and persistent research data for the Evaluate phase.

---

## 11. Open questions for the client

| # | Blocks | Question | Why it matters |
|---|---|---|---|
| Q1 | **P5** 🔴 | **Rescue rules.** One assist per *sender* per adventure, or one per *receiver*? Can a player be rescued repeatedly? Does the receiver accept, or is it instant? Can you rescue someone already eliminated? | Changes the whole team-strategy layer and the UI of the Rescue dropdown. |
| Q2 | **P5** 🔴 | **Elimination.** Does an eliminated player stop playing entirely, or keep answering at 0 gems? Can gems go negative? | Currently gems clamp at 0, so elimination can never trigger. |
| Q3 | **P7** 🔴 | **"Online" in the paper.** Does the research write-up require literal internet-based play, or is a classroom LAN/hotspot session acceptable? | Decides whether Phase 7 is optional or mandatory. |
| Q4 | P3 | **Randomize Questions** appears in the draft layout's Game Controls but was dropped from the newest PDF. Keep it? | If kept, it shuffles item order per player — which weakens fair team comparison. |
| Q5 | **P3** 🔴 | **"Set"** button in Question Management — what does it do? (Mark the question active for this round? Set it as the item for a specific circle?) | Three plausible meanings; affects the `QuestionStore` schema. |
| ~~Q6~~ | ~~P1~~ | **Victory Gate.** ~~What does the player see on arrival?~~ **Answered 2026-09-21: the summary.** Walking in calls `Game.end_adventure()` and the summary opens. A wait-for-teammates lobby only means something once Phase 4 networking exists; revisit then. | — |
| Q7 | P2 | **Character select.** No mockup. How many characters, and are they chosen once at registration (changeable later?) or per adventure? | 32 heroes currently exist; the client may want a curated few. |
| Q8 | P4 | **Time-up mid-question.** Does the player get cut off instantly, or finish the current item? | Affects fairness and the −25 penalty's trigger point. |
| Q9 | P0 | **Skip.** Confirm: skipping costs −15 and advances to the next circle *without* showing the answer. | The PDFs say answering advances you; they don't say what skipping shows. |
| Q10 | P4 | **Rejoin.** If a student's phone dies or drops mid-adventure, can they rejoin and keep their gems? | Realistic in a classroom of 40 phones; needs server-side state either way. |
| Q11 | P4 | **Team size.** Paper says 5–6 members. Is that enforced (join refused at 7) or advisory? | Affects the join flow and the admin's Teams panel. |
| Q12 | P4 | **Multiple sessions.** Can two teachers run adventures at once on the same network/server? | Decides whether `Net.gd` needs a session ID or can assume one. |
| Q13 | P6 | **Learn content.** The mockup shows instructional images. Who supplies the final artwork/text? | Blocks Phase 6. |
| Q14 | P0 | **Perfect-station bonus** — does using a Hint void it? Current code says yes. | Undocumented in the PDFs; currently implemented as a guess. |

🔴 = answer needed before that phase can start. The rest have a safe default recorded in §10 and can be confirmed later.

---

## Change log

| Date | Change |
|---|---|
| 2026-09-22 | Ring marker deleted: the tower **is** the interactable, and a bobbing **"!"** over the hero says when pressing E/GO would actually do something (station keeps and the Victory Gate too, not just circles). No "current" marker any more — identical towers, the floating number is the progress cue. Taps now aim at the tower, not the bare grass the ring used to sit on. `_can_act_on()` is the one rule, shared by the "!" and the prompt line. |
| 2026-09-22 | Every question circle is now a `Blue_Tower` sprite tinted per station (was a generated flat disc), full building scale per the client's call. `_build_path()`'s decor keep-out box resized to the tower's real footprint. |
| 2026-09-22 | Simplified per feedback: towers no longer dim when locked -- full brightness in every state. State is just the item number floating above the tower (constant color, present until done, then gone) plus the pulsing ring underfoot while it's the current item. Locked towers stay walkable and interactable; walking up and answering out of order already gave "finish X first" (`_try_answer_circle()`), unchanged. |
| 2026-09-22 | Per feedback: circles use each station's *own* building, no tint (`Blue_Tower`/`Yellow_Archery`/`Red_House1`) -- multiply-tinting one shared asset was muddying stations 2/3. Circles are now also solid with a doorstep, matching the 3 station outposts, via the same `_tower_lift()` island-aware offset (a fixed-side offset blocked the trail on station 2's tighter island -- flood-fill reachability caught it, same bug class the original towers hit). |
| 2026-09-22 | Victory Gate is now `Red_Castle` (was two boulders + a ribbon). Freed it up by stepping station 3's tower down to `Red_House1` (the red livery has no second castle-scale asset). |
| 2026-09-22 | Client cut item counts to **8/3/3** (14 total, was 20/10/10). `Game.ITEMS_PER_STATION`/`TOTAL_ITEMS` updated; map, gating and tests are parametric off those two constants so nothing else changed. |
| 2026-09-22 | **Base camp is its own island**, and Tower 1 moved onto it as the camp's gatehouse. The causeway out of camp only rises once the Station 1 briefing is done, so the board cannot be walked at all before the first station. Four islands / four `TRAILS` now; `_station_island()` (one station = one island) replaced by `_island_of_anchor()`, since Tower 1 and its circles no longer share ground. Camp *dressing* is still the old fire + label — deferred. |
| 2026-09-22 | **`config/quit_on_go_back=false` was never applying.** Godot's config parser does not treat `#` as a comment — it folds the `#` line and the key beneath it into one garbage quoted key — so the two `#` lines above it silently voided the setting, and Android's back button was quitting mid-run instead of opening the pause menu. Switched to `;`, which parses. Non-default settings are now recorded in §8 "Project settings", because Godot's writer drops every comment when a setting changes. |
| 2026-09-22 | Per feedback, rearranged: camp island moved to the map's **right** (island 1 mirrored about x=0.5 to make room), the crossing became a walkable **land bridge**, and Tower 1 moved across it onto Station 1's own island. The gate is now a **giant knight** plugging a stamped three-tile neck behind the station, fading to black on the briefing (`_stamp_neck()`, `_post_knight()`, `_dismiss_knight()`). Net simplification downstream: `_find_causeways()` skips seam 0, so the causeway array means "the gate into station i+1" again and last round's `i == 0` special cases in `_refresh_causeways()`, the signage and the toast all reverted. |
| 2026-09-22 | **Island 1 reworked.** Station 1's keep is the **Blue Monastery**, and it moved west off the headland onto island 1's own ground — its whole sprite box, roof included, is checked against `_island_index()`, so nothing hangs over water. The stamped three-tile neck is gone; `_build_barricade()` lays a **line of boulders** across the island instead, shore to shore, with the knight filling its two-cell gap. Station 1's eight circles shifted west to clear it (`TRAILS[1][0]`). Knobs: `BARRICADE_T`, `BARRICADE_GAP`, `ROCK_SCALE`. |
| 2026-09-22 | Per feedback, the art split in two: **keeps** are one building each (`BUILDINGS` — Blue Monastery / Yellow Archery / **Red Barracks**), **circles** are all towers in the station's livery (`CIRCLE_BUILDINGS` — Blue / Yellow / Red Tower). Each keep still has its two flanking houses. |
| 2026-09-22 | `_stamp_path()` was relabelling `_island_of` for cells that were *already* land, so the camp trail's run across island 1 would have dressed it with the camp's props. It now only claims ground the trail invents. Station signage joined the decor keep-out set — a tree was being planted through the topic line. |
| 2026-09-22 | **`tools/map_shot.gd`**: `godot --path game --script res://tools/map_shot.gd -- <out dir>` writes PNGs of the whole board and of the spots worth eyeballing. Windowed, not headless — it needs a GL context. Dev tool, never loaded by the game. |
| 2026-09-22 | Decor pass rewritten: props grow in **patches** of one kind and keep off the road corridor, the shore, the stations and each other (`_plantable()`, `_plant_patch()`, `_trail`, `_taken`). Same fixed seed, so the board does not change run to run. Fixes the loose boulder that stood in the barricade line looking solid and was not — the line's keep-out grew a tile, and nothing plants near it now. |
| 2026-09-22 | Per feedback: widened the yard between Station 1 and the boulder line (`BARRICADE_T` 0.5 -> 0.55, circle 1 further west) and the knight now **walks** into it when briefed instead of fading out. `_knight_stand` is searched once by `_knight_rest()` -- toward the station, off the road, clear of the rocks and the buildings -- and reserved against the decor pass so he does not step down into a tree. `map_shot.gd` grew `dismiss`/`hold` so the after state can be photographed. |
| 2026-09-22 | Knight walks on `Warrior_Run` instead of sliding in his idle pose (idle + walk on one `AnimatedSprite2D`, facing set from the direction of travel), and the decor keep-outs grew to cover the gap, his walk and his spot, plus two tiles either side of the boulder line -- trees were standing in all four. |
| 2026-09-22 | Island 2 is reached by a **land bridge with a guard**, like island 1, instead of a causeway that rises. The hard-coded knight became `BARRICADES`, a list of gates (station, what opens it, where the line stands); `BRIDGED_SEAMS` says which crossings are bridges, `_stamp_path()` lays ground under the hop from one trail to the next where they are, and each causeway now carries its own `seam` so one being skipped does not shift what the others mean. Station 2's guard wears its livery, carries a `Clear Station 1 to pass` sign, and steps aside to the outpost when Station 1 runs out of circles. Guards now pick a stand-down spot furthest-first toward their own station, and clear the signage with their whole body rather than just the cell they stand on. |
| 2026-09-22 | **Dev drawer** (`scripts/DevDrawer.gd`), debug builds only: a slide-out panel on the left of the Adventure map with Skip Station, Teleport, Aerial, Open Gates, Fast Walk, Freeze, +1:00, Show Walls and End Run. `TOOLS` is the table — one line adds a button. Skip Station is what the later islands are tested through, so `test_collisions.gd` now walks the whole gating ladder with it as well. The joystick's zone shrinks to the strip the drawer is not using, since it claims the left half of the canvas and marks those touches handled. |
| 2026-09-21 | Created from the three PDFs. |
| 2026-09-22 | Map redesign: three islands on a 96×54 (16:9) world, causeway gates proved by flood fill, ~208px circle spacing, station outposts, per-island props, tap-a-circle card, `PLAY_ZOOM`. |
| 2026-09-22 | Aerial POV holds until a **tap anywhere** (offline stand-in for the admin's Start Game) and hides the joystick while frozen; fixed two bugs a real tap uncovered (input swallowed by the root Control, clock unpaused by a restart race). |
| 2026-09-21 | Decided: mockups win over the paper on station order; our own art style, PDFs are a mechanics/layout contract only; admin question bank with generator fallback; LAN first with cloud behind the same `Net.gd` interface. |
| 2026-09-21 | **Phase 0 shipped.** Station order swapped (G12), splash screen added (G13), font floor `Art.MIN_FONT`, landscape lock, `±` on all platforms (G19), exponent generator de-duplicated. All tests green. Next: Phase 1 (map rework) — blocked on **Q6** (what the Victory Gate shows). |
| 2026-09-21 | **Phase 1 shipped.** The client's board exists: authored path, 40 circles one item each, tower briefings, Victory Gate (G10, G11, G17). Q6 answered — the gate opens the summary. Decided: the path is drawn **on** the generated island and sequential order is enforced logically, not with corridor walls. All five suites green (393 e2e checks). Next: Phase 2 (accounts & roles) — no blocking questions. |
