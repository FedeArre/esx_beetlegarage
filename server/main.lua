ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Config check
if Config.PreloadVehicles then
    if Config.ReleaseMemory then
        print("Do not use PreloadVehicles with ReleaseMemory! Check your config.lua")
    elseif Config.LoadOnlyRequested then
        print("Do not use PreloadVehicles with LoadOnlyRequired! Check your config.lua")
    end
end

-- Server restart
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        if Config.SendVehiclesToGarage then
            MySQL.Async.execute("UPDATE owned_vehicles SET owned_vehicles.stored=1 WHERE 1", {}, function(result)
                if result == 1 then
                    print("All vehicles were sent to garage!")
                end
            end)
        end
    end
end)
  

-- Event to check if a vehicle is from the player.
ESX.RegisterServerCallback("beetle_garage:validCar", function(source, cb)
    local _source = source
    local playerPed = GetPlayerPed(_source)
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    local plate = GetVehicleNumberPlateText(playerVeh)
    local xPlayerIdentifier = ESX.GetPlayerFromId(_source).getIdentifier()

    MySQL.Async.fetchScalar('SELECT COUNT(owner) FROM owned_vehicles WHERE owner=@identifier AND plate=@plate', {
        ['@identifier'] = xPlayerIdentifier,
        ["@plate"] = plate}
    , function(result)
        if result == 1 then
            cb(true)
        else
            cb(false)
        end
      end)
end)

-- Event to save the player vehicle.
ESX.RegisterServerCallback("beetle_garage:saveVehicle", function(source, cb, vehprop)
    local _source = source
    local playerPed = GetPlayerPed(_source)
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    local plate = GetVehicleNumberPlateText(playerVeh)
    local xPlayerIdentifier = ESX.GetPlayerFromId(_source).getIdentifier()
    
    local vehJson = json.encode(vehprop)
    
    MySQL.Async.execute("UPDATE owned_vehicles SET vehicle=@vehdata, owned_vehicles.stored=1 WHERE owner=@identifier AND plate=@plate", {
        ['@vehdata'] = vehJson,
        ['@identifier'] = xPlayerIdentifier,
        ['@plate'] = plate
    }, function(result)
        if result == 1 then
            cb(true)
        else
            cb(false)
        end
    end)
end)

-- Event to get player vehicles
ESX.RegisterServerCallback("beetle_garage:getVehicleList", function(source, cb)
    local _source = source
    local xPlayerIdentifier = ESX.GetPlayerFromId(_source).getIdentifier()
    local toReturn = {}

    MySQL.Async.fetchAll("SELECT vehicle, owned_vehicles.stored FROM owned_vehicles WHERE owner = @identifier", {
        ['@identifier'] = xPlayerIdentifier
    }, function(result)
        for _, v in pairs(result) do
            local vehicle = json.decode(v.vehicle)

            table.insert(toReturn, {
                vehicle = vehicle,
                stored = v.stored
            })
        end

        cb(toReturn)
    end)
end)

-- Event to set stored vehicle status to false
ESX.RegisterServerCallback("beetle_garage:changeStatus", function(source, cb, plate)
    local _source = source
    local xPlayerIdentifier = ESX.GetPlayerFromId(_source).getIdentifier()

    MySQL.Async.execute("UPDATE owned_vehicles SET owned_vehicles.stored=0 WHERE plate=@plate AND owner=@identifier", {
        ["@plate"] = plate,
        ["@identifier"] = xPlayerIdentifier
    }, function(result)
        if result then
            TriggerClientEvent("beetle_garage:removeSimilarVehicle", _source, plate)
            cb(true)
        else
            cb(false)
        end
    end)
end)

-- Event to pay the impound
ESX.RegisterServerCallback("beetle_garage:payimpound", function(source,cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local playerMoney = xPlayer.getMoney()

    if playerMoney >= Config.ImpoundPrice then
        xPlayer.removeMoney(Config.ImpoundPrice)
        cb(true)
    else
        cb(false)
    end
end)

-- Event to pay the repair
ESX.RegisterServerCallback("beetle_garage:payRepair", function(source,cb)
    local _source = source
    local playerPed = GetPlayerPed(_source)
    local playerVeh = GetVehiclePedIsIn(playerPed)
    local difference = Config.RepairPriceMax / GetVehicleEngineHealth(playerVeh)

    local xPlayer = ESX.GetPlayerFromId(_source)
    local playerMoney = xPlayer.getMoney()

    if playerMoney >= difference then
        xPlayer.removeMoney(difference)
        cb(true)
    else
        cb(false)
    end
end)
