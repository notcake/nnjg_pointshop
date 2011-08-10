local LastShopCategory = nil

if POINTSHOP.Menu then
	if POINTSHOP.Menu:IsValid () then
		POINTSHOP.Menu:Remove ()
	end
	POINTSHOP.Menu = nil
end

usermessage.Hook("PointShop_Menu", function(um)
	if um:ReadBool() then
		POINTSHOP.Menu = POINTSHOP.Menu or vgui.Create("NNJGShop")
		POINTSHOP.Menu:SetVisible(true)
	else
		if POINTSHOP.Menu then
			POINTSHOP.Menu:SetVisible(false)
		end
	end
end)

usermessage.Hook("PointShop_UpdateMenu", function(um)
	if POINTSHOP.Menu then
		POINTSHOP.Menu:Update()
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