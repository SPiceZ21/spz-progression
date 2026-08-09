# spz-progression

> XP, ranks, Safety Rating, iRating, license promotion, seasons · `v2.1.0`

## Overview

`spz-progression` listens for race results and turns them into progress: XP and levels,
championship points, Safety Rating, an Elo-style iRating, rank promotion and demotion, and
license unlocks. It also handles seasons, rivals and series.

## Structure

| Side | File | Purpose |
|---|---|---|
| Shared | `shared/init.lua` | Shared init and type definitions |
| Shared | `shared/points.lua` | Points-to-XP conversion |
| Shared | `shared/ranks.lua` | Rank thresholds and display data |
| Shared | `shared/licenses.lua` | License promotion criteria |
| Server | `config.lua` | Multipliers and tuning |
| Server | `server/main.lua` | Entry point, race-result listener |
| Server | `server/xp.lua` · `bonus.lua` | XP award, levelling, bonuses |
| Server | `server/points.lua` | Championship points |
| Server | `server/sr.lua` | Safety Rating calculation and clamping |
| Server | `server/irating.lua` | iRating deltas |
| Server | `server/ranks.lua` · `promotion.lua` | Rank movement and license grants |
| Server | `server/season.lua` | Season reset and archiving |
| Server | `server/rivals.lua` · `series.lua` | Rivals and race series |
| Client | `client/main.lua` | Progression events and UI feedback |

## Exports

| Group | Exports |
|---|---|
| XP | `CalculateXP` · `LevelFromXP` · `XPRequired` · `GrantBonus` |
| Points | `CalculatePoints` |
| Ratings | `CalculateSRDelta` · `ApplySR` · `CalculateIRatingDeltas` |
| Ranks | `ComputeRank` · `CheckRankPromotion` |
| Licenses | `CheckLicenseUnlock` |
| Series | `GetSeries` |

## Commands

`/spz` · `/rival` · `/series`

## Dependencies

`ox_lib` · `spz-core` · `spz-identity` · `spz-races`

---

Part of [SPiceZ-Core](../README.md) · GPL-3.0
