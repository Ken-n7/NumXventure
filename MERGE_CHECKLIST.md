# Merge checklist: `stairs-rescue-menu` → `main`

Tick as you go. Started 2026-10-07. `main` has not moved since the branch was
cut, and `git merge-tree` reports a clean merge.

## What is on the branch (12 commits)

| Commit | Change |
|---|---|
| `1704584` | Windows desktop export preset |
| `6fb140e` | Room on stairs, Rescue on the top bar, no player menu (client 2026-10-01) |
| `d7cb726` | Learn: lessons rebuilt from the client's posters (Q13) |
| `47c32c5` | Hero 1.6 (was 1.4), size knob in the dev drawer, `[`/`]` debug-only |
| `8f38b9b` | Bushes, door guards, sheep layered by their feet |
| `2137570` | Six team colours (purple, pink added) |
| `e482ac5` | "Tap GO" prompt on a dark plate, 18px |
| `4cbfed8` | Tower numbers on the roof, floating, next one gold + firefly that flies on |
| `10dab47` | Team-colour arrow over every hero, own included |
| `92106d2` | Change Character on the admin dashboard |
| `9d55bc2` | Phone controls crib fades after 10s |
| `a6f44cc` | Hero in front of the station sign; BASE CAMP label raised |

Client notes covered: "Tap GO" text, team colour above characters, bigger
character, tower numbers not plain.

## Automated checks

- [x] `game/tools/run_tests.sh`: all suites green (rules, mathtext, auth,
      collisions + 4 seeds, smoke, e2e, touch, rescue, alltime, keyboard,
      backdrop, tower, layout, guards, 14 shots)
- [ ] Server SQL suite (`supabase/test/run.sh`) — skipped, no local Postgres.
      Branch does not touch `supabase/`, so not blocking.
- [x] Release APK exports and signs (`tools/device.sh release`)
- [x] Windows release export builds
- [x] Clean merge into `main`
- [x] Code audit of the branch diff: 2 blocking, 5 to fix, see "Audit findings"

## On a phone (Realme RMX1851, 2026-10-07, debug APK)

- [x] Sign in, character pick, join by code, team pick, enter map
- [x] Hero 1.6, red Team-2 arrow, "!" above it
- [x] "Tap GO — enter Station 1" / "Tap GO — Answer Quest!" on the plate
- [x] Gold floating number + firefly; fly-away from 1 to 2 after answering
- [x] Dev drawer shows Hero −/+ (no Zoom)
- [x] Crib fade after 10s (re-checked 2026-10-07: gone by 0:22)
- [x] Station sign / BASE CAMP fix (re-checked on the phone)
- [x] Admin header with a real admin name + character face (desktop, real login)
- [ ] Two or more phones in one session: arrows and names in team colours
      (only one phone here; 6×5 teams checked in desktop renders) —
      **for the client test day**, not blocking
- [x] Rescue greyed before Start, enabled after (phone)
- [x] Release APK on a phone: launches, signs in, no D tabs or dev tools
      (2026-10-07; the phone keeps the release build — uninstall before a
      debug install, the signatures differ)

The phone now has this branch's debug APK.

## Known open issues (not blocking unless noted)

- [x] Hero spawns on the Base Camp campfire: fire moved beside the spawn (`852e35e`)
- [ ] Game Controls still caps at 4 teams (`MAX_TEAMS`); colours are ready for 6
      — kept at 4 on purpose for now (user, 2026-10-07), not blocking
- [x] `touch_test` "the hero walks while the player looks" was flaky: the
      test waited 10 frames (~1px of walking headless). Waits on the clock
      now (`897a76c`)
- [x] `tools/admin.tscn` (live Supabase) "a code ended elsewhere is
      announced": failed every run. The check ended the session before the
      screens' realtime stream was subscribed, so it was never delivered.
      Waits for `Net.realtime().live` now; passes (`897a76c`)
- [x] Game Controls "not seeing ready": not a bug. Reproduced with the admin
      open before the phone joined: lobby at 16s, ready at 18s, live. My
      script had pressed Start the instant the phone entered the map, before
      its presence arrived (the phone itself still said "0 of 1 ready").
- [x] Question screen's Rescue (not greyed while paused): removed altogether
      (user, 2026-10-07): Rescue lives on the top bar only. The mockups had
      one with Hint and Skip — worth a word with the client.
- [x] SPECS.md changelog entry for 2026-10-07

## Audit findings

Fixes (uncommitted at time of writing): B1/B2 with 5 new checks in
`rescue_test` (they fail without the fix), 3/4 checked by a scripted flight,
6 measured on screen; full `run_tests.sh` green after.

Code review of `main...stairs-rescue-menu` (12 commits, 39 files), each
finding checked against the code. **B** = blocks the merge.

- [x] **B1. Rescue button skips the old guards** (`6fb140e`).
      `AdventureScreen.open_rescue()` only checks `_overlay` and
      `Game.rescue_block()`; the old menu could not open while paused, in
      the frozen intro or spectating. So a finished player can still give
      gems after their finish is recorded, and anyone can rescue while the
      Quest Keeper has paused. Fix: guard `open_rescue()` (and grey the
      button) on `hud.paused`, `_frozen`, `_spectate`.
- [x] **B2. Cancelling Rescue in those states brings the pad back**:
      `close_overlay()` always calls `hud.set_pad(true)`, so the joystick
      and GO reappear while spectating or in the intro. Goes away with B1.
- [x] 3. Firefly always leaves from the number's middle: `set_state("done")`
      hides it before `send_firefly()` reads `_firefly.visible`, so the
      jump from its loop to the middle happens on every answer. Cosmetic.
- [x] 4. Firefly hand-off undone by another refresh: a second
      `_refresh_circles()` mid-flight (e.g. Rescue opened and cancelled)
      hides the flyer and shows the next tower's at once; a rejoin can send
      one across the map. Cosmetic.
- [x] 5. Admin Change Character writes the teacher's name into the device's
      one profile (`Game.player_name`), so a student signing in next on that
      phone skips the character picker and plays the teacher's hero. Fix:
      for an admin, save the hero only, not the name. (The same carry-over
      already happens between two students on one phone.)
- [x] 6. Long flash messages (server errors) run off both sides of the
      screen: the bigger prompt has no wrap and no maximum width.
- [x] 7. Stale: `play_zoom` (`AdventureScreen.gd:75`) is never changed now
      that Zoom is gone, and its comment still mentions the drawer's Zoom.

Checked and **not** acted on:
- [x] Sheep halving in size when they walk: one size now, 0.45 (the size
      players knew). Sheep also walked through rocks, trunks and buildings:
      they keep to the hero's walls now (17 of 23 went in before, 0 after).
- Sheep "drawn 58px higher": wrong. Their frames are trimmed to 48px, so
  the shift is about 22px and they do sort by their feet. But it showed an
  **older bug**: sheep are placed at scale 0.9 and `Wander.gd` sets 0.45
  once they walk, so every sheep halves in size when it moves (on `main`
  too).
- Tower signs still seeded from instance ids (`TowerSymbols`, `6fb140e`):
  true; tests pass. Seeding from the tower index would make them exact.
  Optional.
- One shared firefly instead of one per tower: a design suggestion. The
  idle cost is small (particles off when not current); it would also make
  3 and 4 simpler. Optional.
- [x] Minor: `var sign` in `Stations.gd` shadowed the built-in `sign()`
  (renamed `board`).
- Minor: `Art.sit_on_art` mis-measures a fully transparent frame (scatter
  tool only).

## Bug hunt (2026-10-07, after the audit)

- [x] Warnings/errors printed during smoke, e2e, touch, rescue, tower,
      keyboard runs: none (beyond Godot's exit leak notes)
- [x] Layout at 640×360 and 800×360 (20:9): covered by `tools/layout.tscn`
- [x] Pause during an open question: answers held, server refuses rescue

## Server load (2026-10-07, live Supabase, free tier)

`tools/sim/classroom.py --reuse --teams 6 --students N --move 90 [--pos-every S]`:
the whole class answering, a pause, rescues, and every phone on Realtime
walking at the app's rate. Positions on one shared channel (`numxventure`).

| Run | In | Out (fan-out) | Delivered | Lag p95 | Cut off |
|---|---|---|---|---|---|
| 6 players, 0.15s (app today) | 38/s | 226/s | 100% | 289ms | none |
| 30 players, 0.15s (app today) | 185/s | 597/s | 6–17% | 3.0s | ~all |
| 30 players, 0.5s | 59/s | 541/s | 20–41% | 607ms | 28/31 |
| 30 players, 1.0s | 30/s | 491/s | 34–70% | 192ms | 17/31, at 31s and 46s |
| 6 players, 0.15s, **90s** | 38/s | 226/s | 100% | 128ms | none |
| 30 players, 0.15s, **per-team channels** | 187/s | 414/s | 22–72% | 555ms | 20/36, at 20–60s |
| 30 players, 0.5s, **per-team channels** | 59/s | 295/s | **100%** | **126ms** | **none** |
| 30 players, 0.5s, **teacher hub**, snapshots 0.25s | ~61/s | ~155/s | **99–100%** | 561ms | **none** |
| App hub as built, 29 sim + teacher, 0.5s / 4 snaps/s | 57/s pos | 57 + 88 snaps/s | 99% | 456ms | none — snapshots 5.9 KB |
| **Optimized**: on change + 1s heartbeat, 3 snaps/s, slim | **34/s** pos | **34 + 82 snaps/s** | 94% (rest superseded) | 505ms | none — snapshots **2.1 KB** |
| Same, **answering too** (walk 8–15s, answer 8–15s), all member changes to every phone | 23/s pos | 23 + 82 snaps + **35.7 db changes/s** | 96% | 505ms | none |
| **+ progress in snapshots, own row only, silent while answering** | **18/s** pos | 18 + 82 snaps + **1.4 db changes/s** | 93% | 511ms | none — snapshots 1.3 KB |

Realtime says `Too many messages per second` on the channel and closes it;
that phone's later positions are refused ("unmatched topic"), so it freezes on
everyone's map. Not the join/presence burst (cuts come 30-45s into steady
walking) and not the incoming rate (22/s in still cut). Not per channel
either: six team channels at the app's rate were still cut. It is the
project's total Realtime traffic, in and out: clean at ~260-350 messages/s,
cut at ~520+. **Per-team channels at 2 positions a second fit**: the full
class, 100% delivered, nothing cut. REST was fine throughout: every student who played was scored
exactly (30/30 in the last three runs); `apply_answer` p95 ~0.8-1.4s, and 8
answers failed in the heaviest run.

- [x] **Blocking for a full class of 30 on the free tier — fixed.** Client
      wants everyone on one map, live. Built the **teacher hub** in the app
      (`scripts/net/PosHub.gd` on Game Controls; phones send on
      `Realtime.in_topic`, read the teacher's `snap_topic`). Checked live
      2026-10-07: the app's own Game Controls as teacher (session H9H8), 29
      simulated students + the real phone, 6 teams, 120s walking: 99% of
      positions delivered to every student, lag median 326ms / p95 485ms,
      nothing cut; the phone's aerial view shows the whole class walking.
      Needs the teacher's Game Controls open during play.

## Teacher hub: device checks (2026-10-07, real phone + app Game Controls)

- [x] Phone sees the whole class walking (aerial view, 15 sim classmates)
- [x] Teacher's Game Controls killed mid-game: classmates held ~12s, then
      stand at their towers; their rows advance tower to tower as they
      answer (the 20s server fallback)
- [x] Game Controls reopened on the running session: walking again within
      ~10s. 7-minute run incl. a 93s outage: 73% of positions overall —
      ~93% outside the outage — 267 answers, 2977 progress rows delivered
- [x] Smoothness: a second game window on the laptop as a student,
      recording every frame (`build/shots/hub_walk_desktop.mp4`): 15
      classmates over 15s, 0% frames standing still, 1 jump, speed 139-161
      px/s against a true 150
- [ ] **Teacher's window must not be paused.** On this Linux laptop
      (Wayland) a fully covered game window drops to ~1 frame/s; the hub then
      sends ~1 snapshot every few seconds and every classmate stops and jumps.
      Windows is not known to do this, but check on the client's Windows
      laptop: Game Controls minimized, and covered by another app. If it
      slows, tell teachers to keep it visible (or keep the hub running
      while hidden).

## Housekeeping

- [ ] Server test leftovers (live project): accounts `qa_admin10071339`,
      `qa_player10071339` (`@numxventure-test.dev`; deleting needs the
      service-role key or the dashboard), sessions `EXD6`, `3Y83` (3Y83
      ended; EXD6 probably ended by the same admin); plus
      whatever `tools/admin.tscn` created and did not clean up
- [x] `build/` rebuilt from this branch (dev APK, signed release APK,
      Windows debug), 2026-10-07 15:18 — rebuild again only if `main` gets
      anything else
- [ ] `in-app-patches` branch: rebase onto `main` after this merge

## Merge

- [ ] All blocking items above ticked
- [ ] `git switch main && git merge --no-ff stairs-rescue-menu`
- [ ] Push (only when you say so)
