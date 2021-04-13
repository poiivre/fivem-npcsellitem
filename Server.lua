-------------------------
--- Declaration d'ESX ---
-------------------------

ESX  = nil TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

----------------------
--- Register Event ---
----------------------

ESX.RegisterServerCallback('seln_SellItem:recupInventaire', function(source, cb)
  	local xPlayer = ESX.GetPlayerFromId(source)
  	local items   = xPlayer.inventory
  	local accounts =  nil
  	local data  = nil

  	cb({items = items})
end)



RegisterServerEvent("seln_SellItem:checkInventaire")
AddEventHandler("seln_SellItem:checkInventaire", function(Notif)
  	if possedeItems() then
    		TriggerClientEvent("seln_SellItem:OuvrirInventaire", source)
 	else 		TriggerClientEvent('esx:showAdvancedNotification', source, '[ Ventes ]', Notif, nil, 'CHAR_BIKESITE', 0)
	end
end)

RegisterServerEvent("seln_SellItem:VendreItem")
AddEventHandler("seln_SellItem:VendreItem", function(item, Prix, Notif, Combien, Sale)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getInventoryItem(item).count > Combien then
		xPlayer.removeInventoryItem(item, Combien)
		Prix = Prix*Combien

		if Sale == false then 		xPlayer.addMoney(Prix)
		else				xPlayer.addAccountMoney('black_money', Prix)
		end
			
		local itemlabel = ESX.GetItemLabel(item)
		Notif = Combien..Notif..Prix
 		TriggerClientEvent('esx:showAdvancedNotification', source, '[ Ventes ]', Notif, nil, 'CHAR_BIKESITE', 0)

	else 
		Combien = xPlayer.getInventoryItem(item).count

		xPlayer.removeInventoryItem(item, Combien)
		Prix = Prix*Combien
		xPlayer.addMoney(Prix)
	
		local itemlabel = ESX.GetItemLabel(item)

		Notif = Combien..' '..itemlabel..Notif..Prix

 		TriggerClientEvent('esx:showAdvancedNotification', source, '[ Ventes ]', Notif, nil, 'CHAR_BIKESITE', 0)

	end
	
end)


RegisterServerEvent('seln_SellItem:AlertePolice')
AddEventHandler('seln_SellItem:AlertePolice', function(serverid)
	_source  = source
	xPlayer  = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			TriggerClientEvent('seln_SellItem:PhotoMugshot', xPlayers[i], serverid)
		end		
	end
end)

---------------
-- Fonctions --
---------------

function possedeItems()
  	local xPlayer = ESX.GetPlayerFromId(source)
  	local possede = false

  	for i,v in ipairs(Config.Items) do
    		if xPlayer.getInventoryItem(v.item).count > 0 then possede = true end
  	end

  	if possede then return true else return false end
end

