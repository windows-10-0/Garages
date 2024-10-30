local ESX = exports.es_extended:getSharedObject()

-- FUNCTIONS

local function openGarage(spawnCoords)
    SendNUIMessage({
        action = "open",
        type = "garage",
        vehSpawnCoords = spawnCoords
    })
    SetNuiFocus(true, true)
end

local function openImpound(spawnCoords, price)
    SendNUIMessage({
        action = "open",
        type = "impound",
        vehSpawnCoords = spawnCoords,
        price = price
    })
    SetNuiFocus(true, true)
end

local function handleSaveCar()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local props = ESX.Game.GetVehicleProperties(vehicle)
    ESX.TriggerServerCallback("garage:server:saveVehicle", function(saved)
        if saved == true then
            ESX.Game.DeleteVehicle(vehicle)
            Settings.Notify(Locales[Settings.locale].notify_title, Locales[Settings.locale].notify_car_saved)
        elseif saved.type == "notPlayerCar" then
            Settings.Notify(Locales[Settings.locale].notify_title, Locales[Settings.locale].notify_car_not_player)
        end
    end, props)
end

-- THREAD

Citizen.CreateThread(function()
    for name, garage in pairs(Settings.Garages) do
        local blip = AddBlipForCoord(garage.coords)
        SetBlipSprite(blip, garage.blip.icon)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, garage.blip.scale)
        SetBlipColour(blip, garage.blip.color)
        SetBlipAsShortRange(blip, garage.blip.shortRange)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(name)
        EndTextCommandSetBlipName(blip)

        RequestModel(GetHashKey(garage.ped))
        while not HasModelLoaded(GetHashKey(garage.ped)) do
            Wait(500) 
        end
        local garagePed = CreatePed(4, GetHashKey(garage.ped), garage.coords.x, garage.coords.y, garage.coords.z - 1.0, garage.coords.w, false, true)
        SetEntityInvincible(garagePed, true)
        SetBlockingOfNonTemporaryEvents(garagePed, true)
        FreezeEntityPosition(garagePed, true)

        exports['ox_target']:addBoxZone({
            coords = vector3(garage.coords.x, garage.coords.y, garage.coords.z),
            options = {
                {
                    icon = Settings.target.icon,
                    label = Locales[Settings.locale].open_garage,
                    onSelect = function ()
                        openGarage(garage.vehSpawn)
                    end
                },
                {
                    icon = Settings.target.icon,
                    label = Locales[Settings.locale].save_car,
                    onSelect = function ()
                        handleSaveCar()
                    end,
                    canInteract = function()
                        return IsPedInAnyVehicle(PlayerPedId(), false)
                    end
                },
            },
            distance = Settings.target.distance
        })
    end

    for name, impound in pairs(Settings.Impounds) do
        local blip = AddBlipForCoord(impound.coords)
        SetBlipSprite(blip, impound.blip.icon)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, impound.blip.scale)
        SetBlipColour(blip, impound.blip.color)
        SetBlipAsShortRange(blip, impound.blip.shortRange)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(name)
        EndTextCommandSetBlipName(blip)

        RequestModel(GetHashKey(impound.ped))
        while not HasModelLoaded(GetHashKey(impound.ped)) do
            Wait(500) 
        end
        local impoundPed = CreatePed(4, GetHashKey(impound.ped), impound.coords.x, impound.coords.y, impound.coords.z - 1.0, impound.coords.w, false, true)
        SetEntityInvincible(impoundPed, true)
        SetBlockingOfNonTemporaryEvents(impoundPed, true)
        FreezeEntityPosition(impoundPed, true)

        exports['ox_target']:addBoxZone({
            coords = vector3(impound.coords.x, impound.coords.y, impound.coords.z),
            options = {
                {
                    icon = Settings.target.icon,
                    label = Locales[Settings.locale].open_impound,
                    onSelect = function ()
                        openImpound(impound.vehSpawn, impound.price)
                    end
                }
            },
            distance = Settings.target.distance
        })
    end
end)

-- NUI CALLBACKS

RegisterNUICallback("closeNui", function(data, cb)
    SetNuiFocus(false, false)
    cb(true)
end)

RegisterNUICallback("setLocale", function(data, cb)
    cb(Locales[Settings.locale])
end)

RegisterNUICallback("getOwnedVehicles", function(data, cb)
    ESX.TriggerServerCallback("garage:server:getOwnedVehicles", function(vehicles)
        local convertedVehicles = {}

        for _, vehicleData in ipairs(vehicles) do
            local decodedVehicle = json.decode(vehicleData.vehicle)
            if decodedVehicle then
                decodedVehicle.model = GetDisplayNameFromVehicleModel(decodedVehicle.model)
                decodedVehicle.fuelPrecentage = math.floor((decodedVehicle.fuelLevel / 65) * 100)
                decodedVehicle.engineHealthPercentage = math.floor((decodedVehicle.engineHealth / 1000) * 100)

                table.insert(convertedVehicles, decodedVehicle)
            end
        end
        cb(convertedVehicles)
    end, data.type)
end)

RegisterNUICallback("handleGarage", function(data, cb)
    ESX.TriggerServerCallback("garage:server:handleGarage", function(response)
        if response.success then
            local spawnedVehicle = NetworkGetEntityFromNetworkId(response.spawnedVehicle)
            TaskWarpPedIntoVehicle(PlayerPedId(), spawnedVehicle, -1)
            cb(true)
        else
            cb(false)
        end
    end, data.vehSpawnCoords, data.vehicle)
end)

RegisterNUICallback('handleImpound', function(data, cb)
    ESX.TriggerServerCallback('garage:server:canPay', function(canPay)
        if canPay then
            ESX.TriggerServerCallback('garage:server:handleImpound', function(response)
                if response.success then
                    local spawnedVehicle = NetworkGetEntityFromNetworkId(response.spawnedVehicle)
                    TaskWarpPedIntoVehicle(PlayerPedId(), spawnedVehicle, -1)
                    cb(true)
                    Settings.Notify(
                        Locales[Settings.locale].notify_title,
                        string.format(Locales[Settings.locale].notify_impound_success, data.price)
                    )
                else
                    cb(false)
                end
            end, data.vehSpawnCoords, data.vehicle)
        else
            cb(false)
            Settings.Notify(Locales[Settings.locale].notify_title, Locales[Settings.locale].notify_no_money)
        end
    end, data.price)
end)