# spz-progression

> XP, safety rating, iRating and rank points.

![version](https://img.shields.io/badge/version-1.1.1-ff6200) ![SPiceZ-Core](https://img.shields.io/badge/SPiceZ--Core-beta-18181b)

## Overview

Turns race results into progression: XP and levels, a safety rating, an iRating-style skill number and rank points that decide your rank tier. Also tracks rivals.

## Features

- XP and levels
- Safety rating from incidents
- iRating-style skill rating
- Rank points and tiers
- Rivals

## Requirements

| Resource | Type |
|---|---|
| `ox_lib` | third-party |
| `spz-core` | SPiceZ module |
| `spz-identity` | SPiceZ module |
| `spz-races` | SPiceZ module |

## Installation

Included in the [txAdmin recipe](https://github.com/SPiceZ21/spz-txrecipe). Manual install:

1. Download `spz-progression` from GitHub (latest release, or the repository) into your `resources` folder.
2. Add to `server.cfg`, after its requirements:

```cfg
ensure spz-progression
```

## Configuration

- `config.lua`

See the file for every option.

## Commands

| Command | Who | Description |
|---|---|---|
| `/rank` | player | Show your rank |
| `/rival` | player | Show your rival and the gap on your last track |

## Exports

| Export | Side |
|---|---|
| `AdminRankInfo` | server |
| `AdminRankStats` | server |
| `AdminRecentRaces` | server |
| `AdminSetRP` | server |
| `AdminVoidRace` | server |
| `CalculateXP` | server |
| `GrantBonus` | server |
| `GrantFlatRP` | server |
| `LevelFromXP` | server |
| `XPRequired` | server |

```lua
exports["spz-progression"]:AdminRankInfo(...)
```

---

Part of **SPiceZ-Core** — [documentation](https://github.com/SPiceZ21/Docs) · [all modules](https://github.com/SPiceZ21/Docs/blob/main/modules/README.md)
