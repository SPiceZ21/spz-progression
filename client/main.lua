---Relays progression updates from the server to the HUD.
---@param data table The progression payload containing gains and rank updates.
RegisterNetEvent("SPZ:progressionUpdate", function(data)
    -- Relay to hud for the post-race summary screen
    exports["spz-hud"]:ShowProgression(data)
end)
