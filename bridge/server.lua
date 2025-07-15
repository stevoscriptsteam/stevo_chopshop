local config = require('config')
---@param src integer
---@param msg string
---@param type "success" | "warning" | "error"
function Bridge.Server.Notify(src, title, msg, type)
  TriggerClientEvent("stevo_chopshops:client:notify", src, title, msg, type, 5000)
end

---@param model string|integer
---@param plate string
---@return integer|nil vehicleId
function Bridge.Server.SaveVehicleToGarage(src, model, plate)
  local vehicleId = nil
  local props = json.encode({
    model = convertModelToHash(model),
    plate = plate
  })

  if config.Framework == "QBCore" or config.Framework == "Qbox" then
    local playerData = Bridge.Server.GetPlayer(src).PlayerData
    local license = playerData.license
    local citizenid = playerData.citizenid

    vehicleId = MySQL.insert.await(
      "INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate) VALUES(?, ?, ?, ?, ?, ?)",
      {license, citizenid, model, joaat(model), props, plate}
    )

  elseif config.Framework == "ESX" then
    local identifier = Bridge.Server.GetPlayerIdentifier(src)
    debugPrint("Saving vehicle to garage for "..identifier)

    vehicleId = MySQL.insert.await(
      "INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES(?, ?, ?)",
      {identifier, plate, props}
    )
  end

  return vehicleId
end

---@param vehicle boolean|QueryResult|unknown|{ [number]: { [string]: unknown  }|{ [string]: unknown }}
---@return string | number | false model
function Bridge.Server.GetModelColumn(vehicle)
  if config.Framework == "QBCore" or config.Framework == "Qbox" then
    return vehicle.vehicle or tonumber(vehicle.hash) or false
  elseif config.Framework == "ESX" then
    if not vehicle or not vehicle.vehicle then return false end

    if type(vehicle.vehicle) == "string" then
      if not json.decode(vehicle.vehicle) then return false end
      return json.decode(vehicle.vehicle).model
    else
      return vehicle.vehicle.model
    end
  end

  return false
end

--
-- Player Functions
--

---@param src integer
function Bridge.Server.GetPlayer(src)
  if config.Framework == "QBCore" then
    return QBCore.Functions.GetPlayer(src)
  elseif config.Framework == "Qbox" then
    return exports.qbx_core:GetPlayer(src)
  elseif config.Framework == "ESX" then
    return ESX.GetPlayerFromId(src)
  end
end

---@param src integer
function Bridge.Server.GetPlayerInfo(src)
  local player = Bridge.Server.GetPlayer(src)
  if not player then return false end

  if config.Framework == "QBCore" or config.Framework == "Qbox" then
    return {
      name = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    }
  elseif config.Framework == "ESX" then
    return {
      name = player.getName()
    }
  end
end

---@param identifier string
function Bridge.Server.GetPlayerInfoFromIdentifier(identifier)
  local player = MySQL.single.await("SELECT * FROM " .. Bridge.PlayersTable .. " WHERE " .. Bridge.PlayersTableId .. " = ?", {identifier})
  if not player then return false end

  if config.Framework == "QBCore" or config.Framework == "Qbox" then
    local charinfo = json.decode(player.charinfo)
    return {
      name = charinfo.firstname .. " " .. charinfo.lastname
    }
  elseif config.Framework == "ESX" then
    return {
      name = player.firstname .. " " .. player.lastname
    }
  end
end

---@param src integer
function Bridge.Server.GetPlayerIdentifier(src)
  local player = Bridge.Server.GetPlayer(src)
  if not player then return false end

  if config.Framework == "QBCore" or config.Framework == "Qbox" then
    return player.PlayerData.citizenid
  elseif config.Framework == "ESX" then
    return player.getIdentifier()
  end
end

---@param src integer
function Bridge.Server.GetPlayerName(src)
  local player = Bridge.Server.GetPlayer(src)
  if not player then return false end

  if config.Framework == "QBCore" or config.Framework == "Qbox" then
    return player.PlayerData.charinfo.firstname..' '..player.PlayerData.charinfo.lastname
  elseif config.Framework == "ESX" then
    return player.getName()
  end
end

---@param src integer
function Bridge.Server.GetPlayerRank(src)
  local player = Bridge.Server.GetPlayer(src)
  if not player then return false end

  if config.Framework == "QBCore" or config.Framework == "Qbox" then
    return player.PlayerData.job.grade.name,player.PlayerData.job.grade.level
  elseif config.Framework == "ESX" then
    return player.getJob().grade
  end
end

---@param identifier string
---@return integer | false src
function Bridge.Server.GetPlayerFromIdentifier(identifier)
  if config.Framework == "QBCore" then
    local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
    if not player then return false end
    return player.PlayerData.source
  elseif config.Framework == "Qbox" then
    local player = exports.qbx_core:GetPlayerByCitizenId(identifier)
    if not player then return false end
    return player.PlayerData.source
  elseif config.Framework == "ESX" then
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if not xPlayer then return false end
    return xPlayer.source
  end

  return false
end

---@param src integer
---@param type "cash" | "bank" | "money"
function Bridge.Server.GetPlayerBalance(src, type)

  local player = Bridge.Server.GetPlayer(src)
  if not player then return 0 end

  if config.Framework == "QBCore" or config.Framework == "Qbox" then
    return player.PlayerData.money[type]
  elseif config.Framework == "ESX" then
    if type == "cash" then type = "money" end

    for i, acc in pairs(player.getAccounts()) do
      if acc.name == type then
        return acc.money
      end
    end

    return 0
  end
end

---@param source number 
---@param item string 
---@param amount number
function Bridge.Server.AddItem(source, item, amount)
  local amount = 0

  if config.Framework == "QBCore" then
    local player = QBCore.Functions.GetPlayer(source)
    return player.Functions.AddItem(item, count)
  elseif config.Framework == "Qbox" then
    return exports.ox_inventory:AddItem(source, item, count)
  elseif config.Framework == "ESX" then
    local player = ESX.GetPlayerFromId(source)
    return player.addInventoryItem(item, count)
  end

  return false
end

---@param job string
---@return integer
function Bridge.Server.GetJobCount(job)
  local amount = 0

  if config.Framework == "QBCore" then
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.name == job then
            amount = amount + 1
        end
    end
  elseif config.Framework == "Qbox" then
    local players = exports.qbx_core:GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.name == job then
            amount = amount + 1
        end
    end
  elseif config.Framework == "ESX" then
    ESX.GetExtendedPlayers('job', job)
  end

  return amount
end

---@param src integer
---@param amount number
---@param account "cash" | "bank" | "money"
function Bridge.Server.PlayerRemoveMoney(src, amount, account)
  local player = Bridge.Server.GetPlayer(src)
  account = account or "bank"

  if account == "custom" then
    -- Add your own custom balance system here
  elseif config.Framework == "QBCore" or config.Framework == "Qbox" then
    player.Functions.RemoveMoney(account, round(amount, 0))
  elseif config.Framework == "ESX" then
    if account == "cash" then account = "money" end
    player.removeAccountMoney(account, round(amount, 0))
  end
end

