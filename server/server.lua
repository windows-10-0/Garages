local ESX = exports.es_extended:getSharedObject()

ESX.RegisterServerCallback('garage:server:getOwnedVehicles', function(source, cb, type)
    local player = ESX.GetPlayerFromId(source)
    local storedStatus = type == 'garage' and 1 or (type == 'impound' and 0)

    if storedStatus ~= nil then
        MySQL.query('SELECT vehicle FROM owned_vehicles WHERE owner = @owner AND stored = @stored', {
            ['@owner'] = player.identifier,
            ['@stored'] = storedStatus
        }, function(result)
            local ownedVehicles = {}
            for _, vehicle in ipairs(result or {}) do
                table.insert(ownedVehicles, vehicle)
            end
            cb(ownedVehicles)
        end)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('garage:server:handleGarage', function(source, cb, coords, vehicle)
    MySQL.query('UPDATE owned_vehicles SET stored = 0 WHERE plate = ?', {vehicle.plate}, function(updated)
        if not updated then return cb({success = false}) end

        ESX.OneSync.SpawnVehicle(vehicle.model, vector3(coords.x, coords.y, coords.z), coords.w, vehicle, function(spawnedVehicle)
            Wait(200)
            cb({success = spawnedVehicle ~= nil, spawnedVehicle = spawnedVehicle})
        end)
    end)
end)

ESX.RegisterServerCallback('garage:server:canPay', function(source, cb, price)
    local player = ESX.GetPlayerFromId(source)
    cb(player and player.getMoney() >= price and player.removeMoney(price) == nil)
end)

ESX.RegisterServerCallback('garage:server:handleImpound', function(source, cb, coords, vehicle)
    ESX.OneSync.SpawnVehicle(vehicle.model, vector3(coords.x, coords.y, coords.z), coords.w, vehicle, function(spawnedVehicle)
        Wait(200)
        cb({success = spawnedVehicle ~= nil, spawnedVehicle = spawnedVehicle})
    end)
end)

ESX.RegisterServerCallback('garage:server:saveVehicle', function(source, cb, props)
    local player = ESX.GetPlayerFromId(source)
    local plate = props.plate
    MySQL.query('SELECT * FROM owned_vehicles WHERE plate = ? AND owner = ?', {plate, player.identifier}, function(result)
        if #result == 0 then
            return cb({type = "notPlayerCar"})
        end

        MySQL.query('UPDATE owned_vehicles SET stored = 1, vehicle = ? WHERE plate = ? AND owner = ?', {json.encode(props), plate, player.identifier}, function(updated)
            if not updated then return cb(false) end
            cb(true)
        end)    
    end)
end)