local Log = SPZ.Logger("spz-progression")

---Computes the appropriate rank string and name based on license tier and class points.
---@param licenseTier number 0-3
---@param classPoints number current seasonal points
---@return string rank "C-1", "B-5" etc.
---@return string rankName "Newcomer", "Ace" etc.
local function ComputeRank(licenseTier, classPoints)
    local brackets = SPZ.RankBrackets[licenseTier]
    if not brackets then return "Unknown", "Unknown" end

    local currentBracket = brackets[1] -- default: lowest rank in class

    for _, bracket in ipairs(brackets) do
        if classPoints >= bracket.threshold then
            currentBracket = bracket
        end
    end

    return currentBracket.rank, currentBracket.name
end

---Checks if a player has ranked up and fires notifications/events.
---@param source number Player server ID
---@param oldRank string The previous rank string
---@param newRank string The new rank string (computed from ComputeRank)
---@param newRankName string The human-readable name of the new rank
local function CheckRankUp(source, oldRank, newRank, newRankName)
    if newRank ~= oldRank then
        -- Update the profile data via spz-identity
        exports["spz-identity"]:UpdateProfile(source, { rank = newRank })

        -- Notify the player
        SPZ.Notify(source, ("Rank up! You are now %s (%s)"):format(newRankName, newRank), "success", 6000)

        -- Fire events for other modules to react (e.g., animations on HUD)
        TriggerEvent("SPZ:rankChanged", source, oldRank, newRank, newRankName)
        TriggerClientEvent("SPZ:rankChanged", source, {
            old_rank      = oldRank,
            new_rank      = newRank,
            new_rank_name = newRankName,
        })
        
        Log.info("Player", source, "ranked up from", oldRank, "to", newRank)
    end
end

exports("ComputeRank", ComputeRank)
exports("CheckRankUp", CheckRankUp)
