QBCore = exports['qb-core']:GetCoreObject()

local sirens = {}

RegisterNetEvent("setSiren", function(siren, carNetId)
   --print("state:" .. siren .. "car:" .. carNetId)
    sirens[carNetId] = {}
    sirens[carNetId].siren = siren
end)

QBCore.Functions.CreateCallback('qb-simplesirens:server:listSirenCars', function(source, cb, safe)
   -- print(sirens)
    cb(sirens)
end)

AddEventHandler("entityRemoved", function(handle)
    local entityModel = GetEntityModel(handle)
    local carModel = GetHashKey("police3")
    local entity = NetworkGetNetworkIdFromEntity(handle)

    if entityModel == carModel then 
        sirens[entity] = nil
    end

end)

CreateThread(function()

    while true do 
        for val,key in pairs(cops) do 
            print(val)
        end
        Wait(1000) 
    end

end)