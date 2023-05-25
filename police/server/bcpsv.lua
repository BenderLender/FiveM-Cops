--[[
__________        .__  __   _________             __________                
\______   \_____  |__|/  |_ \_   ___ \_____ ______\______   \_______  ____  
 |    |  _/\__  \ |  \   __\/    \  \/\__  \\_  __ \     ___/\_  __ \/  _ \ 
 |    |   \ / __ \|  ||  |  \     \____/ __ \|  | \/    |     |  | \(  <_> )
 |______  /(____  /__||__|   \______  (____  /__|  |____|     |__|   \____/ 
		\/      \/                  \/     \/                               
		
 -------------------------------------
|		 	 BaitCarPro v1.0		  |
|		  Written by EURoFRA1D		  |
 -------------------------------------

 -------------------------------------
|	  **  DO NOT REDISTRIBUTE  **     |
|   **  DO NOT REMOVE MY CREDITS  **  |
|   ** DO NOT CHANGE FILE NAMES **    |
 -------------------------------------

]]

--------------------------------------
--			     Networking		   	--		
--------------------------------------

   RegisterServerEvent("netDisable")
   AddEventHandler("netDisable", function(bcnetid, target)
      TriggerClientEvent('disableBaitCar', target, bcnetid)
   end)

   RegisterServerEvent("netUnlock")
   AddEventHandler("netUnlock", function(bcnetid, target)
      TriggerClientEvent('unlockBaitCar', target, bcnetid)
   end)

   RegisterServerEvent("netRearm")
   AddEventHandler("netRearm", function(bcnetid, target)
      TriggerClientEvent('rearmBaitCar', target, bcnetid)
   end)

   RegisterServerEvent("netReset")
   AddEventHandler("netReset", function(bcnetid, target)
      TriggerClientEvent('resetBaitCar', -1)
   end)

--------------------------------------
--			  Permission Check			--		
--------------------------------------

   -- RegisterServerEvent("BaitCarPro.getIsAllowed")
   -- AddEventHandler("BaitCarPro.getIsAllowed", function()
   --    if IsPlayerAceAllowed(source, "BaitCarPro.open_menu") then
   --       TriggerClientEvent("BaitCarPro.returnIsAllowed", source, true)
   --    else
   --       TriggerClientEvent("BaitCarPro.returnIsAllowed", source, false)
   --    end
   -- end)