local Log = SPZ.Logger("spz-progression")

---The core entry point for the progression module.
---Listens for the race end results from spz-races and processes progression for all participants.
AddEventHandler("SPZ:raceEnd", function(results)
    if not results or not results.finishers then 
        Log.warn("SPZ:raceEnd received with invalid results data.")
        return 
    end

    Log.info("Processing race progression for", #results.finishers, "finishers")

    -- 1. Process Finishers
    for _, finisher in ipairs(results.finishers) do
        local source = finisher.source
        local profile = exports["spz-identity"]:GetProfile(source)
        
        if profile then
            -- XP Calculation & Granting
            local xpGain = exports["spz-progression"]:CalculateXP(
                finisher.position, 
                finisher.laps or 0, 
                finisher.raceType or "circuit", 
                finisher.personalBest or false
            )
            exports["spz-progression"]:GrantXP(source, xpGain)

            -- Bundled Profile Updates
            -- Note: XP is already updated via GrantXP. 
            -- We update other stats like top3_count here.
            local profileUpdates = {
                top3_count = (finisher.position <= 3) and (profile.top3_count + 1) or profile.top3_count
            }
            
            -- TODO Hooks:
            -- local classPointsGain = exports["spz-progression"]:CalculatePoints(finisher.position, finisher.carClass)
            -- local srDelta = exports["spz-progression"]:CalculateSRDelta(true, finisher.position, false)
            -- local iRatingDelta = exports["spz-progression"]:CalculateIRatingDelta(source, results.finishers)
            
            -- profileUpdates.class_points = profile.class_points + (classPointsGain or 0)
            -- profileUpdates.sr = math.max(0.0, math.min(5.0, profile.sr + (srDelta or 0)))
            
            exports["spz-identity"]:UpdateProfile(source, profileUpdates)

            -- Sync to Client (Relays to spz-hud)
            TriggerClientEvent("SPZ:progressionUpdate", source, {
                xpGain = xpGain,
                position = finisher.position,
                -- pointsGain = classPointsGain,
                -- srDelta = srDelta,
            })
        else
            Log.warn("Could not process progression for source", source, "- Profile cache missing.")
        end
    end

    -- 2. Process DNFs
    if results.dnf then
        for _, dnf in ipairs(results.dnf) do
            local source = dnf.source
            local profile = exports["spz-identity"]:GetProfile(source)

            if profile then
                -- DNFs receive NO XP/Points, only SR penalty
                -- TODO: srDelta = exports["spz-progression"]:CalculateSRDelta(false, nil, true)
                
                TriggerClientEvent("SPZ:progressionUpdate", source, {
                    xpGain = 0,
                    dnf = true,
                    -- srDelta = srDelta
                })
            end
        end
    end
end)
