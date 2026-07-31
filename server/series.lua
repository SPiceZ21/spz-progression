-- server/series.lua
-- Rolling championship series. There is no schedule: the series flows race to
-- race. Every finished race is a ROUND that awards F1 points; standings carry
-- across rounds; after the final round a champion is crowned + rewarded and a
-- fresh series starts immediately. The hook is "you're mid-series, 2 rounds
-- left, 8 points off first — stay for the next race."
--
-- Round count is DYNAMIC: it scales with how many drivers showed up, so a busy
-- night is a longer championship and a quiet one wraps up quickly.
--
-- In-memory by player DB id (survives reconnects; a server restart starts a
-- fresh series, which is fine for a live rolling championship).

local Points = (SPZ and SPZ.PointsTable) or { [1]=25,[2]=18,[3]=15,[4]=12,[5]=10,[6]=8,[7]=6,[8]=4,[9]=2,[10]=1 }

local MIN_ROUNDS = 3
local MAX_ROUNDS = 8

local Series = {
    round     = 0,      -- rounds completed
    total     = MIN_ROUNDS,
    standings = {},     -- [playerId] = { name = , points = , wins = , rounds = }
}

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function profileId(src)
    local ok, p = pcall(function() return exports["spz-identity"]:GetProfile(src) end)
    return ok and p and p.id or nil
end

local function srcOfPlayer(playerId)
    for _, s in ipairs(GetPlayers()) do
        if profileId(tonumber(s)) == playerId then return tonumber(s) end
    end
    return nil
end

local function notifyAll(title, msg, ntype)
    TriggerClientEvent("ox_lib:notify", -1, {
        title = title, description = msg, type = ntype or "inform", duration = 7000,
    })
end

local function discord(title, msg, fields)
    if GetResourceState("spz-log") ~= "started" then return end
    pcall(function() exports["spz-log"]:Success("race", title, msg, fields) end)
end

-- Ordered standings array, highest points first.
local function orderedStandings()
    local arr = {}
    for pid, s in pairs(Series.standings) do
        arr[#arr + 1] = { id = pid, name = s.name, points = s.points, wins = s.wins }
    end
    table.sort(arr, function(a, b)
        if a.points ~= b.points then return a.points > b.points end
        return (a.wins or 0) > (b.wins or 0)
    end)
    return arr
end

-- Compact "P1 Name 43 · P2 Name 31 · P3 …" for notifications.
local function standingsLine(limit)
    local arr = orderedStandings()
    local parts = {}
    for i = 1, math.min(#arr, limit or 5) do
        parts[i] = ("P%d %s %d"):format(i, arr[i].name, arr[i].points)
    end
    return table.concat(parts, "  ·  ")
end

-- ── Series lifecycle ──────────────────────────────────────────────────────────

local function startSeries(driverCount)
    -- Dynamic length: ~1 round per driver, clamped. More drivers = longer season.
    Series.round     = 0
    Series.total     = math.max(MIN_ROUNDS, math.min(MAX_ROUNDS, driverCount or MIN_ROUNDS))
    Series.standings = {}
    notifyAll("Championship", ("A new %d-round series begins! Finish races to score points.")
        :format(Series.total), "success")
    discord("New Series", ("A fresh %d-round championship has started."):format(Series.total))
end

local function crownChampion()
    local arr = orderedStandings()
    local champ = arr[1]
    if not champ then Series.round = 0; return end

    -- Reward the champion (credits + bonus XP via identity/progression).
    local src = srcOfPlayer(champ.id)
    local rewardCredits = 500 + Series.total * 100
    if src then
        local ok, p = pcall(function() return exports["spz-identity"]:GetProfile(src) end)
        if ok and p then
            exports["spz-identity"]:UpdateProfile(src, { credits = (p.credits or 0) + rewardCredits })
        end
        TriggerClientEvent("ox_lib:notify", src, {
            title = "🏆 CHAMPION",
            description = ("You won the %d-round series with %d points! +%d credits.")
                :format(Series.total, champ.points, rewardCredits),
            type = "success", duration = 12000,
        })
    end

    -- Everyone sees the result + final table.
    notifyAll("🏆 Series Champion",
        ("%s wins the championship (%d pts)!  %s"):format(champ.name, champ.points, standingsLine(3)),
        "success")

    local fields = {}
    for i = 1, math.min(#arr, 5) do
        fields[i] = { name = ("P%d  %s"):format(i, arr[i].name),
                      value = ("%d pts · %d wins"):format(arr[i].points, arr[i].wins or 0), inline = false }
    end
    discord("🏆 Series Champion", ("**%s** is the champion with %d points."):format(champ.name, champ.points), fields)

    -- Roll straight into the next series (length picks up next race's field).
    startSeries(#arr)
end

-- ── Score each finished race ──────────────────────────────────────────────────

AddEventHandler("SPZ:raceEnd", function(results)
    if type(results) ~= "table" or type(results.finishers) ~= "table" then return end
    if #results.finishers == 0 then return end

    -- First race after boot / after a finale: open a series sized to the field.
    if Series.round == 0 and next(Series.standings) == nil then
        startSeries(#results.finishers + #(results.dnf or {}))
    end

    -- Award points to finishers by finishing position.
    for _, f in ipairs(results.finishers) do
        local pid = profileId(f.source)
        if pid then
            local s = Series.standings[pid] or { name = f.name, points = 0, wins = 0, rounds = 0 }
            s.name   = f.name or s.name
            s.points = s.points + (Points[f.position] or 0)
            s.rounds = s.rounds + 1
            if f.position == 1 then s.wins = s.wins + 1 end
            Series.standings[pid] = s
        end
    end

    Series.round = Series.round + 1

    if Series.round >= Series.total then
        crownChampion()
    else
        local left = Series.total - Series.round
        notifyAll("Championship",
            ("Round %d/%d done · %d to go  —  %s"):format(Series.round, Series.total, left, standingsLine(3)),
            "inform")
    end
end)

-- ── /series — show the live championship ─────────────────────────────────────

RegisterCommand("series", function(source)
    local src = source
    if Series.round == 0 and next(Series.standings) == nil then
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Championship", description = "No series running yet — finish a race to start one.",
            type = "inform",
        })
        return
    end

    local arr = orderedStandings()
    local myPid = profileId(src)
    local lines = {}
    for i = 1, math.min(#arr, 8) do
        local me = (arr[i].id == myPid) and "  ◄ you" or ""
        lines[#lines + 1] = ("P%d  %s  —  %d pts%s"):format(i, arr[i].name, arr[i].points, me)
    end
    TriggerClientEvent("ox_lib:notify", src, {
        title = ("Championship · Round %d/%d"):format(Series.round, Series.total),
        description = table.concat(lines, "\n"),
        type = "inform", duration = 10000,
    })
end, false)

-- Exports so a UI / website could read the live standings later.
exports("GetSeries", function()
    return { round = Series.round, total = Series.total, standings = orderedStandings() }
end)
