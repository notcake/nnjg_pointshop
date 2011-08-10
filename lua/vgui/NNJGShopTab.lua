if POINTSHOP and POINTSHOP.MenuPreviewPanel then
	POINTSHOP.MenuPreviewPanel:Remove ()
	POINTSHOP.MenuPreviewPanel = nil
end

local PANEL = {}
local PreviewOnLeft = true

function PANEL:Init ()
	self.Category = nil
	
	self.PanelList = vgui.Create ("DPanelList", self)
	self.PanelList:EnableVerticalScrollbar (true)
	self.PanelList:SetPadding (4)
	self.PanelList:SetSpacing (4)
	
	if not POINTSHOP.MenuPreviewPanel or not POINTSHOP.MenuPreviewPanel:IsValid () then
		POINTSHOP.MenuPreviewPanel= vgui.Create ("NNJGShopPreview", self)
	end
	self.Preview = POINTSHOP.MenuPreviewPanel
end

function PANEL:GetCategory ()
	return self.Category
end

function PANEL:Paint ()
	local color = Color (55, 57, 61)
	if self.m_Skin and self.m_Skin.bg_color_dark then
		color = self.m_Skin.bg_color_dark
	end
	draw.RoundedBox (4, 0, 0, self:GetWide (), self:GetTall (), color)
end

function PANEL:PerformLayout ()
	self.Preview:SetTall (self:GetTall () - 8)
	self.Preview:SetWide (self:GetWide () * 0.32)
	
	if PreviewOnLeft then
		self.Preview:SetPos (4, 4)
		self.PanelList:SetPos (self.Preview:GetWide () + 4, 0)
		self.PanelList:SetSize (self:GetWide () - self.Preview:GetWide () - 4, self:GetTall ())
	else
		self.Preview:SetPos (self:GetWide () - self.Preview:GetWide () - 4, 4)
		self.PanelList:SetPos (0, 0)
		self.PanelList:SetSize (self:GetWide () - self.Preview:GetWide () - 8, self:GetTall ())
	end
end

function PANEL:SetAlpha (alpha)
	_R.Panel.SetAlpha (self, alpha)
	if alpha >= 255 and self:IsVisible () then
		self.Preview:SetParent (self)
	end
end

function PANEL:SetCategory (category)
	self.PanelList:Clear (true)
	self.Category = category
	
	for itemID, item in pairs (self.Category.Items) do
		if item.Enabled then
			local itemPanel = vgui.Create ("NNJGShopItem", self)
			itemPanel:SetItem (itemID, item)
			self.PanelList:AddItem (itemPanel)
		end
	end
end

function PANEL:Update ()
	for _, itemPanel in pairs (self.PanelList:GetItems ()) do
		itemPanel:Update ()
	end
	self.PanelList:InvalidateLayout ()
end

vgui.Register ("NNJGShopTab", PANEL, "DPanel")