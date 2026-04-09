local Log = SPZ.Logger("spz-progression")

---Calculates points gain based on position and car class.
---@param position number Finisher position (1-based)
---@param carClass number Car class ID (0-3)
---@return number pointsGain
local function CalculatePoints(position, carClass)
    local base = SPZ.PointsTable[position] or 0
    local multiplier = (Config.ClassMultiplier and Config.ClassMultiplier[carClass]) or (SPZ.ClassMultiplier and SPZ.ClassMultiplier[carClass]) or 1.0
    return math.floor(base * multiplier)
end

---Grants both class and all-time points to a specific player.
---Points diverge only at season reset (not handled here).
---@param source number Player server ID
---@param points number Amount of points to grant
local function GrantPoints(source, points)
    local profile = exports["spz-identity"]:GetProfile(source)
    if not profile then 
        Log.warn("Failed to grant points: Profile not found for source", source)
        return 
    end

    local newClassPoints = profile.class_points + points
    local newAlltimePoints = profile.alltime_points + points

    local success = exports["spz-identity"]:UpdateProfile(source, {
        class_points = newClassPoints,
        alltime_points = newAlltimePoints,
    })

    if success then
        Log.info("Points granted", source, "+" .. points, "Class:", newClassPoints, "All-time:", newAlltimePoints)
    else
        Log.error("Failed to update profile with new points for source", source)
    end
end

exports("CalculatePoints", CalculatePoints)
exports("GrantPoints", GrantPoints)
