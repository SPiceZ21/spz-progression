local Log = SPZ.Logger("spz-progression")

---Computes the appropriate rank string based on license tier and class points.
---@param licenseTier number 0-3
---@param classPoints number current seasonal points
---@return string rank "C-1", "B-5" etc.
local function ComputeRank(licenseTier, classPoints)
    local tierPrefix = ({"C", "B", "A", "S"})[licenseTier + 1]
    local subRank = 5
    
    for i = 1, 5 do
        if classPoints >= (Config.RankThresholds[i] or 999999) then
            subRank = i
        end
    end

    return tierPrefix .. "-" .. subRank
end

---Checks if a player has ranked up/down and fires notifications.
---@param source number
local function CheckRankPromotion(source)
    local profile = Player(source).state.profile
    if not profile then return end

    local oldRank = profile.rank
    local newRank = ComputeRank(profile.license_tier, profile.class_points)

    if newRank ~= oldRank then
        exports["spz-identity"]:UpdateProfile(source, { rank = newRank })
        
        local isPromotion = true -- Simple logic for now: if rank string changed, notify
        -- In a real scenario, we'd compare the rank indices
        
        TriggerEvent("SPZ:rankChanged", source, oldRank, newRank, isPromotion)
        TriggerClientEvent("SPZ:rankChanged", source, {
            oldRank = oldRank,
            newRank = newRank,
            isPromotion = isPromotion
        })
        
        Log.info("Rank changed for", source, oldRank, "->", newRank)
    end
end

exports("ComputeRank", ComputeRank)
exports("CheckRankPromotion", CheckRankPromotion)
