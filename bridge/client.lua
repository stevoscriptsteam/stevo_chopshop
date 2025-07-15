Bridge.Client.PlayerData = {}

if (GetResourceState("qbx_core") == "started") then

  RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
  AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    local PlayerData = exports.qbx_core:GetPlayerData()

    Bridge.Client.PlayerData.job = PlayerData.job.name
    LoadChopShops()
  end)

  RegisterNetEvent("QBCore:Client:OnJobUpdate")
  AddEventHandler("QBCore:Client:OnJobUpdate", function(job)
    Bridge.Client.PlayerData.job = job.name
    LoadChopShops()
  end)

  AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end

    local PlayerData = exports.qbx_core:GetPlayerData()
    Bridge.Client.PlayerData.job = PlayerData.job.name
    LoadChopShops()
  end)
end

if (GetResourceState("qb-core") == "started") and not (GetResourceState("qbx_core") == "started") then
  RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
  AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    local PlayerData = QBCore.Functions.GetPlayerData()
  
    Bridge.Client.PlayerData.job = PlayerData.job.name
    LoadChopShops()
  end)
  

  AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end

    local PlayerData = QBCore.Functions.GetPlayerData()
  
    Bridge.Client.PlayerData.job = PlayerData.job.name
    LoadChopShops()
  end)
end

if (GetResourceState("es_extended") == "started") then
  RegisterNetEvent("esx:playerLoaded")
  AddEventHandler("esx:playerLoaded", function(xPlayer)
    local PlayerData = xPlayer
    
    Bridge.Client.PlayerData.job = PlayerData.job.name
    LoadChopShops()
  end)

  AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end

    local PlayerData = ESX.PlayerData

    Bridge.Client.PlayerData.job = PlayerData.job.name
    LoadChopShops()
  end)
end

function Bridge.Client.HideRadar(shouldHide)
  DisplayHud(shouldHide)
  DisplayRadar(shouldHide)
end