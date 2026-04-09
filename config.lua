-- config.lua
Config = {}

-- [[ XP ]] ─────────────────────────────────────────────────────────────────────
Config.XP = {
  BasePerRace    = 50,     -- XP for finishing any race
  PositionBonus  = 100,    -- P1 bonus
  PositionStep   = 15,     -- Reduction per position (P2 = 85, P3 = 70...)
  PerLap         = 10,     -- XP per lap (circuit)
  SprintBonus    = 15,     -- Flat bonus for sprint runs instead of per-lap
  PersonalBest   = 25,     -- PB bonus
}
-- DNF = 0 XP always (hardcoded, not configurable)

-- [[ Points multipliers by class ]] ─────────────────────────────────────────────
Config.ClassMultiplier = {
  [0] = 1.0,   -- Class C
  [1] = 1.2,   -- Class B
  [2] = 1.5,   -- Class A
  [3] = 2.0,   -- Class S
}

-- [[ Safety Rating deltas ]] ────────────────────────────────────────────────────
Config.SR = {
  finish         =  0.10,
  top3           =  0.20,
  personal_best  =  0.05,
  dnf_disconnect = -0.50,
  dnf_timeout    = -0.25,
}

-- [[ iRating ]] ─────────────────────────────────────────────────────────────────
Config.IRating = {
  KFactor  = 32,     -- Elo K-factor — higher = more volatile
  MinValue = 100,    -- Floor: iRating can never go below this
}

-- [[ License promotion gates ]] ──────────────────────────────────────────────────
-- These mirror SPZ.LicenseRequirements in shared/licenses.lua
-- Change here and re-run if you want easier/harder promotion
Config.LicenseRequirements = {
  [1] = { points = 500,  top3 = 5,  min_sr = 1.0 },   -- C -> B
  [2] = { points = 1000, top3 = 8,  min_sr = 1.5 },   -- B -> A
  [3] = { points = 2000, top3 = 12, min_sr = 2.0 },   -- A -> S
}

-- [[ Season ]] ───────────────────────────────────────────────────────────────────
Config.Season = {
  -- Snapshot standings before reset?
  SnapshotBeforeReset = true,
}

-- [[ Debug ]] ────────────────────────────────────────────────────────────────────
Config.Debug = false
