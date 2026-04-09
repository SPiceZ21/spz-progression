local Log = SPZ.Logger("spz-progression")

---Calculates the expected score for player A against player B.
---@param ratingA number
---@param ratingB number
---@return number expectedScore
local function ExpectedScore(ratingA, ratingB)
    return 1.0 / (1.0 + 10 ^ ((ratingB - ratingA) / 400.0))
end

---Calculates iRating deltas for a field of racers using Elo logic.
---@param racers table List of { source, i_rating, position, dnf }
---@return table deltas A map of [source] = delta
local function CalculateIRatingDeltas(racers)
    local K = Config.IRating.KFactor or 32
    local deltas = {}

    for _, player in ipairs(racers) do
        deltas[player.source] = 0.0
    end

    -- Compare each pair of racers (Matchups)
    for i = 1, #racers do
        for j = i + 1, #racers do
            local a = racers[i]
            local b = racers[j]

            -- Skip if both DNF
            if a.dnf and b.dnf then goto continue end

            local actualA, actualB

            if a.dnf then
                actualA, actualB = 0.0, 1.0
            elseif b.dnf then
                actualA, actualB = 1.0, 0.0
            else
                -- Lower position number (1, 2, 3) means better result
                actualA = a.position < b.position and 1.0 or 0.0
                actualB = 1.0 - actualA
            end

            local expectedA = ExpectedScore(a.i_rating, b.i_rating)
            local expectedB = 1.0 - expectedA

            deltas[a.source] = deltas[a.source] + K * (actualA - expectedA)
            deltas[b.source] = deltas[b.source] + K * (actualB - expectedB)

            ::continue::
        end
    end

    -- Round deltas to nearest integer
    for source, delta in pairs(deltas) do
        deltas[source] = math.floor(delta + 0.5)
    end

    return deltas
end

---Applies an iRating delta to a player and updates their profile.
---@param source number Player server ID
---@param delta number Amount of rating to add/subtract
---@return number actualDelta
local function ApplyIRating(source, delta)
    local profile = exports["spz-identity"]:GetProfile(source)
    if not profile then 
        Log.warn("Failed to apply iRating: Profile not found for source", source)
        return 0
    end

    local oldRating = profile.i_rating
    local newRating = math.max(Config.IRating.MinValue or 100, oldRating + delta)

    local success = exports["spz-identity"]:UpdateProfile(source, { i_rating = newRating })

    if success then
        local actualDelta = newRating - oldRating
        Log.info("iRating updated", source, ("Δ %+d"):format(actualDelta), "Total:", newRating)
        return actualDelta
    else
        Log.error("Failed to update profile with new iRating for source", source)
    end

    return 0
end

exports("CalculateIRatingDeltas", CalculateIRatingDeltas)
exports("ApplyIRating", ApplyIRating)
