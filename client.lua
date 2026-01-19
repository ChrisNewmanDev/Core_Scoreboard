local display = false
local QBCore = exports['qb-core']:GetCoreObject()

-- Function to get all players with their information
-- We rely on the server to provide a per-player table (id, name, job)
-- because client-side cannot reliably fetch other players' PlayerData.
local function GetPlayers()
    -- placeholder in case local usage expects the function; real list comes from server callback
    local players = {}
    local active = GetActivePlayers()
    for _, ply in ipairs(active) do
        local serverId = GetPlayerServerId(ply)
        table.insert(players, {
            id = serverId,
            name = GetPlayerName(ply) or ('Player ' .. tostring(serverId)),
            job = ''
        })
    end
    return players
end

-- Function to update scoreboard data
local function UpdateScoreboard()
    if display then
        QBCore.Functions.TriggerCallback('core-scoreboard:getServerData', function(data)
            -- Prefer server-provided players list (includes job labels). Fall back to local active players if missing.
            local players = data.players or GetPlayers()

            SendNUIMessage({
                type = 'update',
                players = players,
                serverName = Config.ServerName,
                jobs = data.jobs,
                jobOrder = Config.JobOrder,
                jobColors = Config.JobColors,
                jobDisplayNames = data.jobDisplayNames,
                heists = data.heists
            })
        end)
    end
end

-- Toggle scoreboard visibility
RegisterCommand('togglescoreboard', function()
    display = not display
    SendNUIMessage({ type = 'toggle', show = display })
    -- Give NUI focus when showing so mouse and keys work
    SetNuiFocus(display, display)
    if display then
        UpdateScoreboard()
    end
end)

-- Register keybinding
RegisterKeyMapping('togglescoreboard', 'Toggle Scoreboard', 'keyboard', Config.Key)

-- NUI Callback for closing scoreboard
RegisterNUICallback('closeScoreboard', function(data, cb)
    display = false
    SendNUIMessage({
        type = 'toggle',
        show = false
    })
    -- Remove NUI focus so game controls return
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Update scoreboard periodically when visible
Citizen.CreateThread(function()
    while true do
        if display then
            UpdateScoreboard()
        end
        Citizen.Wait(1000) -- Update every second when visible
    end
end)