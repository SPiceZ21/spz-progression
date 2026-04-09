-- Shared Licenses requirements

-- Requirements to unlock the next license tier
SPZ.LicenseRequirements = {
    [1] = { points = 500,  top3 = 5,  min_sr = 1.0 },   -- Class C -> Class B
    [2] = { points = 1000, top3 = 8,  min_sr = 1.5 },   -- Class B -> Class A
    [3] = { points = 2000, top3 = 12, min_sr = 2.0 },   -- Class A -> Class S
}
