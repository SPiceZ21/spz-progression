local Log = SPZ.Logger("spz-progression")

---Calculates XP gain based on race performance.
---@param position number Finisher position (1-based)
---@param laps number Total laps completed
---@param raceType string "circuit" or "sprint"
---@param personalBest boolean Whether the player broke their PB
---@return number xpGain
local function CalculateXP(position, laps, raceType, personalBest)
    local base = Config.XP.BasePerRace

    -- Position bonus: uses the configured table for P1-P10
    local posBonus = Config.XP.PositionBonus[position] or 0

    -- Lap/Run bonus: rewards distance/length
    local distanceBonus = 0
    if raceType == "circuit" then
        distanceBonus = laps * Config.XP.PerLap
    elseif raceType == "sprint" then
        distanceBonus = Config.XP.SprintBonus -- Fixed bonus for sprints
    end

    -- Personal best bonus
    local pbBonus = personalBest and Config.XP.PersonalBest or 0

    return base + posBonus + distanceBonus + pbBonus
end

---Grants XP to a specific player and updates their profile.
---@param source number Player server ID
---@param amount number Amount of XP to grant
local function GrantXP(source, amount)
    local profile = exports["spz-identity"]:GetProfile(source)
    if not profile then 
        Log.warn("Failed to grant XP: Profile not found for source", source)
        return 
    end

    local newTotal = profile.xp + amount
    local success = exports["spz-identity"]:UpdateProfile(source, {
        xp = newTotal,
    })

    if success then
        Log.info("XP granted", source, "+" .. amount, "total", newTotal)
    else
        Log.error("Failed to update profile with new XP for source", source)
    end
end

exports("CalculateXP", CalculateXP)
exports("GrantXP", GrantXP)
