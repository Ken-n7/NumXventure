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
One continuous path: base camp → Tower 1 → 20 circles → Tower 2 → circles → Tower 3 → circles → Victory Gate. Circle colour per station (blue / orange / red).

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
| 1 | **Master the Basics!** | +, −, ×, ÷ of integers, incl. negative signs | **20** |
| 2 | **Follow the Right Order!** | PEMDAS / GEMDAS order of operations | **10** |
| 3 | **Power Up with Exponents!** | exponential notation, base & exponent | **10** |

> **Resolved 2026-09-21:** the research paper orders these S1 Basics · S2 *Exponential Notation* · S3 *Order of Operations*. **The mockups win** — use the table above. The paper's prose should be corrected to match before publication.
>
> Current code already matches: `Game.ITEMS_PER_STATION = [20, 10, 10]`, and `QuestionGen.item_for_station` maps index 1 → exponents, 2 → PEMDAS — **so stations 2 and 3 must be swapped in `QuestionGen.gd`.**

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

---

## 9. Current implementation vs. spec

Engine: **Godot 4.6.3**, GL Compatibility, 640×360 landscape canvas, Android export preset already wired to `build/NumXventure.apk` (arm64, no keystore yet). Every screen is built in code; `scenes/Main.tscn` is a stub. Router: `scripts/Main.gd` with six screens (`title, hero, adventure, learn, board, summary`).

### Already correct — do not rebuild

| Spec item | Where |
|---|---|
| Whole gem economy, exact values | `scripts/Game.gd:12-18`, `mark_correct/mark_wrong/spend_hint/mark_skipped/finish_station` `:190-232` |
| 50 start gems, +10/−5/−5/−15, perfect-station +10, −25 unfinished | same |
| One hint per item | `Game.spend_hint()` + `item_used_hint`, reset in `begin_item()` |
| Item counts 20/10/10 | `Game.ITEMS_PER_STATION:21` |
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
| G10 | Circles on the map = one per item | **absent** | Progression is a counter + 3 HUD pips; no circle nodes |
| G11 | Tower-then-circles walk order, Victory Gate | **absent** | 3 free-standing towers on a procedural island; no gate, no path |
| G12 | Station 2/3 content order | **swapped** | `QuestionGen.STATIONS` has S2=Exponents, S3=Order — must swap to match mockups |
| G13 | Loading/splash screen | **absent** | `boot_splash/show_image=false` |
| G14 | Login screen, register screen | **absent** | `HeroSelectScreen.gd:4-5` explicitly waves this off as "a web concern" |
| G15 | Home dashboard with 4 tabs + username + character + Log Out | **partial** | `TitleScreen.gd` is a main menu, not a tabbed dashboard |
| G16 | Team-name entry as its own screen after Start Adventure | **partial** | One optional `LineEdit` on hero select |
| G17 | Aerial map POV → admin starts → camera swoop transition | **absent** | Camera is always on the hero |
| G18 | Learn locked during gameplay | **absent** | Reachable from the pause menu |
| G19 | Answer input allows negatives on desktop | **check** | Digit-only regex filter + a `±` button shown **only on touch** (`QuizOverlay.gd:92-95, 300-304`) |
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

### Phase 0 — Correctness fixes (small, do first)
Cheap items that don't depend on any decision.

- Swap S2/S3 in `QuestionGen.STATIONS` and `item_for_station()` so S2 = Order of Operations, S3 = Exponents. Update `test_rules.gd:55-61` (it bounds "station 3" answers) and `e2e_test.gd`.
- Add the loading/splash screen (`scripts/SplashScreen.gd`, register in `Main.SCREENS`).
- Legibility pass — the client asked twice. Audit every font size at 640×360 against a real phone; raise minimums in `Ui.gd`.
- Lock orientation explicitly: add `display/window/handheld/orientation="landscape"` to `project.godot`.
- Show the `±` sign toggle on all platforms, not just touch (`QuizOverlay.gd:92-95`).

**Verify:** `godot --headless --path game --script res://test_rules.gd` and `res://test_collisions.gd` both pass; `godot --headless res://scripts/tests/e2e_test.tscn` passes.

### Phase 1 — Map rework (single-player, still offline)
Makes the map match the client's board before any networking exists.

- Replace the procedural island in `AdventureScreen.gd:131-161` with an authored path: **base camp → Tower 1 → 20 circles → Tower 2 → 10 circles → Tower 3 → 10 circles → Victory Gate**.
- New `scripts/PathCircle.gd`: one node per item, colour per station (blue/orange/red), states locked / current / done. Reuse `Art.cell()` for the sprite.
- Walk order = tower first (intro card), then its circles. `_try_enter_station()` becomes "enter tower", and a new `_try_answer_circle()` shows the **Answer Quest!** button.
- Victory Gate node at the end → triggers `Game.end_adventure()` and the summary.
- Aerial "frozen" POV before start, then a camera tween down to the hero (`AdventureScreen.gd:354-361`).

**Verify:** extend `test_collisions.gd` — assert 40 circles exist, that circle *n+1* is unreachable until *n* is resolved, and that the gate is walkable only after all 40.

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
| Q6 | **P1** 🔴 | **Victory Gate.** No mockup exists. What does the player see on arrival — a results screen, a wait-for-teammates lobby, or just the summary? | It's the end of the entire player flow and is currently undefined. |
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
| 2026-09-21 | Created from the three PDFs. |
| 2026-09-21 | Decided: mockups win over the paper on station order; our own art style, PDFs are a mechanics/layout contract only; admin question bank with generator fallback; LAN first with cloud behind the same `Net.gd` interface. |
