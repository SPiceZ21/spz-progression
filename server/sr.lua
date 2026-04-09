local Log = SPZ.Logger("spz-progression")

---Calculates SR delta based on race result.
---@param result table { dnf: boolean, dnf_reason: string, position: number, personal_best: boolean }
---@return number srDelta
local function CalculateSRDelta(result)
    local delta = 0.0

    if result.dnf then
        if result.dnf_reason == "disconnect" then
            delta = Config.SR.dnf_disconnect
        else
            delta = Config.SR.dnf_timeout
        end
        return delta
    end

    -- Finished
    delta = delta + Config.SR.finish

    if result.position and result.position <= 3 then
        delta = delta + Config.SR.top3
    end

    if result.personal_best then
        delta = delta + Config.SR.personal_best
    end

    return delta
end

---Applies an SR delta to a player and updates their profile.
---Clamped to [0.00, 5.00] and rounded to 2 decimal places.
---@param source number Player server ID
---@param delta number Amount of SR to add/subtract
---@return number actualDelta The actual delta applied after clamping.
local function ApplySR(source, delta)
    local profile = exports["spz-identity"]:GetProfile(source)
    if not profile then 
        Log.warn("Failed to apply SR: Profile not found for source", source)
        return 0.0
    end

    local oldSR = profile.sr
    local newSR = math.max(0.0, math.min(5.0, oldSR + delta))
    
    -- Round to 2 decimal places
    newSR = math.floor(newSR * 100 + 0.5) / 100

    local success = exports["spz-identity"]:UpdateProfile(source, { sr = newSR })
    
    if success then
        local actualDelta = newSR - oldSR
        Log.info("SR updated", source, ("Δ %+.2f"):format(actualDelta), "Total:", ("%.2f"):format(newSR))
        return actualDelta
    else
        Log.error("Failed to update profile with new SR for source", source)
    end

    return 0.0
end

exports("CalculateSRDelta", CalculateSRDelta)
exports("ApplySR", ApplySR)
