Config = {
    Locale = 'en', -- Language
    RepairPriceMax = 1250, -- This value gets multiplied by 2
    ImpoundPrice = 3500, -- Price to take the vehicle out of the impound. 

    PreloadVehicles = true, -- true by default, this preloads the player vehicles when he connects to the server. The vehicles are NOT UNLOADED from the memory, so do not use if you use badly optimized mod vehicles.
    ReleaseMemory = false, -- false by default, use this if you use badly optimized vehicles and dont want your users to run out of memory. Do not use with PreloadVehicles = true.
    LoadOnlyRequested = false, -- false by default, the garage will load only the model the player is requesting instead of loading all previously. Do not use with PreloadVehicles = true.
    
    SendVehiclesToGarage = true, -- true by default, when the resource starts will send all vehicles to garage.
    GarageBlipSprite = 524,
    GarageBlipColor = 74,

    DisableImpound = false, -- false by default, if true you can't take vehicles that are not in the garage.
    ImpoundCooldown = 300000, -- Cooldown for the impound. 5 minutes by default. Value is in miliseconds (if you want 10 minutes for example, do 1000 * 60 * 10). Use -1 if you want to disable it.
    DrawDistance = 10.0
}

Config.GarageList = {
    LosSantos = {
        GarageId = 1,
        BlipPos = vector3(225.9824, -793.7011, 30.08),
        SpawnMarker = vector3(216.73, -810.27, 29.71),
        DeleteMarker = vector3(215.10, -791.68, 30.83),
        VisualizerCoords = vector4(230.36, -800.48, 29.56, 0.0),
        CamCoords = vector3(227.9077, -795.4945, 32.00),
        CamSpeed = 3000,
        SpawnPoints = {
            vector4(216.86, -799.14, 30.79, 69.2),
            vector4(210.81, -788.58, 30.91, 250.46),
            vector4(213.46, -783.88, 30.86, 247.26),
            vector4(214.88, -778.66, 30.85, 248.03),
            vector4(216.59, -773.38, 30.84, 249.58),
            vector4(218.08, -768.34, 30.84, 247.25),
            vector4(226.75, -771.24, 30.79, 72.11),
            vector4(231.54, -776.32, 30.73, 246.91),
            vector4(242.79, -777.21, 30.66, 68.58),
            vector4(246.73, -784.61, 30.54, 247.04),
            vector4(243.75, -792.46, 30.46, 250.44),
            vector4(242.03, -797.5, 30.4, 248.74),
            vector4(240.0, -805.47, 30.33, 243.79)
        }
    },
    Sandy = {
        GarageId = 2,
        BlipPos = vector3(1530.5, 3777.13, 34.51),
        SpawnMarker = vector3(1503.73, 3762.3, 32.99),
        DeleteMarker = vector3(1489.18, 3739.33, 33.88),
        VisualizerCoords = vector4(1513.9, 3748.28, 34.34, 300.77),
        CamCoords = vector3(1516.02, 3753.79, 35.17),
        CamSpeed = 2000,
        SpawnPoints = {
            vector4(1511.31, 3761.76, 34.01, 196.88),
            vector4(1517.0, 3763.31, 34.03, 194.57),
            vector4(1523.05, 3767.83, 34.05, 220.61),
            vector4(1497.38, 3760.64, 33.92, 215.57),
            vector4(1494.73, 3758.99, 33.9, 210.88)
        }
    } --[[,
    GarageExample = { -- Name of the garage
        GarageId = 1000, -- Has to be unique!
        BlipPos = vector3(225.9824, -793.7011, 30.08), -- The position of the blip in the map
        SpawnMarker = vector3(216.73, -810.27, 29.71), -- Where players can access the garage
        DeleteMarker = vector3(215.10, -791.68, 30.83), -- Where players can store the vehicles
        VisualizerCoords = vector4(230.36, -800.48, 29.56, 0.0), -- Position of the preview vehicle.
        CamCoords = vector3(227.9077, -795.4945, 32.00), -- Camera position
        CamSpeed = 3000, -- Time between the camera transitions, in miliseconds
        SpawnPoints = { -- Vector4 for heading, all posible spawnpoints.
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(1.0, 1.0, 1.0, 1.0)
        }
    }
    ]]--
}