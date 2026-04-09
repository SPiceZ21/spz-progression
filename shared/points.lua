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

-- Multiplier awarded based on car class (numeric keys 0-3)
SPZ.ClassMultiplier = {
    [0] = 1.0,   -- Class C: base points
    [1] = 1.2,   -- Class B: +20%
    [2] = 1.5,   -- Class A: +50%
    [3] = 2.0,   -- Class S: double points
}
