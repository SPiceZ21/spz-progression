-- F1-style scoring table
SPZ.PointsTable = {
    [1]  = 25,
    [2]  = 18,
    [3]  = 15,
    [4]  = 12,
    [5]  = 10,
    [6]  = 8,
    [7]  = 6,
    [8]  = 4,
    [9]  = 2,
    [10] = 1,
    -- P11+ = 0
}

-- Multipliers awarded based on car class (0-3).
-- Note: These are mirrored in config.lua for tuning.
SPZ.ClassMultiplier = {
    [0] = 1.0,   -- Class C
    [1] = 1.2,   -- Class B
    [2] = 1.5,   -- Class A
    [3] = 2.0,   -- Class S
}
