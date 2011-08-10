local Player = FindMetaTable("Player")

function Player:PS_SetPoints(num)
	self:SetPData("PointShop_Points", num)
	self:PS_UpdatePoints()
end

function Player:PS_GetPoints(num)
	return tonumber(self:GetPData("PointShop_Points")) or 0
end

function Player:PS_GivePoints(num, reason)
	local p = tonumber(self:GetPData("PointShop_Points")) or 0
	self:PS_SetPoints(p + num)
	
	if reason then reason = " (" .. reason .. ")" else reason = "" end
	self:PS_Notify('+' .. num .. ' points!' .. reason)
	
	return p + num
end

function Player:PS_TakePoints(num, reason)
	local p = tonumber(self:GetPData("PointShop_Points")) or 0
	if p - num < 0 then num = 0 end
	self:PS_SetPoints(p - num)
	
	if reason then reason = " (" .. reason .. ")" else reason = "" end
	self:PS_Notify('-' .. num .. ' points!' .. reason)
	
	return p - num
end

function Player:PS_UpdatePoints()
	umsg.Start("PointShop_Points", self)
		umsg.Long(self:PS_GetPoints())
	umsg.End()
end

function Player:PS_CanAfford(item_id)
	if not item_id then return false end
	
	local item = POINTSHOP.FindItemByID(item_id)
	if not item then return end
	
	return self:PS_GetPoints() - item.Cost >= 0
end

function Player:PS_GiveItem(item_id, buy, count)
	local count = count or 1
	if self:PS_GetItemCount(item_id) < POINTSHOP.FindItemByID (item_id).Maximum then
		if self:PS_GetItemCount(item_id) < 1 then
			table.insert(self.Items, item_id)
		end
		self.ItemCounts[item_id] = (self.ItemCounts[item_id] or 0) + count
		
		self:PS_SaveItems()
		self:PS_UpdateItem(item_id)
		
		local item = POINTSHOP.FindItemByID(item_id)
		
		if not item then return end
		
		if item.Functions and item.Functions.OnGive then
			item.Functions.OnGive(self, item, count)
		end
		
		if buy then
			if item.Functions.OnBuy then
				item.Functions.OnBuy(self, item)
			end
		
			self:PS_TakePoints(item.Cost, "bought " .. item.Functions.GetName(self, item))
			self:PS_UpdateShop()
		end
		
		return true
	end
	
	return false
end

function Player:PS_TakeItem(item_id, sell, count)
	count = count or 1
	if self:PS_HasItem(item_id) then
		local item = POINTSHOP.FindItemByID(item_id)
		local name = item and item.Functions.GetName(self, item) or item_id
		
		-- cannot sell items which are not visible in inventory
		if item and item.HideInInventory and sell then
			return false
		end
		
		count = count <= self.ItemCounts[item_id] and count or self.ItemCounts[item_id]
		self.ItemCounts[item_id] = self.ItemCounts[item_id] - count
		if self.ItemCounts[item_id] < 1 then
			for id, name in pairs(self.Items) do
				if name == item_id then
					table.remove(self.Items, id)
				end
			end
			self.ItemCounts[item_id] = nil
			self.DisabledItems[item_id] = nil
		end
		
		self:PS_SaveItems()
		self:PS_UpdateItem(item_id)
		
		if not item then return end
		
		if item.Functions and item.Functions.OnTake then
			item.Functions.OnTake(self, item)
		end
		
		if sell then
			self:PS_GivePoints(POINTSHOP.Config.SellCost(item.Cost) * count, "sold " .. name)
			self:PS_UpdateShop()
		end
		
		return true
	end
	
	return false
end

function Player:PS_HasItem(item_id)
	if not self.Items then
		self:PS_LoadItems()
	end
	return table.HasValue(self.Items, item_id)
end

function Player:PS_GetItemCount(item_id)
	if not self.ItemCounts[item_id] and self:PS_HasItem(item_id) then
		self.ItemCounts[item_id] = 1
	end
	return self.ItemCounts[item_id] or 0
end

function Player:PS_DisableItem(item_id)
	if not self:PS_HasItem(item_id) then
		return
	end
	if self:PS_IsItemDisabled(item_id) then
		return
	end
	
	self.DisabledItems[item_id] = true
	
	local item = POINTSHOP.FindItemByID(item_id)
	if not item then return end
	
	if item.Functions then
		if item.Functions.OnTake then
			item.Functions.OnTake(self, item)
		end
		if item.Functions.OnDisable then
			item.Functions.OnDisable(self, item)
		end
	end
	
	self:PS_SaveDisabledItems()
	self:PS_UpdateItem(item_id)
end

function Player:PS_EnableItem(item_id)
	if not self:PS_HasItem(item_id) then
		return
	end
	if not self:PS_IsItemDisabled(item_id) then
		return
	end
	
	self.DisabledItems[item_id] = nil
	
	local item = POINTSHOP.FindItemByID(item_id)
	if not item then return end
	
	if item.Functions then
		if item.Functions.OnGive then
			item.Functions.OnGive(self, item, self:PS_GetItemCount(item_id))
		end
		if item.Functions.OnEnable then
			item.Functions.OnEnable(self, item)
		end
	end
	
	self:PS_SaveDisabledItems()
	self:PS_UpdateItem(item_id)
end

function Player:PS_IsItemDisabled(item_id)
	return self.DisabledItems[item_id] or false
end

function Player:PS_NumItemsFromCategory(category)
	local num = 0
	for item_id, item in pairs(category.Items) do
		if table.HasValue(self.Items, item_id) then
			num = num + 1
		end
	end
	return num
end

function Player:PS_SaveItems()
	self:SetPData("PointShop_Items", glon.encode(self.Items))
	self:SetPData("PointShop_ItemCounts", glon.encode(self.ItemCounts))
	self:SetPData("PointShop_DisabledItems", glon.encode(self.DisabledItems))
end

function Player:PS_SaveDisabledItems()
	self:SetPData("PointShop_DisabledItems", glon.encode(self.DisabledItems))
end

function Player:PS_UpdateItems()
	self:PS_SaveItems()
	datastream.StreamToClients(self, "PointShop_Items", self.Items)
	datastream.StreamToClients(self, "PointShop_ItemCounts", self.ItemCounts)
	datastream.StreamToClients(self, "PointShop_DisabledItems", self.DisabledItems)
end

function Player:PS_UpdateItem(item_id)
	umsg.Start("PointShop_Item", self)
		umsg.String(item_id)
		umsg.Long(self:PS_GetItemCount(item_id))
		umsg.Bool(self:PS_IsItemDisabled(item_id))
	umsg.End()
end

function Player:PS_LoadItems()
	self.Items = POINTSHOP.ValidateItems(glon.decode(self:GetPData("PointShop_Items", "\2\1")) or {})
	self.ItemCounts = POINTSHOP.ValidateItemCounts(self, glon.decode(self:GetPData("PointShop_ItemCounts", "\2\1"))) or {}
	self.DisabledItems = glon.decode(self:GetPData("PointShop_DisabledItems", "\2\1")) or {}
end

function Player:PS_ShowShop(bool)	
	umsg.Start("PointShop_Menu", self)
		umsg.Bool(bool)
	umsg.End()
end

function Player:PS_UpdateShop()
	umsg.Start("PointShop_UpdateMenu", self)
	umsg.End()
end

function Player:PS_Notify(text)
	umsg.Start("PointShop_Notify", self)
		umsg.String(text)
	umsg.End()
end

function Player:PS_AddHat(item)
	if not POINTSHOP.Hats[self] then POINTSHOP.Hats[self] = {} end
	POINTSHOP.Hats[self][item.ID] = item.ID
	
	SendUserMessage("PointShop_AddHat", player.GetAll(), self:EntIndex(), item.ID)
end

function Player:PS_RemoveHat(item)
	if not POINTSHOP.Hats[self] then return end
	POINTSHOP.Hats[self][item.ID] = nil
	
	SendUserMessage("PointShop_RemoveHat", player.GetAll(), self:EntIndex(), item.ID)
end

function Player:PS_SendHats()
	for ply, hats in pairs(POINTSHOP.Hats) do
		for _, item_id in pairs(hats) do
			SendUserMessage("PointShop_AddHat", self, ply:EntIndex(), item_id)
		end
	end
end