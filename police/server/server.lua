--[[
            Cops_FiveM - A cops script for FiveM RP servers.
              Copyright (C) 2018 FiveM-Scripts
              
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.
You should have received a copy of the GNU Affero General Public License
along with Cops_FiveM in the file "LICENSE". If not, see <http://www.gnu.org/licenses/>.
]]

RegisterServerEvent("CheckCopPerms")
AddEventHandler("CheckCopPerms", function()
    if IsPlayerAceAllowed(source, "clockin") then
        TriggerClientEvent("isAllowed", source, true)
    else
        TriggerClientEvent("isAllowed", source, false)
    end
end)

if GetResourceMetadata(GetCurrentResourceName(), 'resource_Isdev', 0) == "yes" then
	RconPrint("/!\\ You are running a dev version of Cops FiveM !\n")
end



local inServiceCops = {}



AddEventHandler('playerDropped', function()
	local name = GetPlayerName(source)
	
	if(inServiceCops[source]) then
        TriggerEvent("panic:server:breakService", source)	
		DiscordLog("Clocked Out (Logged Out)", "From: " .. name .. " ", "ID: " .. source) -- logs clock out to discord via webhook
		inServiceCops[source] = nil
		for i, c in pairs(inServiceCops) do
			TriggerClientEvent("police:resultAllCopsInService", i, inServiceCops)
		end
	end
end)

RegisterServerEvent('police:checkIsCop')
AddEventHandler('police:checkIsCop', function()
	local src = source
	TriggerClientEvent('police:receiveIsCop', src, 0, 1)
end)

RegisterServerEvent('police:takeService')
AddEventHandler('police:takeService', function()
	local name = GetPlayerName(source)
	DiscordLog("Clocked In", "From: " .. name .. " ", "ID: " .. source) -- logs clock in to discord via webhook

	if(not inServiceCops[source]) then
		inServiceCops[source] = getPlayerID(source)
		
		for i, c in pairs(inServiceCops) do
			TriggerClientEvent("police:resultAllCopsInService", i, inServiceCops)
		end
	end
end)


RegisterCommand("clockin", function(source,args,raw)
    if IsPlayerAceAllowed(source, "clockin.command") then
        TriggerClientEvent("clockedIn", source)
    end
end)
RegisterCommand("clockout", function(source,args,raw)
    if IsPlayerAceAllowed(source, "clockin.command") then
        TriggerClientEvent("clockedOut", source)
    end
end)



RegisterServerEvent('police:breakService')
AddEventHandler('police:breakService', function()
	local name = GetPlayerName(source)
	DiscordLog("Clocked Out (Clock Room)", "From: " .. name .. " ", "ID: " .. source) -- logs clock out to discord via webhook
    TriggerEvent("panic:server:breakService", source)
	if(inServiceCops[source]) then
		inServiceCops[source] = nil
		
		for i, c in pairs(inServiceCops) do
			TriggerClientEvent("police:resultAllCopsInService", i, inServiceCops)
		end
	end
end)

RegisterServerEvent('police:getAllCopsInService')
AddEventHandler('police:getAllCopsInService', function()
	TriggerClientEvent("police:resultAllCopsInService", source, inServiceCops)
end)

RegisterServerEvent('police:removeWeapons')
AddEventHandler('police:removeWeapons', function(target)
	local identifier = getPlayerID(target)
	TriggerClientEvent("police:removeWeapons", target)
end)

RegisterServerEvent('police:confirmUnseat')
AddEventHandler('police:confirmUnseat', function(t)
	TriggerClientEvent("police:notify", source, "CHAR_AGENT14", 1, i18n.translate("title_notification"), false, i18n.translate("unseat_sender_notification_part_1") .. GetPlayerName(t) .. i18n.translate("unseat_sender_notification_part_2"))
	TriggerClientEvent('police:unseatme', t)
end)

RegisterServerEvent('police:dragRequest')
AddEventHandler('police:dragRequest', function(t)
	TriggerClientEvent("police:notify", source, "CHAR_AGENT14", 1, i18n.translate("title_notification"), false, i18n.translate("drag_sender_notification_part_1").. GetPlayerName(t) .. i18n.translate("drag_sender_notification_part_2"))
	TriggerClientEvent('police:toggleDrag', t, source)
end)

RegisterServerEvent('police:finesGranted')
AddEventHandler('police:finesGranted', function(target, amount)
	TriggerClientEvent('police:payFines', target, amount, source)
	TriggerClientEvent("police:notify", source, "CHAR_AGENT14", 1, i18n.translate("title_notification"), false, i18n.translate("send_fine_request_part_1")..amount..i18n.translate("send_fine_request_part_2")..GetPlayerName(target))
end)

RegisterServerEvent('police:finesETA')
AddEventHandler('police:finesETA', function(officer, code)
	if(code==1) then
		TriggerClientEvent("police:notify", officer, "CHAR_AGENT14", 1, i18n.translate("title_notification"), false, GetPlayerName(source)..i18n.translate("already_have_a_pendind_fine_request"))
	elseif(code==2) then
		TriggerClientEvent("police:notify", officer, "CHAR_AGENT14", 1, i18n.translate("title_notification"), false, GetPlayerName(source)..i18n.translate("request_fine_timeout"))
	elseif(code==3) then
		TriggerClientEvent("police:notify", officer, "CHAR_AGENT14", 1, i18n.translate("title_notification"), false, GetPlayerName(source)..i18n.translate("request_fine_refused"))
	elseif(code==0) then
		TriggerClientEvent("police:notify", officer, "CHAR_AGENT14", 1, i18n.translate("title_notification"), false, GetPlayerName(source)..i18n.translate("request_fine_accepted"))
	end
end)

RegisterServerEvent('police:cuffGranted')
AddEventHandler('police:cuffGranted', function(t)
	TriggerClientEvent("police:notify", source, "CHAR_AGENT14", 1, i18n.translate("title_notification"), false, i18n.translate("toggle_cuff_player_part_1")..GetPlayerName(t)..i18n.translate("toggle_cuff_player_part_2"))
	TriggerClientEvent('police:getArrested', t)
end)

RegisterServerEvent('police:forceEnterAsk')
AddEventHandler('police:forceEnterAsk', function(t, v)
	TriggerClientEvent("police:notify", source, "CHAR_AGENT14", 1, i18n.translate("title_notification"), false, i18n.translate("force_player_get_in_vehicle_part_1")..GetPlayerName(t)..i18n.translate("force_player_get_in_vehicle_part_2"))
	TriggerClientEvent('police:forcedEnteringVeh', t, v)
end)

RegisterServerEvent('CheckPoliceVeh')
AddEventHandler('CheckPoliceVeh', function(vehicle)
	TriggerClientEvent('FinishPoliceCheckForVeh',source)
	TriggerClientEvent('policeveh:spawnVehicle', source, vehicle)
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

RegisterServerEvent("Gasmask:getIsAllowed")
AddEventHandler("Gasmask:getIsAllowed", function()
        TriggerClientEvent("Gasmask:returnIsAllowed", source, true)
end)

-----------------------------------------------------------------------
-----------------------  ONDUTY 911        ----------------------------
-----------------------------------------------------------------------

if config.enable == false then
    config.prefix = ""
end

RegisterCommand("911", function(source, args, raw)
    if not args[1] and not args[2] then
        TriggerClientEvent('chat:addMessage', source, config.prefix .. '^1Please specify a postal and description!')
    else
        TriggerClientEvent('chat:addMessage', source, config.prefix .. '^4^*911 ^2Successfully ^r^2sent!')
        TriggerClientEvent('911:newCall', -1, source, GetPlayerName(source), GetEntityCoords(GetPlayerPed(source)), table.remove(args, 1), table.concat(args, " "))
    end
end)

-- RegisterCommand("panic", function(source, args, raw)
--     if not args[1] and not args[2] then
--         TriggerClientEvent('chat:addMessage', source, config.prefix .. '^1Please specify a postal and description!')
--     else
--         TriggerClientEvent('chat:addMessage', source, config.prefix .. '^4^*911 ^2Successfully ^r^2sent!')
--         TriggerClientEvent('911:newPanic', -1, source, GetPlayerName(source), GetEntityCoords(GetPlayerPed(source)), table.concat(args, " "))
--     end
-- end)

-----------------------------------------------------------------------
-----------------------     SPEED ZONE     ----------------------------
-----------------------------------------------------------------------
RegisterServerEvent('ZoneActivated')
AddEventHandler('ZoneActivated', function(speed, radius, x, y, z)
    TriggerClientEvent('Zone', -1, speed, radius, x, y, z)
end)

RegisterServerEvent('Disable')
AddEventHandler('Disable', function(blip)
    TriggerClientEvent('RemoveBlip', -1)
end)

RegisterServerEvent('GetData')
AddEventHandler('GetData', function(mode)
local identifiers = GetPlayerIdentifiers(source)
    if mode == "IP" then
        for k,v in pairs(identifiers) do
            if string.sub(v, 0, 3) == "ip:" then
                TriggerClientEvent('ReturnData', source, v)
            end
        end
    else
        for k,v in pairs(identifiers) do
            if string.sub(v, 0, 6) == "steam:" then
                TriggerClientEvent('ReturnData', source, v)
            end
        end
    end
end)


-- discord clock in/out log
function DiscordLog(title, msg, sender, player)
    local embed = {}
    embed = {
        {
            ["color"] = 3447003,
            ["title"] = "**".. title .."**",
            ["description"] = msg,
            ["footer"] = {
                ["text"] = sender,
            },
        }
    }
    PerformHttpRequest(config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  end



  -- mdoorlocks

  isLocked = nil

RegisterServerEvent('mDoorLocks:update')
AddEventHandler('mDoorLocks:update', function(id, isLocked)
    if (id ~= nil and isLocked ~= nil) then
		TriggerClientEvent('mDoorLocks:state', -1, id, isLocked)
		
    end
end)