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

--
--Local variables : Please do not touch theses variables
--


Citizen.CreateThread(function()
	TriggerServerEvent("CheckCopPerms")
end)

RegisterNetEvent("clockedIn", function()
	clockIn()
end)

RegisterNetEvent("clockedOut", function()
	clockOut()
end)

RegisterNetEvent("isAllowed")
AddEventHandler("isAllowed", function(allowed)
	isCop = allowed
end)

local firstSpawn = true
local isInService = false
local policeHeli = nil
local handCuffed = false
local isAlreadyDead = false
local allServiceCops = {}
local blipsCops = {}
local drag = false
local officerDrag = -1

rank = -1

anyMenuOpen = {
	menuName = "",
	isActive = false
}

SpawnedSpikes = {}

--
--Events handlers
--

AddEventHandler("playerSpawned", function()
	if config.useCopWhitelist then
--		TriggerServerEvent("police:checkIsCop")
	else
--		isCop = true
		TriggerServerEvent("police:checkIsCop")
		load_armory()
		load_garage()
	end

	if firstSpawn then
		TriggerServerEvent("police:GetPayChecks")
		firstSpawn = false
	end
end)

RegisterNetEvent('police:receiveIsCop')
AddEventHandler('police:receiveIsCop', function(svrank, svdept)
	if(svrank == -1) then
		if(config.useCopWhitelist == true) then
			isCop = false
		else
--			isCop = true
			rank = 0
			dept = 1

			load_armory()
			load_garage()
		end
	else
--		isCop = true
		rank = svrank
		dept = svdept
		if(isInService) then --and config.enableOutfits
			if(GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01")) then
				SetPedComponentVariation(PlayerPedId(), 10, 8, config.rank.outfit_badge[rank], 2)
			else
				SetPedComponentVariation(PlayerPedId(), 10, 7, config.rank.outfit_badge[rank], 2)
			end
		end

		load_armory()
		load_garage()
	end
end)

if(config.useCopWhitelist == true) then
	RegisterNetEvent('police:nowCop')
	AddEventHandler('police:nowCop', function()
--		isCop = true
	end)
end

RegisterNetEvent('police:Update')
AddEventHandler('police:Update', function(boolState)
	local data = GetResourceMetadata(GetCurrentResourceName(), 'resource_fname', 0)

	if boolState then
		DisplayNotificationLabel("FMMC_ENDVERC1", "~y~" .. data .. "~s~")
	end
end)

if(config.useCopWhitelist == true) then
	RegisterNetEvent('police:noLongerCop')
	AddEventHandler('police:noLongerCop', function()
		if(config.useCopWhitelist == true) then
			isCop = false
		end

		isInService = false

		if(config.enableOutfits == true) then
			RemoveAllPedWeapons(PlayerPedId())
			TriggerServerEvent("skin_customization:SpawnPlayer")
		else
			local model = GetHashKey("a_m_y_mexthug_01")

			RequestModel(model)
			while not HasModelLoaded(model) do
				Citizen.Wait(0)
			end
		 
			SetPlayerModel(PlayerId(), model)
			SetModelAsNoLongerNeeded(model)
			RemoveAllPedWeapons(PlayerPedId())
		end
		
		if(policeHeli ~= nil) then
			SetEntityAsMissionEntity(policeHeli, true, true)
			Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(policeHeli))
			policeHeli = nil
		end

		ServiceOff()
	end)
end

RegisterNetEvent('police:getArrested')
AddEventHandler('police:getArrested', function()
	handCuffed = not handCuffed
	if(handCuffed) then
		TriggerEvent("police:notify",  "CHAR_AGENT14", 1, i18n.translate("title_notification"), false, i18n.translate("now_cuffed"))
	else
		TriggerEvent("police:notify",  "CHAR_AGENT14", 1, i18n.translate("title_notification"), false, i18n.translate("now_uncuffed"))
		cuffing = false
		drag = false
		ClearPedTasksImmediately(PlayerPedId())
	end
end)

--Inspired from emergency for request system (by Jyben : https://forum.fivem.net/t/release-job-save-people-be-a-hero-paramedic-emergency-coma-ko/19773)
local lockAskingFine = false
RegisterNetEvent('police:payFines')
AddEventHandler('police:payFines', function(amount, sender)
	Citizen.CreateThread(function()
		
		if(lockAskingFine ~= true) then
			lockAskingFine = true
			local notifReceivedAt = GetGameTimer()
			Notification(i18n.translate("info_fine_request_before_amount")..amount..i18n.translate("info_fine_request_after_amount"))
			while(true) do
				Wait(0)
				
				if (GetTimeDifference(GetGameTimer(), notifReceivedAt) > 15000) then
					TriggerServerEvent('police:finesETA', sender, 2)
					Notification(i18n.translate("request_fine_expired"))
					lockAskingFine = false
					break
				end
				
				if IsControlPressed(1, config.bindings.accept_fine) then
					TriggerServerEvent('bank:withdraw', amount)
					Notification(i18n.translate("pay_fine_success_before_amount")..amount..i18n.translate("pay_fine_success_after_amount"))
					TriggerServerEvent('police:finesETA', sender, 0)
					lockAskingFine = false
					break
				end
				
				if IsControlPressed(1, config.bindings.refuse_fine) then
					TriggerServerEvent('police:finesETA', sender, 3)
					lockAskingFine = false
					break
				end
			end
		else
			TriggerServerEvent('police:finesETA', sender, 1)
		end
	end)
end)

RegisterNetEvent('police:receivePaycheck')
AddEventHandler('police:receivePaycheck', function(amount)
	if amount then
		local _, currentValue = StatGetInt("BANK_BALANCE", -1)
		local value = math.floor(amount + currentValue)

		StatSetInt("BANK_BALANCE", value, true)
		ShowHudComponentThisFrame(4)
	end
end)

-- Copy/paste from fs_freemode (by FiveM-Script: https://github.com/FiveM-Scripts/fs_freemode)

RegisterNetEvent("police:notify")
AddEventHandler("police:notify", function(icon, type, sender, title, text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	SetNotificationMessage(icon, icon, true, type, sender, title, text)
	DrawNotification(false, true)
end)

--Piece of code given by Thefoxeur54
RegisterNetEvent('police:unseatme')
AddEventHandler('police:unseatme', function(t)
	local ped = GetPlayerPed(t)        
	ClearPedTasksImmediately(ped)
	plyPos = GetEntityCoords(PlayerPedId(),  true)
	local xnew = plyPos.x+2
	local ynew = plyPos.y+2
   
	SetEntityCoords(PlayerPedId(), xnew, ynew, plyPos.z)
end)

RegisterNetEvent('police:toggleDrag')
AddEventHandler('police:toggleDrag', function(t)
	if(handCuffed) then
		drag = not drag
		officerDrag = t
	end
end)

RegisterNetEvent('police:forcedEnteringVeh')
AddEventHandler('police:forcedEnteringVeh', function(veh)
	if(handCuffed) then
	    drag = false	
		local pos = GetEntityCoords(PlayerPedId())
		local entityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0, 0.0)

		local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, PlayerPedId(), 0)
		local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)

		if vehicleHandle ~= nil then
			if(IsVehicleSeatFree(vehicleHandle, 1)) then
				SetPedIntoVehicle(PlayerPedId(), vehicleHandle, 1)

			else 
				if(IsVehicleSeatFree(vehicleHandle, 2)) then
					SetPedIntoVehicle(PlayerPedId(), vehicleHandle, 2)
				end
			end
		end
	end
end)

RegisterNetEvent('police:removeWeapons')
AddEventHandler('police:removeWeapons', function()
    RemoveAllPedWeapons(PlayerPedId(), true)
end)

if(config.enableOtherCopsBlips == true) then
	RegisterNetEvent('police:resultAllCopsInService')
	AddEventHandler('police:resultAllCopsInService', function(array)
		allServiceCops = array
		enableCopBlips()
	end)
end

--
--Functions
--

function Notification(msg)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(msg)
	DrawNotification(0,1)
end

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function DisplayNotificationLabel(label, sublabel)
    SetNotificationTextEntry(label)
    if sublabel then
        AddTextComponentSubstringPlayerName(sublabel)
    end

    DrawNotification(true, true)
end

--From Player Blips and Above Head Display (by Scammer : https://forum.fivem.net/t/release-scammers-script-collection-09-03-17/3313)
function enableCopBlips()
	for k, existingBlip in pairs(blipsCops) do
        RemoveBlip(existingBlip)
    end
	blipsCops = {}
	
	local localIdCops = {}
	for _, player in ipairs(GetActivePlayers()) do
		if(GetPlayerPed(player) ~= PlayerPedId()) then
			for i,c in pairs(allServiceCops) do
				if(i == GetPlayerServerId(player)) then
					localIdCops[player] = c
					break
				end
			end
		end
	end
	
	for id, c in pairs(localIdCops) do
		local ped = GetPlayerPed(id)
		local blip = GetBlipFromEntity(ped)
		
		if not DoesBlipExist(blip) then
			blip = AddBlipForEntity(ped)
			SetBlipSprite(blip, 1)
			Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true)
			HideNumberOnBlip( blip)
			SetBlipNameToPlayerName(blip, id)
			
			SetBlipScale(blip,  0.85)
			SetBlipAlpha(blip, 255)
			
			table.insert(blipsCops, blip)
		else			
			blipSprite = GetBlipSprite(blip)
			
			HideNumberOnBlip(blip)
			if blipSprite ~= 1 then
				SetBlipSprite(blip, 1)
				Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true)
			end
			
			SetBlipNameToPlayerName(blip, id)
			SetBlipScale(blip, 0.85)
			SetBlipAlpha(blip, 255)
			
			table.insert(blipsCops, blip)
		end
	end
end

function GetPlayers()
    local players = {}

    for _, player in ipairs(GetActivePlayers()) do
        if NetworkIsPlayerActive(player) then
            table.insert(players, player)
        end
    end

    return players
end

function GetClosestPlayer()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)
	
	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = Vdist(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"])
			if(closestDistance == -1 or closestDistance > distance) then
				closestPlayer = value
				closestDistance = distance
			end
		end
	end
	
	return closestPlayer, closestDistance
end

function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

function isNearTakeService()
	local distance = 10000
	local pos = {}
	for i = 1, #clockInStation do
		local coords = GetEntityCoords(PlayerPedId(), 0)
		local currentDistance = Vdist(clockInStation[i].x, clockInStation[i].y, clockInStation[i].z, coords.x, coords.y, coords.z)
		if(currentDistance < distance) then
			distance = currentDistance
			pos = clockInStation[i]
		end
	end
	
	if anyMenuOpen.menuName == "cloackroom" and anyMenuOpen.isActive and distance > 3 then
		CloseMenu()
	end

	if(distance < 30) then
		if anyMenuOpen.menuName ~= "cloackroom" and not anyMenuOpen.isActive then
			DrawMarker(1, pos.x, pos.y, pos.z-1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 155, 255, 200, 0, 0, 2, 0, 0, 0, 0)
		end
	end

	if(distance < 2) then
		return true
	end
end

function isNearStationGarage()
	local distance = 10000
	local pos = {}
	for i = 1, #garageStation do
		local coords = GetEntityCoords(PlayerPedId(), 0)
		local currentDistance = Vdist(garageStation[i].x, garageStation[i].y, garageStation[i].z, coords.x, coords.y, coords.z)
		if(currentDistance < distance) then
			distance = currentDistance
			pos = garageStation[i]
		end
	end
	
	if anyMenuOpen.menuName == "garage" and anyMenuOpen.isActive and distance > 5 then
		CloseMenu()
	end

	if(distance < 30) then
		if anyMenuOpen.menuName ~= "garage" and not anyMenuOpen.isActive then
			DrawMarker(1, pos.x, pos.y, pos.z-1, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 1.0, 0, 155, 255, 200, 0, 0, 2, 0, 0, 0, 0)
		end
	end

	if(distance < 2) then
		return true
	end
end

function isNearHelicopterStation()
	local distance = 10000
	local pos = {}
	for i = 1, #heliStation do
		local coords = GetEntityCoords(PlayerPedId(), 0)
		local currentDistance = Vdist(heliStation[i].x, heliStation[i].y, heliStation[i].z, coords.x, coords.y, coords.z)
		if(currentDistance < distance) then
			distance = currentDistance
			pos = heliStation[i]
		end
	end
	
	if(distance < 30) then
		DrawMarker(1, pos.x, pos.y, pos.z-1, 0, 0, 0, 0, 0, 0, 2.5, 2.5, 1.0, 0, 155, 255, 200, 0, 0, 2, 0, 0, 0, 0)
	end
	if(distance < 2) then
		return true
	end
end

function isNearArmory()
	local distance = 10000
	local pos = {}
	for i = 1, #armoryStation do
		local coords = GetEntityCoords(PlayerPedId(), 0)
		local currentDistance = Vdist(armoryStation[i].x, armoryStation[i].y, armoryStation[i].z, coords.x, coords.y, coords.z)
		if(currentDistance < distance) then
			distance = currentDistance
			pos = armoryStation[i]
		end
	end
	
	if (anyMenuOpen.menuName == "armory" or anyMenuOpen.menuName == "armory-weapon_list") and anyMenuOpen.isActive and distance > 2 then
		CloseMenu()
	end
	if(distance < 30) then
		DrawMarker(1, pos.x, pos.y, pos.z-1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 155, 255, 200, 0, 0, 2, 0, 0, 0, 0)
	end
	if(distance < 2) then
		return true
	end
end

function ServiceOn()
	isInService = true
	TriggerEvent('police:isInService', isInService)
	TriggerServerEvent("police:takeService")
end

function ServiceOff()
	isInService = false
	TriggerEvent('police:isInService', isInService)
	TriggerServerEvent("police:breakService")
	TriggerEvent("panic:breakService")
	if config.enableOtherCopsBlips == true then
		allServiceCops = {}
		
		for k, existingBlip in pairs(blipsCops) do
			RemoveBlip(existingBlip)
		end
		blipsCops = {}
	end
end

exports('inInService', function()
	return isInService
end)
  



function DisplayHelpText(str)
	BeginTextCommandDisplayHelp("STRING")
	AddTextComponentSubstringPlayerName(str)
	EndTextCommandDisplayHelp(0, 0, 1, -1)
end

function CloseMenu()
	SendNUIMessage({
		action = "close"
	})
	
	anyMenuOpen.menuName = ""
	anyMenuOpen.isActive = false
end

RegisterNUICallback('sendAction', function(data, cb)
	_G[data.action](data.params)
    cb('ok')
end)

--
--Threads
--

local alreadyDead = false
local playerStillDragged = false

Citizen.CreateThread(function()
	DoScreenFadeIn(100)
	local gxt = "fmmc"
	local CurrentSlot = 0

	while HasAdditionalTextLoaded(CurrentSlot) and not HasThisAdditionalTextLoaded(gxt, CurrentSlot) do
		Wait(1)
		CurrentSlot = CurrentSlot + 1
	end

	if not HasThisAdditionalTextLoaded(gxt, CurrentSlot) then
		ClearAdditionalText(CurrentSlot, true)
		RequestAdditionalText(gxt, CurrentSlot)
		while not HasThisAdditionalTextLoaded(gxt, CurrentSlot) do
			Wait(0)
		end
	end

	RequestAnimDict('mp_arresting')
	while not HasAnimDictLoaded('mp_arresting') do
		Citizen.Wait(50)
	end	

	if not IsIplActive("FIBlobby") then
		RequestIpl("FIBlobbyfake")
	end

	TriggerServerEvent("police:checkIsCop")

	if config.enableNeverWanted then
		SetMaxWantedLevel(0)
		SetWantedLevelMultiplier(0.0)
	else
		SetMaxWantedLevel(5)
		SetWantedLevelMultiplier(1.0)
	end

	if config.stationBlipsEnabled then
		for _, item in pairs(clockInStation) do
			item.blip = AddBlipForCoord(item.x, item.y, item.z)
			SetBlipSprite(item.blip, 60)
			SetBlipScale(item.blip, 0.8)
			SetBlipColour(item.blip, 3)
			SetBlipAsShortRange(item.blip, true)
		end
	end
   
    while true do
        Citizen.Wait(5)	
		DisablePlayerVehicleRewards(PlayerId())	

		if(anyMenuOpen.isActive) then
			DisableControlAction(1, 21)
			DisableControlAction(1, 140)
			DisableControlAction(1, 141)
			DisableControlAction(1, 142)

			SetDisableAmbientMeleeMove(PlayerPedId(), true)

			if (IsControlJustPressed(1,172)) then
				SendNUIMessage({
					action = "keyup"
				})
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			elseif (IsControlJustPressed(1,173)) then
				SendNUIMessage({
					action = "keydown"
				})
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			elseif (anyMenuOpen.menuName == "cloackroom") then
				if IsControlJustPressed(1, 176) then
					SendNUIMessage({
						action = "keyenter"
					})

					PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
					Citizen.Wait(500)
					CloseMenu()
				end
			elseif (IsControlJustPressed(1,176)) then
				SendNUIMessage({
					action = "keyenter"
				})
				PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			elseif (IsControlJustPressed(1,177)) then
				if(anyMenuOpen.menuName == "policemenu" or anyMenuOpen.menuName == "cloackroom" or anyMenuOpen.menuName == "garage") then
					CloseMenu()
				elseif(anyMenuOpen.menuName == "armory") then
					CloseArmory()					
				elseif(anyMenuOpen.menuName == "armory-weapon_list") then
					BackArmory()
				else
					BackMenuPolice()
				end
			end
		else
			EnableControlAction(1, 21)
			EnableControlAction(1, 140)
			EnableControlAction(1, 141)
			EnableControlAction(1, 142)
		end
		
		if (handCuffed == true) then
			local myPed = PlayerPedId()
			local animation = 'idle'
			local flags = 50				
			
			while IsPedBeingStunned(myPed, 0) do
				ClearPedTasksImmediately(myPed)
			end

			DisableControlAction(1, 12, true)
			DisableControlAction(1, 13, true)
			DisableControlAction(1, 14, true)

			DisableControlAction(1, 23, true)
			DisableControlAction(1, 24, true)

			DisableControlAction(1, 15, true)
			DisableControlAction(1, 16, true)
			DisableControlAction(1, 17, true)

			DisableControlAction(1, 71, true) -- vehicle controls
			DisableControlAction(1, 72, true)
			DisableControlAction(1, 63, true)
			DisableControlAction(1, 64, true)

			DisableControlAction(1, 75, true) -- exit vehicle
			DisableControlAction(1, 288, true) -- f1 menu
			DisableControlAction(1, 168, true) -- f7 teleport
			DisableControlAction(1, 21, true) -- left shift

			if not cuffing then
				SetCurrentPedWeapon(myPed, GetHashKey("WEAPON_UNARMED"), true)
				RemoveAllPedWeapons(myPed, true)
				cuffing = true
			end

			if not IsEntityPlayingAnim(myPed, "mp_arresting", animation, 3) then
				TaskPlayAnim(myPed, "mp_arresting", animation, 8.0, -8.0, -1, flags, 0, 0, 0, 0 )
			end
		else
			EnableControlAction(1, 12, false)
			EnableControlAction(1, 13, false)
			EnableControlAction(1, 14, false)

			EnableControlAction(1, 15, false)
			EnableControlAction(1, 16, false)
			EnableControlAction(1, 17, false)

			if IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "idle", 3) then
				StopAnimTask(PlayerPedId(), "mp_arresting", animation, 3)
				ClearPedTasksImmediately(PlayerPedId())
			end

			cuffing = false		
		end
		
		--Piece of code from Drag command (by Frazzle, Valk, Michael_Sanelli, NYKILLA1127 : https://forum.fivem.net/t/release-drag-command/22174)
		if drag then
			local ped = GetPlayerPed(GetPlayerFromServerId(officerDrag))
			local myped = PlayerPedId()
			AttachEntityToEntity(myped, ped, 4103, 11816, 0.48, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
			playerStillDragged = true
		else
			if(playerStillDragged) then
				DetachEntity(PlayerPedId(), true, false)
				playerStillDragged = false
			end
		end

		if config.enableNeverWanted then
			if IsPlayerWantedLevelGreater(PlayerId(), 0) then
				ClearPlayerWantedLevel(PlayerId())
			end
		end
	
        if(isCop) then
			if(isNearTakeService()) then
				if not (anyMenuOpen.isActive) then
				    DisplayHelpText(i18n.translate("help_text_open_cloackroom") .. GetLabelText("collision_8vlv02g"),0,1,0.5,0.8,0.6,255,255,255,255)
				    if IsControlJustPressed(1,config.bindings.interact_position) then
				    	load_cloackroom()
				    	OpenCloackroom()
				    end
				end
			end
			
			if(isInService) then			
				if(isNearStationGarage()) then
					if(policevehicle ~= nil) then
						if not (anyMenuOpen.isActive) then
							DisplayHelpText(i18n.translate("help_text_put_car_into_garage"),0,1,0.5,0.8,0.6,255,255,255,255)
						end
					else
						DisplayHelpText(i18n.translate("help_text_get_car_out_garage"),0,1,0.5,0.8,0.6,255,255,255,255)
					end
					
					if IsControlJustPressed(1,config.bindings.interact_position) then
						if(policevehicle ~= nil) then
							Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(policevehicle))
							policevehicle = nil
						else
							OpenGarage()
						end
					end
				end
				
				--Open Armory menu
				if(isNearArmory()) then
					if not (anyMenuOpen.isActive) then					
						DisplayHelpText(i18n.translate("help_text_open_armory"),0,1,0.5,0.8,0.6,255,255,255,255)

						if IsControlJustPressed(1,config.bindings.interact_position) then
							Lx, Ly, Lz = table.unpack(GetEntityCoords(PlayerPedId(), true))
							DoScreenFadeOut(500)
							Wait(600)

							SetEntityCoords(PlayerPedId(), 452.119966796875, -980.061966796875, 30.690966796875)
							Wait(800)
							armoryPed = createArmoryPed()

							if not DoesCamExist(ArmoryRoomCam) then
								ArmoryRoomCam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
								AttachCamToEntity(ArmoryRoomCam, PlayerPedId(), 0.0, 0.0, 1.0, true)
								PointCamAtEntity(ArmoryRoomCam, armoryPed, 0.0, -30.0, 1.0, true)

								SetCamRot(ArmoryRoomCam, 0.0,0.0, GetEntityHeading(PlayerPedId()))
								SetCamFov(ArmoryRoomCam, 70.0)							
							end

							Wait(100)
							DoScreenFadeIn(500)

							if DoesEntityExist(armoryPed) then
								TaskTurnPedToFaceEntity(PlayerPedId(), armoryPed, -1)
							end							

							Wait(300)
							OpenArmory()
							if not IsAmbientSpeechPlaying(armoryPed) then
								PlayAmbientSpeechWithVoice(armoryPed, "WEPSEXPERT_GREETSHOPGEN", "WEPSEXP", "SPEECH_PARAMS_FORCE", 0)
							end
						end
					end
				end

				if (anyMenuOpen.menuName == "armory") then			
					if DoesCamExist(ArmoryRoomCam) then
						RenderScriptCams(true, 1, 1800, 1, 0)
					end		
				end

				if (IsControlJustPressed(1,config.bindings.use_police_menu)) then
					load_menu()
					TogglePoliceMenu()
				end
				
				if isNearHelicopterStation() then
					if(policeHeli ~= nil) then
						DisplayHelpText(i18n.translate("help_text_put_heli_into_garage"),0,1,0.5,0.8,0.6,255,255,255,255)
					else
						DisplayHelpText(i18n.translate("help_text_get_heli_out_garage"),0,1,0.5,0.8,0.6,255,255,255,255)
					end
					
					if IsControlJustPressed(1,config.bindings.interact_position)  then
						if(policeHeli ~= nil) then
							Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(policeHeli))
							policeHeli = nil
						else
							local heli = GetHashKey("polmav")
							local ply = PlayerPedId()
							local plyCoords = GetEntityCoords(ply, 0)
							
							RequestModel(heli)
							while not HasModelLoaded(heli) do
								Citizen.Wait(0)
							end
							
							policeHeli = CreateVehicle(heli, plyCoords["x"], plyCoords["y"], plyCoords["z"], 90.0, true, false)
							SetVehicleHasBeenOwnedByPlayer(policevehicle,true)

							local netid = NetworkGetNetworkIdFromEntity(policeHeli)
							SetNetworkIdCanMigrate(netid, true)
							NetworkRegisterEntityAsNetworked(VehToNet(policeHeli))
							
							SetVehicleLivery(policeHeli, 0)
							TaskWarpPedIntoVehicle(ply, policeHeli, -1)
							SetEntityAsMissionEntity(policeHeli, true, true)
						end
					end
				end
			end
		end
    end
end)

if config.enablePaychecks then
	Citizen.CreateThread(function()
		while true do
			Wait(1600)
			if GetClockHours() == 10 and GetClockMinutes() == 00 then
				TriggerServerEvent("police:TransferPayCheck")
			end
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		if drag then
			local ped = GetPlayerPed(GetPlayerFromServerId(playerPedDragged))
			plyPos = GetEntityCoords(ped, true)
			SetEntityCoords(ped, plyPos.x, plyPos.y, plyPos.z)
		end
		Citizen.Wait(1000)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			currentVeh = GetVehiclePedIsIn(PlayerPedId(), false)
			x,y,z = table.unpack(GetEntityCoords(PlayerPedId(), true))

			if DoesObjectOfTypeExistAtCoords(x, y, z, 0.9, GetHashKey("P_ld_stinger_s"), true) then
				for i= 0, 7 do
					SetVehicleTyreBurst(currentVeh, i, true, 1148846080)
				end

				Citizen.Wait(100)
				DeleteSpike()
			end
		end
	end
end)

local isAllowed = false

AddEventHandler('playerSpawned', function()
    local src = source
    TriggerServerEvent("Gasmask:getIsAllowed")
end)

RegisterNetEvent("Gasmask:returnIsAllowed")
AddEventHandler("Gasmask:returnIsAllowed", function(Allowed)
    isAllowed = Allowed
end)


-- FUNCTIONS

gasMaskOn = false
wearingMask = false

function notify(string)
        SetNotificationTextEntry("STRING")
        AddTextComponentString(string)
        DrawNotification(true, false)
    end

local function PlayEmote()
    local playerped = GetPlayerPed(-1)
    RequestAnimDict('mp_masks@standard_car@ds@')
        TaskPlayAnim(playerped, 'mp_masks@standard_car@ds@', 'put_on_mask', 8.0, 8.0, 800, 16, 0, false, false, false)
    end 

function Draw2DText(x, y, text, scale, r, g, b, a)
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- WEARING MASK 

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if config.mask == GetPedDrawableVariation(PlayerPedId(), 1) then
			wearingMask = true
		else
			wearingMask = false
		end
		if wearingMask then
			if(isInService) then
				gasMaskOn = true
       	    	local playerped = GetPlayerPed(-1)
       	    	SetEntityProofs(playerped, false, false, false, false, false, false, true, true, false)
       	    	if config.showhud then
                	Draw2DText(config.hudx, config.hudy, "~w~Gasmask: ~g~Equipped", config.hudscale, 255, 255, 255, 255);
                end
            else
            	gasMaskOn = false
            	SetPedComponentVariation(PlayerPedId(), 1, 0, 0, 1)
            	notify("You must be ~b~Clocked In ~w~to wear this!")
            end
        elseif not wearingMask then
        	gasMaskOn = false
        	local playerped = GetPlayerPed(-1)
        	SetEntityProofs(playerped, false, false, false, false, false, false, false, false, false)
        	if(isInService) then
        		if config.showhud then
        			Draw2DText(config.hudx, config.hudy, "~w~Gasmask: ~r~Unequipped", config.hudscale, 255, 255, 255, 255);
        		end
        	end
        end
    end
end)

-- COMMAND
function clockedIn()
    if (isInService) then
        return true
    end
    return false
end

-- Clocked In

RegisterCommand("gasmask", function(Source, args, rawCommand)
	if(isInService) then
		if args[1] == "on" then
      	 	if not gasMaskOn then
       	  		gasMaskOn = true
       	    	local playerped = GetPlayerPed(-1)
       	    	SetEntityProofs(playerped, false, false, false, false, false, false, true, true, false)
                PlayEmote()              
                SetPedComponentVariation(PlayerPedId(), 1, config.mask, 0, 1)
       	    	notify("Gasmask ~g~equipped")
        	else
        		notify("Your mask ~w~is already ~g~on")
        	end
    	elseif args[1] == "off" then
    		if gasMaskOn then
            	gasMaskOn = false
            	local playerped = GetPlayerPed(-1)
            	SetEntityProofs(playerped, false, false, false, false, false, false, false, false, false)
                PlayEmote()
                SetPedComponentVariation(PlayerPedId(), 1, 0, 0, 1)
            	notify("Gasmask ~r~unequipped")
        	else 
        		notify("Your mask ~w~is already ~r~off")
        	end
    	elseif args[1] == nil then
    		if not gasMaskOn then
                gasMaskOn = true
                local playerped = GetPlayerPed(-1)
                SetEntityProofs(playerped, false, false, false, false, false, false, true, true, false)
                PlayEmote()
                SetPedComponentVariation(PlayerPedId(), 1, config.mask, 0, 1)
                notify("Gasmask ~g~equipped")
            else
                gasMaskOn = false
                local playerped = GetPlayerPed(-1)
                SetEntityProofs(playerped, false, false, false, false, false, false, false, false, false)
                PlayEmote()
                SetPedComponentVariation(PlayerPedId(), 1, 0, 0, 1)
                notify("Gasmask ~r~unequipped")
            end
   		else
    		notify("This command is not recognized")
    	end
    else
        notify("You must be ~b~Clocked In ~w~to wear this!")
    end
end) 

TriggerEvent('chat:addSuggestion', '/gasmask', 'Take a gasmask on/off')

--------------------------------------------------------------------------
----------------             ONDUTY 911           ------------------------
--------------------------------------------------------------------------

TriggerEvent('chat:addSuggestion', '/911', 'Sends an emergency call to the local Police Department!', {
    { name="Nearest Postal", help="Example: 362" },
    { name="Call Description", help="Example: Shots fired by semi-auto firearm" }
})

-- TriggerEvent('chat:addSuggestion', '/panic', 'Press your panic button, sending a signal to all OnDuty Units!!', {
--     { name="Postal/Street", help="Example: 362" },

-- })

local calls = {}
local panic = {}

local function createBlip(coords, name, color)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 162)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.5)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING");
    AddTextComponentString("911 Report - " .. name);
    EndTextCommandSetBlipName(blip);

    return blip
end

RegisterNetEvent('911:newCall')
AddEventHandler('911:newCall', function (id, name, coords, location, description)
    if (isInService) then
        TriggerEvent('t-notify:client:Custom', {
            style = 'error',
            duration = 35000,
            title = "New 911",
            message = "**Location**: " ..  location .. "\n\n" .. "**Call Description**: \n".. description,
            sound = true,
            custom = true
        })
        if calls[id] then
            RemoveBlip(calls[id])
        end
        calls[id] = createBlip(coords, name, 5)
        Citizen.CreateThread(function()
            if not config.AutoRemove or config.AutoRemove == 0 then
                return
            end
            Wait(config.AutoRemove * 1000)
            RemoveBlip(calls[id])
            calls[id] = nil
        end)
    end
end)

RegisterNetEvent('911:newPanic')
AddEventHandler('911:newPanic', function (id, name, coords, location)
    if (isInService) then
        TriggerEvent('t-notify:client:Custom', {
            style = 'error',
            duration = 50000,
            message = name .. " triggered their panic button!",
            sound = true,
            custom = true
        })
        TriggerEvent('t-notify:client:Custom', {
            style = 'error',
            duration = 100000,
            message = "**Location Pressed**: " ..  location,
            sound = true,
            custom = true
        })
        TriggerEvent('t-notify:client:Custom', {
            style = 'error',
            duration = 100000,
            title = "Signal 100",
            message = "**SIGNAL 100 IS NOW IN EFFECT!!**\nEMERGENCY RTO TRAFFIC ONLY!!!",
            sound = true,
            custom = true
        })
        if panic[id] then
            RemoveBlip(panic[id])
        end
        panic[id] = createBlip(coords, name, 1)
        Citizen.CreateThread(function()
            if not config.AutoRemove or config.AutoRemove == 0 then
                return
            end
            Wait(config.AutoRemove * 1000)
            RemoveBlip(panic[id])
            panic[id] = nil
        end)
    end
end)



---  mDoorLocks

doorList = config.doorList

Citizen.CreateThread(function()
    while true do
		Citizen.Wait(0)
        for i = 1, #doorList do
            local playerCoords = GetEntityCoords( GetPlayerPed(-1) )
            local closeDoor = GetClosestObjectOfType(doorList[i]["x"], doorList[i]["y"], doorList[i]["z"], 1.0, GetHashKey(doorList[i]["objName"]), false, false, false)
            local objectCoordsDraw = GetEntityCoords( closeDoor )            
            local playerDistance = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, doorList[i]["x"], doorList[i]["y"], doorList[i]["z"], true)

            if(playerDistance < doorList[i]["distance"]) then
                if doorList[i]["locked"] == true then
                    DrawText3d(doorList[i]["x"], doorList[i]["y"], doorList[i]["z"], "[E] - Locked")
                else
                    DrawText3d(doorList[i]["x"], doorList[i]["y"], doorList[i]["z"], "[E] - Unlocked")
                end
                
                -- Control input for door locking.
                if (IsControlJustReleased(0, 51) and IsInputDisabled(0) and isInService) then
                    TriggerEvent('mDoorLocks:anim')
                    Citizen.Wait(850)
                        if doorList[i]["locked"] == true then
                            FreezeEntityPosition(closeDoor, false)
                            doorList[i]["locked"] = false
                        else
                            FreezeEntityPosition(closeDoor, true)
                            doorList[i]["locked"] = true
                        end
                        TriggerServerEvent('mDoorLocks:update', i, doorList[i]["locked"])
                    end
                else
                    FreezeEntityPosition(closeDoor, doorList[i]["locked"])
                end
            end
        end
    end)

function DrawText3d(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
        local factor = (string.len(text)) / 370
        DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 100)
		ClearDrawOrigin()
    end
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

RegisterNetEvent('mDoorLocks:anim')
AddEventHandler('mDoorLocks:anim', function()
    ClearPedSecondaryTask(GetPlayerPed(-1))
    loadAnimDict("anim@heists@keycard@") 
    TaskPlayAnim(GetPlayerPed(-1), "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
    Citizen.Wait(60)
    ClearPedTasks(GetPlayerPed(-1))
end)

RegisterNetEvent('mDoorLocks:state')
AddEventHandler('mDoorLocks:state', function(id, isLocked)
    if type(doorList[id]) ~= nil then
        doorList[id]["locked"] = isLocked
    end
end)
