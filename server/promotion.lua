local Log = SPZ.Logger("spz-progression")

---Checks if a player is eligible for a license promotion.
---Validates points, top-3 wins, and safety rating.
---@param source number Player server ID
local function CheckPromotion(source)
    local profile = exports["spz-identity"]:GetProfile(source)
    if not profile then return end

    local tier = profile.license_tier

    -- Class S is the top — no further promotion
    if tier >= 3 then return end

    -- The requirements are for the UNLOCKING of the NEXT tier
    local nextTier = tier + 1
    local req = SPZ.LicenseRequirements[nextTier]
    if not req then return end

    local blockers = {}

    if profile.class_points < req.points then
        table.insert(blockers, ("Points: %d/%d"):format(profile.class_points, req.points))
    end

    if profile.top3_count < req.top3 then
        table.insert(blockers, ("Top-3 finishes: %d/%d"):format(profile.top3_count, req.top3))
    end

    if profile.sr < req.min_sr then
        table.insert(blockers, ("SR: %.2f/%.2f"):format(profile.sr, req.min_sr))
    end

    if #blockers == 0 then
        -- All gates passed — promote
        local success = exports["spz-identity"]:UnlockLicense(source, nextTier, "progression_threshold")
        if success then
            Log.info("License promoted", source, ("C%d → C%d"):format(tier, nextTier))
        else
            Log.error("Failed to unlock license for source", source, "to tier", nextTier)
        end
    else
        -- Log which gates are still blocking (debug only)
        Log.debug("Promotion blocked for source", source, table.concat(blockers, " | "))
    end
end

exports("CheckPromotion", CheckPromotion)
