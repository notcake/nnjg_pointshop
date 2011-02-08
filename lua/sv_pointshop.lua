KeyToHook = {
	F1 = "ShowHelp",
	F2 = "ShowTeam",
	F3 = "ShowSpare1",
	F4 = "ShowSpare2"
}

local meta = FindMetaTable("Player")
function meta:IsObserver()

	return ( self:GetObserverMode() > OBS_MODE_NONE )
	
end

hook.Add("Tick", "PointShop_RemoveTrial", function()
	for k, v in pairs( player.GetAll() ) do
		if v.Trail then
			if !v:Alive() or v:IsObserver() then
				SafeRemoveEntity( v.Trail )
				v.Trail = nil
			end
		end
		
		if v.Hat then
			if !v:Alive() or v:IsObserver() then
				SafeRemoveEntity( v.Hat )
				v.Hat = nil
			end
		end
	end
end)

hook.Add("PlayerDeath", "PointShop_PlayerDeath", function(victim, inflictor, attacker)
	if attacker:IsPlayer() and attacker:IsValid() then
		
		if attacker == victim then
			attacker:PS_TakePoints( 1, "Suicide" ) -- Remove 1 point if they kill them self
			return
		end
		
		if attacker:IsTraitor() != victim:IsTraitor() and ( attacker:IsUserGroup( "vip" ) or attacker:IsAdmin() ) then
			attacker:PS_GivePoints( 2, "Killed " .. victim:Nick() ) -- 2 Point if he kills a enemy and is VIP
			return
		elseif attacker:IsTraitor() != victim:IsTraitor() then
			attacker:PS_GivePoints( 1, "Killed " .. victim:Nick() ) -- 1 Point if he kills a enemy and is not VIP
			return
		end
		
		if attacker:IsTraitor() == victim:IsTraitor() and ( attacker:IsUserGroup( "vip" ) or attacker:IsAdmin() ) then
			attacker:PS_TakePoints( 1, "Team killed " .. victim:Nick() ) -- Remove 1 point if its team kill and VIP
			return
		elseif attacker:IsTraitor() == victim:IsTraitor() then
			attacker:PS_TakePoints( 2, "Team killed " .. victim:Nick() ) -- Remove 2 point if its team kill and not VIP
			return
		end
		
	end
	
end)

hook.Add(KeyToHook[POINTSHOP.Config.ShopKey], "PointShop_ShopKey", function(ply)
	ply:PS_ShowShop(true)
end)

hook.Add("PlayerInitialSpawn", "PointShop_PlayerInitialSpawn", function(ply)
	ply.Points = 0
	ply.Items = {}
	
	timer.Simple(1, function()
		ply:PS_UpdatePoints()
		ply:PS_LoadItems()
	end)
	
	if POINTSHOP.Config.PointsTimer then
		timer.Create("PointShop_" .. ply:UniqueID(), 60 * POINTSHOP.Config.PointsTimerDelay, 0, function(ply)
			ply:PS_GivePoints(POINTSHOP.Config.PointsTimerAmount, POINTSHOP.Config.PointsTimerDelay .. " minutes on server")
		end, ply)
	end
	
	if POINTSHOP.Config.ShopNotify then
		ply:PS_Notify('You have ' .. ply:PS_GetPoints() .. ' points to spend! Press ' .. POINTSHOP.Config.ShopKey .. ' to open the Shop!')
	end
end)

-- Add a hook for each hook in each item.
hook.Add( "InitPostEntity", "LetsTryThisShallWe", function()
	for id, category in pairs(POINTSHOP.Items) do
		if category.Enabled then
			for item_id, item in pairs(category.Items) do
				if item.Enabled then
					if item.Hooks then
						for name, func in pairs(item.Hooks) do
							hook.Add(name, "PointShop_" .. item_id .. "_" .. name, function(ply, ...) -- Pass any arguments through.
								if ply:PS_HasItem(item_id) then -- only run the hook if the player actually has this item.
									item.ID = item_id -- Pass the ID incase it's needed in the hook.
									return func(ply, item, unpack({...}))
								end
							end)
						end
					end
					
					if item.ConstantHooks then
						for name, func in pairs(item.ConstantHooks) do
							hook.Add(name, "PointShop_" .. item_id .. "_Contant_" .. name, function(ply, ...) -- Pass any arguments through.
								return func(ply, item, unpack({...}))
							end)
						end
					end
					
					if item.Model then
						resource.AddFile(item.Model)
					end
				end
			end
		end
	end
end)

concommand.Add("pointshop_buy", function(ply, cmd, args)
	local item_id = args[1]
	if not item_id then return end
	
	if ply:PS_HasItem(item_id) then
		ply:PS_Notify('You already have this item!')
		return
	end
	
	local item = POINTSHOP.FindItemByID(item_id)
	if not item then return end
	
	local category = POINTSHOP.FindCategoryByItemID(item_id)
	
	if not item.Enabled then
		ply:PS_Notify('This item isn\'t enabled!')
		return
	end
	
	if not category.Enabled then
		ply:PS_Notify('The category ' .. category.Name .. 'is not enabled!')
		return
	end
	
	if item.AdminOnly and not ply:IsAdmin() then
		ply:PS_Notify('Only admins can buy this item!')
		return
	end
	
	if item.Functions and item.Functions.CanPlayerBuy then
		local canbuy, reason = item.Functions.CanPlayerBuy(ply)
		if not canbuy then
			ply:PS_Notify('Can\'t buy item (' .. reason .. ')')
			return
		end
	end
	
	if category.NumAllowedItems and ply:PS_NumItemsFromCategory(category) >= category.NumAllowedItems then -- More than would never happen, but just incase.
		ply:PS_Notify('You can only have ' .. category.NumAllowedItems .. ' items from the ' .. category.Name .. ' category!')
		return
	end
	
	if not ply:PS_CanAfford(item_id) then
		ply:PS_Notify('You can\'t afford this!')
		return
	end
	
	if item.Respawnable and item.Respawnable >= 0 then
		ply:SetPData("PS_" .. item_id .. "_Respawns", item.Respawnable)
	end
	
	ply:PS_GiveItem(item_id, true)
end)

concommand.Add("pointshop_sell", function(ply, cmd, args)
	local item_id = args[1]
	if not ply:Alive() then return end
	if not item_id then return end
	
	if not ply:PS_HasItem(item_id) then return end
	
	ply:PS_TakeItem(item_id, true)
end)

concommand.Add("pointshop_respawn", function(ply, cmd, args)
	local item_id = args[1]
	if not item_id then return end
	
	if not ply:PS_HasItem(item_id) then return end
	
	local item = POINTSHOP.FindItemByID(item_id)
	if not item then return end
	
	if not item.Respawnable then return end
	
	local respawns
	
	if item.Respawnable >= 0 then
		respawns = tonumber(ply:GetPData("PS_" .. item_id .. "_Respawns") or item.Respawnable)
	
		if respawns == 0 then
			ply:PS_Notify("You have no more available respawns of this item!")
			return
		elseif respawns > 0 then
			ply:PS_Notify("You have " ..respawns .. " more available respawns of this item!")
		end
	end
	
	if item.Functions and item.Functions.Respawn then
		item.Functions.Respawn(ply, item)
		if item.Respawnable > 0 then
			ply:SetPData("PS_" .. item_id .. "_Respawns", respawns - 1)
		end
	end
end)