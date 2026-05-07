local Log = SPZ.Logger("spz-progression")

---Processes progression for a single player at the end of a race.
---@param source number Player server ID
---@param raceData table Data from the race (position, class, laps, dnf, collisions, etc.)
---@param field table The entire field of racers for iRating context
local function ProcessPlayerProgression(source, raceData, field)
    local profile = Player(source).state.profile
    if not profile then 
        Log.warn("Profile missing for", source, "skipping progression.")
        return 
    end

    -- 1. Anti-Abuse Checks
    local xpMultiplier = 1.0
    local now = os.time()
    
    -- a. Minimum seconds between races
    if profile.last_race_at and (now - profile.last_race_at < Config.AntiAbuse.minSecondsBetweenRaces) then
        xpMultiplier = xpMultiplier * 0.5
        Log.info("Applying back-to-back penalty to", source)
    end

    -- b. Minimum race duration
    if raceData.duration and raceData.duration < Config.AntiAbuse.minRaceDurationSeconds then
        Log.info("Race too short for progression for", source)
        return
    end

    -- c. Minimum finishers for full XP
    if raceData.finisherCount and raceData.finisherCount < Config.AntiAbuse.minFinishersForFullXP then
        xpMultiplier = xpMultiplier * Config.AntiAbuse.smallRacePenalty
        Log.info("Applying small lobby penalty to", source)
    end

    -- d. Same track penalty
    if profile.last_race_track == raceData.trackId then
        profile.same_track_count = (profile.same_track_count or 0) + 1
        if profile.same_track_count >= Config.AntiAbuse.sameTrackThreshold then
            local penalty = (profile.same_track_count == Config.AntiAbuse.sameTrackThreshold) 
                and Config.AntiAbuse.sameTrackPenalty4 
                or Config.AntiAbuse.sameTrackPenalty5plus
            xpMultiplier = xpMultiplier * penalty
            Log.info("Applying same track penalty to", source)
        end
    else
        profile.same_track_count = 0
    end

    -- 2. Calculate Gains
    local xpGain = exports["spz-progression"]:CalculateXP(raceData) * xpMultiplier
    local pointsGain = exports["spz-progression"]:CalculatePoints(raceData) * (xpMultiplier < 1.0 and 0.5 or 1.0)
    local srDelta = exports["spz-progression"]:CalculateSRDelta(raceData)
    
    -- iRating context
    local irDeltas = exports["spz-progression"]:CalculateIRatingDeltas(field)
    local irDelta = irDeltas[source] or 0

    -- 3. Apply Gains
    local oldLevel = profile.level or 1
    local newXP = (profile.xp or 0) + math.floor(xpGain)
    local newLevel = exports["spz-progression"]:LevelFromXP(newXP)
    
    local newPoints = (profile.class_points or 0) + math.floor(pointsGain)
    local newSR = math.max(0, math.min(5.0, (profile.sr or 2.0) + srDelta))
    local newIR = math.max(0, math.min(5000, (profile.i_rating or 1500) + irDelta))

    -- 4. Update Profile & Save
    local profileUpdates = {
        xp = newXP,
        level = newLevel,
        class_points = newPoints,
        sr = newSR,
        i_rating = newIR,
        last_race_at = now,
        last_race_track = raceData.trackId,
        same_track_count = profile.same_track_count,
        top3_count = (not raceData.dnf and raceData.position <= 3) and (profile.top3_count + 1) or profile.top3_count
    }

    -- Class-specific top3 tracking
    local classKey = "top3_in_class_" .. ({"c", "b", "a", "s"})[(raceData.class or 0) + 1]
    if not raceData.dnf and raceData.position <= 3 then
        profileUpdates[classKey] = (profile[classKey] or 0) + 1
    end

    exports["spz-identity"]:UpdateProfile(source, profileUpdates)

    -- 5. Check Promotions (Ordered)
    local oldRank = profile.rank
    exports["spz-progression"]:CheckRankPromotion(source)
    exports["spz-progression"]:CheckLicenseUnlock(source)

    -- 6. Events & Notifications
    if newLevel > oldLevel then
        TriggerEvent("SPZ:levelUp", source, oldLevel, newLevel)
    end

    TriggerClientEvent("SPZ:progressionUpdate", source, {
        xpGain = xpGain,
        pointsGain = pointsGain,
        srDelta = srDelta,
        irDelta = irDelta,
        level = newLevel,
        levelUp = (newLevel > oldLevel)
    })
end

AddEventHandler("SPZ:raceEnd", function(results)
    if not results or not results.finishers then return end

    -- Prepare field data for iRating
    local field = {}
    for _, f in ipairs(results.finishers) do
        local p = Player(f.source).state.profile
        table.insert(field, { source = f.source, iRating = p and p.i_rating or 1500, position = f.position, dnf = false })
    end
    if results.dnf then
        for _, d in ipairs(results.dnf) do
            local p = Player(d.source).state.profile
            table.insert(field, { source = d.source, iRating = p and p.i_rating or 1500, position = 999, dnf = true })
        end
    end

    -- Process finishers
    for _, finisher in ipairs(results.finishers) do
        finisher.class = results.carClass
        finisher.trackId = results.trackId
        finisher.duration = results.duration
        finisher.finisherCount = #results.finishers
        ProcessPlayerProgression(finisher.source, finisher, field)
    end

    -- Process DNFs
    if results.dnf then
        for _, dnf in ipairs(results.dnf) do
            dnf.class = results.carClass
            dnf.trackId = results.trackId
            dnf.duration = results.duration
            dnf.finisherCount = #results.finishers
            dnf.dnf = true
            ProcessPlayerProgression(dnf.source, dnf, field)
        end
    end
end)
