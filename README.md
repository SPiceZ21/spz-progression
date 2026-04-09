<div align="center">
  <img src="https://github.com/SPiceZ21/spz-core-media-kit/raw/main/Banner/Banner%232.png" alt="SPiceZ-Core Banner" width="100%">

  # spz-progression — XP, SR & Licensing
  
  `SPiceZ-Core` | **Progression Module**
  
  *Automated skill tracking, safety ratings, and class-based career progression.*
</div>

---

Core progression and skill-tracking module for the **SPiceZ-Core** racing framework. This resource manages the full player lifecycle, from Rookie (Class C) to Elite (Class S).

## 🏎️ Features

- **XP System**: Global experience points rewarded for race completion and performance.
- **iRating (Skill)**: Elo-based skill rating that measures raw driving ability against the field.
- **Safety Rating (SR)**: Measures clean racing and consistency (Range: 0.00 – 5.00).
- **Points System**: Parallel tracking of seasonal **Class Points** and permanent **All-time Points**.
- **Rank Brackets**: Points-based career progression within each car class (e.g., Rookie, Amateur, Legend).
- **License Promotions**: Automated "Three-Gate" validation (Points + Wins + SR) to unlock higher racing classes.
- **Season Management**: Robust season reset logic with database-level synchronization and standing snapshots.

## 🛠️ Integration

The entire module is driven by a single server-side event:

```lua
TriggerEvent('SPZ:raceEnd', results)
```

The `results` object expected consists of `finishers` and `dnf` lists, which the progression module processes to calculate gains/losses for all participants simultaneously.

## 📜 Admin Commands

- `/spz seasonreset`: Wipes seasonal standings (Points, Ranks, Top-3s) for all players.
  - *Requires `spz.admin` Ace permission.*
  - *Requires `confirm` argument (e.g., `/spz seasonreset confirm`).*

## 📁 Structure

- `shared/`: Static metadata, rank brackets, and default license requirements.
- `server/`: Core logic for each progression sub-system.
- `config.lua`: Centralized tuning for multipliers, reward deltas, and promotion thresholds.

---
*Part of the SPiceZ-Core Ecosystem.*
