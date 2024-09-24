return {
    dropCheaters = true, -- If cheaters should be dropped/kicked from the server for exploiting events

    globalCooldown = 5, -- Time in minutes for global cooldown (Set to false for no cooldown)
    policeRequired = false, -- Police required to start chopping vehicle
    policeJob = 'police',

    policeDispatch = function(ped, vehicle)
        -- PS dispatch example
        --exports['ps-dispatch']:VehicleTheft(vehicle)
    end,

    chopShops = {
        lsia = {
            securityCoords = vec3(-425.2410, -1687.6906, 19.0291), -- Put in the middle of the chopping zone
            blip = false,
            zonePoints = {
                vec3(-426.0, -1674.0, 19),
                vec3(-434.0, -1697.0, 19),
                vec3(-423.0, -1700.0, 19),
                vec3(-411.0, -1680.0, 19)
            }
        },
        sandy = {
            securityCoords = vec3(2340.4993, 3052.4824, 48.1473), -- Put in the middle of the chopping zone
            blip = {
                coords = vec3(2340.4993, 3052.4824, 48.1473),
                sprite = 225, -- https://docs.fivem.net/docs/game-references/blips/#blips
                color = 59, -- https://docs.fivem.net/docs/game-references/blips/#blip-colors
                scale = 0.8, -- float
                name = 'Chop Shop'

            }, zonePoints = {
                vec3(2343.0, 3049.0, 48.0),
                vec3(2338.0, 3049.0, 48.0),
                vec3(2337.0, 3058.0, 48.0),
                vec3(2344.0, 3059.0, 48.0),
            }
        }
    },

    blockedVehicleTypes = { -- Its advised you dont change this unless you know what your doing. (Removing it may break the script as bikes cannot be chopped)
        'bike',
        'heli',
        'boat'
    },

    rewards = { -- Add rewards for each part.

        ["stevo_chopshop:1"] = { -- Bonnet
            {item = 'plastic', amount = 1},
        },

        ["stevo_chopshop:2"] = { -- Front dri Door
            {item = 'plastic', amount = 1},
        },

        ["stevo_chopshop:3"] = { -- Front pas door
            {item = 'plastic', amount = 1},
        },

        ["stevo_chopshop:4"] = { -- Back dri Door
            {item = 'plastic', amount = 1},
        },

        ["stevo_chopshop:5"] = { -- Back pas Door
            {item = 'plastic', amount = 1},
        },

        ["stevo_chopshop:6"] = { -- Boot
            {item = 'plastic', amount = 1},
        },

        ["stevo_chopshop:7"] = { -- Front dri wheel
            {item = 'plastic', amount = 1},
        },

        ["stevo_chopshop:8"] = { -- Front pas wheel
            {item = 'plastic', amount = 1},
        },

        ["stevo_chopshop:9"] = {-- Back dri wheel
            {item = 'plastic', amount = 1},
        },

        ["stevo_chopshop:10"] = {-- Back pas wheel
            {item = 'plastic', amount = 1},
        },

        ["stevo_chopshop:11"] = { -- Whole chassis
            {item = 'plastic', amount = 1},
            {item = 'steel', amount = 1},
        },

    },

    skillchecks = {
        ["stevo_chopshop:1"] = {'easy', 'easy'}, -- Bonnet
        ["stevo_chopshop:2"] = {'easy', 'easy'}, -- Front dri Door
        ["stevo_chopshop:3"] = {'easy', 'easy'}, -- Front pas Door
        ["stevo_chopshop:4"] = {'easy', 'easy'}, -- Back dri Door
        ["stevo_chopshop:5"] = {'easy', 'easy'}, -- Back pas Door
        ["stevo_chopshop:6"] = {'easy', 'easy'}, -- Boot
        ["stevo_chopshop:7"] = {'easy', 'easy'}, -- Front dri wheel
        ["stevo_chopshop:8"] = {'easy', 'easy'}, -- Front pas wheel
        ["stevo_chopshop:9"] = {'easy', 'easy'}, -- Back dri wheel
        ["stevo_chopshop:10"] = {'easy', 'easy'}, -- Back pas wheel
        ["stevo_chopshop:11"] = {'easy', 'easy'}, -- Whole chassis
    },

    
    duration = {
        ["stevo_chopshop:1"] = 2000, -- Bonnet
        ["stevo_chopshop:2"] = 3000, -- Front dri Door
        ["stevo_chopshop:3"] = 3000, -- Front pas Door
        ["stevo_chopshop:4"] = 3000, -- Back dri Door
        ["stevo_chopshop:5"] = 3000, -- Back pas Door
        ["stevo_chopshop:6"] = 2000, -- Boot
        ["stevo_chopshop:7"] = 2500, -- Front dri wheel
        ["stevo_chopshop:8"] = 2500, -- Front pas wheel
        ["stevo_chopshop:9"] = 2500, -- Back dri wheel
        ["stevo_chopshop:10"] = 2500, -- Back pas wheel
        ["stevo_chopshop:11"] = 5000, -- Whole chassis
    },

    debug = false, -- Enabling debug prints and zones.
    
}