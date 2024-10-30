Locales = {}
Settings = {}

Settings.locale = "en"

Settings.target = {
    icon = 'fas fa-parking',
    distance = 2.5
}

Settings.Notify = function (title, message)
    ESX = exports.es_extended:getSharedObject()
    ESX.ShowNotification(message, 5000)
end

Settings.Garages = {
    ["Garage"] = {
        coords = vector4(-65.6274, -1114.3586, 26.5024, 258.9973),
        vehSpawn = vector4(-54.5130, -1110.3597, 26.4358, 74.5853),
        blip = {
            icon = 357,
            scale = 0.8,
            color = 26,
            shortRange = true
        },
        ped = "s_m_y_clubbar_01"
    }
}

Settings.Impounds = {
    ["Impound"] = {
        price = 1000,
        coords = vector4(409.2786, -1622.8799, 29.2919, 233.2162),
        vehSpawn = vector4(408.2939, -1646.4929, 29.2919, 225.7697),
        blip = {
            icon = 357,
            scale = 0.8,
            color = 44,
            shortRange = true
        },
        ped = "s_m_y_clubbar_01"
    }
}