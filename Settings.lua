Locales = {}
Settings = {}

Settings.locale = "en"

Settings.target = {
    icon = 'fas fa-parking',
    distance = 2.5
}

Settings.spawnChecker = { -- when spawning car check if on spawn point is free space for spawning car
    enabled = true,
    distance = 5
}

Settings.Notify = function (title, message)
    ESX = exports.es_extended:getSharedObject()
    ESX.ShowNotification(message, 5000)
end

Settings.Garages = {
    {
        coords = vector4(-65.6274, -1114.3586, 26.5024, 258.9973),
        vehSpawn = vector4(-54.5130, -1110.3597, 26.4358, 74.5853),
        blip = {
            label = "Garage",
            icon = 357,
            scale = 0.8,
            color = 26,
            shortRange = true
        },
        ped = "s_m_y_clubbar_01"
    },
    {
        coords = vector4(218.3843, -809.1786, 30.6995, 248.9417),
        vehSpawn = vector4(227.7476, -802.7572, 30.5810, 157.0992),
        blip = {
            label = "Garage",
            icon = 357,
            scale = 0.8,
            color = 26,
            shortRange = true
        },
        ped = "s_m_y_clubbar_01"
    }
}

Settings.Impounds = {
    {
        price = 1000,
        coords = vector4(409.2786, -1622.8799, 29.2919, 233.2162),
        vehSpawn = vector4(408.2939, -1646.4929, 29.2919, 225.7697),
        blip = {
            label = "Impound",
            icon = 357,
            scale = 0.8,
            color = 44,
            shortRange = true
        },
        ped = "s_m_y_clubbar_01"
    }
}