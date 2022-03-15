QBCore = exports['qb-core']:GetCoreObject()

local toggle = false
local sirenHorn = "SIRENS_AIRHORN"
local sirenNormal = "VEHICLES_HORNS_SIREN_1"
local sirenAlt = "VEHICLES_HORNS_SIREN_2"
local sirenWarn = "VEHICLES_HORNS_POLICE_WARNING"
local sirenList = {}

RegisterCommand("sirenDefault", function()
    if isSirenChange(sirenNormal) or not toggle then
        toggle = true
        playSiren(sirenNormal)
    elseif toggle and not isSirenChange(sirenNormal) then
        toggle = false
        playSiren("muted")
    end
end)

RegisterCommand("sirenAlt", function()
    if isSirenChange(sirenAlt) or not toggle then 
        toggle = true
        playSiren(sirenAlt)
    elseif toggle and not isSirenChange(sirenAlt) then 
        toggle = false
        playSiren("muted")
    end
end)

RegisterCommand("sirenWarn", function()
    if isSirenChange(sirenWarn) or not toggle then 
        toggle = true
        playSiren(sirenWarn)
    elseif toggle and not isSirenChange(sirenWarn) then 
        toggle = false
        playSiren("muted")
    end
end)

RegisterCommand("sirenHorn", function()
    if isSirenChange(sirenHorn) or not toggle then 
        toggle = true
        playSiren(sirenHorn)
    elseif toggle and not isSirenChange(sirenHorn) then 
        toggle = false
        playSiren("muted")
    end
end)

RegisterCommand("sirenMute", function()
    local siren = "muted"
    local playerPed = PlayerPedId()
    local playerCar = GetVehiclePedIsIn(playerPed,false)
    local carNetId = VehToNet(playerCar)
    if isSirenChange("muted") or Entity(playerCar).state.currentSiren == nil then 
        playSiren("muted")
    else
        local siren = sirenNormal
        playSiren(siren)
    end
end)


RegisterKeyMapping("sirenDefault", "Play the default police siren", "KEYBOARD", "UP")
RegisterKeyMapping("sirenAlt", "Play the alternative police siren", "KEYBOARD", "DOWN")
RegisterKeyMapping("sirenWarn", "Play the warning police siren", "KEYBOARD", "LEFT")
RegisterKeyMapping("sirenHorn", "Play the horn police siren", "KEYBOARD", "RIGHT")
RegisterKeyMapping("sirenMute", "Mute sirens", "KEYBOARD", "NUMPAD0")

CreateThread(function()
    while true do 
        QBCore.Functions.TriggerCallback('qb-simplesirens:server:listSirenCars', function(sirenServerList)
           sirenList = sirenServerList or sirenList
        end)
        Wait(5000)
    end
end)

CreateThread(function()
    while true do 
        for carNet, val in pairs(sirenList) do
            if NetworkDoesNetworkIdExist(carNet) then 
                local car = NetToVeh(carNet)
                SetVehicleHasMutedSirens(car, true)
                local muted = val.siren == "muted" or not IsVehicleSirenOn(car) or IsVehicleSeatFree(car, -1) or false
                local currentSiren = Entity(car).state.currentSiren
                local sirenChange = currentSiren ~= val.siren or false
                local sirenOn = Entity(car).state.sirenOn == nil or Entity(car).state.sirenOn == false and IsVehicleSirenOn(car) or false
                if muted then 
                    StopSound(Entity(car).state.soundId)
                    Entity(car).state:set('sirenOn', false, true)
                    Entity(car).state:set("currentSiren", val.siren ,true)
                elseif sirenOn then 
                    local soundId = GetSoundId()
                    Entity(car).state:set('sirenOn', true, true)
                    Entity(car).state:set('soundId', soundId, true)
                    Entity(car).state:set("currentSiren", val.siren ,true)
                    PlaySoundFromEntity(soundId, val.siren, car, 0,0,0)
                elseif sirenChange then 
                    local soundId = GetSoundId()
                    StopSound(Entity(car).state.soundId)
                    Entity(car).state:set('sirenOn', true, true)
                    Entity(car).state:set('soundId', soundId, true)
                    Entity(car).state:set("currentSiren", val.siren ,true)
                    PlaySoundFromEntity(soundId, val.siren, car, 0,0,0)
                end
            end
        end
        Wait(500)
    end
end)

function playSiren(siren)
    local playerPed = PlayerPedId()
    local playerCar = GetVehiclePedIsIn(playerPed,false)
    local soundId = GetSoundId()
    local carNetId = VehToNet(playerCar)
    if GetVehicleClass(playerCar) == 18 and IsVehicleSirenOn(playerCar) then 
        TriggerServerEvent("setSiren", siren, carNetId)
        sirenList[carNetId] = {}
        sirenList[carNetId].siren = siren
    end
end

function isSirenChange(siren)
    local playerPed = PlayerPedId()
    local playerCar = GetVehiclePedIsIn(playerPed,false)
    local carNetId = VehToNet(playerCar)
    local currentSiren = Entity(playerCar).state.currentSiren or false
    if sirenList[carNetId] == nil then 
        return false
    else 
     return currentSiren ~= siren or false
    end
end