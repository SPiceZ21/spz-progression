local Log = SPZ.Logger("spz-progression")

---Calculates iRating deltas for a field of racers.
---@param field table List of { source, iRating, position, dnf }
---@return table deltas Map of [source] = delta
local function CalculateIRatingDeltas(field)
    local deltas = {}

    for i, player in ipairs(field) do
        local delta = 0
        
        if player.dnf then
            delta = Config.IRating.dnfPenalty
        else
            local pos = player.position or 8
            delta = Config.IRating.positionDeltas[pos] or Config.IRating.positionDeltas[#Config.IRating.positionDeltas]
        end

        -- Opponent context bonus/penalty
        local contextBonus = 0
        for _, opponent in ipairs(field) do
            if player.source ~= opponent.source then
                if not player.dnf and not opponent.dnf then
                    -- If we beat them
                    if player.position < opponent.position then
                        local diff = opponent.iRating - player.iRating
                        if diff >= 500 then
                            contextBonus = contextBonus + Config.IRating.opponentBonus500
                        elseif diff >= 200 then
                            contextBonus = contextBonus + Config.IRating.opponentBonus200
                        end
                    -- If they beat us
                    elseif player.position > opponent.position then
                        local diff = player.iRating - opponent.iRating
                        if diff >= 500 then
                            contextBonus = contextBonus - Config.IRating.opponentBonus500
                        elseif diff >= 200 then
                            contextBonus = contextBonus - Config.IRating.opponentBonus200
                        end
                    end
                end
            end
        end

        -- Clamp context bonus
        contextBonus = math.max(-Config.IRating.bonusCap, math.min(Config.IRating.bonusCap, contextBonus))
        
        deltas[player.source] = delta + contextBonus
    end

    return deltas
end

exports("CalculateIRatingDeltas", CalculateIRatingDeltas)
