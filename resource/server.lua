lib.versionCheck('stevoscriptsteam/stevo_chopshop')
if not lib.checkDependency('stevo_lib', '1.6.8') then error('stevo_lib version 1.6.8 is required for stevo_chopshop to work!') return end
lib.locale()
local stevo_lib = exports['stevo_lib']:import()
local config = lib.require('config')

GlobalState.stevo_chopshop_cooldown = false

---@param source number
local function playerCheating(source)
    local identifier = stevo_lib.GetIdentifier(source)
    local name = GetPlayerName(source)
    local warningMessage = (locale("cheater_warning")):format(name, identifier)
    lib.print.info(warningMessage)

    if not config.dropCheaters then return end

    return DropPlayer(source, 'Exploiting stevo_chopshop') 
end

---@param source number
---@param name string
local function giveRewards(source, name)
    local rewardTable = config.rewards[name]

    for i, reward in pairs(rewardTable) do 
        stevo_lib.AddItem(source, reward.item, reward.amount)
    end
end

local function cooldown()
    CreateThread(function()
        if config.globalCooldown then 
            GlobalState.stevo_chopshop_cooldown = true 
            SetTimeout(config.globalCooldown*60000, function()
                GlobalState.stevo_chopshop_cooldown = false
            end)
        end
    end)
end

---@param source number
---@param _vehicle integer
lib.callback.register('stevo_chopshop:chopPart', function(source, data, _vehicle, doors)
    local vehicle = NetworkGetEntityFromNetworkId(_vehicle)

    if not DoesEntityExist(vehicle) then 
        return playerCheating(source)
    end 

    if not Entity(vehicle).state.currentlyChopping then 
        return playerCheating(source)
    end 
    
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local insideChopshop = false

    for i, chopshop in pairs(config.chopShops) do
        local dist = #(chopshop.securityCoords - playerCoords)
        if dist < 50 then 
            insideChopshop = true 
            break
        end
    end
    
    if not insideChopshop then 
        return playerCheating(source)
    end

    local choppingStage = Entity(vehicle).state.choppingStage

    if Entity(vehicle).state.choppingStage == 11 then 
        DeleteEntity(vehicle)
        giveRewards(source, data.name)

        return true, locale("notify."..data.name)
    end

    
    if doors == 3 and choppingStage == 3 then 
        Entity(vehicle).state:set('choppingStage', 7, true) 
        giveRewards(source, data.name)
        
        return true, locale("notify.stevo_chopshop:6")
    end

    if doors == 4 and choppingStage == 3 then 
        Entity(vehicle).state:set('choppingStage', 6, true) 
        giveRewards(source, data.name)

        return true, locale("notify.stevo_chopshop:5")
    end

        
    Entity(vehicle).state:set('choppingStage', choppingStage + 1, true)
    giveRewards(source, data.name)

    return true, locale("notify."..data.name)
end)

---@return boolean
lib.callback.register('stevo_chopshop:canChop', function()

    if GlobalState.stevo_chopshop_cooldown then return false end

    if not config.policeRequirement then cooldown() return true end

    local police = stevo_lib.GetJobCount(config.policeJob)

    if police >= config.policeRequired then cooldown() return true end
    
    return false
end)




 