if not lib.checkDependency('stevo_lib', '1.6.8') then error('stevo_lib version 1.6.8 is required for stevo_chopshop to work!') return end
lib.locale()
local config = require('config')
local stevo_lib = exports['stevo_lib']:import()

local insideZone = false
local blips = {}

lib.onCache('vehicle', function(value)
    if not insideZone then return end

    local isOpen, text = lib.isTextUIOpen()

    if not value then if isOpen then lib.hideTextUI() end return end
  
    if Entity(value).state.currentlyChopping then lib.showTextUI(locale("textui.being_chopped")) return end
        
    lib.showTextUI(locale("textui.start_chopping"))

end)

local function onEnter(self)
    insideZone = self.chopshop
    if cache.vehicle then 
        lib.showTextUI(locale("textui.start_chopping"))
    end
end
 
local function onExit(self)
    insideZone = false

    local isOpen, text = lib.isTextUIOpen()
    if isOpen then 
        lib.hideTextUI()
    end
end
 
local function inside(self)

    if not cache.vehicle then return end

    if Entity(cache.vehicle).state.currentlyChopping then return end

    local isOpen, text = lib.isTextUIOpen()

    if not isOpen then lib.hideTextUI() return end

    if IsControlJustReleased(1, 38) then 

        if GlobalState.stevo_chopshop_cooldown then 
            return stevo_lib.Notify(locale("notify.chop_cooldown"), 'error', 5000)
        end

        if not lib.callback.await('stevo_chopshop:canChop', false) then 
            return stevo_lib.Notify(locale("notify.chop_police"), 'error', 5000)
        end

        local vehicleType = GetVehicleType(cache.vehicle)

        for i, type in pairs(config.blockedVehicleTypes) do 
            if vehicleType == type then return stevo_lib.Notify(locale("notify.cant_chop"), 'error', 5000) end 
        end

        stevo_lib.Notify(locale("notify.start_chopping"), 'info', 5000)

        Entity(cache.vehicle).state:set('currentlyChopping', true, true)
        Entity(cache.vehicle).state:set('choppingStage', 1, true)

        FreezeEntityPosition(cache.vehicle, true)
        SetVehicleDoorsLocked(cache.vehicle, 2)
        SetVehicleEngineOn(cache.vehicle, false, true, true)
        TaskLeaveVehicle(cache.ped, cache.vehicle, 0)

        lib.hideTextUI()
    end

end

local function chopPart(data)
    TaskTurnPedToFaceEntity(cache.ped, data.entity, 300)
    Wait(300)
    
    if not lib.skillCheck(config.skillchecks[data.name]) then stevo_lib.Notify(locale("notify.fail_skillcheck"), 'error', 3000) return end

    local vehicle = data.entity

    if data.name == 'stevo_chopshop:1' then config.policeDispatch(cache.ped, vehicle) end

    if data.doorIndex then 
        SetVehicleDoorOpen(vehicle, data.doorIndex, false, false)
    end

    local wheelAnim = {scenario = "CODE_HUMAN_MEDIC_TEND_TO_DEAD"}
    local otherAnim = {dict = 'amb@world_human_welding@male@base', clip = 'base'}
    local otherProp = {model = `prop_weld_torch`, bone = 28422, pos = vec3(-0.01, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5)}

    if  lib.progressBar({
            duration = config.duration[data.name],
            label = locale("progress."..data.name),
            canCancel = true,
            disable = {
                car = true,
                move = true
            },
            anim = data.wheelIndex and wheelAnim or otherAnim,
            prop = data.wheelIndex and false or otherProp
        })

    then

        if data.doorIndex then 
            SetVehicleDoorCanBreak(vehicle, data.doorIndex, true)
            SetVehicleDoorBroken(vehicle, data.doorIndex, true)
        end

        if data.wheelIndex then 
            SetVehicleWheelsCanBreak(vehicle, true)
            SetVehicleTyreBurst(vehicle, data.wheelIndex, true, 1000.0)
        end


        local doors = GetNumberOfVehicleDoors(vehicle)

        local chopPart, chopNotify = lib.callback.await('stevo_chopshop:chopPart', false, data, NetworkGetNetworkIdFromEntity(vehicle), doors)

        if chopPart then stevo_lib.Notify(chopNotify, 'success', 5000) end
    else 
        return
    end
end

local function loadChopShops()
    local totalChopShops = 0
    for i, chopShop in pairs(config.chopShops) do    
        lib.zones.poly({
            points = chopShop.zonePoints,
            thickness = 2,
            debug = config.debug,
            inside = inside,
            onEnter = onEnter,
            onExit = onExit,
            chopshop = i
        })

        local blip = chopShop.blip
        if blip then 
            blips[i] = AddBlipForCoord(blip.coords.x, blip.coords.y, blip.coords.z)

            SetBlipAsShortRange(blips[i], true)
            SetBlipSprite(blips[i], blip.sprite) 
            SetBlipColour(blips[i], blip.color) 
            SetBlipScale(blips[i], blip.scale)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(blip.name)
            EndTextCommandSetBlipName(blips[i])

            SetBlipDisplay(blips[i], 4)
            SetBlipAsMissionCreatorBlip(blips[i], true)
        end

        totalChopShops = totalChopShops +1
    end

    if config.debug then 
        local debugPrint = ('%s Chop Shops Loaded'):format(totalChopShops)
        lib.print.info(debugPrint)
    end

    local options = {
        {
            name = 'stevo_chopshop:1',
            icon = 'fa-solid fa-car',
            label = locale('target.stevo_chopshop:1'),
            bones = {'bonnet'},
            doorIndex = 4,
            wheelIndex = false,
            chassis = false,
            onSelect = chopPart,
            canInteract = function(entity)
                return insideZone and Entity(entity).state.currentlyChopping and Entity(entity).state.choppingStage == 1
            end
        },
        {
            name = 'stevo_chopshop:2',
            icon = 'fa-solid fa-car',
            label = locale('target.stevo_chopshop:2'),
            bones = {'door_dside_f'},
            doorIndex = 0,
            wheelIndex = false,
            chassis = false,
            onSelect = chopPart,
            canInteract = function(entity)
                return insideZone and Entity(entity).state.currentlyChopping and Entity(entity).state.choppingStage == 2
            end
        },
        {
            name = 'stevo_chopshop:3',
            icon = 'fa-solid fa-car',
            label = locale('target.stevo_chopshop:3'),
            bones = {'door_pside_f'},
            doorIndex = 1,
            wheelIndex = false,
            chassis = false,
            onSelect = chopPart,
            canInteract = function(entity)
                return insideZone and Entity(entity).state.currentlyChopping and Entity(entity).state.choppingStage == 3
            end
        },
        {
            name = 'stevo_chopshop:4',
            icon = 'fa-solid fa-car',
            label = locale('target.stevo_chopshop:4'),
            doorIndex = 2,
            wheelIndex = false,
            chassis = false,
            bones = {'door_dside_r'},
            onSelect = chopPart,
            canInteract = function(entity)
                return insideZone and Entity(entity).state.currentlyChopping and Entity(entity).state.choppingStage == 4
            end
        },
        {
            name = 'stevo_chopshop:5',
            icon = 'fa-solid fa-car',
            label = locale('target.stevo_chopshop:5'),
            doorIndex = 3,
            wheelIndex = false,
            chassis = false,
            bones = {'door_pside_r'},
            onSelect = chopPart,
            canInteract = function(entity)
                return insideZone and Entity(entity).state.currentlyChopping and Entity(entity).state.choppingStage == 5
            end
        },
        {
            name = 'stevo_chopshop:6',
            icon = 'fa-solid fa-car',
            label = locale('target.stevo_chopshop:6'),
            doorIndex = 5,
            wheelIndex = false,
            chassis = false,
            bones = {'boot'},
            onSelect = chopPart,
            canInteract = function(entity)
                return insideZone and Entity(entity).state.currentlyChopping and Entity(entity).state.choppingStage == 6
            end
        },
        {
            name = 'stevo_chopshop:7',
            icon = 'fa-solid fa-car',
            label = locale('target.stevo_chopshop:7'),
            bones = {'wheel_lf'},
            doorIndex = false,
            wheelIndex = 0,
            chassis = false,
            onSelect = chopPart,
            canInteract = function(entity)
                return insideZone and Entity(entity).state.currentlyChopping and Entity(entity).state.choppingStage == 7
            end
        },
        {
            name = 'stevo_chopshop:8',
            icon = 'fa-solid fa-car',
            label = locale('target.stevo_chopshop:8'),
            doorIndex = false,
            wheelIndex = 1,
            chassis = false,
            bones = {'wheel_rf'},
            onSelect = chopPart,
            canInteract = function(entity)
                return insideZone and Entity(entity).state.currentlyChopping and Entity(entity).state.choppingStage == 8
            end
        },
        {
            name = 'stevo_chopshop:9',
            icon = 'fa-solid fa-car',
            label = locale('target.stevo_chopshop:9'),
            doorIndex = false,
            wheelIndex = 4,
            chassis = false,
            bones = {'wheel_lr'},
            onSelect = chopPart,
            canInteract = function(entity)
                return insideZone and Entity(entity).state.currentlyChopping and Entity(entity).state.choppingStage == 9
            end
        },
        {
            name = 'stevo_chopshop:10',
            icon = 'fa-solid fa-car',
            label = locale('target.stevo_chopshop:10'),
            doorIndex = false,
            wheelIndex = 5,
            chassis = false,
            bones = {'wheel_rr'},
            onSelect = chopPart,
            canInteract = function(entity)
                return insideZone and Entity(entity).state.currentlyChopping and Entity(entity).state.choppingStage == 10
            end
        },
        {
            name = 'stevo_chopshop:11',
            icon = 'fa-solid fa-car',
            label = locale('target.stevo_chopshop:11'),
            distance = 3,
            doorIndex = false,
            wheelIndex = false,
            chassis = true,
            onSelect = chopPart,
            canInteract = function(entity)
                return insideZone and Entity(entity).state.currentlyChopping and Entity(entity).state.choppingStage == 11
            end
        }
    }

    exports.ox_target:addGlobalVehicle(options)
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end

    loadChopShops()
end)

AddEventHandler('stevo_lib:playerLoaded', function()
    loadChopShops()
end)

AddEventHandler('onResourceStop', function(resource)   
    if resource ~= cache.resource then return end

    for i, blip in pairs(blips) do 
        if DoesBlipExist(blip) then 
            RemoveBlip(blip)
        end 
    end
end)
