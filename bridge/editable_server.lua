local config = require('config.config')

RegisterNetEvent('stevo_dealerships:server:giveKeys', function(plate)

  if (config.keys == "auto" and GetResourceState("jaksam-vehicles-keys") == "started") or config.keys == "jaksam-vehicles-keys" then
    local identifier = Bridge.Server.GetPlayerIdentifier(source)
    exports["vehicles_keys"]:giveVehicleKeysToIdentifier(identifier, plate, "owned")

  elseif (config.keys == "auto" and GetResourceState("wasabi_carlock") == "started") or config.keys == "wasabi_carlock" then
    exports.wasabi_carlock:GiveKey(source, plate)

  elseif (config.keys == "auto" and GetResourceState("qbx_vehiclekeys") == "started") or config.keys == "qbx_vehiclekeys" then
    
    exports['qb-vehiclekeys']:GiveKeys(source, plate)

  elseif (config.keys == "auto" and GetResourceState("qb-vehiclekeys") == "started") or config.keys == "qb-vehiclekeys" then
    exports['qb-vehiclekeys']:GiveKeys(source, plate)

  elseif (config.keys == "auto" and GetResourceState("Renewed-VehicleKeys") == "started") or config.keys == "Renewed-VehicleKeys" then
    exports['Renewed-Vehiclekeys']:addKey(source, plate)
  elseif (config.keys == "auto" and GetResourceState("MrNewbVehicleKeys") == "started") or config.keys == "MrNewbVehicleKeys" then
    exports.MrNewbVehicleKeys:GiveKeysByPlate(source, plate)
  else
    error("We do not support it or you don't have a keys system!")
  end
end)

