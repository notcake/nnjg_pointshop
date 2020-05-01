POINTSHOP.Hats = {}

require ("glon")

local KeyToHook = {
	F1 = "ShowHelp",
	F2 = "ShowTeam",
	F3 = "ShowSpare1",
	F4 = "ShowSpare2",
	None = "ThisHookDoesNotExist"
}

debug.getregistry ().Player.IsObserver = function (self)
	return self:GetObserverMode() > OBS_MODE_NONE
end

util.AddNetworkString ("PointShop_Items")
util.AddNetworkString ("PointShop_ItemCounts")
util.AddNetworkString ("PointShop_DisabledItems")

hook.Add("Tick", "PointShop_RemoveObserverHats", function()
	for _, v in ipairs(player.GetAll()) do
		if v.Hat then
			if not v:Alive() or v:IsObserver() then
				SafeRemoveEntity(v.Hat)
				v.Hat = nil
			end
		end
	end
	for _, v in ipairs(ents.FindByClass("pointshop_hat")) do
		local owner = v:GetOwner()
		if owner then
			if not owner:Alive() or owner:IsObserver() then
				SafeRemoveEntity(v)
			end
		end
	end
end)

hook.Add("PlayerDeath", "PointShop_PlayerDeath", function(victim, inflictor, attacker)
	if attacker:IsPlayer() and attacker:IsValid() and GetRoundState() == ROUND_ACTIVE then
		
		if attacker == victim then
			attacker:PS_TakePoints( 1, "Suicide" ) -- Remove 1 point if they kill them self
			return
		end
		
		--if attacker:IsTraitor() != victim:IsTraitor() and ( attacker:IsUserGroup( "vip" ) or attacker:IsAdmin() ) then
		--
		-- pharaohsgroup
		--if attacker:IsTraitor() != victim:IsTraitor() and ( attacker:IsUserGroup( "vip" ) or attacker:IsUserGroup( "operator" ) or attacker:IsAdmin() ) then
		if attacker:IsTraitor() != victim:IsTraitor() and ( attacker:IsUserGroup( "vip" ) or attacker:IsUserGroup( "operator" ) or attacker:IsAdmin() ) then
			attacker:PS_GivePoints( 2, "Killed " .. victim:Nick() ) -- 2 Point if he kills a enemy and is VIP
			return
		elseif attacker:IsTraitor() != victim:IsTraitor() then
			attacker:PS_GivePoints( 1, "Killed " .. victim:Nick() ) -- 1 Point if he kills a enemy and is not VIP
			return
		end
		
		--if attacker:IsTraitor() == victim:IsTraitor() and ( attacker:IsUserGroup( "vip" ) or attacker:IsAdmin() ) then
		--if attacker:IsTraitor() == victim:IsTraitor() and ( attacker:IsUserGroup( "vip" ) or attacker:IsUserGroup( "operator" ) or attacker:IsAdmin() ) then
			if attacker:IsTraitor() == victim:IsTraitor() and ( attacker:IsUserGroup( "vip" ) or attacker:IsUserGroup( "operator" ) or attacker:IsUserGroup( "pharaohsgroup" ) or attacker:IsAdmin() ) then
			attacker:PS_TakePoints( 1, "Team killed " .. victim:Nick() ) -- Remove 1 point if its team kill and VIP
			return
		elseif attacker:IsTraitor() == victim:IsTraitor() then
			attacker:PS_TakePoints( 2, "Team killed " .. victim:Nick() ) -- Remove 2 point if its team kill and not VIP
			return
		end
		
	end
	
end)

hook.Add(KeyToHook[POINTSHOP.Config.ShopKey], "PointShop_ShopKey", function(ply)
	--if ply:Alive() and not ply:IsObserver() then
		ply:PS_ShowShop(true)
	--else
		--ply:PS_Notify("You can only use the shop while you're alive!")
	--end
end)

hook.Add("PlayerInitialSpawn", "PointShop_PlayerInitialSpawn", function(ply)
	ply:PS_LoadItems()
	timer.Simple(1, function()
		ply:PS_UpdatePoints()
		ply:PS_UpdateItems()
		ply:PS_SendHats()
	end)
	
	if POINTSHOP.Config.PointsTimer then
		local uid = ply:UniqueID()
		timer.Create("PointShop_" .. uid, 60 * POINTSHOP.Config.PointsTimerDelay, 0, function()
			if not ply or not ply:IsValid() then
				timer.Destroy("PointShop_" .. uid)
			end
			ply:PS_GivePoints(POINTSHOP.Config.PointsTimerAmount, POINTSHOP.Config.PointsTimerDelay .. " minutes on server")
		end)
	end
	
	if POINTSHOP.Config.ShopNotify then
		ply:PS_Notify('You have ' .. ply:PS_GetPoints() .. ' points to spend! Press ' .. POINTSHOP.Config.ShopKey .. ' to open the Shop!')
	end
end)

hook.Add("DoPlayerDeath", "PointShop_CloseShop", function(ply)
	-- ply:PS_ShowShop(false)
end)

local Scammers = { "STEAM_0:1:32333637" }

-- Point trading
hook.Add("PlayerSay", "PointShop_Give", function(ply, text)
	text = text:lower():gsub("[ ]+", " ")
	local bits = string.Explode(" ", text)
	if bits[1] == "!give" or bits[1] == "/give" then
		if not bits[2] then
			ply:PS_Notify("You need to specify a player to give points to.")
			return
		end
		if not bits[3] then
			ply:PS_Notify("You need to specify the number of points you want to give out.")
			return
		end
		local name = bits[2]:lower()
		local amount = tonumber(bits[3] or 0)
		local found = 0
		local targetply = nil
		for _, v in ipairs(player.GetAll()) do
			if v:Name():lower():find(name) then
				targetply = v
				found = found + 1
			end
		end
		if found == 0 then
			ply:PS_Notify("There are no players with that name.")
			return
		elseif found > 1 then
			ply:PS_Notify("There's more than one player with that name.")
			return
		end
		if not amount or amount <= 0 then
			ply:PS_Notify("That's not a valid number of points to give.")
			return
		elseif amount > ply:PS_GetPoints() then
			ply:PS_Notify("You don't have that many points to give out.")
			return
		end
		if not table.HasValue( Scammers, targetply:SteamID() ) then
			ply:PS_TakePoints(amount, "sent to " .. targetply:Name())
			targetply:PS_GivePoints(amount, "gift from " .. ply:Name())
			return ""
		else
			ply:PS_Notify( targetply:Nick().." has been blacklisted from receiving points through !give." )
			return ""
		end
	end
end)

for id, category in pairs(POINTSHOP.Items) do
	if category.Enabled then
		if category.Hooks then
			for name, func in pairs(category.Hooks) do
				hook.Add(name, "PointShop_Category_" .. category.Name .. "_" .. name, function(ply, ...) -- Pass any arguments through.
					for item_id, item in pairs(category.Items) do
						if ply:PS_HasItem(item_id) and not ply:PS_IsItemDisabled(item_id) then -- only run the hook if the player actually has this item.
							return func(ply, item, unpack({...}))
						end
					end
				end)
			end
		end
		for item_id, item in pairs(category.Items) do
			if item.Enabled then
				if category.ConstantHooks then
					item.ConstantHooks = item.ConstantHooks or {}
					for name, func in pairs(category.ConstantHooks) do
						item.ConstantHooks[name] = item.ConstantHooks[name] or func
					end
				end
				if item.Hooks then
					for name, func in pairs(item.Hooks) do
						hook.Add(name, "PointShop_" .. item_id .. "_" .. name, function(ply, ...) -- Pass any arguments through.
							if ply:PS_HasItem(item_id) and not ply:PS_IsItemDisabled(item_id) then -- only run the hook if the player actually has this item.
								if category.PreHooks and category.PreHooks[name] then
									category.PreHooks[name](ply, item, unpack({...}))
								end
								return func(ply, item, unpack({...}))
							end
						end)
					end
				end
				if item.ConstantHooks then
					for name, func in pairs(item.ConstantHooks) do
						hook.Add(name, "PointShop_" .. item_id .. "_Constant_" .. name, function(ply, ...) -- Pass any arguments through.
							item.ID = item_id
							return func(ply, item, unpack({...}))
						end)
					end
				end
				if category.Functions then
					for name, func in pairs(category.Functions) do
						if item.Functions[name] then
							local itemfunc = item.Functions[name]
							item.Functions[name] = function(...)
								local r1, r2, r3, r4 = itemfunc(...)
								func(...)
								return r1, r2, r3, r4
							end
						else
							item.Functions[name] = func
						end
					end
				end
			end
		end
	end
end

concommand.Add("pointshop_buy", function(ply, cmd, args)
	local item_id = args[1]
	if not item_id then return end
	if not ply:Alive() or ply:IsObserver() then ply:PS_Notify('You must be alive to use the shop!') return end
	
	local item = POINTSHOP.FindItemByID(item_id)
	if not item then return end
	
	if ply:PS_HasItem(item_id) and item.Maximum == 1 then
		ply:PS_Notify('You already have this item!')
		return
	end
	if ply:PS_GetItemCount(item_id) >= item.Maximum then
		ply:PS_Notify('You can\'t buy any more of this item!')
		return
	end
	
	local category = POINTSHOP.FindCategoryByItemID(item_id)
	
	if not item.Enabled then
		ply:PS_Notify('This item isn\'t enabled!')
		return
	end
	
	if not category.Enabled then
		ply:PS_Notify('The category ' .. category.Name .. 'is not enabled!')
		return
	end
	
	if item.Donator and not ply:IsVIP() then
		ply:PS_Notify('You must be a VIP to buy this item!')
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
	if category.NumAllowedEnabledItems and ply:PS_NumEnabledItemsFromCategory(category) > category.NumAllowedEnabledItems then
		ply:PS_DisableItem(item_id)
		return
	end
end)

concommand.Add("pointshop_sell", function(ply, cmd, args)
	local item_id = args[1]
	if not item_id then return end
	if not ply:Alive() or ply:IsObserver() then ply:PS_Notify('You must be alive to use the shop!') return end
	
	if not ply:PS_HasItem(item_id) then return end
	
	ply:PS_TakeItem(item_id, true, ply:PS_GetItemCount(item_id))
end)

concommand.Add("pointshop_disable", function(ply, cmd, args)
	local item_id = args[1]
	if not item_id then return end
	if not ply:Alive() or ply:IsObserver() then ply:PS_Notify('You must be alive to use the shop!') return end
	
	ply:PS_DisableItem(item_id)
end)

concommand.Add("pointshop_enable", function(ply, cmd, args)
	local item_id = args[1]
	if not item_id then return end
	if not ply:Alive() or ply:IsObserver() then ply:PS_Notify('You must be alive to use the shop!') return end
	
	local item = POINTSHOP.FindItemByID(item_id)
	if not item then return end
	
	local category = POINTSHOP.FindCategoryByItemID(item_id)
	if category.NumAllowedEnabledItems and ply:PS_NumEnabledItemsFromCategory(category) >= category.NumAllowedEnabledItems then
		ply:PS_Notify('You can only have ' .. category.NumAllowedEnabledItems .. ' equipped items from the ' .. category.Name .. ' category!')
		return
	end
	
	ply:PS_EnableItem(item_id)
end)

concommand.Add("pointshop_respawn", function(ply, cmd, args)
	local item_id = args[1]
	if not item_id then return end
	if not ply:Alive() or ply:IsObserver() then return end
	
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

--[[
concommand.Add("ps_givepoints", function(ply, cmd, args)
	-- Give Points
	if not ply:IsAdmin() then return end
	
	local to_give = POINTSHOP.FindPlayerByName(args[1])
	local num = tonumber(args[2])
	
	if not to_give or not num then
		ply:PS_Notify("Please give a name and number!")
		return
	end
	
	if not type(to_give) == "player" then
		if to_give then
			ply:PS_Notify("You weren't specific enough with the name you typed!")
		else
			ply:PS_Notify("No player found by that name!")
		end
	else
		to_give:PS_GivePoints(num, "given by " .. ply:Nick() .. "!")
		to_give:PS_UpdateShop()
	end
end)

concommand.Add("ps_takepoints", function(ply, cmd, args)
	-- Take Points
	if not ply:IsAdmin() then return end
	
	local to_take = POINTSHOP.FindPlayerByName(args[1])
	local num = tonumber(args[2])
	
	if not to_take or not num then
		ply:PS_Notify("Please give a name and number!")
		return
	end
	
	if not type(to_take) == "player" then
		if to_take then
			ply:PS_Notify("You weren't specific enough with the name you typed!")
		else
			ply:PS_Notify("No player found by that name!")
		end
	else
		to_take:PS_TakePoints(num, "taken by " .. ply:Nick() .. "!")
		to_take:PS_UpdateShop()
	end
end)

concommand.Add("ps_setpoints", function(ply, cmd, args)
	-- Set Points
	if not ply:IsAdmin() then return end
	
	local to_set = POINTSHOP.FindPlayerByName(args[1])
	local num = tonumber(args[2])
	
	if not to_set or not num then
		ply:PS_Notify("Please give a name and number!")
		return
	end
	
	if not type(to_set) == "player" then
		if to_set then
			ply:PS_Notify("You weren't specific enough with the name you typed!")
		else
			ply:PS_Notify("No player found by that name!")
		end
	else
		to_set:PS_SetPoints(num)
		to_set:PS_Notify("Points set to " .. num .. " by " .. ply:Nick() .. "!")
		to_set:PS_UpdateShop()
	end
end)
]]