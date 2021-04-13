

--[[	GitHub : Selene-Desna	  ]]--

--	If you need help editing 
--	this script, contact me on 
--	my github or add an issue
--	in the github script page

--	Si vous avez besoin d'aide
--	pour modifier ce script
--	contacter moi sur github
--	ou créez une issue sur la 
--	page github du script


-----------------
--- Variables ---
-----------------

local Chance = 4
local Notif1 = ' Vendu pour $'
local Notif2 = '~r~Personne Ã  ProximitÃ©e'
local Notif3 = '~r~Vente Impossible en Vehicule'
local Notif4 = '~r~La Personne Ã  refusÃ© !' -- deja acheter
local Notif5 = '~r~La Personne Ã  refusÃ© !' -- appel police
local Notif6 = '~r~Aucun Article'
local Notif7 = '~y~Trafic de StupÃ©fiant en cours !'

BlacklistNPC = {}

-------------------------
--- Declaration d'ESX ---
-------------------------

ESX = nil
Citizen.CreateThread(function()
	Citizen.Wait(5000)

	-- Joueur
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	-- Job
	while ESX.GetPlayerData().job == nil do
        	Citizen.Wait(1000)
   	end

	-- Faction
	while ESX.GetPlayerData().faction == nil do
		Citizen.Wait(100)
	end
	
	PlayerData = ESX.GetPlayerData()
end)

---------------------
--- Thread Client ---
---------------------



Citizen.CreateThread(function()
 	while ESX == nil do Wait(100) end
 	while true do Wait(0)

		-- Ouverture du menu F11 ?
    		if IsControlJustPressed(0, 344) and GetLastInputMethod( 0 ) then
        		TriggerServerEvent("seln_SellItem:checkInventaire", Notif6)	
		
    		end

  	end
end)




----------------------
--- Register Event ---
----------------------

RegisterNetEvent("seln_SellItem:OuvrirInventaire")
AddEventHandler("seln_SellItem:OuvrirInventaire", function() 
	ouvreInventaire() 
end)

RegisterNetEvent('seln_SellItem:PhotoMugshot')
AddEventHandler('seln_SellItem:PhotoMugshot', function(serverid)

	local serverid = GetPlayerPed(GetPlayerFromServerId(serverid))
	local Joueur = GetEntityCoords(serverid,  true)
        local r1, r2 = Citizen.InvokeNative( 0x2EB41072B4C1E4C0, Joueur.x, Joueur.y, Joueur.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
	local rue = GetStreetNameFromHashKey(r1)
        local zone = GetNameOfZone(Joueur.x, Joueur.y, Joueur.z)                                                                              
    	
	ESX.ShowAdvancedNotification('~o~Alerte BCSO :', '~o~['..zone..']', Notif7,  'CHAR_CALL911', 1)


	
	blipscrimescene(Joueur.x, Joueur.y, Joueur.z)
end)


-----------------
--- Fonctions ---
-----------------

function ouvreInventaire()
	local elements = {}

    	ESX.TriggerServerCallback('seln_SellItem:recupInventaire', function(result)

        	for i=1, #result.items, 1 do
        
            	local invitem = result.items[i]
      		
      			for k,v in ipairs(Config.Items) do
      				if invitem.count > 0 and invitem.name == v.item then
                		table.insert(elements, { 	sale = v.sale ,	
								legal = v.legal , 
								itemprix = v.prix ,
								itemlabel = invitem.label ,label = invitem.label ..  '<span></span>|  ' .. invitem.count  , 
								type = "item_standard", 
								count = invitem.count, 
								value = invitem.name 
							})
            		end
      			end
        	end    

        	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'items_show', {
			css = 'Hollidays', 
			title= "Vente Citadine", align = 'right', 
			elements = elements
		}, 	function(data, menu)
					
			local amount 	= tonumber(data.value)
			local item   	= data.current.value
        		local itemLabel	= data.current.itemlabel
			local itemPrix 	= data.current.itemprix
        		local invcount 	= data.current.count
			local itemlegal = data.current.legal
			local itemsale	= data.current.sale
			
			menu.close()
			RechercheNPC(item, itemLabel, itemPrix, itemlegal, itemsale)

        	end,function(data, menu) 
		menu.close() 
        	end)

    	end)
end

function RechercheNPC(item, itemLabel, itemPrix, itemlegal, itemsale )

	local Joueur = GetPlayerPed(-1)
	local Coords    = GetEntityCoords(Joueur)
          
	local NPCproche, distance = ESX.Game.GetClosestPed({
            	x = Coords.x,
            	y = Coords.y,
            	z = Coords.z
	}, {Joueur})


	if distance == -1 then
            
		local success, NPC = GetClosestPed(Coords.x,  Coords.y,  Coords.z,  5.0, 1, 0, 0, 0,  26)

		if DoesEntityExist(NPC) then
              		local 	NPCcoords 	= GetEntityCoords(NPC)
              			NPCproche      	= NPC
              		distance = GetDistanceBetweenCoords(Coords.x,  Coords.y,  Coords.z,  NPCcoords.x,  NPCcoords.y,  NPCcoords.z,  true)
            	end

	end

	-- NPC assez proche du joueur pour continuer ?
	
	if distance <= 3 and NPCproche ~= Joueur then	

		------------------------------------
		-- Conditions Autorisant la Vente --
		------------------------------------

		-- NPC blacklisté ?
		local NPCblacklister = false

              	for i=1, #BlacklistNPC, 1 do if BlacklistNPC[i] == NPCproche then NPCblacklister = true end end
		if NPCblacklister then ESX.ShowAdvancedNotification('[ Action Impossible ]', '~o~[ '..Notif4..' ]', nil , 'CHAR_BLOCKED', 0) else

		-- Joueur ou NPC en voiture ?
		if IsPedInAnyVehicle(Joueur) or IsPedInAnyVehicle(NPCproche) then 
			ESX.ShowAdvancedNotification('[ Action Impossible ]', '~o~[ '..Notif3..' ]', nil , 'CHAR_BLOCKED', 0) SortirVoiture()
		else

		-- NPC Humain ?
		if GetPedType(NPCproche) ~= 28 then

		-- NPC mort ?
		if not IsPedDeadOrDying(NPCproche, 1) then	
	
		-- Item Illégal ? + Alerte Police
		if illegal(itemlegal) then 
	
			local Prix = itemPrix * ( math.random(90,110) / 100 )
			Prix = math.floor(Prix)
			Combien = math.random(1,4)
			TriggerServerEvent("seln_SellItem:VendreItem", item, Prix, Notif1, Combien, itemsale)
			table.insert( BlacklistNPC , NPCproche )
		
		else table.insert( BlacklistNPC , NPCproche )
		end
		else ESX.ShowAdvancedNotification('[ Action Impossible ]', '~o~[ '..Notif4..' ]', nil , 'CHAR_BLOCKED', 0)
		end -- Mort
		else ESX.ShowAdvancedNotification('[ Action Impossible ]', '~o~[ '..Notif4..' ]', nil , 'CHAR_BLOCKED', 0)
		end -- Humain
		end -- Voiture
		end -- Blacklist

	else ESX.ShowAdvancedNotification('[ Action Impossible ]', '~o~[ '..Notif2..' ]', nil , 'CHAR_BLOCKED', 0)

	end

	ouvreInventaire()

end

function illegal(legal)

	if legal then retour = true

	else 

		local random = math.random(1,4)
		if random == 1 then

			
			ESX.ShowAdvancedNotification('[ Action Impossible ]', '~o~[ '..Notif5..' ]', nil , 'CHAR_BLOCKED', 0)
			local serverid = GetPlayerServerId(PlayerId())
			TriggerServerEvent('seln_SellItem:AlertePolice', serverid)
			retour = false

		else retour = true
		end
	end
	return retour
end



function blipscrimescene(gx, gy, gz)
	PlayerData = ESX.GetPlayerData()
	if PlayerData.job ~= nil and PlayerData.job.name == 'police' then
		local transG = 1500
		AlreadyPressed = false
		local Blip = AddBlipForCoord(gx, gy, gz)
		SetBlipSprite(Blip,  161)
		SetBlipColour(Blip,  47)
		SetBlipAlpha(Blip,  transG)
		SetBlipAsShortRange(Blip,  1)

		while transG ~= 0 do
			local AlreadyBlipActive = false
			Wait(10)
				
			if AlreadyPressed == false then
				ESX.ShowHelpNotification('~INPUT_CONTEXT~ Mettre le GPS sur l\'Appel')
				if IsControlJustReleased(0, 38) and GetLastInputMethod( 0 ) then
					AlreadyBlipActive = true
					AlreadyPressed = true
					SetBlipRoute(Blip, true)

					Ppos = GetEntityCoords(GetPlayerPed(-1))
					while AlreadyBlipActive == true do
						Wait(10)
						ESX.ShowHelpNotification('~INPUT_VEH_DROP_PROJECTILE~ Enlever le GPS')
						if IsControlJustReleased(0, 73) and GetLastInputMethod( 0 ) then 
							SetBlipRoute(Blip, false)
							AlreadyBlipActive = false
							transG = 10 
						end
					end
						
				end
			end

			transG = transG - 1
			SetBlipAlpha(Blip,  transG)
			if transG == 0 then
				SetBlipSprite(Blip,  2)
				return
			end		   
		end		
		
	end
end








