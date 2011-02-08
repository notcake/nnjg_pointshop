local Player = FindMetaTable("Player")

function Player:PS_SetPoints(num)
	self:SetPData("PointShop_Points", num)
	self:PS_UpdatePoints()
end

function Player:PS_GetPoints(num)
	return self:GetPData("PointShop_Points") or 0
end

function Player:PS_GivePoints(num, reason)
	local p = self:GetPData("PointShop_Points") or 0
	self:PS_SetPoints(p + num)
	
	if reason then reason = " (" .. reason .. ")" else reason = "" end
	self:PS_Notify('+' .. num .. ' points!' .. reason)
	
	return p + num
end

function Player:PS_TakePoints(num, reason)
	local p = self:GetPData("PointShop_Points") or 0
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

function Player:PS_GiveItem(item_id, buy)
	if not self:PS_HasItem(item_id) then
		table.insert(self.Items, item_id)
		
		self:PS_UpdateItems()
		
		local item = POINTSHOP.FindItemByID(item_id)
		
		if item.Functions and item.Functions.OnGive then
			item.Functions.OnGive(self, item)
		end
		
		if buy then
			self:PS_TakePoints(item.Cost, "bought " .. item.Name)
			self:PS_ShowShop(false)
			timer.Simple(0.1, function() self:PS_ShowShop(true) end)
		end
		
		return true
	end
	
	return false
end

function Player:PS_TakeItem(item_id, sell)
	if self:PS_HasItem(item_id) then
		for id, name in pairs(self.Items) do
			if name == item_id then
				table.remove(self.Items, id)
			end
		end
		
		self:PS_UpdateItems()
		
		local item = POINTSHOP.FindItemByID(item_id)
		
		if item.Functions and item.Functions.OnTake then
			item.Functions.OnTake(self, item)
		end
		
		if sell then
			self:PS_GivePoints(POINTSHOP.Config.SellCost(item.Cost), "sold " .. item.Name)
			self:PS_ShowShop(false)
			timer.Simple(0.1, function() self:PS_ShowShop(true) end)
		end
		
		return true
	end
	
	return false
end

function Player:PS_HasItem(item_id)
	return table.HasValue(self.Items, string.lower(item_id))
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

function Player:PS_UpdateItems()
	self:SetPData("PointShop_Items", glon.encode(self.Items))
	datastream.StreamToClients(self, "PointShop_Items", self.Items)
end

function Player:PS_LoadItems()
	self.Items = POINTSHOP.ValidateItems(glon.decode(self:GetPData("PointShop_Items", {})) or {})
	self:PS_UpdateItems()
end

function Player:PS_ShowShop(bool)	
	umsg.Start("PointShop_Menu", self)
		umsg.Bool(bool)
	umsg.End()
end

function Player:PS_Notify(text)
	umsg.Start("PointShop_Notify", self)
		umsg.String(text)
	umsg.End()
end