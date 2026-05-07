-- spz-progression/config.lua
Config = {}

-- ── Pace tuning (preset to MEDIUM) ────────────────────────────────────────
Config.Pace = "MEDIUM"  -- "CASUAL"|"MEDIUM"|"HARDCORE"
                         -- multiplier applied globally

Config.PaceMultipliers = {
  CASUAL   = { xp = 1.50, points = 1.50 },   -- 50% faster progression
  MEDIUM   = { xp = 1.00, points = 1.00 },   -- baseline
  HARDCORE = { xp = 0.65, points = 0.65 },   -- 35% slower
}

-- ── XP rewards ────────────────────────────────────────────────────────────
Config.XPRewards = {
  positions  = { 250, 175, 125, 100, 85, 75, 65, 55 },
  dnf        = 25,
  perLap     = 10,           -- max 5 laps counted
  maxLapBonus = 50,
  cleanRace  = 25,
  personalBest = 50,
  trackRecord  = 100,
}

Config.ClassMultipliers = {
  [0] = 1.00,   -- Class C
  [1] = 1.25,   -- Class B
  [2] = 1.50,   -- Class A
  [3] = 1.75,   -- Class S
}

-- ── Class Points ──────────────────────────────────────────────────────────
Config.ClassPointRewards = {
  positions = { 50, 35, 25, 18, 12, 8, 4, 2 },
  dnf       = 0,
}

-- ── Rank thresholds (within a class) ──────────────────────────────────────
Config.RankThresholds = {
  -- points required to reach each rank
  [5] = 0,      -- starting rank in class
  [4] = 50,
  [3] = 125,
  [2] = 250,
  [1] = 400,    -- top of class
}

-- ── License unlocks ───────────────────────────────────────────────────────
Config.LicenseRequirements = {
  [1] = { level = 10, top3InPrior = 10, minSR = 2.0 },   -- B
  [2] = { level = 25, top3InPrior = 20, minSR = 2.5 },   -- A
  [3] = { level = 50, top3InPrior = 30, minSR = 3.0 },   -- S
}

-- ── SR ────────────────────────────────────────────────────────────────────
Config.SR = {
  finishGain        = 0.05,
  top3Gain          = 0.10,
  top5Gain          = 0.05,
  pbGain            = 0.03,
  dnfPenalty        = -0.20,
  collisionPenalty  = -0.02,
  collisionCapPerRace = -0.10,
  dailyMaxGain      = 0.50,
  dailyMaxLoss      = -0.40,
  startBufferSeconds = 3,         -- ignore collisions in first N seconds
  minImpactSpeed    = 30,         -- km/h, below = ignored
  pingFilterMs      = 200,        -- desync filter
  startingValue     = 2.0,
  min               = 0.00,
  max               = 5.00,
}

-- ── iRating ───────────────────────────────────────────────────────────────
Config.IRating = {
  positionDeltas = { 25, 18, 12, 6, 2, -2, -6, -10 },
  dnfPenalty     = -15,
  opponentBonus200 = 1,    -- per opponent rated 200+ above
  opponentBonus500 = 2,    -- per opponent rated 500+ above
  bonusCap       = 10,     -- +/- max bonus per race
  startingValue  = 1500,
  min            = 0,
  max            = 5000,
}

-- ── Bonus modifiers ───────────────────────────────────────────────────────
Config.Bonuses = {
  dailyLogin       = 50,
  weekStreak       = 100,
  monthStreak      = 250,
  classLoyaltyMax  = 1.25,
  classLoyaltyStep = 0.05,
  comeback = {
    minPositionsGained = 5,
    xpBonus           = 50,
    pointsBonus       = 15,
  },
  trackRecordHolderXPBonus = 1.20,
  trackTop3XPBonus         = 1.10,
}

-- ── Anti-abuse ────────────────────────────────────────────────────────────
Config.AntiAbuse = {
  minSecondsBetweenRaces  = 60,    -- below halves XP
  minRaceDurationSeconds  = 45,    -- below = no progression
  minFinishersForFullXP   = 3,
  smallRacePenalty        = 0.50,  -- multiplier when < min finishers
  sameTrackThreshold      = 4,     -- penalty after this many races same track
  sameTrackPenalty4       = 0.75,
  sameTrackPenalty5plus   = 0.50,
}

-- ── Season ────────────────────────────────────────────────────────────────
Config.SeasonDays = 90
Config.AutoSnapshotOnReset = true
Config.SeasonRewardBadges = {
  [1]  = "champion",
  [3]  = "podium",
  [10] = "top10",
}

Config.Debug = false
