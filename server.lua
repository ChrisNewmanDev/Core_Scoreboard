local QBCore = exports['qb-core']:GetCoreObject()
local heistStates = {}

-- Initialize heist states
Citizen.CreateThread(function()
    for _, heist in ipairs(Config.Heists) do
        heistStates[heist.id] = {
            inProgress = false,
            cooldownRemaining = 0
        }
    end
end)

-- Update heist cooldowns
Citizen.CreateThread(function()
    while true do
        for heistId, state in pairs(heistStates) do
            if state.cooldownRemaining > 0 then
                state.cooldownRemaining = state.cooldownRemaining - 1
            end
        end
        Citizen.Wait(1000)
    end
end)

-- Get count of players for each job
local function GetJobCounts()
    local jobs = {}
    local Players = QBCore.Functions.GetPlayers()

    -- Initialize job counts
    for job, _ in pairs(Config.ShowJobs) do
        jobs[job] = 0
    end

    -- Count players in each job
    for _, playerId in ipairs(Players) do
        local Player = QBCore.Functions.GetPlayer(tonumber(playerId))
        if Player and Player.PlayerData and Player.PlayerData.job then
            local jobName = Player.PlayerData.job.name
            local onduty = Player.PlayerData.job.onduty
            -- Only count if the job is configured to be shown and player is on duty (if onduty flag exists)
            if Config.ShowJobs[jobName] and (onduty == nil or onduty == true) then
                jobs[jobName] = (jobs[jobName] or 0) + 1
            end
        end
    end

    return jobs
end

-- Get current heist states with updated information
local function GetHeistStates()
    local heists = {}
    for _, heist in ipairs(Config.Heists) do
        local state = heistStates[heist.id]
        table.insert(heists, {
            name = heist.name,
            id = heist.id,
            minPD = heist.minPD,
            inProgress = state.inProgress,
            cooldownRemaining = state.cooldownRemaining
        })
    end
    return heists
end

-- Callback to get server data for scoreboard
QBCore.Functions.CreateCallback('core-scoreboard:getServerData', function(source, cb)
    -- Build job display name map (prefer config override, then QBCore shared jobs)
    local jobDisplay = {}
    for job,_ in pairs(Config.ShowJobs) do
        local displayName = nil
        if Config.JobDisplayNames and Config.JobDisplayNames[job] then
            displayName = Config.JobDisplayNames[job]
        elseif QBCore.Shared and QBCore.Shared.Jobs and QBCore.Shared.Jobs[job] and QBCore.Shared.Jobs[job].label then
            displayName = QBCore.Shared.Jobs[job].label
        end
        if not displayName then
            displayName = job:gsub('^%l', string.upper) -- capitalize
        end
        jobDisplay[job] = displayName
    end

    if Config.TestPopulate then
        -- Generate fake data for testing
        local fakeJobs = {}
        for job in pairs(Config.ShowJobs) do
            fakeJobs[job] = math.random(1, 20)
        end
        -- Also generate fake player entries for testing
        local fakePlayers = {}
        for i=1,100 do
            -- pick a random job from the configured jobs
            local jobKeys = {}
            for k,_ in pairs(Config.ShowJobs) do table.insert(jobKeys, k) end
            local randJob = jobKeys[math.random(1, #jobKeys)]
            table.insert(fakePlayers, { id = i, name = ('TestPlayer%d'):format(i), job = jobDisplay[randJob] or randJob })
        end
        cb({
            players = fakePlayers,
            jobs = fakeJobs,
            jobDisplayNames = jobDisplay,
            heists = GetHeistStates()
        })
    else
        -- Build a players table (id, name, job label) to send to clients
        local players = {}
        local allPlayers = QBCore.Functions.GetPlayers()
        for _, pid in ipairs(allPlayers) do
            local ply = QBCore.Functions.GetPlayer(tonumber(pid))
            local name = GetPlayerName(tonumber(pid)) or ('Player ' .. tostring(pid))
            local jobLabel = 'Unemployed'
            if ply and ply.PlayerData and ply.PlayerData.job then
                local jobName = ply.PlayerData.job.name
                -- Prefer config override, then QBCore job label, then the player's job label/name
                if Config.JobDisplayNames and Config.JobDisplayNames[jobName] then
                    jobLabel = Config.JobDisplayNames[jobName]
                elseif QBCore.Shared and QBCore.Shared.Jobs and QBCore.Shared.Jobs[jobName] and QBCore.Shared.Jobs[jobName].label then
                    jobLabel = QBCore.Shared.Jobs[jobName].label
                else
                    jobLabel = ply.PlayerData.job.label or ply.PlayerData.job.name or jobLabel
                end
            end
            table.insert(players, {
                id = tonumber(pid),
                name = name,
                job = jobLabel
            })
        end

        cb({
            players = players,
            jobs = GetJobCounts(),
            jobDisplayNames = jobDisplay,
            heists = GetHeistStates()
        })
    end
end)

-- Export functions for other resources to use
exports('startHeist', function(heistId)
    if heistStates[heistId] and not heistStates[heistId].inProgress and heistStates[heistId].cooldownRemaining <= 0 then
        heistStates[heistId].inProgress = true
        return true
    end
    return false
end)

exports('endHeist', function(heistId)
    if heistStates[heistId] then
        heistStates[heistId].inProgress = false
        -- Find the heist config to get the cooldown time
        for _, heist in ipairs(Config.Heists) do
            if heist.id == heistId then
                heistStates[heistId].cooldownRemaining = heist.cooldown
                break
            end
        end
        return true
    end
    return false
end)

-- Add command to reset heist states (for admins)
RegisterCommand('resetheists', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and Player.PlayerData.permission == 'admin' then
        for heistId, _ in pairs(heistStates) do
            heistStates[heistId] = {
                inProgress = false,
                cooldownRemaining = 0
            }
        end
        TriggerClientEvent('QBCore:Notify', source, 'All heist states have been reset.', 'success')
    end
end)