Config = {}

-- XP System Configuration
Config.XP = {
    BasePerRace = 50,
    PositionBonus = { 100, 75, 55, 40, 28, 20, 15, 10, 8, 5 }, -- P1 to P10
    PerLap = 10,
    SprintBonus = 15,    -- Extra XP for sprint races
    PersonalBest = 25,   -- Extra XP for breaking PB
}

Config.SaveInterval = 60 -- Seconds between DB saves

-- Safety Rating (SR) System
Config.SR = {
    finish         =  0.10,   -- finishing any race
    top3           =  0.20,   -- finishing P1, P2, or P3
    personal_best  =  0.05,   -- new personal best lap/run
    dnf_disconnect = -0.50,   -- disconnect mid-race
    dnf_timeout    = -0.25,   -- race timeout, failed to finish
}

-- iRating (Skill Rating) System
Config.IRating = {
    KFactor = 32,
    MinValue = 100,
}
