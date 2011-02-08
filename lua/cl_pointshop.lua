usermessage.Hook("PointShop_Menu", function(um)
	if um:ReadBool() then
		POINTSHOP.Menu = vgui.Create("DFrameTransparent")
		POINTSHOP.Menu:SetSize(475, 475)
		POINTSHOP.Menu:SetTitle("You have " .. LocalPlayer():PS_GetPoints() .. " Points available.")
		POINTSHOP.Menu:SetVisible(true)
		POINTSHOP.Menu:SetDraggable(true)
		POINTSHOP.Menu:ShowCloseButton(true)
		POINTSHOP.Menu:MakePopup()
		POINTSHOP.Menu:Center()
		POINTSHOP.Menu:SizeToContents()
		
		local Tabs = vgui.Create("DPropertySheet", POINTSHOP.Menu)
		Tabs:SetPos(5, 30)
		Tabs:SetSize(POINTSHOP.Menu:GetWide() - 10, POINTSHOP.Menu:GetTall() - 35)
		
		-- Feel free to add your own tabs.
		
		local ShopCategoryTabs = vgui.Create("DColumnSheet")
		ShopCategoryTabs:SetSize(Tabs:GetWide() - 10, Tabs:GetTall() - 10)
        ShopCategoryTabs.Navigation:SetWidth(24)
        ShopCategoryTabs.Navigation:DockMargin(0, 0, 4, 0)
		
		for c_id, category in pairs(POINTSHOP.Items) do
			if category.Enabled then
				local CategoryTab = vgui.Create("DPanelList", ShopCategoryTabs)
				CategoryTab:SetSpacing(5)
				CategoryTab:SetPadding(5)
				CategoryTab:EnableHorizontal(true)
				CategoryTab:EnableVerticalScrollbar(true)
				CategoryTab:Dock(FILL)
				
				for item_id, item in pairs(category.Items) do
					if item.Enabled then
						if not table.HasValue(LocalPlayer():PS_GetItems(), item_id) then
							if item.Model then
								local Icon = vgui.Create("DShopModel")
								Icon:SetData(item)
								Icon:SetSize(96, 96)
								Icon.DoClick = function()
									if LocalPlayer():PS_CanAfford(item.Cost) then
										Derma_Query("Do you want to buy '" .. item.Name .. "'?", "Buy Item",
											"Yes", function() RunConsoleCommand("pointshop_buy", item_id) end,
											"No", function() end
										)
									else
										Derma_Message("You can't afford this item!", "PointShop", "Close")
									end
								end
								CategoryTab:AddItem(Icon)
							elseif item.Material then
								local Icon = vgui.Create("DShopMaterial")
								Icon:SetData(item)
								Icon:SetSize(96, 96)
								Icon.DoClick = function()
									if LocalPlayer():PS_CanAfford(item.Cost) then
										Derma_Query("Do you want to buy '" .. item.Name .. "'?", "Buy Item",
											"Yes", function() RunConsoleCommand("pointshop_buy", item_id) end,
											"No", function() end
										)
									else
										Derma_Message("You can't afford this item!", "PointShop", "Close")
									end
								end
								CategoryTab:AddItem(Icon)
							end
						end
					end
				end
				ShopCategoryTabs:AddSheet(category.Name, CategoryTab, "gui/silkicons/" .. category.Icon, category.Name)
			end
		end
		
		Tabs:AddSheet("Shop", ShopCategoryTabs, "gui/silkicons/application_view_tile", false, false, "Browse the shop!")
		
		-- Inventory Tab
		
		local InventoryContainer = vgui.Create("DPanelList", POINTSHOP.Menu)
		InventoryContainer:SetSize(Tabs:GetWide() - 10, Tabs:GetTall() - 30)
		InventoryContainer:SetSpacing(5)
		InventoryContainer:SetPadding(5)
		InventoryContainer:EnableHorizontal(true)
		InventoryContainer:EnableVerticalScrollbar(false)
		
		for id, item_id in pairs(LocalPlayer():PS_GetItems()) do
			
			local item = POINTSHOP.FindItemByID(item_id)
			
			if item then
				if item.Model then
					local Icon = vgui.Create("DShopModel")
					Icon:SetData(item)
					Icon:SetSize(96, 96)
					Icon.Sell = true
					Icon.DoClick = function()
						local menu = DermaMenu()
						menu:AddOption("Sell", function()
							RunConsoleCommand("pointshop_sell", item_id)
						end)
						if item.Respawnable then
							menu:AddOption("Respawn", function()
								RunConsoleCommand("pointshop_respawn", item_id)
							end)
						end
						menu:Open()
					end
					
					InventoryContainer:AddItem(Icon)
				elseif item.Material then
					Icon = vgui.Create("DShopMaterial")
					Icon:SetData(item)
					Icon:SetSize(96, 96)
					Icon.Sell = true
					Icon.DoClick = function()
						local menu = DermaMenu()
						menu:AddOption("Sell", function()
							RunConsoleCommand("pointshop_sell", item_id)
						end)
						if item.Respawnable then
							menu:AddOption("Respawn", function()
								RunConsoleCommand("pointshop_respawn", item_id)
							end)
						end
						menu:Open()
					end
					
					InventoryContainer:AddItem(Icon)
				end
			end
		end
		
		Tabs:AddSheet("Inventory", InventoryContainer, "gui/silkicons/box", false, false, "Browse your inventory!")
		
		-- Donator Tab
		DonatorContainer = vgui.Create("DPanelList", POINTSHOP.Menu)
		DonatorContainer:SetSize(Tabs:GetWide() - 10, Tabs:GetTall() - 30)
		DonatorContainer:SetSpacing(5)
		DonatorContainer:SetPadding(5)
		DonatorContainer:EnableHorizontal(true)
		DonatorContainer:EnableVerticalScrollbar(false)
		
		DonatorLabel = vgui.Create("DLabel", DonatorContainer)
		DonatorLabel:SetPos(5, 5)
		DonatorLabel:SetText( POINTSHOP.Config.DonatorText )
		DonatorLabel:SizeToContents()
		
		
		Tabs:AddSheet("Info", DonatorContainer, "gui/silkicons/heart", false, false, "Information about this shop!")
		
	else
		if POINTSHOP.Menu then
			POINTSHOP.Menu:Remove()
		end
	end
end)

usermessage.Hook("PointShop_Notify", function(um)
	local text = um:ReadString()
	if text then
		chat.AddText(Color(131, 255, 0), "[PS] ", Color(255, 255, 255), text)
	end
end)

hook.Add("InitPostEntity", "PointShop_InitPostEntity", function()
	LocalPlayer().PS_Points = 0
	LocalPlayer().PS_Items = {}
end)

hook.Add("Initialize", "PointShop_DColumnSheet_AddSheet_Override", function()
	function DColumnSheet:AddSheet(label, panel, material, tooltip)
		if not IsValid(panel) then return end

		local Sheet = {}
		
		if self.ButtonOnly then
			Sheet.Button = vgui.Create("DImageButton", self.Navigation)
		else
			Sheet.Button = vgui.Create("DButton", self.Navigation)
		end
		
		Sheet.Button:SetImage(material)
		Sheet.Button.Target = panel
		Sheet.Button:Dock(TOP)
		Sheet.Button:SetText(label)
		Sheet.Button:DockMargin(0, 1, 0, 0)
		
		if tooltip then
			Sheet.Button:SetToolTip(tooltip)
		end
		
		Sheet.Button.DoClick = function()
			self:SetActiveButton(Sheet.Button)
		end
		
		Sheet.Panel = panel
		Sheet.Panel:SetParent(self.Content)
		Sheet.Panel:SetVisible(false)
		
		if self.ButtonOnly then
			Sheet.Button:SizeToContents()
			Sheet.Button:SetColor(Color(150, 150, 150, 100))
		end
		
		table.insert(self.Items, Sheet)
		
		if not IsValid(self.ActiveButton) then
			self:SetActiveButton(Sheet.Button)
		end
	end
end)