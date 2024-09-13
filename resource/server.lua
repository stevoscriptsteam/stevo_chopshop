lib.versionCheck('stevoscriptsteam/stevo_chopshop')
if not lib.checkDependency('stevo_lib', '1.6.8') then error('stevo_lib version 1.6.9 is required for stevo_chopshop to work!') return end
local stevo_lib = exports['stevo_lib']:import()
local config = lib.require('config')

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
---@param _vehicle integer
lib.callback.register('stevo_chopshop:finish', function(source, _vehicle)
    local vehicle = NetworkGetEntityFromNetworkId(_vehicle)

    if not DoesEntityExist(vehicle) then 
        return playerCheating(source)
    end 

    if not Entity(vehicle).state.currentlyChopping then 
        return playerCheating(source)
    end 

    if Entity(vehicle).state.choppingStage ~= 11 then 
        return playerCheating(source)
    end 

    DeleteEntity(vehicle)

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

    for i, reward in pairs(config.rewards) do 
        stevo_lib.AddItem(source, reward.item, reward.amount)
    end


    return true
end)




 