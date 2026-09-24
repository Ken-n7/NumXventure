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

Registration: **Email** + **Username** (globally unique) + **Password** (min 8 chars, with Show toggle) + **Select Role** dropdown.

**Sign in with either the email or the username, plus a Forgot Password flow** (client, 2026-09-23 — neither is in any PDF; the mockups show username + password only). Registration takes all three. The username remains the unique display name on Home and both leaderboards. Recovery is a **6-digit emailed code**, not a link — a link needs a web page or an Android deep link to land on, and the app has neither. GoTrue only knows emails, so a username is resolved through `public.email_for_username()`; see `supabase/README.md`.
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

The base camp sits on its own small island at the map's right, joined to Station 1's island by a **land bridge**. Station 1's monastery stands on island 1's own ground where that bridge lands, and a **fence of boulders curves right round it**, shore to shore, with a giant knight filling its one gap — so the walk cannot begin before the first station has been entered. Island 2 is the same idea in a different shape: a second land bridge lands in its south-east corner, where Station 2's outpost stands, and its own giant guard holds a **curved fence of boulders swung right round that corner** — water on one side of it to water on the other, with one gap where the road leaves west for the circles. Island 3 is a third bridge and a third guard: its fence curves too, from the right of Station 3's outpost down and away to the island's lower-left shore, well clear of the Victory Gate, with the three red towers and the gate all past it.

**One rule for every guard — his own station's briefing stands him down.** Every crossing is a land bridge; nothing rises out of the sea any more. What keeps the walk in order is not the guards but `_can_enter_tower()`: a station only opens its briefing while the current item belongs to it, so reaching a later station's door early gets you nothing but the view.

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

**Not locked during an adventure** (client, 2026-09-23: "follow the pdf"). The research paper argues Learn should be pre-gameplay only on Cognitive Load Theory grounds, but the mockups show it purely as a Home tab and say nothing about locking it. The mockups win, as §1 states.

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

- **`tools/board_dump.gd`** — `godot --headless --path game --script
  res://tools/board_dump.gd -- <out file>` writes a sorted text dump of the
  built board: every anchor, station wall, circle, keep-out box, guard post and
  rest spot, every boulder wall, digests of the land/beach/trail/taken cell
  sets, and every node under `world` with its position, scale and texture. Take
  one before a change and one after and `diff` them — they must be identical
  for any refactor that is not meant to move anything. Screenshots cannot do
  this job: every unit on the board is animating, so two runs of `map_shot.gd`
  differ by up to 1.7% of their pixels on animation phase alone, and a
  threshold loose enough to swallow that is loose enough to swallow a boulder
  moving a cell. The dump is taken the instant `setup()` returns, before a
  single idle frame, so nothing in it depends on timing.

### Code map

One concern per file. Open the one whose name says what you want to change.

| File | What lives there |
|---|---|
| **`scripts/config/MapCfg.gd`** | **Every knob the map is built from** — world size, islands, trails, buildings, blockers, guards, hero, camera, decor, and the asset paths. Change a number here, nowhere else. |
| **`scripts/config/Pal.gd`** | **Every colour and font size**, plus the 640×360 canvas the layouts are built against. |
| `scripts/map/MapGrid.gd` | What is where: land / shore / road / taken cells, walls, keep-outs, the anchors — and every spatial question put to them. Holds no nodes. |
| `scripts/map/MapBuilder.gd` | The ground and the walk: tilemaps, island shapes, the authored trails stamped over them, where each stop stands. |
| `scripts/map/Stations.gd` | The buildings: each keep, its two houses and door guards, the base camp, the Victory Gate. |
| `scripts/map/Barricades.gd` | The gates: a fence of boulders per station and the giant knight in its gap. |
| `scripts/map/Decor.gd` | Everything growing: prop patches, sheep, water rocks. |
| `scripts/AdventureScreen.gd` | The walk and the play: gating, targeting, input, camera, the quiz handoff. Builds nothing itself. |
| `scripts/AdventureHud.gd` | Everything drawn over the board: top bar, prompt line, gem gauge, touch pad, pause menu. |
| `scripts/Art.gd` · `scripts/Ui.gd` | Shared drawing and shared widgets. `Ui.screen_panel/dim/scroll/centre_row/mmss` are what the menu screens are built from. |
| `scripts/Game.gd` | The only autoload: run state, the gem economy, the clock, the save file, the input map. |
| `scripts/tests/TestCase.gd` | What the scene suites share, including the guard that stops a broken suite reporting PASS. |

**Running the suites:** `tools/run_tests.sh` — all five headless suites plus, where
there is a display, the two windowed tools. One exit code. It fails on a timeout
and on a `SCRIPT ERROR` as well as on a failed check, because GDScript aborts the
function and carries on, so a broken suite can otherwise still exit 0.

**Changing anything on the map:** take a `tools/board_dump.gd` before and after and
diff them. See the tool's entry above for why screenshots cannot do that job.

### Known compromises

Values that are **not** free choices — the geometry pins them, and the knob in
`scripts/config/MapCfg.gd` carries a one-line pointer here rather than the
derivation.

#### Station 3's keep, knight and fence are one problem

Each is sitting at a compromise the geometry forced, not at what was wanted:

| | asked for | got | why |
|---|---|---|---|
| keep | move 0.03 east to clear the water | 0.01 | a bigger fence is the price, see below |
| knight | stand down-left of his post | stands through the gap | down-left is the road, and below that the station's signboard |
| boulders | room either side of `arc 6.0` | none | 6.0 is simultaneously the floor and the ceiling |

They are one problem, not three: the keep's x sets the fence's radius, and the
radius plus the signage is what leaves the knight nowhere on his own side.
Moving the signboard, or re-cutting the gap with `shift`, loosens all three at
once.

**Why `arc` is pinned at 6.0.** A fence only gates while *both* its arms run out
of island. The west arm has to reach the west shore, or it carries on round,
crosses the land bridge the player arrives by, and closes the arc around the
station — putting the gate between the player and the briefing, with the circles
loose outside it. The shore by that bridge sits at x 0.548, so the arm reaches
it only while

    arc >= (station x - 0.548) * WORLD_W

— 6.0 cells at x 0.61. Moving the keep further east costs a bigger fence (0.63
needs 8.0), and by then the arc has swung out over the Victory Gate. That pair
of limits is why the keep moved 0.01 east and not the 0.03 it was offered.

`tools/check_guards.gd` walks the board and fails if this ever stops holding.

## 9. Current implementation vs. spec

Engine: **Godot 4.6.3**, GL Compatibility, 640×360 landscape canvas, Android export preset already wired to `build/NumXventure.apk` (arm64, no keystore yet). Every screen is built in code; `scenes/Main.tscn` is a stub. Router: `scripts/Main.gd` with seven screens (`splash, title, hero, adventure, learn, board, summary`).

### Already correct — do not rebuild

Named by function, not by line: half these line numbers were already stale
before the 2026-09-23 cleanup moved the rest of them. Grep for the name.

| Spec item | Where |
|---|---|
| Whole gem economy, exact values | `Game.GEM_*` consts; `Game.mark_correct/mark_wrong/spend_hint/mark_skipped/finish_station()` |
| 50 start gems, +10/−5/−5/−15, perfect-station +10, −25 unfinished | same |
| One hint per item | `Game.spend_hint()` + `item_used_hint`, reset in `begin_item()` |
| Item counts 8/3/3 | `Game.ITEMS_PER_STATION` |
| Shared countdown timer, auto-end at zero | `Game._process()` → `end_adventure()` |
| Station intro card with Mission line | `QuizOverlay._show_intro()` |
| Question screen: prompt, Hint, Skip, answer input, Submit | `QuizOverlay._build()`, `_submit()`. The answer is typed on the screen's **own numeric keypad**, not the OS keyboard |
| CORRECT / Almost There result overlays with gem delta + rule text | `QuizOverlay._show_result()` |
| Strict sequential station gating | `AdventureScreen._can_enter_tower/_can_answer/_can_enter_gate()`, dispatched by `_act_on()` |
| Character select (32 heroes) | `HeroSelectScreen._build()` |
| Learn hub, 3 topics | `LearnScreen.LESSONS` |
| Leaderboard screen + summary screen | `LeaderboardScreen.gd`, `SummaryScreen.gd` |
| Landscape, Android export, touch controls | `project.godot`, `export_presets.cfg`, `AdventureHud._build_pad()` |
| Test suite (rules, collisions, smoke, e2e, touch) | `tools/run_tests.sh` runs all of them |

### Missing or wrong

| # | Spec item | State | Note |
|---|---|---|---|
| G1 | Accounts: username + password (≥8) + role | **absent** | No auth code at all |
| G2 | Admin role & entire admin dashboard | **mostly done** | `AdminHomeScreen.gd` with all five tabs; `GameControlsScreen.gd` writes real `sessions`/`teams` rows. Sign-in routes by role. Joined Members stays empty until Phase 4 gives players a way in |
| G3 | Multi-device play, shared session | **absent** | Zero networking; no `rpc`, no HTTP, no INTERNET permission |
| G4 | Teams & team-name-as-join-code | **done (joining)** | `net/Teams.gd` — `join()` refuses a name the admin did not create, matches case-insensitively, and moves a membership rather than adding a second. `roster()` fills Game Controls' "Joined Members:". Scores per team are still Phase 4's leaderboard slice |
| G5 | Live leaderboard (team + player tabs, correct-response count) | **done** | `net/Board.gd` + `LeaderboardScreen`: Team Ranking from the `team_scores` view for everyone, **Player Ranking** (gems, Correct Responses, idle time) for the admin only. `Game.RIVALS` deleted |
| G6 | Admin-set duration, Start/Pause/Resume for everyone | **done (offline)** | Duration is gone from hero select — `GameControlsScreen` owns it and writes `sessions.duration_s`. `toggle_pause()` is now `open_menu()`: it never touched `Game.clock_paused`, so "Paused" was only ever a label. Phase 4 makes the admin's state reach the players |
| G7 | Question bank CRUD + per-question hint + per-question feedback | **done** | `QuestionStore.gd` over `public.questions`; `QuestionMgmtScreen.gd` (Set / Edit / Delete + Add), `FeedbackScreen.gd` (300-char counter) |
| G8 | Rescue (transfer 10 gems) | **done** | `public.rescue()` moves both halves in one statement; `QuizOverlay`'s `Rescue ▾` lists team-mates with their gems. Refuses yourself, another team, an eliminated player, a second assist, or a sender under 10 gems |
| G9 | Elimination at 0 gems → −50 team | **done** | The clamp is gone from both places; a trigger latches `eliminated` the first time gems reach zero, so the team is charged −50 exactly once. The player keeps answering — **Q2** is still open on whether they should stop, and that flag is what the map would read |
| G10 | Circles on the map = one per item | **done** | 14 `PathCircle` nodes on the path, locked / current / done; progress is `Game.items_done` |
| G11 | Tower-then-circles walk order, Victory Gate | **done** | `AdventureScreen._build_path()`: base camp → T1 → 20 → T2 → 10 → T3 → 10 → gate; `_can_enter_tower/_can_answer/_can_enter_gate` |
| G12 | Station 2/3 content order | **done** | Swapped in Phase 0; asserted in `test_rules.gd` |
| G13 | Loading/splash screen | **done** | `scripts/SplashScreen.gd`, routed first from `Main._ready()` |
| G14 | Login screen, register screen | **done** | `LoginScreen.gd` (email **or** username + password + Show + Forgot), `RegisterScreen.gd` (email + username + password + role), `ResetScreen.gd`. Email and recovery are client additions beyond the PDF |
| G15 | Home dashboard with 4 tabs + username + character + Log Out | **done, one navigation** | `HomeScreen.gd` — username, character, Log Out, the mockup's welcome copy. The four destinations are a **left column, not a bottom tab bar** (client 2026-09-23): landscape phone, height is the scarce axis. Same shape on `AdminHomeScreen`. Our own art per §1 |
| G16 | Team-name entry as its own screen after Start Adventure | **done** | `TeamNameScreen.gd` — "Enter Team Name" + **Ready!**. Hero select's own team field was only deleted on 2026-09-23; until then it was a second copy, and hero select started the run itself. It hands off to the team screen now |
| G17 | Aerial map POV → admin starts → camera swoop transition | **done** | `AdventureScreen._start_intro()` holds the board frozen with **no joystick** until a tap, click or interact press fires `_swoop()`; `Game.clock_paused` means the wait is free. That's the offline stand-in — Phase 3 routes the admin's Start Game into the same `_swoop()` call instead. The world is exactly 16:9 so `_aerial_zoom()` frames the whole board with no bars; what it cannot do is text — circle numbers and station signs are world-space and illegible at 0.208 |
| G18 | Learn locked during gameplay | **not a requirement** | Client 2026-09-23: follow the PDF, which does not lock it. The pause menu never had a Learn entry anyway |
| G19 | Answer input allows negatives on desktop | **done** | `±` button now built on every platform (`QuizOverlay.gd`) |
| G20 | Release signing | **absent** | `export_presets.cfg` keystore paths empty |

---

## 10. Roadmap

### Transport decision — **cloud only** *(client, 2026-09-23)*

**Decided: fully online, Supabase. LAN is not being built.** This reverses the
"LAN first" plan below it and answers **Q3** in practice — the session is
literally internet-based, so what the paper calls "online" is what ships.

**LAN is not ruled out, it is undecided.** If school WiFi turns out to be worse
than a phone hotspot during the pilot, `NetEnet.gd` comes back. So the call list
below stays the contract — but it is **not being built as an abstraction today**.
There is one backend, so the methods live directly on the Supabase client; an
interface with one implementation is the thing to extract on the day a second
one exists, not before. Naming the calls now is what makes that day cheap.

What the session needs, wherever it ends up running:

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

**Shipping: Supabase** — `game/scripts/net/Supabase.gd` over `HTTPRequest`
(GoTrue + PostgREST), schema in `supabase/schema.sql`, setup in
`supabase/README.md`. Realtime carries the pause and the live leaderboard, so
nothing polls. `permissions/internet` and `permissions/access_network_state` are
on in `export_presets.cfg` and verified in the built APK.

**Deferred, undecided — LAN (`NetEnet.gd`)**: `ENetMultiplayerPeer` + `@rpc`,
admin device hosts, no hosting bill, survives dead school WiFi via a hotspot.
Revisit if the pilot's network disappoints.

> ⚠️ **What going cloud-only costs.** No internet in the room is now no game at
> all, where LAN would have needed only a hotspot. Before the pilot: check the
> room's connection, and have a hotspot plan. This is a real risk the client
> accepted, not an oversight.

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
  the list, one entry per gate: the station it belongs to (its livery, and the
  tower its guard steps aside toward) and how far along the stretch between that
  station's tower and its first circle the line stands (`t`), **or** the radius of
  a fence swung right round the station instead (`arc`). One rule for all of them —
  **his own station's briefing stands him down** — so a station is always on the
  near side of its own guard. `_build_barricade()` lays **boulders** either way,
  land's end to land's end:
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
  **Why a guard and not a causeway:** the crossing has to be walkable for the
  station on the far side to be reachable at all — you have to get to a station to
  be briefed by it — so the choke sits *between* a station and its own circles,
  never on the water. `test_collisions.gd` proves it by walking the ground: with
  the three posted, nothing past any of them is reachable from camp; stood down one
  at a time, each station's circles appear in turn.
- ✅ **A fence, not a line** (`_lay_arc()`). Island 2's walk lands in its south-east
  corner and loops back on itself to reach the seam, so a line square across it
  always strands the last circle on the station's side — every column checked —
  and the one horizontal cut that did isolate all three ran through a circle's own
  doorstep. A fence drawn *round* the corner has the whole island outside it. All
  three gates are fences now: a wall that bows away from the station reads as one
  from the yard inside it, which a straight line does not. `_lay_line()` went with
  the last of them. It is swung at `arc` cells' radius from the station's
  doorstep, with the gap on the bearing the walk leaves by give or take `shift`
  cells of arc (nothing draws the road, so the way out is open wherever the gap
  is -- `shift` only decides where the guard stands). Half a cell of arc per step
  so the curve never skips a cell, and each cell's wall is `ROCK_WALL` — wider
  than its cell — so neighbours overlap however it steps and no diagonal slip
  opens between two of them. Which shape a gate takes is not asserted per-gate:
  the flood fill in `test_collisions.gd` walks the ground and sees where it gets,
  which answers it whatever the shape.
- ✅ **A wall stands on what you can see** (`ROCK_WALL`, `GUARD_REACH`). Every
  sprite on this board is base-anchored, so a boulder is drawn a whole texture
  height *above* the cell it was laid on. The fence's walls were centred on the
  cell instead, which put most of a tile of invisible wall on the open grass below
  each stone and left the stone's own top walkable — 30% of the blocked ground on
  the board had nothing drawn over it, and the fences bumped you into thin air.
  Three fixes, all of them the same idea:
  - a boulder's wall is `ROCK_WALL`, sized and placed on the stone, the way a
    building's wall has always been the foot of the building;
  - the gap is sized off the guard's **drawn body** rather than evenly round his
    post (`GUARD_REACH`: his shoulders across, his chest above, and just enough
    below to keep the cell he stands on), because he too is drawn upward from his
    boots — centred, the slack always landed under him, which was the one stretch
    of the whole fence that read as a way through. It is measured against each
    cell's *middle*, not along the arc: a post sits wherever the bearing puts it
    inside its own cell, so one arc length rounded to two cells at station 1 and
    three at station 3, which left the red knight a stride of bare grass over his
    head with the wall still in it;
  - each arm takes one step past the last land cell, so the fence ends with a
    stone in the shallows. A wall on the stone leaves the stone's own cell — the
    ground at its foot — open, and at an arm's end that foot was the way round.
  Every guard's flanking stones now overlap him, above and below, and no wall
  reaches past his helmet or more than 6px under his boots. Bare blocked ground
  is down to 4%, and what is left is the corner slivers where
  the curve steps diagonally, which is the overlap that seals it. `_assert_line()`
  holds both invariants: every wall sits above its own cell's middle, and each
  fence has exactly two stones in the water.
- ✅ **A guard faces the way the player will come at him** — from his own station's
  side, since reaching the station is what opens his gate, so that is the only
  direction anyone arrives from. West of the station he faces east, east of it he
  faces west (`_face()`; the sheets' own direction is east).
- ✅ **Where he steps aside** (`_guard_rest()`, `_stands_clear()`) is searched, not
  authored: open ground beside his own station, on his own side of the wall if
  there is room. Often there is not — a yard with an outpost, a road and a wall of
  rocks in it fills up fast, and island 2's is half sea besides — so it widens to
  anywhere near the station, then to anywhere just off the gap. "Open" is one box
  for a man about two cells across and two high: off the road, out of the rubble
  (measured a little below his feet, since the y-sort draws a stone in the cell
  below him over his boots), off the signage, and not standing on a building.
- ✅ **Four islands** (`AdventureScreen.ISLANDS`), on a world grown
  from 44×30 to **96×54** — 3072×1728, deliberately 16:9 so the whole-board view
  fills the screen exactly.
- ✅ **Every seam is a land bridge** (`BRIDGED_SEAMS`), so the causeway that used to
  rise out of the sea is gone — `_find_causeways()`, `_dress_causeways()`,
  `open_causeway()` and their stepping stones and signage with it. It is one
  `git revert` away if a crossing ever wants to be terrain again; nothing in the
  board reached it any more.
  **Why a line of boulders and not a channel:** *one* boulder on open ground can be
  walked around, which is what made a channel the original answer. A whole line of
  them cannot, and neither can a fence — and unlike a channel, a line can sit
  between a station and its own circles, which is the one place a gate can go if
  briefing the station is what opens it.
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
circles, sequential gating, **flood-fill reachability per island**, every guard
posted then stood down), `smoke_test` (142), `e2e_test` (393), `touch_test` (14). Plus eleven
screenshots off a real GL context: aerial, camp, each outpost, each gate posted
and open, the card, the Victory Gate.

> **Still owed:** region gating is a *visual* expression of the sequential rule the
> PDFs already specify, not a new rule, so nothing is owed the client here. Next is
> the stylized overview — the camera aerial frames the board correctly now, but
> world-space text is unreadable at that zoom.

### Phase 2 — Accounts & roles (local, offline)
- `scripts/AuthStore.gd`: usernames unique, password ≥8 chars, hashed (`Crypto`/SHA-256 + salt — do not store plaintext), role `player|admin`. Backed by `user://accounts.cfg` for now; moves to the host in Phase 4.
- New screens: `LoginScreen.gd`, `RegisterScreen.gd` (Username · Password + Show · Select Role · Register). Register → character select → Home.
- Rework `TitleScreen.gd` into `HomeScreen.gd`: username + character portrait top-left, **Log Out** top-right, welcome banner, bottom tab bar **Home · Start Adventure · Leaderboard · Learn**.
- `TeamNameScreen.gd` — the "Start Adventure → Enter Team Name → Ready!" step, split out of `HeroSelectScreen._build()`.
- Lock Learn during an active adventure (remove it from the pause menu).

**Verify:** new `test_auth.gd` — duplicate username rejected, <8-char password rejected, wrong password rejected, role round-trips, password never appears in the save file.

### Phase 3 — Admin dashboard (local first)
Build the screens against local data; they light up for real in Phase 4.

- `AdminHomeScreen.gd` — tabs **Home · Game Controls · Leaderboard · Question Management · Feedback**.
- `GameControlsScreen.gd` — duration `hr`/`min` steppers + **Apply Time**; **Start Game** / **Pause Game** / **Resume**; Teams panel with editable team names, live "Joined Members:" lists, **Add Team**. (Draft-only **Randomize Questions** — see Q4.)
- `QuestionMgmtScreen.gd` — per-station list, each row `prompt (Ans: x)` + **Set** / **Edit** / **Delete**; Add form `Enter Question` · `Enter Hint` · `Enter Answer` → **Add**.
- `FeedbackScreen.gd` — Select Question dropdown → 300-char feedback textarea with counter → **SAVE FEEDBACK**.
- `scripts/QuestionStore.gd` — persisted bank: `{station, prompt, answer, hint, feedback, active}`, backed by `public.questions`.

  **Decided 2026-09-23 (client): the admin authors the questions. There is no
  ready-made set in the shipped app.** `QuestionGen` stays, but as a
  development convenience behind an explicit **"Use sample questions"** button
  in Question Management — not as a silent top-up.

  The difference matters: a silent fallback means a teacher who authored four
  of the eight items for Station 1 never finds out, and four generated
  questions appear in a graded run. So `QuestionStore.item()` no longer tops
  up. A station short of active items is a **refusal at Start Game** naming
  the station and the shortfall, which the teacher can fix by authoring more
  or by pressing the seed button.
- Remove the player-side pause button; `AdventureHud.toggle_pause()` becomes admin-driven only.
- Move duration out of `HeroSelectScreen._pick_duration()` — admin owns it now.

**Verify:** `test_questions.gd` — CRUD round-trips, feedback >300 chars rejected, deleting a question clears its feedback, a station short of active items refuses to start and names the shortfall, and the seed button fills a station to its item count.

### Phase 4 — Online session (the big one)
- Build against `Supabase.gd` and `supabase/schema.sql` directly — no `Net.gd` indirection until a second backend exists. Admin creates a `sessions` row; students join by team name.
- Team name is the join code — it must match a team the admin created, or the join is refused.
- Host authoritative: shared clock, one pause pauses everyone, gem deltas validated server-side (never trust the client's arithmetic).
- Live leaderboard streamed to both dashboards: **Team Ranking** (Rank · Team · Gems) and **Player Ranking** (Rank · Username · Gems · Correct Responses). Player-facing board shows the team tab only. Delete the hardcoded rivals at `Game.RIVALS`.
- Accounts + question bank live in Postgres, so every player gets identical items.
- **Gem arithmetic moves server-side**: a `security definer` RPC (`apply_answer`, `spend_hint`, `skip_item`) does the sums, and the `own_member` RLS policy narrows to `finished`/`hero`. Until that lands a client can write its own score — flagged in `schema.sql`.

**Verify:** two headless instances against a real Supabase project — two accounts join one team, the admin starts, both clocks agree within 1s, the admin pause reaches both over realtime, scores aggregate per team.

### Phase 5 — Rescue & elimination
- Enable the Rescue dropdown (`QuizOverlay`'s Rescue button): lists teammates, transfers **10 gems** (−10 sender, +10 receiver), **one assist per sender per adventure**.
- Elimination: a player hitting 0 gems is eliminated and the team takes **−50**. Remove the `maxi(gems+delta, 0)` clamp at `Game._apply()` — it currently makes elimination unreachable.
- `−25` for any member who doesn't finish all stations before time-up (already at `Game.end_adventure()`, needs to feed the team total).

**Verify:** extend `test_rules.gd` — elimination fires at exactly 0, team total reflects −50, rescue can't be used twice by one sender, rescue can't target a non-teammate.

### Phase 6 — Polish & release
- Match every label, button caption and copy string to the PDFs verbatim.
- Real teacher-facing content in Learn (the mockup's instructional images).
- Android: generate a release keystore, fill `export_presets.cfg`, add `INTERNET` permission if the cloud backend ships.
- Pilot-test build, per the paper's Develop phase.

### Phase 7 — ~~Cloud backend~~ *(folded into Phase 4, 2026-09-23)*
The cloud **is** the transport now, so there is no separate phase. What remains here is the research payoff Supabase brings for free: Postgres holds every session, so the paper's Evaluate phase has real data to query instead of a spreadsheet.

---

## 11. Open questions for the client

| # | Blocks | Question | Why it matters |
|---|---|---|---|
| Q1 | **P5** 🔴 | **Rescue rules.** One assist per *sender* per adventure, or one per *receiver*? Can a player be rescued repeatedly? Does the receiver accept, or is it instant? Can you rescue someone already eliminated? | Changes the whole team-strategy layer and the UI of the Rescue dropdown. |
| Q2 | **P5** 🔴 | **Elimination.** Does an eliminated player stop playing entirely, or keep answering at 0 gems? Can gems go negative? | Currently gems clamp at 0, so elimination can never trigger. |
| ~~Q3~~ | ~~P7~~ | ~~**"Online" in the paper."**~~ **Answered 2026-09-23: fully online, no LAN.** Supabase is the transport; `NetEnet.gd` is deferred and undecided. See the transport decision in §10. | — |
| Q4 | P3 | **Randomize Questions** appears in the draft layout's Game Controls but was dropped from the newest PDF. Keep it? | If kept, it shuffles item order per player — which weakens fair team comparison. |
| Q5 | P3 | **"Set"** button in Question Management. **No document defines it** — checked all three on 2026-09-23. Both mockup PDFs draw `Set · Edit · Delete` with no legend; the paper's only sentence on the feature is that teachers "input, edit, and **organize** questions per station". **Working default: Set marks the question as one of the station's active items for the next adventure** — the `active` flag the schema already has, no change needed. The reasoning is arithmetic, not wishful: item counts are fixed at 8/3/3, a bank holds more than that, so something must choose *which eight*, and Add/Edit/Delete each already have a job. Confirm with the client, but do not wait on it. | Decides whether `questions` needs a per-round join table or just `active`. |
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
| 2026-09-24 | **40 students, 37 played, 37/37 scores exact.** With the sign-in rate limit raised from 30 to 40 per 5 minutes, three students still bounced at #36-38 — 40 sign-ups plus the teacher's is 41 requests, so the row wants to be **300**, not the class size. Worth recording: **the p95 tail more than halved, 4.0s → 1.6s**, and the slow calls moved from `apply_answer` to `poll`/`find_team`, so the earlier four-second tail was rate-limit retries backing up rather than Postgres struggling. Two natural eliminations, team totals adding up, 15 correct refusals during the pause. The simulation gained `--reuse`: a fixed roster (`simclass000…`) that signs in instead of registering, because it cannot delete auth users — that needs the service key — and 123 profiles had accumulated, 73 of them simulated students. |
| 2026-09-24 | **40 students, and the wall is exactly 30.** A second classroom run failed at student 31 again, the same number as at 30 students — which says the limit did not move, not that 40 is too many. The setting is **Authentication → Rate Limits → "sign ups and sign ins"**, default **30 per 5 minutes per IP**; raising the email or token-refresh rows changes nothing. Recorded in `supabase/README.md` with the measurement. Of the 30 who did play, **30/30 gem totals matched**. Two things the bigger run showed that 30 did not: **p95 latency went 315ms → 4.0s** with 42 `apply_answer` calls over two seconds, which is free-tier compute straining under ~40 concurrent writers and an argument for a paid instance on pilot day; and the report was **counting correct pause-refusals as failures** — 78 of the 100 "failed" calls were the server properly refusing to score while the teacher had everyone stopped. The report separates them now. |
| 2026-09-24 | **The black bars are gone.** `window/stretch/aspect` is `keep_height`, so a 20:9 phone gets a canvas ~800×360 instead of 640×360 letterboxed — about 27% of the screen was unused. Four things had assumed 640: the aerial zoom framed the board against `Pal.CANVAS` rather than the viewport it actually has (it would have cropped on one phone and floated on another); the map drew water only over the world, so a taller screen saw the clear colour past its edge (`MapCfg.WATER_MARGIN`, 20 cells of sea all round); Home's island diorama was 21 tiles, 672px, which left a bare strip at 800; and the HUD's top bar was a fixed 632 wide while GO and MENU sat at fixed coordinates, stranding them 160px short of the thumb reaching for them. The layout checker now runs **every screen at both 640 and 800 wide** — the narrow one catches overflow, the wide one catches anything that assumed a width. |
| 2026-09-24 | **Admin screens driven on the phone.** All three work on a touch screen with the real backend: Question Management lists the live bank, **Unset** writes from the device (row greys, button flips to Set, the count drops to red *7 of 8*), Game Controls shows `State: running` and the real roster under Teams, Feedback loads the authored text with its 34/300 counter. Touch targets land at ~100×64 real pixels. One thing the desktop sweep saw and skipped: `OptionButton` and `TextEdit` still wore the engine's grey, which on parchment reads as an OS form dropped onto the artwork — the exact complaint `Ui.line_edit()` was written to fix. `Ui.option()` and `Ui.text_area()` now share its face, including the dropdown's popup, and Register's Role picker with them. |
| 2026-09-24 | **Phase 5: rescue and elimination.** The `greatest(gems, 0)` clamp is gone from `Game._apply()` and from the scoring functions — elimination could never fire while gems floored at zero, which they had since the first commit. A trigger latches `eliminated` the first time gems reach zero, so the team is charged **−50 exactly once** however the run goes afterwards, and the player keeps answering: the penalty is taken, and benching a student for the rest of a proctored class is the worse outcome. `public.rescue()` moves both halves in one statement so a failure cannot create or destroy gems, and refuses yourself, another team, an eliminated player, a second assist from the same sender, or a sender under 10 gems. The `Rescue ▾` dropdown lists team-mates with their gem counts and greys the ones who are out — **but the dropdown only decides what is easy, never what is allowed**. Defaults recorded against Q1/Q2, all overrulable. **Caught by its own check:** the clamp came out of `spend_hint` and `skip_item` but my edit to `apply_answer` did not match the file's whitespace and silently did nothing, so a wrong answer still floored at zero while a hint did not. |
| 2026-09-24 | **The dev tools stop pretending to be the game.** `scripts/DevUi.gd` — a flat dark box, white text on grey buttons, the default font, no pack art and no tween. Both the screen navigator in `Main` and the map's `DevDrawer` use it: a plain `D` tab on the left edge, one tap shows the box, one tap hides it. The slide animation is gone; waiting 0.18s to reach a cheat is 0.18s of nothing. Deliberately *not* `Ui`, because a cheat panel dressed as parchment reads as part of the game. The navigator is two columns — fifteen entries stacked ran off the canvas, and a row is ~24px however small a height it asks for, since the content margins set the floor, not the request. |
| 2026-09-24 | **The question screen has its own keypad.** `7 8 9 ⌫ / 4 5 6 ± / 1 2 3 0` beside the answer field, and `virtual_keyboard_enabled = false` so the OS keyboard never appears there. The answers are numbers; a full QWERTY to type one digit was the wrong tool, it covered the Submit button, and forty cheap phones means forty keyboard apps with different heights, different "done" keys and autocorrect that would happily mangle `-5`. The minus sign is a key now rather than a toggle nobody finds — and negatives are the whole of Station 1. Question Management refuses a non-numeric answer, since an answer the keypad cannot type is one the grader cannot settle either. **The layout checker had never seen this screen** — it is an overlay, not a route — which is how a keypad could push Submit off the canvas; it now checks the quiz in both its states, and it was itself reading `visible` instead of `is_visible_in_tree()`, so hidden widgets were reported as collisions. Stacked 3×4 the keypad was one row too tall, so it is 4×3. **Verified on the phone end to end:** teleport to circle 1, tap `2` for `1 + 1`, Submit → *CORRECT! +10 gems* on screen and `gems 60, correct 1, items_done 1` in Postgres. |
| 2026-09-24 | **First run on a real phone (Redmi 13C, 720×1600, Android 13), and it found what nothing else could.** `tools/device.sh` builds, installs, launches, screenshots and tails the log over adb; `adb shell input` drives the flow, so a device pass is repeatable rather than a person tapping. **One real bug:** `Supabase.gd` had a single `HTTPRequest`, and the map issues two calls at once — the question bank and the session — so the second died on *"HTTPRequest is processing a request"* and the board silently fell back to tap-to-start. It only surfaced on hardware, where the requests actually raced. One `HTTPRequest` per call now; node churn at a few requests a minute costs nothing, a dropped request costs a student their adventure. **Three phone-only UI problems:** the forms grabbed focus on load, so the soft keyboard covered the password field and Sign In before the student had read anything (no autofocus now); the keyboard still hides the button, so `Main` lifts the screen while it is up and **Enter walks the form** — the keyboard's own ✓ is the submit button on a phone; and the hero portrait was drawn over the username, which the overlap checker had missed because it only collected Buttons, Labels and LineEdits, never a Control holding a sprite. Verified on the device end to end: sign in, relaunch straight to Home on the stored session, join by team name, and the board swooping itself in on a **running** session with the server's clock counting down. **Known and unfixed: ~27% of the screen is black bars** — a 16:9 canvas on a 20:9 phone. `keep_height` would fill it, but the world is authored exactly 16:9, so the aerial view would show past its edges. |
| 2026-09-24 | **Phase 4, slice 5: the live leaderboard.** `net/Board.gd` reads teams from the `team_scores` view and players from `members` joined to their profile. One screen, two tabs: everyone sees **Team Ranking** (the winner is a team, never a player), and the teacher also gets **Player Ranking** — gems, Correct Responses, and **idle time**, since "on circle 3" and "stuck on circle 3" look identical without it, and a row goes red after three minutes of silence. **Only the admin subscribes**: every answered item writes a `members` row, so forty students watching that turns ~200 realtime messages an adventure into ~22,000 for a screen nobody looks at mid-run. A student's board is a plain fetch. **`Game.RIVALS` is deleted** — four invented teams that sat above real students on a board the client reads as a result. Two suites leaned on them without saying so: `test_rules` asserted the fakes were listed, and `smoke` took two rows for granted; both make their own rows now. `TestCase` also hides any real session file for the run, because the live tools leave one and the splash would otherwise wait on a token refresh the offline suites never wanted. |
| 2026-09-24 | **Phase 4, slice 4: the score belongs to the server.** `apply_answer` / `spend_hint` / `skip_item` / `finish_station` are `security definer` functions that check the caller is in that session **and that the session is running**, then do the arithmetic in Postgres. RLS cannot restrict columns, so `revoke update on public.members` plus `grant update (team_id)` is what actually closes the door — verified: a client PATCHing its own gems to 9999 succeeded before and is refused now. The client still sums locally so the result overlay never waits on a round trip, and the server's number replaces the guess when it lands. `Game` emits a `scored` signal rather than calling the backend, because naming `Net` in that file hangs `test_rules` under `--script`, which has no autoloads — the third time that trap has bitten, now prevented by structure. Also **persistent login**: the refresh token lives in `user://session.cfg`, is traded for a new access token before the splash chooses a screen, and renews once on a 401 mid-run so an expiring hour cannot drop a student out of a graded adventure. |
| 2026-09-23 | **Phase 4, slice 3: the shared clock.** `Game.apply_session()` reads the admin's session row — `ends_at` while running, `remaining_s` while paused — and the local tick only fills the gaps between updates, so a phone that joins late or sleeps still agrees with the room (§3, *"durungan an ira pag-answer dapat"*). Online the map waits for **Start Game** instead of a tap, the hint says so, and a student cannot tap their way in early; the admin's pause reaches every phone over the realtime socket and stops the hero as well as the clock. G17's offline stand-in is retired. Four states pinned down in `test_rules` offline — lobby, running, paused, ended, plus a deadline already passed clamping to zero rather than counting negative. **Side fix:** `ends_at` was being written with `use_space`, i.e. `"2026-09-23 15:06:13"`, which is not what `Time.get_unix_time_from_datetime_string()` reads back — the clock would have come out wrong the first time an admin pressed Start. |
| 2026-09-23 | **Phase 4, slice 2: the realtime socket.** `net/Realtime.gd` speaks Supabase's Phoenix channel protocol over `WebSocketPeer` directly — there is no Godot SDK — with one topic carrying every watched table, a 25s heartbeat ahead of the server's 30s timeout, and the user's JWT in the join payload, because **RLS applies to the stream too**: without the token a watcher sees nothing and no error explains why. `Net.realtime()` makes it on first use, so a signed-out client holds no socket. **The trap, found by the check failing once and passing once with no code change:** `phx_join` being accepted is *not* the stream being live. The server sends a separate `"Subscribed to PostgreSQL"` system message afterwards, and a row changed in between is never delivered — so the client exposes `live` / `subscribed` and nothing waits on a timer. `tools/realtime.tscn` drives it against a live project: socket opens, stream goes live, a REST PATCH comes back the other way with the right table, type and new value. |
| 2026-09-23 | **Phase 4, slice 1: players join a team.** `net/Teams.gd` — the team name really is the join code now: `Teams.join()` finds the newest session that has not ended, refuses a name the admin never created ("No team by that name. Check with your teacher."), matches **case-insensitively** so a student is not turned away over a capital they were never given, and **moves** an existing membership rather than inserting a second, which the `unique (session_id, profile_id)` constraint would have shown the student as a raw database error. Game Controls' "Joined Members:" now lists real usernames. Offline and the headless suites skip the join entirely, so they still reach the map. **A bug in the check itself, worth recording:** the second half runs as a student, and a student may not delete questions or sessions — RLS refused every cleanup delete *silently*, so test rows were accumulating in the teacher's bank while the check reported PASS. It signs back in as the admin before cleaning up, and its pool assertion counts only the rows that run authored. |
| 2026-09-23 | **Looked at all twelve screens, and found what measuring could not.** Two were broken, not untidy. **Game Controls** showed a teacher `invalid input syntax for type uuid: ""` — it queried `sessions` with an empty `admin_id` whenever nobody was signed in. **Hero select** had the form inside one scroll and the portrait grid inside another, so Begin Adventure and Back sat past the outer fold where nothing reached them; it also still carried a **Team field**, a second copy of what became `TeamNameScreen` with G16, and it started the run itself rather than handing off. Both fixed. Styling with them: Start Game is the one red primary on its page, Pause and Resume pair on a row, the duration steppers grew `hr` / `min` captions (they read `- + 0 hr 10 min - +`), hero labels came off near-invisible grey, and the DEV button moved to the bottom-left, the one corner no screen claims. |
| 2026-09-23 | **Screenshots, at last, and what they showed.** `tools/ui_shot.tscn` renders a screen into a **SubViewport** and saves the PNG — capturing `root.get_texture()` returned a flat fill on this session however long it waited, and an earlier attempt wrote twelve identical blank images before that was noticed. With real pixels: the admin column was ~400px wide against Home's 186, because an unwrapped heading sets the VBox's minimum width and every button stretches to match; entry colours alternated red/teal and read as arbitrary (one primary now, the rest alike); and the DEV button sat on the title. `tools/layout.tscn` gained **overlap detection** — everything fitting the canvas is not the same as everything being readable, and it immediately found Home's last button sitting on the footer whenever a hero was saved, which the fitting check had passed all along. The footer name is deleted: the header has carried the signed-in name since Phase 2, and the second copy was the thing in the way. |
| 2026-09-23 | **One button size, everywhere.** The admin screens looked unstyled beside Home because they asked for heights of 22, 24, 26, 28 and 30 — and `Ui.button`'s nine-patch has a **~31px floor**, so every one of them rendered ~31 and only the spacing around them differed. The declared heights were fiction. `Ui.H = 32` and three named widths (`W_WIDE` 186, `W_MED` 120, `W_TINY` 70) replace every hand-picked number across the admin screens, the auth screens, the team name screen, the leaderboard and Home. Primary actions are `Ui.RED` consistently — SAVE FEEDBACK, Add, Sign In, Register, Ready!, Start Game — as Home's first column entry already was. |
| 2026-09-23 | **The admin dashboard is the player's Home.** It was a flat background with a column of buttons beside the player's island diorama — two screens that looked like two apps. `AdminHomeScreen` now **extends `HomeScreen`** and overrides five hooks: `_hail()`, `_sub()`, `_entries()`, `_show_portrait()` (a teacher never picked a character), `_after_menu()` (the question-bank readiness line) and `_footer()`. 51 lines against the 130 it was, and the island, header, Log Out and column can no longer drift apart. |
| 2026-09-23 | **One navigation per dashboard, down the left.** Home was carrying a menu column *and* a bottom tab bar — nine buttons for four destinations, with Learn and Leaderboard listed twice. Client's call, and the right one for a landscape phone: the column stays, the tab bar goes, on both dashboards. Buttons collapse to Start Adventure / Continue Quest · Change Character (only with a hero saved, the sole route back to the picker) · Leaderboard · Learn. **Quit is gone** — the back button leaves an app, and Log Out is the action that means something to a student. `Ui.tab_bar()` was deleted with its last caller rather than left for a future one. The admin's five tabs become four column entries, no longer clipping their own labels to fit. |
| 2026-09-23 | **Every menu screen fits the canvas.** Reported as "the UI is messy and going over the screen", measured by a new `tools/layout.tscn` — it opens each screen, walks the control tree and names anything outside 640×360, which beats a screenshot because the complaint is a number. It found 22 overflowing controls across 8 of 12 screens. **Two systemic causes:** `Ui.screen_panel()` positioned a panel from its *declared* size while the box grew to its contents, so anything taller hung off the bottom — it is centred by a `CenterContainer` now; and `Ui.scroll()` used `SIZE_EXPAND_FILL`, so a scroll region inside a panel with no height of its own grew to its contents and scrolled nothing, pushing the rest off-screen — the height is a cap now. Then `clip_text` on tab buttons ("Question Management" alone pushed the admin bar 54px past the right edge), panel row gaps 8 → 4, Home's menu buttons 40 → 30, and hero select's 32 portraits moved into a scroll. Button heights are **not** the lever they look like: `Ui.button`'s nine-patch has a ~31px floor, so asking for 24 gets 31. The check is in `run_tests.sh`, so a screen that grows past the canvas now fails a suite. |
| 2026-09-23 | **Backend keys moved into `project.godot`.** They were environment-only, so a plain launch — and the APK — had no backend and skipped straight past the login screen. The anon key ships inside every APK anyway, so keeping it out of git protected nothing while making editor launches differ from builds; RLS is the guard, and the environment still overrides the settings for pointing a dev run elsewhere. The open door is **signup**, not the key: close it under Authentication → Providers → Email once the roster exists. Fallout caught by the suites: with a backend always configured, e2e's launch now lands on the login form, so it asserts the gate and steps over it rather than signing in — a suite that needs the network is a suite that fails on a train. |
| 2026-09-23 | **The authored bank reaches the player.** Phase 3 built the questions and the admin screens, but `QuizOverlay` still called `QuestionGen` at runtime — a teacher could author eight items for Station 1 and the class would answer eight generated ones. `QuestionStore.load_bank()` now pulls the active questions once when the map opens (forty round trips on a classroom connection is forty chances to stall mid-question) and `item_for()` serves them; the generator remains only for an offline run with no backend, where Start Game's refusal cannot apply. The admin's **feedback becomes the wrong-answer rule reminder**, which is what the Feedback screen writes it for, falling back to the hint when none was written. Answers compare as text now, so authored answers need not be integers, with numeric comparison when both sides are numbers and `−` folded to `-`. **Two bugs the new check found:** the bank was ordered by `id`, which is a uuid — deterministic but arbitrary, so the class met the questions shuffled; `questions` gained `created_at` and authoring order is now play order. And the bank could not live on `Game`, because `test_rules.gd` loads that file with `--script`, which registers no autoloads, so naming `Net` there hung the suite rather than failing it. |
| 2026-09-23 | **G6 closed, and a dev navigator.** The duration picker left hero select — the admin owns the clock, and a player who picks their own length can out-sit the class. `AdventureHud.toggle_pause()` became `open_menu()`: it never set `Game.clock_paused`, so the title "Paused" was a lie the label told for months; players have no pause and only the admin stops the clock. `Main._build_dev_nav()` adds a DEV button in debug builds that jumps to any registered screen from any screen, since walking the real flow to reach the sixth one gets old — jumping to the map starts a run first, because that screen reads one. e2e's duration assertions inverted to prove the picker is *gone*. |
| 2026-09-23 | **Phase 3 — admin dashboard.** `AdminHomeScreen` (five tabs, the mockup's copy, and a live question-bank readiness line), `QuestionMgmtScreen` (Set / Edit / Delete, Add with hint, **Use Sample Questions**), `FeedbackScreen` (Select Question, 300-char counter, SAVE FEEDBACK), `GameControlsScreen` (hr/min steppers + Apply Time, Start / Pause / Resume, Teams) and `QuestionStore.gd` over `public.questions`. Sign-in routes by role. The clock is stored as the schema intends — `ends_at` running, `remaining_s` paused — so resuming cannot hand the class extra time, and **Start Game refuses on an incomplete bank** and names the shortfall. `active` defaults to true, so Set is mostly used to take a question *out* of the pool; a station with more active questions than its item count takes the first N in id order, deterministic so every team sees the same items. Driven against a live project by `tools/admin.tscn` (15 checks, cleans up its own rows). |
| 2026-09-23 | **The question bank is authored, not generated.** Client: the admin creates the questions; the shipped app has no ready-made set. `QuestionGen` survives as a development convenience behind a **"Use sample questions"** button, not as a silent fallback — a bank that quietly tops itself up means a teacher who wrote four of eight items never learns the other four were invented, in a run that is being graded. A station short of active items now refuses at Start Game and names the shortfall. Phase 3's verify list updated to match. |
| 2026-09-23 | **Phase 2 shipped, and the PDFs read back against it.** Login, Register, Forgot Password, the tabbed Home dashboard and the Team Name screen all exist (G14, G15, G16). Client decisions on reading the mockups: sign-in accepts **email or username** (the PDF shows username only; email and recovery are additions), the Home layout stands as built provided nothing from the mockup is missing — so the welcome copy and the character portrait were added verbatim — and **G18 is not a requirement**: follow the PDF, which never locks Learn. Confirmed too that players have no pause button; the admin hosts and pauses everyone (G6, Phase 3). Art stays ours per §1: the mockups are mechanics and wording, not a skin. Username sign-in needs `public.email_for_username()`, a `security definer` function, because GoTrue only knows emails — it lets a username be mapped to an email, which is recorded in the schema as a deliberate tradeoff. |
| 2026-09-23 | **Fully online — LAN dropped.** Client's call: Supabase is the transport, `NetEnet.gd` is not being built. Q3 answered, Phase 7 folded into Phase 4, `permissions/internet` + `access_network_state` on and verified in the built APK. **LAN is deferred, not ruled out** — so the session call list in §10 stays as the contract, but is *not* being extracted into a `Net.gd` interface while there is one backend; the methods live on `Supabase.gd` until a second implementation makes the abstraction earn its keep. The cost of the decision is recorded next to it: no internet in the room is now no game, where LAN needed only a hotspot. |
| 2026-09-23 | **Supabase scaffolding + email login.** `supabase/schema.sql` (profiles by trigger off `auth.users`, sessions holding the shared clock, teams whose name is the join code, members, question bank, `team_scores` view, RLS, `sessions`+`members` on the realtime publication), `supabase/README.md` (setup steps), `game/scripts/net/Supabase.gd` (GoTrue + PostgREST over `HTTPRequest`; no SDK exists and none is needed). Then the client added **email login and Forgot Password**, which killed the `<username>@numxventure.local` shim — real inboxes now. Both confirm and recovery send `{{ .Token }}`, a 6-digit code, because a link has nowhere to land in an APK. **Two things owed:** custom SMTP before the pilot (the built-in mailer does ~2 messages/hour, and 40 students register at once), and the gem arithmetic moved into a `security definer` RPC — the `own_member` policy currently lets a client write its own score, which §10 Phase 4 says not to do. Both marked in place. Phase 7 is still gated on **Q3**; this is scaffolding, not a decision to skip Phase 4's LAN. |
| 2026-09-23 | **Codebase cleanup — no behaviour change.** `AdventureScreen.gd` 2053 → 662 lines, split by the concerns its own section headers already named: `map/MapBuilder`, `map/Stations`, `map/Barricades`, `map/Decor`, all writing into one `map/MapGrid`, plus `AdventureHud` for everything drawn over the board. Every tunable moved to `config/MapCfg.gd` (including ~150 that were unnamed numbers inline and 13 inline asset paths) and every colour and font size to `config/Pal.gd` (95 raw `Color()` literals, one of which — `5a4632` / `5a4630` — was the same brown typo'd in two files). `Ui` grew `screen_panel/dim/scroll/centre_row/mmss` for the blocks the ten menu screens were each copying. `DevTools.gd` deleted (18 lines, one static, one caller). Proved by `tools/board_dump.gd`, identical at every step. Three deliberate visual consolidations: panels are centred now (the quiz was 4px high, the pause menu 9), the title is 26 not 27, and five dim overlays had four alphas between them. Three copy strings unified where the prompt line and its toast said the same thing two ways. |
| 2026-09-23 | **Three suites were green while broken.** GDScript aborts the function on a runtime error and carries on, so `e2e_test` reported PASS having run 12 of its 267 checks, `test_collisions` erred on every run and exited 0, and `tools/map_shot.gd` — windowed, so not in any runner — called a method that had moved for a whole refactor. `tools/run_tests.sh` now runs everything under a timeout and fails on `SCRIPT ERROR`; `TestCase.finish()` refuses to pass a suite that did not reach its own last line. |
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
| 2026-09-22 | Per feedback — *"the player have to interact with the station first to make the knight move like how it is in station 1"* — **one rule for every guard: his own station's briefing stands him down**, so a station always stands on the near side of its own gate. That needed island 2 re-routed: its walk looped back on itself, and no line across it isolated all three circles (every column checked; the one horizontal cut that worked ran through a circle's doorstep). It now lands in the south-west and runs east, `TRAILS[1]` ends in island 1's north-west to meet it, and `BARRICADES` lost its `opens`/`step` fields since there is only the one rule left. Sideways-lifted keeps put their signage below the outpost. |
| 2026-09-22 | Island 2's walk put back the way it was (bridge into the south-east corner, circles looping west–north–east) and its gate became a **curve**: a fence of boulders swung round Station 2's corner from water to water, gap on the road out, per *"the boulder extends from it from its left side curving towards the islands edge"*. Station 2 moved back and right into that corner. `BARRICADES` entries now take `t` for a straight line or `arc` for a fence; `_assert_line()` stopped checking that a line's ends run into water, since that is a statement about straight lines and the flood fill answers "does it hold" for both shapes. |
| 2026-09-22 | Island 3 gets the same treatment: the last causeway became a **land bridge with a guard**, straight across the walk like Station 1's, with the red towers and the Victory Gate past it. With every seam bridged the causeway machinery had no users left, so it is deleted — `_find_causeways()`, `_dress_causeways()`, `_refresh_causeways()`, `open_causeway()`, `_items_through()`, `CAUSEWAY_HALF`, the stepping stones and the signage. One `git revert` away if a crossing ever wants to be terrain again. |
| 2026-09-22 | Island 3's gate became a curve as well, per feedback: from the right of Station 3's outpost, starting below its east house rather than beside it, sweeping down and away to the island's lower-left shore and nowhere near the Victory Gate. Guards now **face the way the player comes at them** — Station 3's was looking away from its own bridge. And where a guard steps aside is searched properly now: he was landing in his own rubble, then on a roof. One box, one filter, three widening searches. |
| 2026-09-22 | Station 3's guard moved two boulders down his own fence (`shift` on an `arc` barricade, in cells of arc). |
| 2026-09-22 | Station 1's wall curved too, radius picked so the gap lands on the cell the straight line put the knight on — he has not moved, the wall around him has. With all three gates fences, `_lay_line()` and `_cells_rect()` had no callers and are gone. |
| 2026-09-21 | Created from the three PDFs. |
| 2026-09-22 | Map redesign: three islands on a 96×54 (16:9) world, causeway gates proved by flood fill, ~208px circle spacing, station outposts, per-island props, tap-a-circle card, `PLAY_ZOOM`. |
| 2026-09-23 | **The fences were walls in the wrong place.** Every sprite here is base-anchored, but a boulder's `_solid` rect was centred on the cell it was laid on — so the block sat most of a tile *below* the stone you can see, the stone's own top was walkable, and 30% of the blocked ground on the board had no art over it. Walls now stand on the stone (`ROCK_WALL`), a guard's gap is sized off his drawn body instead of evenly round his post, measured against cell middles rather than arc length (`GUARD_REACH` — evenly round, the slack landed under his boots; by arc length one number rounded to two cells at station 1 and three at station 3, leaving the red knight bare grass over his head), and each arm steps one cell into the shallows, because a wall on the stone leaves the stone's foot open and at an arm's end that foot was the way round. `ROCK_SCALE` 1.0 → 1.2 so stones touch where the curve steps diagonally. Bare blocked ground 30% → 4%. `BARRICADE_GAP` is gone; `_assert_line()` gained both invariants. |
| 2026-09-22 | Aerial POV holds until a **tap anywhere** (offline stand-in for the admin's Start Game) and hides the joystick while frozen; fixed two bugs a real tap uncovered (input swallowed by the root Control, clock unpaused by a restart race). |
| 2026-09-21 | Decided: mockups win over the paper on station order; our own art style, PDFs are a mechanics/layout contract only; admin question bank with generator fallback; LAN first with cloud behind the same `Net.gd` interface. |
| 2026-09-21 | **Phase 0 shipped.** Station order swapped (G12), splash screen added (G13), font floor `Art.MIN_FONT`, landscape lock, `±` on all platforms (G19), exponent generator de-duplicated. All tests green. Next: Phase 1 (map rework) — blocked on **Q6** (what the Victory Gate shows). |
| 2026-09-21 | **Phase 1 shipped.** The client's board exists: authored path, 40 circles one item each, tower briefings, Victory Gate (G10, G11, G17). Q6 answered — the gate opens the summary. Decided: the path is drawn **on** the generated island and sequential order is enforced logically, not with corridor walls. All five suites green (393 e2e checks). Next: Phase 2 (accounts & roles) — no blocking questions. |
