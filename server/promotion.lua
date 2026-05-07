local Log = SPZ.Logger("spz-progression")

---Checks if a player is eligible for a license promotion.
---@param source number
local function CheckLicenseUnlock(source)
    local profile = Player(source).state.profile
    if not profile then return end

    local currentTier = profile.license_tier or 0
    if currentTier >= 3 then return end -- Already max tier (S)

    local nextTier = currentTier + 1
    local req = Config.LicenseRequirements[nextTier]
    if not req then return end

    -- 1. Level Gate
    if (profile.level or 1) < req.level then return end

    -- 2. Top-3 in PRIOR tier Gate
    local priorClassKey = "top3_in_class_" .. ({"c", "b", "a", "s"})[currentTier + 1]
    local top3Count = profile[priorClassKey] or 0
    if top3Count < req.top3InPrior then return end

    -- 3. Safety Rating Gate
    if (profile.sr or 2.0) < req.minSR then return end

    -- 4. Cross-class performance (Average position of last 5 races)
    -- This requires a last_positions history which we'd need to track.
    -- For now, we'll assume they passed if they meet the top3 requirement.

    -- Promotion!
    local success = exports["spz-identity"]:UnlockLicense(source, nextTier, "progression_threshold")
    if success then
        TriggerEvent("SPZ:licenseUnlocked", source, nextTier)
        TriggerClientEvent("SPZ:licenseUnlocked", source, nextTier)
        Log.info("License unlocked for", source, "Tier", nextTier)
    end
end

exports("CheckLicenseUnlock", CheckLicenseUnlock)
