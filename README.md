# spz-progression

> XP, Safety Rating, iRating and Rank Points (ranking v3) · rivals

## Overview

`spz-progression` turns race results into progress, once per race on `SPZ:raceEnd`:

| System | Role |
|---|---|
| **Rank Points (RP)** | The only thing that decides rank (`C-5` … `S-1`). One formula, any field size. Display/prestige only — nothing gates cars on it |
| XP / level | Reward for playing |
| Safety Rating | Display stat, daily caps enforced |
| iRating | Display stat + rival matching, zero-sum pairwise Elo |

Rank, SR, iRating and the top-3 count only move in **rated** races (2+ players). A solo
race pays XP only. Full design: `Docs/ranking-design.md` and `Docs/report-v3/ranking-v3.pdf`.

## Structure

| Side | File | Purpose |
|---|---|---|
| Shared | `shared/init.lua` | Logger, notify helper |
| Server | `config.lua` | `Config.Rules` (rank) + XP / SR / iRating tuning |
| Server | `domain/rank.lua` | Pure: RP → rank string, class floor, progress |
| Server | `domain/rp.lua` | Pure: the RP formula, class floor + daily cap |
| Server | `domain/irating.lua` | Pure: zero-sum pairwise Elo |
| Server | `domain/sr.lua` | Pure: SR delta + daily caps |
| Server | `server/main.lua` | Race pipeline: map results, ledger, snapshot, compute, write, emit |
| Server | `server/xp.lua` · `bonus.lua` | XP, levels, flat bonuses |
| Server | `server/rank_admin.lua` | Flat RP (perfect lap, record), `/rank`, admin exports used by spz-admin's menu |
| Server | `server/rivals.lua` | Rivals |
| Tests | `tests/run.lua` · `pipeline_mock.lua` | Offline tests (`python tests/run_lupa.py [pipeline]`) |

## Exports

| Group | Exports |
|---|---|
| XP | `CalculateXP` · `LevelFromXP` · `XPRequired` · `GrantBonus` |
| Rank | `GrantFlatRP(src, rp, reason)` |

## Events

| Event | Emitter | Payload |
|---|---|---|
| `SPZ:progressionApplied` | `server/main.lua` | once per race: every player's before/after RP, rank, SR, iRating |
| `SPZ:rankChanged` | `server/main.lua` | `src, oldRank, newRank, isPromotion` |
| `SPZ:progressionUpdate` (client) | `server/main.lua` | post-race card data |
| `SPZ:licenseUnlocked` | **spz-identity** `UnlockLicense` (single emitter) | class letter went up |

## Commands

| Command | Who | Purpose |
|---|---|---|
| `/rank` | everyone | your rank, RP, progress, streak |
| `/rival` | everyone | your rival |

There are **no admin commands**. Rank admin controls are in the admin menu (`spz-admin`,
`/admin`): **Ranking** on the main page (overview, top 10, recent races → void a race) and
**Players → player → Rank** (RP card, set rank points, that player's recent races → void).
spz-admin checks the admin ace on every callback and audit-logs set/void actions. They call
these exports: `AdminRankInfo` · `AdminSetRP` · `AdminRecentRaces` · `AdminVoidRace` ·
`AdminRankStats`.

There is no season reset.

## Database

Migration `038_rank_points.sql` (spz-core) adds `rank_points`, `rank_streak`, `rp_day_gain`,
`rp_day_key` to `players`, creates `rank_awards`, and backfills RP from each player's current
class.

## Dependencies

`ox_lib` · `spz-core` · `spz-identity` · `spz-races`

---

Part of [SPiceZ-Core](../README.md) · GPL-3.0
