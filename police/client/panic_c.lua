local currentPanics = {}
local currentRoute = nil

RegisterNetEvent('police:getPanics')
AddEventHandler('police:getPanics', function(panicsJson)
    local panics = json.decode(panicsJson)

    for i, v in pairs(panics) do
        newPanic(i, vector3(v.coords.x, v.coords.y, v.coords.z), false)
    end
end)

AddEventHandler("panic:breakService", function()
    for i, v in pairs(currentPanics) do
        RemoveBlip(v['blip'])
        RemoveBlip(v['radius'])
    end

    currentPanics = {}
end)

RegisterNetEvent("police:panic")
AddEventHandler("police:panic", function(playerServerId, coords)
    newPanic(playerServerId, coords)
end)

function newPanic(playerServerId, coords, sendNotification)
    if sendNotification == nil then
        sendNotification = true
    end

    if playerServerId == GetPlayerServerId(PlayerId()) then
        currentPanics[playerServerId] = {
            blip = nil,
            radius = nil,
            coords = coords,
            playerId = playerServerId,
            name = GetPlayerName(GetPlayerFromServerId(playerServerId)),
            blipExists = false
        }

        return
    end

    local alpha = 250
    local radius = AddBlipForRadius(coords, 40.0)
    local blip = AddBlipForCoord(coords)

    local name = GetPlayerName(GetPlayerFromServerId(playerServerId))

    local message = string.format("%s has pressed their panic button.", name)

    if sendNotification then
        TriggerEvent('t-notify:client:Custom', {
            style = 'error',
            duration = 50000,
            message = message,
            sound = true,
            custom = true
        })
        SendNUIMessage({
            transactionType = 'playSound',
            transactionFile  = "panic",
            transactionVolume = 0.1
        })
    end

    SetBlipSprite(blip, 480)
    --SetBlipDisplay(blip, 8)
    SetBlipScale(blip, 1.3)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, false)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(string.format("%s's Panic", name))
    EndTextCommandSetBlipName(blip)

    SetBlipHighDetail(radius, true)
    SetBlipColour(radius, 29)
    SetBlipAlpha(radius, alpha)
    SetBlipAsShortRange(radius, true)

    currentPanics[playerServerId] = {
        blip = blip,
        radius = radius,
        coords = coords,
        playerId = playerServerId,
        name = GetPlayerName(GetPlayerFromServerId(playerServerId)),
        blipExists = true
    }

    PanicBlipThread(playerServerId)
    PanicRouteThread(playerServerId)
end

function PanicBlipThread(id)
    CreateThread(function()
        local isBlue = true
        while currentPanics[id] ~= nil and currentPanics[id].blipExists and DoesBlipExist(currentPanics[id].blip) do
            Wait(250)
            if isBlue then
                if currentPanics[id] ~= nil then
                    SetBlipColour(currentPanics[id].radius, 1)
                    isBlue = false
                end
            else
                if currentPanics[id] ~= nil then
                    SetBlipColour(currentPanics[id].radius, 29)
                    isBlue = true
                end
            end
        end
    end)
end

function PanicRouteThread(id)
    CreateThread(function()
        currentRoute = id
        SetBlipRoute(currentPanics[id].blip, true)

        while currentPanics[id] ~= nil and currentPanics[id].blipExists and DoesBlipExist(currentPanics[id].blip) do
            Wait(500)

            if currentRoute ~= id or currentPanics[id] == nil then
                return
            end

            if (#(GetEntityCoords(PlayerPedId(), true) - currentPanics[id].coords) < 30) then
                SetBlipRoute(blip, false)

                return
            end
        end
    end)
end

RegisterNetEvent("police:panicCleared")
AddEventHandler("police:panicCleared", function(playerServerId)
    local foundPanic = currentPanics[playerServerId]

    if foundPanic == nil then
        return
    end

    if DoesBlipExist(foundPanic['blip']) then
        RemoveBlip(foundPanic['blip'])
    end
    if DoesBlipExist(foundPanic['radius']) then
        RemoveBlip(foundPanic['radius'])
    end

    currentPanics[playerServerId] = nil
    currentRoute = nil

    TriggerEvent("police:updatePanics", GetPanics())
end)

RegisterNetEvent("police:clearAllPanics")
AddEventHandler("police:clearAllPanics", function()
    for i, v in pairs(currentPanics) do
        if DoesBlipExist(v['blip']) then
            RemoveBlip(v['blip'])
        end
        if DoesBlipExist(v['radius']) then
            RemoveBlip(v['radius'])
        end

        currentPanics = {}
    end

    TriggerEvent("police:updatePanics", GetPanics())
end)

RegisterCommand("panic", function(source, args, raw)
    TriggerServerEvent("police:panicPressed", GetEntityCoords(GetPlayerPed(-1), true))

    SetTimeout(10000, function()
        TriggerServerEvent("clearPanic")
    end)
end)

function GetPanics()
    local tempArray = {}

    for i, v in pairs(currentPanics) do
        table.insert(tempArray, v)
    end

    return tempArray
end

AddEventHandler('police:panic-gps', function(id)
    local panic = currentPanics[id]

    if panic == nil then
        return
    end

    PanicRouteThread(id)
end)
