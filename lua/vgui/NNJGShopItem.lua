local PANEL = {}
local White = Color (255, 255, 255, 255)

function PANEL:Init ()
	self:SetTall (72)
	
	self.BackgroundColor = Color (64, 64, 64, 255)
	
	self.ItemName = vgui.Create ("DLabel", self)
	self.ItemName:SetTextColor (White)
	self.ItemName:SetFont ("DefaultBold")
	
	self.Description = vgui.Create ("DLabel", self)
	
	self.Buy = vgui.Create ("NNJGShopButton", self)
	self.Buy:SetText ("Buy")
	self.Sell = vgui.Create ("NNJGShopButton", self)
	self.Sell:SetText ("Sell")
	self.Enable = vgui.Create ("NNJGShopButton", self)
	self.Enable:SetText ("Enable")
	self.Respawn = vgui.Create ("NNJGShopButton", self)
	self.Respawn:SetText ("Respawn")
	
	self.Buy.DoClick = function (button)
		RunConsoleCommand ("pointshop_buy", self.ItemID)
	end
	self.Sell.DoClick = function (button)
		RunConsoleCommand ("pointshop_sell", self.ItemID)
	end
	self.Enable.DoClick = function (button)
		self.WasDisabled = LocalPlayer ():PS_IsItemDisabled (self.ItemID)
		self:WaitForStateChange ()
		if LocalPlayer ():PS_IsItemDisabled (self.ItemID) then
			RunConsoleCommand ("pointshop_enable", self.ItemID)
		else
			RunConsoleCommand ("pointshop_disable", self.ItemID)
		end
	end
	self.Respawn.DoClick = function (button)
		RunConsoleCommand ("pointshop_respawn", self.ItemID)
	end
	
	self.Icon = vgui.Create ("NNJGShopIcon", self)

	self.ItemID = nil
	self.Item = nil
end

function PANEL:CanBuy (assumeEnoughMoney)
	assumeEnoughMoney = assumeEnoughMoney or false
	if LocalPlayer ():PS_GetItemCount (self.ItemID) >= self.Item.Maximum then
		return false
	end
	if self.Item.Functions and self.Item.Functions.CanPlayerBuy and not self.Item.Functions.CanPlayerBuy (LocalPlayer ()) then
		return false
	end
	if not assumeEnoughMoney and LocalPlayer ():PS_GetPoints () < self.Item.Cost then
		return false
	end
	return true
end

function PANEL:CanRespawn ()
	if LocalPlayer ():PS_GetItemCount (self.ItemID) == 0 then
		return false
	end
	if self.Item.HideInInventory then
		return false
	end
	if self.Item.Respawnable then
		return true
	end
	return false
end

function PANEL:CanSell ()
	if self.Item.HideInInventory then
		return false
	end
	if LocalPlayer ():PS_GetItemCount (self.ItemID) == 0 then
		return false
	end
	return true
end

function PANEL:GetItem ()
	return self.Item
end

function PANEL:GetItemID ()
	return self.ItemID
end

function PANEL:GetItemName ()
	if LocalPlayer ():PS_GetItemCount (self.ItemID) > 0 and self.Item.Functions.GetName then
		return self.Item.Functions.GetName (LocalPlayer (), self.Item)
	end
	return self.Item.Name
end

function PANEL:GetItemSellPrice ()
	return POINTSHOP.Config.SellCost (self.Item.Cost) * math.max (1, LocalPlayer ():PS_GetItemCount (self.ItemID))
end

function PANEL:Paint ()
	draw.RoundedBox (4, 0, 0, self:GetWide (), self:GetTall (), Color (160, 160, 160, 255))
	draw.RoundedBox (4, 1, 1, self:GetWide () - 2, self:GetTall () - 2, self.BackgroundColor)
end

function PANEL:PerformLayout ()
	self.ItemName:SetPos (72, 4)
	self.ItemName:SetWide (self:GetWide () - 80)
	
	self.Icon:SetPos (4, 4)
	self.Icon:SetSize (64, 64)
	
	self.Description:SetPos (72, 24)
	self.Description:SetWide (self:GetWide () - 80)
	
	self.Buy:SetSize (64, 20)
	self.Buy:SetPos (72, self:GetTall () - 4 - self.Buy:GetTall ())
	self.Sell:SetSize (64, 20)
	self.Sell:SetPos (72 + self.Buy:GetWide () + 4, self:GetTall () - 4 - self.Sell:GetTall ())
	self.Enable:SetSize (64, 20)
	self.Enable:SetPos (72 + self.Buy:GetWide () + 4 + self.Sell:GetWide () + 4, self:GetTall () - 4 - self.Enable:GetTall ())
	self.Respawn:SetSize (64, 20)
	self.Respawn:SetPos (72 + self.Buy:GetWide () + 4 + self.Sell:GetWide () + 4 + self.Enable:GetWide () + 4, self:GetTall () - 4 - self.Respawn:GetTall ())
end

function PANEL:SetItem (itemID, item)
	self.ItemID = itemID
	self.Item = item
	
	if self.Item.Model then
		self.Icon:SetModel (self.Item.Model)
	elseif self.Item.Material then
		self.Icon:SetMaterial (self.Item.Material)
	end
	
	self.Description:SetText (self.Item.Description)
	self.Buy:SetText ("Buy: " .. tostring (self.Item.Cost))
	
	self:Update ()
end

function PANEL:Think ()
	if self.WaitingForStateChange then
		self:WaitForStateChange ()
	end
end

function PANEL:Update ()
	self.ItemName:SetText (self:GetItemName ())
	
	if LocalPlayer ():PS_HasItem (self.ItemID) then
		if LocalPlayer ():PS_IsItemDisabled (self.ItemID) then
			self.BackgroundColor = Color (64, 64, 68, 255)
		else
			self.BackgroundColor = Color (64, 64, 72, 255)
		end
	else
		if self:CanBuy (false) then
			self.BackgroundColor = Color (64, 64, 64, 255)
		else
			self.BackgroundColor = Color (68, 64, 64, 255)
		end
	end
	if self:CanBuy (false) then
		self.Buy:SetDisabled (false)
	else
		self.Buy:SetDisabled (true)
	end
	
	if self:CanBuy (true) then
		self:SetVisible (true)
	else
		if self.Item.HideInInventory then
			self:SetVisible (false)
		end
	end
	
	if self:CanSell () then
		self.Sell:SetText ("Sell: " .. tostring (self:GetItemSellPrice ()))
		self.Sell:SetDisabled (false)
		self.Sell:SetVisible (true)
	else
		self.Sell:SetDisabled (true)
		self.Sell:SetVisible (false)
	end
	
	if LocalPlayer ():PS_GetItemCount (self.ItemID) > 0 then
		self.Enable:SetDisabled (false)
		self.Enable:SetVisible (true)
		if self.Item.HideInInventory then
			self.Enable:SetVisible (false)
		end
		if LocalPlayer ():PS_IsItemDisabled (self.ItemID) then
			self.Enable:SetText ("Enable")
		else
			self.Enable:SetText ("Disable")
		end
	else
		self.Enable:SetDisabled (true)
		self.Enable:SetVisible (false)
	end
	
	if self:CanRespawn () then
		self.Respawn:SetDisabled (false)
		self.Respawn:SetVisible (true)
	else
		self.Respawn:SetDisabled (true)
		self.Respawn:SetVisible (false)
	end
end

function PANEL:WaitForStateChange ()
	self.WaitingForStateChange = true
	if LocalPlayer ():PS_IsItemDisabled (self.ItemID) ~= self.WasDisabled then
		self:Update ()
		self.WaitingForStateChange = false
	end
end

vgui.Register ("NNJGShopItem", PANEL, "DPanel")