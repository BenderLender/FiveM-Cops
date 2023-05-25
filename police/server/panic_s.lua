
local inServiceCops = {}

RegisterCommand("clearpanics", function(source,args,rawCommand)
    if inServiceCops[source] then
        for k,v in pairs(inServiceCops) do
            TriggerClientEvent("police:clearAllPanics", k)
        end
    end
end)

AddEventHandler("panic:server:breakService", function(svrId)
    if inServiceCops[source] then
        inServiceCops[source] = nil
    end

    for k,v in pairs(inServiceCops) do
        TriggerClientEvent("police:panicCleared", k, svrId)
    end
end)


RegisterServerEvent('police:takeService', function()
    if(not inServiceCops[source]) then
		inServiceCops[source] = getPlayerID(source)
		
		for i, c in pairs(inServiceCops) do
			TriggerClientEvent("police:resultAllCopsInService", i, inServiceCops)
		end
	end
end)




RegisterServerEvent("police:panicPressed", function(coords)
    local coords = GetEntityCoords(GetPlayerPed(source))
    TriggerClientEvent('t-notify:client:Custom', source, {
        style = 'error',
        duration = 2000,
        message = "Panic Sent.",
        sound = true,
        custom = true
    })



    if inServiceCops[source] then
        for k,v in pairs(inServiceCops) do
            if k ~= source then
                TriggerClientEvent("police:panic", k, source, coords)
            end
        end
    end

end)

RegisterServerEvent("clearPanic", function()
    for k,v in pairs(inServiceCops) do
        TriggerClientEvent("police:panicCleared", k, source)
    end
end)

































function getPlayerID(source)
    local identifiers = GetPlayerIdentifiers(source)
    local player = getIdentifiant(identifiers)
    return player
end

function getIdentifiant(id)
    for _, v in ipairs(id) do
        return v
    end
end
