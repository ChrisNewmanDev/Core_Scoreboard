Config = {}
Config.ServerName = ""

Config.Heists = {
    { name = 'House Robbery', id = 'house', minPD = 2, cooldown = 3600 },
    { name = 'Store Robbery', id = 'store', minPD = 2, cooldown = 1800 }, -- cooldown in seconds
    { name = 'Fleeca Bank', id = 'fleeca', minPD = 3, cooldown = 900 },
    { name = 'Paleto Bank', id = 'paleto', minPD = 4, cooldown = 1800 }, --1800 = 30 minutes
    { name = 'Pacific Bank', id = 'pacific', minPD = 6, cooldown = 3600 },
    { name = 'Jewelry Store', id = 'jewelry', minPD = 3, cooldown = 1800 }, -- cooldown in seconds
    { name = 'Bobcat', id = 'bobcat', minPD = 4, cooldown = 900 },
    { name = 'Oil Rig', id = 'oil', minPD = 6, cooldown = 1800 }, --1800 = 30 minutes
}
-- Enable to populate scoreboard with 100 fake players for testing
Config.TestPopulate = false

Config.Key = 'Home' -- Key to toggle scoreboard

-- Toggle job visibility (add/remove jobs here)
Config.ShowJobs = {
    ['police'] = true,
    ['ambulance'] = true,
    ['autopeace'] = true,
    ['flowcustoms'] = true,
    ['upnatom'] = true,
    --['realestate'] = true,
}

-- Order jobs are displayed in the scoreboard jobs column
Config.JobOrder = {
    'police',
    'ambulance',
    'autopeace',
    'flowcustoms',
    'upnatom',
    --'realestate',
}

-- Set custom colors for job names (CSS color values)
Config.JobColors = {
    police = '#4a90e2',
    ambulance = '#e94e77',
    autopeace = '#f5a623',
    flowcustoms = '#f5a623',
    upnatom = '#f8e71c',
    --realestate = '#7ed957',
}

-- Optional: Provide custom display names for jobs. If empty, the script will try
-- to pull the display label from QBCore.Shared.Jobs[jobName].label. Example:
-- Config.JobDisplayNames = { police = "Police Department", ambulance = "EMS" }
Config.JobDisplayNames = {}