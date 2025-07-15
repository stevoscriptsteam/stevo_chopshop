local config = require('config.config')


function Bridge.Client.GetCallsign()
  if config.callsign == "stevo_police" then
    return LocalPlayer.state.stevo_police_callsign
  elseif config.callsign == "framework" then
    return Bridge.Client.GetFrameworkCallsign()
  else
    return ''
  end
end

---@param text string
function Bridge.Client.ShowTextUI(text)
  SetTimeout(1, function()
    
    if (config.textUI == "auto" and GetResourceState("ox_lib") == "started") or config.textUI == "ox_lib" then
      exports["ox_lib"]:showTextUI(text, {
        position = "left-center"
      })
    elseif (config.textUI == "auto" and GetResourceState("okokTextUI") == "started") or config.textUI == "okokTextUI" then
      exports["okokTextUI"]:Open(text, "lightblue", "left")
    elseif (config.textUI == "auto" and GetResourceState("ps-ui") == "started") or config.textUI == "ps-ui" then
      exports["ps-ui"]:DisplayText(text, "primary")
    elseif config.Framework == "QBCore" then
      exports["qb-core"]:DrawText(text)
    else
      error("We do not support it or you don't have a TextUI system!")
    end
  end)
end

function Bridge.Client.HideTextUI()

  if (config.textUI == "auto" and GetResourceState("ox_lib") == "started") or config.textUI == "ox_lib" then
    exports["ox_lib"]:hideTextUI()
  elseif (config.textUI == "auto" and GetResourceState("ps-ui") == "started") or config.textUI == "ps-ui" then
    exports["ps-ui"]:HideText()
  elseif (config.textUI == "auto" and GetResourceState("okokTextUI") == "started") or config.textUI == "okokTextUI" then
    exports["okokTextUI"]:Close()
  elseif config.Framework == "QBCore" then
    exports["qb-core"]:HideText()
  else
    error("We do not support it or you don't have a TextUI system!")
  end
end

---@param title string
---@param msg string
---@param type? "success" | "warning" | "error"
---@param time? number
function Bridge.Client.Notify(title, msg, type, time)
  title = title or 'Dealerships'
  type = type or "success"
  time = time or 5000

  if (config.notify == "auto" and GetResourceState("okokNotify") == "started") or config.notify == "okokNotify" then
    exports["okokNotify"]:Alert(title, msg, time, type)
  elseif (config.notify == "auto" and GetResourceState("ps-ui") == "started") or config.notify == "ps-ui" then
    exports["ps-ui"]:Notify(msg, type, time)
  elseif (config.notify == "auto" and GetResourceState("ox_lib") == "started") or config.notify == "ox_lib" then
    exports["ox_lib"]:notify({
      title = title,
      description = msg,
      type = type
    })
  elseif (config.notify == "auto" and GetResourceState("wasabi_notify") == "started") or config.notify == "wasabi_notify" then
    exports.wasabi_notify:notify(title, msg, time, type)
  else
    if config.Framework == "QBCore" then
      return QBCore.Functions.Notify(msg, type, time)
    elseif config.Framework == "Qbox" then
      exports.qbx_core:Notify(msg, type, time)
    elseif config.Framework == "ESX" then
      return ESX.ShowNotification(msg, type)
    end
  end
end

---@param coords vector3
---@param icon string 
---@param label string 
---@param func function
---@return string
function Bridge.Client.AddZone(coords, icon, label, func, id)
  local zone


  if (config.target == "auto" and GetResourceState("ox_target") == 'started') or config.target == "ox_target" then
    zone = exports.ox_target:addSphereZone({
      coords = vec3(coords.x, coords.y, coords.z+1.0),
      radius = 1.3,
      debug = false,
      options = {
          {
            icon = icon, 
            label = label,
              onSelect = func,
              distance = 1.5,
          },
          
      }
    })
  elseif (config.target == "auto" and GetResourceState("qb-target") == "started") or config.target == "qb-target" then
    exports['qb-target']:AddCircleZone(id, vec3(coords.x, coords.y, coords.z+1.0), 1.3,{
      name = id, 
      debugPoly = false, 
      useZ=true, 
    }, { options = {
      { 
          icon = icon, 
          label = label,
          action = func,
      },}, 
      distance = 1.5 
    })
    zone = id
  else 
    error("We do not support it or you don't have a targeting system!")
  end


  return zone
end


---@param zone string
function Bridge.Client.RemoveZone(zone)

  if (config.target == "auto" and GetResourceState("ox_target") == 'started') or config.target == "ox_target" then
    exports.ox_target:removeZone(zone)
  elseif (config.target == "auto" and GetResourceState("qb-target") == "started") or config.target == "qb-target" then
    exports['qb-target']:RemoveZone(zone)
  end
end

---@param type "cash" | "bank" | "money" | string
function Bridge.Client.GetBalance(type)

  if config.Framework == "QBCore" then
    return QBCore.Functions.GetPlayerData().money[type]
  elseif config.Framework == "Qbox" then
    return exports.qbx_core:GetPlayerData().money[type]
  elseif config.Framework == "ESX" then
    if type == "cash" then type = "money" end
    
    for i, acc in pairs(ESX.GetPlayerData().accounts) do
      if acc.name == type then
        return acc.money
      end
    end

    return 0
  end
end


RegisterNetEvent("stevo_chopshops:client:notify", function(...)
  Bridge.Client.Notify(...)
end)



