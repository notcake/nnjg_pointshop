local LastShopCategory = nil

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
		
		local ShopCategoryTabs = vgui.Create("DColumnSheet2")
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
						if LocalPlayer():PS_GetItemCount(item_id) < item.Maximum then
							local Icon
							if item.Model then
								Icon = vgui.Create("DShopModel")
							elseif item.Material then
								Icon = vgui.Create("DShopMaterial")
							end
							Icon:SetData(item, true)
							Icon:SetSize(96, 96)
							Icon.DoClick = function()
								if LocalPlayer():PS_CanAfford(item.Cost) then
									Derma_Query("Do you want to buy '" .. item.Functions.GetShopName(LocalPlayer(), item) .. "'?", "Buy Item",
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
				ShopCategoryTabs:AddSheet(category.Name, CategoryTab, "gui/silkicons/" .. category.Icon, category.Name)
			end
		end
		
		ShopCategoryTabs.OnSheetChanged = function(_, name)
			LastShopCategory = name
		end
		ShopCategoryTabs:SetActiveSheet(LastShopCategory)
		
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
			
			if item and not item.HideInInventory then
				local Icon
				if item.Model then
					Icon = vgui.Create("DShopModel")
				elseif item.Material then
					Icon = vgui.Create("DShopMaterial")
				end
				Icon:SetData(item)
				Icon:SetSize(96, 96)
				Icon.Sell = true
				Icon.DoClick = function()
					local menu = DermaMenu()
					menu:AddOption("Sell", function()
						Derma_Query("Do you want to sell '" .. item.Functions.GetName(LocalPlayer(), item) .. "'?", "Sell Item",
							"Yes", function() RunConsoleCommand("pointshop_sell", item_id) end,
							"No", function() end
						)
					end)
					if LocalPlayer():PS_IsItemDisabled(item.ID) then
						menu:AddOption("Enable", function()
							RunConsoleCommand("pointshop_enable", item_id)
						end)
					else
						menu:AddOption("Disable", function()
							RunConsoleCommand("pointshop_disable", item_id)
						end)
					end
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

usermessage.Hook("PointShop_AddHat", function(um)
	local ply = Entity(um:ReadLong())
	local item_id = um:ReadString()
	
	if not ply or not ply:IsValid() or not item_id then return end
	
	local item = POINTSHOP.FindItemByID(item_id)
	if not item then return end
	
	if not ply._Hats then
		ply._Hats = {}
	end
	
	if ply._Hats[item_id] then return end
	
	local mdl = ClientsideModel(item.Model, RENDERGROUP_OPAQUE)
	mdl:SetNoDraw(true)
	mdl:SetParent(ply)
	
	ply._Hats[item_id] = {
		Model = mdl,
		Attachment = item.Attachment or nil,
		Bone = item.Bone or nil,
		Modify = item.Functions.ModifyHat or function(ent, pos, ang) return ent, pos, ang end
	}
end)

usermessage.Hook("PointShop_RemoveHat", function(um)
	local ply = Entity(um:ReadLong())
	local item_id = um:ReadString()
	
	if not ply or not ply:IsValid() or not item_id then return end
	if not ply._Hats then return end
	if not ply._Hats[item_id] then return end
	
	ply._Hats[item_id] = nil
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

hook.Add("PostPlayerDraw", "PointShop_PostPlayerDraw", function(ply)
	if not ply:Alive() or (ply.IsObserver and ply:IsObserver()) then return end
	if not POINTSHOP.Config.AlwaysDrawHats and not hook.Call("ShouldDrawHats", GAMEMODE) and ply == LocalPlayer() and GetViewEntity():GetClass() == "player" then return end
	
	if ply._Hats then
		for id, hat in pairs(ply._Hats) do
			local pos = Vector()
			local ang = Angle()
			
			if not hat.Attachment and not hat.Bone then return end
			
			if hat.Attachment then
				local attach = ply:GetAttachment(ply:LookupAttachment(hat.Attachment))
				pos = attach.Pos
				ang = attach.Ang
			elseif hat.Bone then
				pos, ang = ply:GetBonePosition(ply:LookupBone(hat.Bone))
			end
			
			hat.Model, pos, ang = hat.Modify(hat.Model, pos, ang)
			hat.Model:SetPos(pos)
			hat.Model:SetAngles(ang)
			if hat.Model.LastDrawTime ~= CurTime() then
				hat.Model:DrawModel()
			end
			hat.Model.LastDrawTime = CurTime()
		end
	end
end)

if POINTSHOP.Config.DisplayPoints then
	hook.Add("HUDPaint", "PointShop_HUDPaint", function()
		local text = "Points: " .. LocalPlayer():PS_GetPoints()
		surface.SetFont("ScoreboardText")
		local w, h = surface.GetTextSize(text)
		draw.RoundedBox(6, 20, 20, w + 10, h + 10, Color(0, 0, 0, 150))
		draw.SimpleText(text, "ScoreboardText", 25, 25, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	end)
end