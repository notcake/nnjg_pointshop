local PANEL = {}

function PANEL:Init ()
	self:SetTitle ("www.NoNerdsJustGeeks.com Shop")
	
	self:SetSize (ScrW () * 0.65, ScrH () * 0.655)
	self:SetDeleteOnClose (false)
	self:MakePopup ()
	self:SetSkin("FusionRP")
	
	self.TabControl = vgui.Create ("DPropertySheet", self)
	self.CategoryTabs = {}
	
	self.PointsIcon = vgui.Create ("DImage", self)
	self.PointsIcon:SetImage ("icon16/star.png")
	self.Points = vgui.Create ("DLabel", self)
	self.Points:SetTextColor (Color (255, 255, 255, 255))
	self.Points:SetExpensiveShadow (1, Color (0, 0, 0, 128))
	self.LastPoints = nil
	
	self:PopulateTabs ()
	
	self:InvalidateLayout ()
end

function PANEL:PerformLayout ()
	DFrame.PerformLayout (self)
	
	if self.TabControl then
		self.TabControl:SetPos (4, 28)
		self.TabControl:SetSize (self:GetWide () - 8, self:GetTall () - 32)
		
		self.Points:SizeToContents ()
		self.Points:SetPos (self:GetWide () - self.Points:GetWide () - 12, 34)
		
		self.PointsIcon:SetSize (16, 16)
		self.PointsIcon:SetPos (self:GetWide () - self.Points:GetWide () - 32, 32)
	end
end

function PANEL:PopulateTabs ()
	self.CategoryTabs = {}
	
	for _, category in pairs (POINTSHOP.Items) do
		if category.Enabled then
			local categoryTab = vgui.Create ("NNJGShopTab")
			categoryTab:SetCategory (category)
			
			self.CategoryTabs [category.Name] = categoryTab
			self.TabControl:AddSheet (category.Name, categoryTab, "icon16/" .. category.Icon .. ".png", false, false, category.Name)
		end
	end
	
	-- Donator Tab
	local donatorContainer = vgui.Create ("DPanelList")
	donatorContainer:SetSpacing (5)
	donatorContainer:SetPadding (5)
	donatorContainer:EnableHorizontal (true)
	donatorContainer:EnableVerticalScrollbar (false)

	local donatorLabel = vgui.Create ("DLabel", donatorContainer)
	donatorLabel:SetPos (5, 5)
	donatorLabel:SetText (POINTSHOP.Config.DonatorText)
	donatorLabel:SizeToContents ()
	
	self.TabControl:AddSheet ("Information", donatorContainer, "icon16/heart.png", false, false, "Information about this shop!")
end

function PANEL:SetVisible (visible)
	debug.getregistry ().Panel.SetVisible (self, visible)
	if visible then
		self:Center ()
		self:Update ()
	end
end

function PANEL:Think ()
	DFrame.Think (self)
	self:UpdatePoints ()
end

function PANEL:Update ()
	self:UpdatePoints ()
	
	for _, categoryTab in pairs (self.CategoryTabs) do
		categoryTab:Update ()
	end
end

function PANEL:UpdatePoints ()
	if LocalPlayer ():PS_GetPoints () ~= self.LastPoints then
		self.Points:SetText (tostring (LocalPlayer ():PS_GetPoints ()) .. " points")
		self:InvalidateLayout ()
		self.LastPoints = LocalPlayer ():PS_GetPoints ()
	end
end

vgui.Register ("NNJGShop", PANEL, "DFrameTransparent")