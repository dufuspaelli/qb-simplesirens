QBCore = exports['qb-core']:GetCoreObject()

local sirens = {}

RegisterNetEvent("setSiren", function(siren, carNetId)
   --print("state:" .. siren .. "car:" .. carNetId)
    sirens[carNetId] = {}
    sirens[carNetId].siren = siren
end)

QBCore.Functions.CreateCallback('qb-cnr:server:listCopCars', function(source, cb, safe)
   -- print(sirens)
    cb(sirens)
end)
