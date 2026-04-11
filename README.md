<div align="center">

<img src="https://github.com/SPiceZ21/spz-core-media-kit/raw/main/Banner/Banner%232.png" alt="SPiceZ-Core Banner" width="100%"/>

<br/>

# spz-progression

### XP, Safety Rating & Career Progression

*Automated skill tracking and class-based career advancement. Listens to every race result and drives the full player lifecycle — from Class C Rookie to Class S Elite.*

<br/>

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-orange.svg?style=flat-square)](https://www.gnu.org/licenses/gpl-3.0)
[![FiveM](https://img.shields.io/badge/FiveM-Compatible-orange?style=flat-square)](https://fivem.net)
[![Lua](https://img.shields.io/badge/Lua-5.4-blue?style=flat-square&logo=lua)](https://lua.org)
[![Status](https://img.shields.io/badge/Status-Planned-lightgrey?style=flat-square)]()

</div>

---

## Overview

`spz-progression` is a pure event-driven module. It does nothing on its own — it listens to `SPZ:raceEnd` and processes the full results object to apply XP, class points, Safety Rating changes, and iRating updates for every participant simultaneously.

After processing, it runs a promotion check for each player. If all three gates (points + top-3 count + SR) are satisfied, it fires a license unlock through `spz-identity` and broadcasts the milestone to the HUD.

---

## Features

- **XP System** — Global experience points rewarded for race completion, position bonus, laps completed, and personal bests
- **F1 Points Scoring** — `P1: 25 · P2: 18 · P3: 15 · P4: 12 · P5: 10 · P6: 8 · P7: 6 · P8: 4 · P9: 2 · P10: 1`
- **Dual Points Tracking** — Seasonal *class points* (reset per season) and permanent *all-time points* (never reset)
- **Safety Rating (SR)** — Consistency score 0.00–5.00. Rises on clean finishes, drops on DNF/disconnect. Acts as a license promotion gate.
- **iRating** — Elo-style raw skill metric (starts at 1500). Beat higher-rated opponents to gain more. Used for future matchmaking within a class.
- **Rank Brackets** — Points-based standings within each class (5 ranks per class, e.g., Rookie → Street King in Class C)
- **Three-Gate License Promotion** — Points + top-3 finish count + minimum SR must all be satisfied simultaneously
- **Season Reset** — Admin command wipes seasonal standings while preserving all-time points, SR, iRating, and license tiers

---

## Dependencies

| Resource | Version | Role |
|---|---|---|
| `spz-lib` | 1.0.0+ | Callbacks, notify, logger |
| `spz-core` | 1.0.0+ | Session cache, event bus |
| `spz-identity` | 1.0.0+ | Profile access, license unlock |
| `oxmysql` | 2.0.0+ | Progression persistence |

---

## Installation

```cfg
ensure spz-lib
ensure spz-core
ensure spz-identity
ensure spz-progression
```

---

## Integration

The entire module is driven by a single server-side event:

```lua
TriggerEvent("SPZ:raceEnd", results)
```

`spz-progression` listens here and processes all participants. No other entry point is needed.

---

## Points System

F1-style scoring applied per finish position:

```
P1: 25  P2: 18  P3: 15  P4: 12  P5: 10
P6:  8  P7:  6  P8:  4  P9:  2  P10:  1
```

Points scale with class — Class S races award `75` for a win vs `25` in Class C.

**Two parallel counters per player:**

| Counter | Description | Resets |
|---|---|---|
| Class Points | Championship standing in current class | Per season |
| All-Time Points | Cumulative across all classes and seasons | Never |

---

## Safety Rating (SR)

Range: `0.00 – 5.00` (default starting value: `2.0`)

| Event | SR Change |
|---|---|
| Finish any race | +0.10 |
| Finish top 3 | +0.20 |
| Personal best lap | +0.05 |
| DNF — disconnect mid-race | −0.50 |
| DNF — race timeout | −0.25 |

SR below the class minimum blocks license promotion even if point and finish thresholds are met.

---

## iRating

Elo-style skill metric. Starts at `1500` for all players.

- Win against a higher-rated opponent → gain more
- Win against a lower-rated opponent → gain less
- Lose against a lower-rated opponent → lose more

Visible on player profile, leaderboard, and post-race iRating card.

---

## Rank Brackets

| Class C | Class B | Class A | Class S |
|---|---|---|---|
| C-5 Rookie | B-5 Sport Driver | A-5 Pro Driver | S-5 Supercar Driver |
| C-4 Newcomer | B-4 Circuit Racer | A-4 Wheelman | S-4 The Specialist |
| C-3 Amateur | B-3 Hotshoe | A-3 Grand Tourer | S-3 Champion |
| C-2 Club Racer | B-2 Racer | A-2 Elite Racer | S-2 Legend |
| C-1 Street King | B-1 Speed Demon | A-1 Ace | S-1 The SPiceZ |

---

## License Promotion Gates

All three must be satisfied simultaneously:

| Promotion | Class Points | Top-3 Finishes | Min SR |
|---|---|---|---|
| C → B | 500 | 5 | 1.0 |
| B → A | 1000 | 8 | 1.5 |
| A → S | 2000 | 12 | 2.0 |

On promotion: `class_points` resets to 0 · `alltime_points`, `SR`, and `i_rating` carry over.

---

## Full Progression Ladder

```
Join → Class C · Rookie (C-5)
           ↓  Race, earn points, build SR
         C-5 → C-4 → C-3 → C-2 → C-1
           ↓  500 pts + 5 top-3 + SR ≥ 1.0
         Class B license unlocked
           ↓  Class points reset · SR and iRating carry over
         B-5 → B-4 → B-3 → B-2 → B-1
           ↓  1000 pts + 8 top-3 + SR ≥ 1.5
         Class A license unlocked
           ↓
         A-5 → A-4 → A-3 → A-2 → A-1
           ↓  2000 pts + 12 top-3 + SR ≥ 2.0
         Class S license unlocked
           ↓  Points accumulate forever
         S-5 → S-4 → S-3 → S-2 → S-1 · The SPiceZ
```

---

## Admin Commands

```
/spz seasonreset confirm   -- Wipes seasonal standings (points, ranks, top-3s) for all players
                           -- Requires: spz.admin ACE permission
                           -- Preserves: all-time points, SR, iRating, license tiers
```

---

## Events

| Event | Direction | Payload | When |
|---|---|---|---|
| `SPZ:raceEnd` | Server | `results{}` | Listened to — triggers all processing |
| `SPZ:progressionUpdate` | Client | `{xp, classPoints, sr, iRating, rankChanged}` | After processing completes |
| `SPZ:rankChanged` | Server + Client | `{source, old_rank, new_rank, new_rank_name}` | When rank bracket changes |
| `SPZ:seasonReset` | Server | — | After admin triggers season reset |

---

<div align="center">

*Part of the [SPiceZ-Core](https://github.com/SPiceZ-Core) ecosystem*

**[Docs](https://github.com/SPiceZ-Core/spz-docs) · [Discord](https://discord.gg/) · [Issues](https://github.com/SPiceZ-Core/spz-progression/issues)**

</div>
