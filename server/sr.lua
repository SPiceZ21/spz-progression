local Log = SPZ.Logger("spz-progression")

---Calculates Safety Rating delta for a race.
---@param data table { dnf, position, personalBest, collisions }
---@return number srDelta
local function CalculateSRDelta(data)
    if data.dnf then
        return Config.SR.dnfPenalty
    end

    local delta = Config.SR.finishGain

    -- Position bonuses
    if data.position <= 3 then
        delta = delta + Config.SR.top3Gain
    elseif data.position <= 5 then
        delta = delta + Config.SR.top5Gain
    end

    -- Performance bonus
    if data.personalBest then
        delta = delta + Config.SR.pbGain
    end

    -- Collision penalties (filtered/pre-validated by spz-races/client)
    if data.collisions and #data.collisions > 0 then
        local penalty = #data.collisions * Config.SR.collisionPenalty
        delta = delta + math.max(penalty, Config.SR.collisionCapPerRace)
    end

    return delta
end

---Applies SR delta to a player, respecting daily caps.
---@param source number
---@param delta number
---@return number actualDelta
local function ApplySR(source, delta)
    local profile = Player(source).state.profile
    if not profile then return 0 end

    -- TODO: Implement daily cap check using profile.sr_daily_gain/loss
    -- For now, basic clamp
    local oldSR = profile.sr or 2.0
    local newSR = math.max(Config.SR.min, math.min(Config.SR.max, oldSR + delta))
    
    return newSR - oldSR
end

exports("CalculateSRDelta", CalculateSRDelta)
exports("ApplySR", ApplySR)
