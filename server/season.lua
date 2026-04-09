local Log = SPZ.Logger("spz-progression")

---Executes a full season reset.
---Wipes class_points, top3_count, and rank for ALL players (online and offline).
local function SeasonReset()
    Log.warn("SEASON RESET initiated")

    -- 1. Snapshot standings for other modules (e.g. Leaderboards)
    TriggerEvent("SPZ:seasonSnapshot")

    -- 2. Reset Online Players (Profile Cache)
    local sessions = exports["spz-core"]:GetAllSessions()
    local onlineResetCount = 0

    for source, _ in pairs(sessions) do
        local profile = exports["spz-identity"]:GetProfile(source)
        if profile then
            local tier = profile.license_tier or 0
            
            -- Determine start rank based on tier
            local startRank = "C-5"
            if tier == 1 then startRank = "B-5"
            elseif tier == 2 then startRank = "A-5"
            elseif tier == 3 then startRank = "S-5" end

            exports["spz-identity"]:UpdateProfile(source, {
                class_points = 0,
                top3_count = 0,
                rank = startRank
            })
            
            SPZ.Notify(source, "Season reset! Class standings wiped — all-time points preserved.", "info", 8000)
            onlineResetCount = onlineResetCount + 1
        end
    end

    -- 3. Bulk Database Update (Offline Players)
    -- Using CASE to handle rank reset per license_tier
    exports.oxmysql:execute([[
        UPDATE players SET 
            class_points = 0, 
            top3_count = 0,
            rank = CASE license_tier
                WHEN 0 THEN 'C-5'
                WHEN 1 THEN 'B-5'
                WHEN 2 THEN 'A-5'
                WHEN 3 THEN 'S-5'
                ELSE 'C-5'
            END
    ]], {}, function(affected)
        Log.info("Database reset complete. Affected rows:", affected or "Unknown")
    end)

    -- 4. Global Events
    TriggerClientEvent("SPZ:seasonReset", -1)
    
    Log.warn("SEASON RESET complete (Online players reset:", onlineResetCount, ")")
end

-- Admin Command with Confirmation
RegisterCommand("spz", function(source, args, rawCommand)
    local subCommand = args[1]
    if not subCommand then return end

    if subCommand == "seasonreset" then
        local confirm = args[2]

        if confirm == "confirm" then
            SeasonReset()
            if source ~= 0 then
                SPZ.Notify(source, "Season reset completed successfully.", "success")
            end
        else
            if source ~= 0 then
                SPZ.Notify(source, "CAUTION: This will wipe all seasonal standings! Type '/spz seasonreset confirm' to proceed.", "warning", 10000)
            else
                print("[WARNING] Season Reset requires confirmation! Use 'spz seasonreset confirm'")
            end
        end
    end
end, true) -- true requires spz.admin ACE permission
