local Log = SPZ.Logger("spz-progression")

---The core entry point for the progression module.
---Listens for the race end results from spz-races and processes progression for all participants.
AddEventHandler("SPZ:raceEnd", function(results)
    if not results or not results.finishers then 
        Log.warn("SPZ:raceEnd received with invalid results data.")
        return 
    end

    Log.info("Processing race progression for", #results.finishers, "finishers")

    -- 1. Pre-process all racers for iRating (Field-wide calculation)
    local allRacers = {}
    for _, finisher in ipairs(results.finishers) do
        local profile = exports["spz-identity"]:GetProfile(finisher.source)
        table.insert(allRacers, {
            source = finisher.source,
            i_rating = profile and profile.i_rating or 1500,
            position = finisher.position,
            dnf = false
        })
    end
    if results.dnf then
        for _, dnf in ipairs(results.dnf) do
            local profile = exports["spz-identity"]:GetProfile(dnf.source)
            table.insert(allRacers, {
                source = dnf.source,
                i_rating = profile and profile.i_rating or 1500,
                position = 999,
                dnf = true
            })
        end
    end

    local iratingDeltas = exports["spz-progression"]:CalculateIRatingDeltas(allRacers)

    -- 2. Process Finishers
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

            -- Points Calculation & Granting
            local pointsGain = exports["spz-progression"]:CalculatePoints(
                finisher.position, 
                finisher.carClass or 0
            )
            exports["spz-progression"]:GrantPoints(source, pointsGain)

            -- SR Calculation & Application
            local srDelta = exports["spz-progression"]:CalculateSRDelta({
                dnf = false,
                position = finisher.position,
                personal_best = finisher.personalBest
            })
            local actualSrDelta = exports["spz-progression"]:ApplySR(source, srDelta)

            -- iRating Application
            local irDelta = iratingDeltas[source] or 0
            local actualIrDelta = exports["spz-progression"]:ApplyIRating(source, irDelta)

            -- Bundled Profile Updates
            -- Note: XP, Points, SR, and iRating are already updated via their respective modules. 
            -- We update other stats like top3_count here.
            local profileUpdates = {
                top3_count = (finisher.position <= 3) and (profile.top3_count + 1) or profile.top3_count
            }
            
            exports["spz-identity"]:UpdateProfile(source, profileUpdates)

            -- Sync to Client (Relays to spz-hud)
            TriggerClientEvent("SPZ:progressionUpdate", source, {
                xpGain = xpGain,
                pointsGain = pointsGain,
                srDelta = actualSrDelta,
                irDelta = actualIrDelta,
                position = finisher.position
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
                local srDelta = exports["spz-progression"]:CalculateSRDelta({
                    dnf = true,
                    dnf_reason = dnf.reason or "timeout"
                })
                local actualSrDelta = exports["spz-progression"]:ApplySR(source, srDelta)
                
                -- iRating Application (DNF)
                local irDelta = iratingDeltas[source] or 0
                local actualIrDelta = exports["spz-progression"]:ApplyIRating(source, irDelta)

                TriggerClientEvent("SPZ:progressionUpdate", source, {
                    xpGain = 0,
                    dnf = true,
                    srDelta = actualSrDelta,
                    irDelta = actualIrDelta
                })
            end
        end
    end
end)
