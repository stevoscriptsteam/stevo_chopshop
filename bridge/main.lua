local config = require('config')
QBCore, ESX = nil, nil
Bridge = {
  Client = {},
  Server = {}
}

if GetResourceState("qbx_core") == "started" then
  config.Framework = "Qbox"

  Bridge.VehiclesTable = "player_vehicles"
  Bridge.VehProps = "mods"
  Bridge.PlayerId = "citizenid"
  Bridge.PlayersTable = "players"
  Bridge.PlayersTableId = "citizenid"
elseif GetResourceState("qb-core") == "started" then
  QBCore = exports['qb-core']:GetCoreObject()
  config.Framework = "QBCore"

  Bridge.VehiclesTable = "player_vehicles"
  Bridge.VehProps = "mods"
  Bridge.PlayerId = "citizenid"
  Bridge.PlayersTable = "players"
  Bridge.PlayersTableId = "citizenid"
elseif GetResourceState("es_extended") == "started" then
  ESX = exports["es_extended"]:getSharedObject()
  config.Framework = "ESX"

  Bridge.VehiclesTable = "owned_vehicles"
  Bridge.VehProps = "vehicle"
  Bridge.PlayerId = "owner"
  Bridge.PlayersTable = "users"
  Bridge.PlayersTableId = "identifier"
else
  error("Your framework is not supported, we only support Qbox, QBCore and ESX!")
end