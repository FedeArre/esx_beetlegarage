-- ESX Start
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)

        Citizen.Wait(0)
    end
end)

-- Useful variables
local currentMarker = nil
local currentGarageId = -1
local currentCoordsToDraw = nil
local inGarage = false -- This variable is the controller for the "conceal".
local hashActualShown = -1

-- Blip
Citizen.CreateThread(function()
    for _, v in pairs(Config.GarageList) do
        local blip = AddBlipForCoord(v.BlipPos.x, v.BlipPos.y, v.BlipPos.z)
        SetBlipSprite(blip, Config.GarageBlipSprite)
        SetBlipColour(blip, Config.GarageBlipColor)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(_U('GARAGE_BLIP_NAME'))
        EndTextCommandSetBlipName(blip)
    end
end)

-- Checking if player is in a garage
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)

        local coords = GetEntityCoords(PlayerPedId())
        local count = 0
        for k, v in pairs(Config.GarageList) do
            if #(coords-v.SpawnMarker) <= Config.DrawDistance then
                currentCoordsToDraw = v.SpawnMarker
                currentMarker = "spawnMarker"
                currentGarageId = v.GarageId
                count = count + 1
            elseif #(coords-v.DeleteMarker) <= Config.DrawDistance then
                currentCoordsToDraw = v.DeleteMarker
                currentMarker = "deleteMarker"
                currentGarageId = v.GarageId
                count = count + 1
            end
        end

        if count == 0 then
            currentMarker = nil
            currentGarageId = -1 
            currentCoordsToDraw = nil
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- 0 since this function calls DrawMarker and DrawText3D

        if currentGarageId ~= -1 then
            if currentMarker == "spawnMarker" then
                DrawMarker(25, currentCoordsToDraw.x, currentCoordsToDraw.y, currentCoordsToDraw.z + 0.03, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 140, 0, 150,  false, true, 2, true, false, false, false)
                local x, y, z = table.unpack(currentCoordsToDraw)
                ESX.Game.Utils.DrawText3D(vector3(x, y, z+1.4), _U('GARAGE_SPAWN_MARKER'))
            elseif currentMarker == "deleteMarker" then
                
                DrawMarker(36, currentCoordsToDraw, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 140, 0, 0, 150,  false, true, 2, true, false, false, false)
                local x, y, z = table.unpack(currentCoordsToDraw)
                ESX.Game.Utils.DrawText3D(vector3(x, y, z+0.55), _U('GARAGE_DELETE_MARKER'))
            end

            if IsControlJustPressed(0, 38) then
                local coords = GetEntityCoords(PlayerPedId())
                if #(coords-currentCoordsToDraw) < 5.0 then
                    if currentMarker == "spawnMarker" then
                        ShowVehicleMenu()
                    else
                        if IsPedInAnyVehicle(PlayerPedId(), false) then
                            StoreVehicle()
                        end
                    end
                end
            end
        end
    end
end)

-- Functions to store vehicles
function StoreVehicle()
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed)
    if GetPedInVehicleSeat(playerVeh, -1) == playerPed then
        ESX.TriggerServerCallback('beetle_garage:validCar', function(cb)
            if cb then
                local enabled = false

                if GetVehicleEngineHealth(playerVeh) ~= 1000.0 or GetVehicleBodyHealth(playerVeh) ~= 1000.0 then
                    local dmgEngine = (1000.0 - GetVehicleEngineHealth(playerVeh)) / 1000
                    local dmgBody = (1000.0 - GetVehicleBodyHealth(playerVeh)) / 1000
                    local difference = (Config.RepairPriceMax * dmgEngine) + (Config.RepairPriceMax * dmgBody)
                    difference = math.floor(difference)
                    
                    if difference >= 20 then
                        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'beetlegaragerepair', {
                            title = _U("TITLE_FIX_VEHICLE"),
                            align = 'bottom-right',
                            elements = {
                                {label = _U('FIX_VEHICLE_MENU_YES', difference), value = "yes"},
                                {label = _U("FIX_VEHICLE_MENU_NO"), value = "no"}
                            }
                        }, function(data, menu) -- Menu select
                            if data.current.value == "yes" then
                                ESX.TriggerServerCallback("beetle_garage:payRepair", function(cb)
                                    if cb then
                                        SetVehicleBodyHealth(playerVeh, 1000.0)
                                        SetVehicleEngineHealth(playerVeh, 1000.0)
                                        SetVehicleFixed(playerVeh)
                                                
                                        local vehProps = ESX.Game.GetVehicleProperties(playerVeh)
                                        ESX.TriggerServerCallback('beetle_garage:saveVehicle', function(cb)
                                            if cb then
                                                ESX.Game.DeleteVehicle(playerVeh)
                                                ESX.ShowNotification(_U('VEHICLE_STORED_SUCCESS'))
                                            else
                                                ESX.ShowNotification(_U('ERROR'))
                                            end
                                        end, vehProps)
                                        menu.close()
                                    else
                                        ESX.ShowNotification(_U("NOT_ENOUGH_MONEY"))
                                    end
                                end)
                            end
                        end, function(data, menu)
                            menu.close()
                        end)
                    else
                        enabled = true
                    end
                else
                    enabled = true
                end

                if enabled then
                    local vehProps = ESX.Game.GetVehicleProperties(playerVeh)
                    ESX.TriggerServerCallback('beetle_garage:saveVehicle', function(cb)
                        if cb then
                            ESX.Game.DeleteVehicle(playerVeh)
                            ESX.ShowNotification(_U('VEHICLE_STORED_SUCCESS'))
                        else
                            ESX.ShowNotification(_U('ERROR'))
                        end
                    end, vehProps)
                end
            else
                ESX.ShowNotification(_U("NOT_YOUR_VEHICLE"))
            end
        end)
    end
end

-- Functions to take out vehicles
function ShowVehicleMenu()
    ESX.TriggerServerCallback('beetle_garage:getVehicleList', function(cb)
        if cb ~= "notCars" and not IsPedInAnyVehicle(PlayerPedId()) and not inGarage then
            local vehicleShowing = nil
            local playerPed = PlayerPedId()
            local spawnCoords, heading = GetDisplayCoordsByGarageId(currentGarageId)
            local markerCoords = GetSpawnMarkerCoordsByGarageId(currentGarageId)
            local cameraCoords = GetCameraCoordsByGarageId(currentGarageId)
            local _currentGarageId = currentGarageId
            local camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)

            inGarage = true
            GarageRestrictions()

            if not Config.LoadOnlyRequested then
                PreloadAllVehicles(cb)
            end
            
			SetEntityCoords(playerPed, spawnCoords)
            
            -- Menu display
            ESX.UI.Menu.CloseAll()
            local vehicles = {}
            for _, v in pairs(cb) do
                if v.stored == 1 then
                    table.insert(vehicles, {
                        label = _U("SHOW_VEHICLE_STORED", GetLabelText(GetDisplayNameFromVehicleModel(v.vehicle.model))),
                        value = v.vehicle.plate
                    })
                else
                    table.insert(vehicles, {
                        label = _U("SHOW_VEHICLE_IMPOUNDED", GetLabelText(GetDisplayNameFromVehicleModel(v.vehicle.model))),
                        value = v.vehicle.plate
                    })
                end
            end

            for _, v in pairs(cb) do -- Spawn first vehicle.
                hashActualShown = RequestLoad(v.vehicle.model, hashActualShown)
                ESX.Game.SpawnLocalVehicle(v.vehicle.model, spawnCoords, heading, function(vehicle)
                    ESX.Game.SetVehicleProperties(vehicle, v.vehicle)
                    vehicleShowing = vehicle
                    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                    FreezeEntityPosition(vehicle, true)
                end)
                break
            end

            -- Camera
            SetCamCoord(camera, cameraCoords.x, cameraCoords.y, cameraCoords.z)
            SetCamActive(camera, true)
            PointCamAtEntity(camera, playerPed , 0.0, 0.0, 0.0, 1)
            RenderScriptCams(true, true, 3000, true, false)
           
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'beetlegarageout', {
                title = _U("TITLE_MY_VEHICLES"),
                align = 'bottom-right',
                elements = vehicles
            }, function(data, menu) -- Menu select
                local veh = nil
                for _, v in pairs(cb) do
                    if v.vehicle.plate == data.current.value then
                        veh = v
                    end
                end

                if veh.stored == 1 then
                    local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(_currentGarageId)
                    if foundSpawn then
                        ESX.TriggerServerCallback("beetle_garage:changeStatus", function(cb)
                            if cb then
                                ESX.Game.SpawnVehicle(veh.vehicle.model, vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z), spawnPoint.w, function(vehicle)
                                    ESX.Game.SetVehicleProperties(vehicle, veh.vehicle)
                                    SetVehRadioStation(vehicle, 'OFF')
                                    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                    exports["LegacyFuel"]:SetFuel(vehicle, GetVehicleFuelLevel(vehicle))
                                end)
                            else
                                ESX.ShowNotification(_U("ERROR"))
                            end

                            inGarage = false
                            SetEntityCoords(playerPed, markerCoords)
                            DeleteVehicle(vehicleShowing)

                            -- Cam
                            ClearFocus()
                            RenderScriptCams(false, false, 0, true, false)
                            DestroyCam(camera, false)

                            -- Menu close
                            menu.close()
                        end, veh.vehicle.plate)
                    else
                        ESX.ShowNotification(_U("NO_SPAWN_POINT"))
                    end
                else
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'beetlegarageimpound', {
                        title = _U("TITLE_IMPOUNDED_VEHICLE"),
                        align = 'bottom-right',
                        elements = {
                            {label = _U('IMPOUNDED_VEHICLE_YES', Config.ImpoundPrice), value = "yes"},
                            {label = _U('IMPOUNDED_VEHICLE_NO'), value = "no"}
                        }
                    }, function(data2, menu2) -- Menu select
                        if data2.current.value == "yes" then
                            ESX.TriggerServerCallback("beetle_garage:payimpound", function(cb)
                                if cb then
                                    local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(_currentGarageId)
                                    if foundSpawn then
                                        ESX.TriggerServerCallback("beetle_garage:changeStatus", function(cb)
                                            if cb then
                                                menu2.close()
                                                menu.close()
                                                
                                                inGarage = false
                                                DeleteVehicle(vehicleShowing)
                                                ClearFocus()
                                                RenderScriptCams(false, false, 0, true, false)
                                                DestroyCam(camera, false)
                                                ESX.Game.SpawnVehicle(veh.vehicle.model, vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z), spawnPoint.w, function(vehicle)
                                                    ESX.Game.SetVehicleProperties(vehicle, veh.vehicle)
                                                    SetVehRadioStation(vehicle, 'OFF')
                                                    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                                    exports["LegacyFuel"]:SetFuel(vehicle, GetVehicleFuelLevel(vehicle))
                                                end)
                                            else
                                                ESX.ShowNotification(_U("ERROR"))
                                            end
                                        end)
                                    end
                                else
                                    ESX.ShowNotification(_U("NOT_ENOUGH_MONEY"))
                                    menu2.close()
                                end
                            end)
                        else
                            menu2.close()
                        end
                    end, function(data2, menu2)
                        menu2.close()
                    end)
                end
            end, function(data, menu) -- Menu close
                inGarage = false
                SetEntityCoords(playerPed, markerCoords)
                DeleteVehicle(vehicleShowing)

                -- Cam
                ClearFocus()
                RenderScriptCams(false, false, 0, true, false)
                DestroyCam(camera, false)

                if Config.ReleaseMemory then
                    ReleaseVehiclesFromMemory(cb)
                end
                -- Menu close
                menu.close()
            end, function(data, menu) -- Menu refresh
                for _, v in pairs(cb) do
                    if v.vehicle.plate == data.current.value then
                        hashActualShown = RequestLoad(v.vehicle.model, hashActualShown)
                        DeleteVehicle(vehicleShowing) 
                        ESX.Game.SpawnLocalVehicle(v.vehicle.model, spawnCoords, heading, function(vehicle)
                            ESX.Game.SetVehicleProperties(vehicle, v.vehicle)
                            vehicleShowing = vehicle
                            TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                            FreezeEntityPosition(vehicle, true)
                        end)
                    end
                end
            end)
        elseif IsPedInAnyVehicle(PlayerPedId()) then
            ESX.ShowNotification(_U("PLAYER_IN_VEHICLE"))
        else
            ESX.ShowNotification(_U("NOT_OWNED_VEHICLES"))
        end
    end)
end


RegisterNetEvent("beetle_garage:removeSimilarVehicle")
AddEventHandler("beetle_garage:removeSimilarVehicle", function(plate)
    local vehicles = ESX.Game.GetVehicles()
    for i=1, #vehicles, 1 do
        if GetVehicleNumberPlateTextIndex(vehicles[i]) == plate then
            ESX.Game.DeleteVehicle(vehicles[i])
            break
        end
    end
end)

function GarageRestrictions()
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        while inGarage do
            Citizen.Wait(0)
            
            SetPedConfigFlag(playerPed, 35, false)
            DisableVehicleFirstPersonCamThisFrame()
            BlockWeaponWheelThisFrame()
            DisableFirstPersonCamThisFrame()
            FreezeEntityPosition(playerPed, true)
			SetEntityVisible(playerPed, false)
            SetEntityInvincible(playerPed, true)
			DisableControlAction(0, 75,  true) -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
        end

        SetEntityInvincible(playerPed, false)
        FreezeEntityPosition(playerPed, false)
		SetEntityVisible(playerPed, true)
		DisableControlAction(0, 75,  false) -- Disable exit vehicle
		DisableControlAction(27, 75, false) -- Disable exit vehicle
    end)
end

function GetAvailableVehicleSpawnPoint(garageId)
	local spawnPoints = GetSpawnPointsById(garageId)
	local found, foundSpawnPoint = false, nil
    
	for i=1, #spawnPoints, 1 do
		if ESX.Game.IsSpawnPointClear(vector3(spawnPoints[i].x, spawnPoints[i].y, spawnPoints[i].z), 2.0) then
			found, foundSpawnPoint = true, spawnPoints[i]
			break
		end
	end

	if found then
		return true, foundSpawnPoint
	else
		return false
	end
end

function GetSpawnPointsById(garageId)
    for k, v in pairs(Config.GarageList) do
        if v.GarageId == garageId then
            return v.SpawnPoints
        end
    end
end

function PreloadAllVehicles(vehicles)
    for k, v in pairs(vehicles) do
        if not HasModelLoaded(v.vehicle.model) then
            RequestModel(v.vehicle.model)
            
            while not HasModelLoaded(v.vehicle.model) do
                Citizen.Wait(0)
            end
        end
    end
end

function ReleaseVehiclesFromMemory(vehicles)
    for k, v in pairs(vehicles) do
        if HasModelLoaded(v.vehicle.model) then
            SetModelAsNoLongerNeeded(v.vehicle.model)
        end
    end
end

function RequestLoad(model, prevModel)
    if prevModel ~= -1 then
        SetModelAsNoLongerNeeded(prevModel)
    end
    
    if not HasModelLoaded(model) then
        RequestModel(model)

        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end
    end
    return model
end

function GetDisplayCoordsByGarageId(garageId)
    for k, v in pairs(Config.GarageList) do
        if v.GarageId == garageId then
            return vector3(v.VisualizerCoords.x, v.VisualizerCoords.y, v.VisualizerCoords.z), v.VisualizerCoords.w
        end
    end
    return vector3(0.0, 0.0, 0.0)
end

function GetSpawnMarkerCoordsByGarageId(garageId)
    for k, v in pairs(Config.GarageList) do
        if v.GarageId == garageId then
            return v.SpawnMarker
        end
    end
    return vector3(0.0, 0.0, 0.0)
end

function GetCameraCoordsByGarageId(garageId)
    for k, v in pairs(Config.GarageList) do
        if v.GarageId == garageId then
            return v.CamCoords
        end
    end
    return vector3(0.0, 0.0, 0.0)
end

-- Vehicle preloading
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    if Config.PreloadVehicles then
        ESX.TriggerServerCallback('beetle_garage:getVehicleList', function(cb)
            if cb ~= "notCars" then
                PreloadAllVehicles(cb)
            end
        end)
    end
end)
