local Log = SPZ.Logger("spz-progression")

---Calculates Class Points gain based on race performance.
---@param data table { position, class, dnf, comeback }
---@return number pointsGain
local function CalculatePoints(data)
    if data.dnf then return Config.ClassPointRewards.dnf end

    local pos = data.position or 8
    local base = Config.ClassPointRewards.positions[pos] or Config.ClassPointRewards.positions[#Config.ClassPointRewards.positions]
    
    -- Class multiplier
    local classMulti = Config.ClassMultipliers[data.class] or 1.0
    local points = base * classMulti

    -- Comeback bonus
    if data.comeback then
        points = points + Config.Bonuses.comeback.pointsBonus
    end

    -- Pace multiplier
    local pace = Config.PaceMultipliers[Config.Pace] or Config.PaceMultipliers.MEDIUM
    points = points * pace.points

    return math.floor(points)
end

exports("CalculatePoints", CalculatePoints)
