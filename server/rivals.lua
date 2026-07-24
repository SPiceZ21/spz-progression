-- server/rivals.lua
-- Rival system. Each player is paired with another of similar iRating. When
-- you set a lap that beats your rival's stored best on a track, you both get
-- pinged — async competition that works whether the rival is online or not.
--
-- Beat detection reads the racelines store (best_ms per player+track, written
-- by spz-raceline on every improved lap). A per-session dedupe set means the
-- "you beat your rival" ping fires once per track, not every lap.

local Notified = {}   -- [playerId] = { [track] = true }  (in-memory, per boot)

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function profileId(src)
    local ok, p = pcall(function() return exports["spz-identity"]:GetProfile(src) end)
    return ok and p and p.id or nil
end

local function nameOf(playerId)
    local row = MySQL.single.await("SELECT username FROM players WHERE id = ?", { playerId })
    return row and row.username or "Unknown"
end

-- online source for a given DB player id (nil if offline)
local function srcOf(playerId)
    for _, src in ipairs(GetPlayers()) do
        if profileId(tonumber(src)) == playerId then return tonumber(src) end
    end
    return nil
end

local function notify(src, title, msg, ntype)
    if not src then return end
    TriggerClientEvent("ox_lib:notify", src, {
        title = title, description = msg, type = ntype or "inform", duration = 8000,
    })
end

local function discord(title, msg, fields)
    if GetResourceState("spz-log") ~= "started" then return end
    pcall(function()
        exports["spz-log"]:Success("race", title, msg, fields)
    end)
end

-- ── Rival assignment ──────────────────────────────────────────────────────────

-- Nearest iRating player who isn't me and isn't banned.
local function pickRival(playerId)
    local me = MySQL.single.await("SELECT i_rating FROM players WHERE id = ?", { playerId })
    if not me then return nil end

    local row = MySQL.single.await([[
        SELECT id FROM players
        WHERE id != ? AND (banned IS NULL OR banned = 0)
        ORDER BY ABS(i_rating - ?) ASC
        LIMIT 1
    ]], { playerId, me.i_rating or 1500 })
    return row and row.id or nil
end

local function getRival(playerId)
    local row = MySQL.single.await("SELECT rival_id FROM rivals WHERE player_id = ?", { playerId })
    if row then return row.rival_id end

    local rid = pickRival(playerId)
    if not rid then return nil end
    MySQL.query.await(
        "INSERT INTO rivals (player_id, rival_id) VALUES (?, ?) ON DUPLICATE KEY UPDATE rival_id = VALUES(rival_id)",
        { playerId, rid }
    )
    return rid
end

-- Assign on join (once the profile is loaded)
AddEventHandler("SPZ:playerReady", function(src)
    CreateThread(function()
        Wait(2000)
        local pid = profileId(src)
        if not pid then return end
        local rid = getRival(pid)
        if rid then
            Notified[pid] = {}   -- fresh session dedupe
        end
    end)
end)

-- ── Beat detection ────────────────────────────────────────────────────────────
-- Fires on any completed race/TT lap (same event spz-raceline listens to).

AddEventHandler("spz-raceline:lapCompleted", function(src, track, lapMs)
    if type(track) ~= "string" or type(lapMs) ~= "number" or lapMs <= 0 then return end

    CreateThread(function()
        local pid = profileId(src)
        if not pid then return end

        local rid = getRival(pid)
        if not rid then return end

        Notified[pid] = Notified[pid] or {}
        if Notified[pid][track] then return end   -- already told them this session

        local rivalBest = MySQL.scalar.await(
            "SELECT best_ms FROM racelines WHERE player_id = ? AND track = ? LIMIT 1",
            { rid, track }
        )
        if not rivalBest then return end          -- rival has no time here yet
        if lapMs >= rivalBest then return end      -- didn't beat them

        Notified[pid][track] = true

        local myName    = nameOf(pid)
        local rivalName = nameOf(rid)
        local gap       = (rivalBest - lapMs) / 1000

        -- You (online — you just drove it)
        notify(src, "RIVAL BEATEN",
            ("You beat your rival %s on %s by %.2fs!"):format(rivalName, track, gap), "success")

        -- Your rival (if online)
        local rsrc = srcOf(rid)
        notify(rsrc, "RIVAL ALERT",
            ("%s just beat your time on %s by %.2fs. Reclaim it."):format(myName, track, gap), "warning")

        discord("Rival Beaten",
            ("**%s** beat rival **%s** on **%s** by %.2fs"):format(myName, rivalName, track, gap),
            {
                { name = "Track",  value = track,                    inline = true },
                { name = "Margin", value = ("%.2fs"):format(gap),    inline = true },
            })
    end)
end)

-- ── /rival — show current rival + gap on the track you last raced ────────────

RegisterCommand("rival", function(source)
    local src = source
    CreateThread(function()
        local pid = profileId(src)
        if not pid then return end
        local rid = getRival(pid)
        if not rid then
            notify(src, "Rival", "No rival assigned yet — race a bit and check back.", "inform")
            return
        end
        local rivalName = nameOf(rid)
        local ir = MySQL.scalar.await("SELECT i_rating FROM players WHERE id = ?", { rid }) or 1500
        notify(src, "Your Rival",
            ("%s  ·  %d iR — beat their track times to climb."):format(rivalName, ir), "inform")
    end)
end, false)

-- ── Periodic re-pairing: keeps rivals near your current iRating ──────────────

CreateThread(function()
    while true do
        Wait(30 * 60 * 1000)   -- every 30 min
        for _, s in ipairs(GetPlayers()) do
            local src = tonumber(s)
            local pid = profileId(src)
            if pid then
                local rid = pickRival(pid)
                if rid then
                    MySQL.query.await(
                        "INSERT INTO rivals (player_id, rival_id) VALUES (?, ?) ON DUPLICATE KEY UPDATE rival_id = VALUES(rival_id)",
                        { pid, rid })
                end
            end
        end
    end
end)
