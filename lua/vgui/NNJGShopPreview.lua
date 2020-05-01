local PANEL = {}

function PANEL:Init ()
	self.DirectionalLight = {}
	self.FOV = 70
	
	self.AmbientLight = Color (50, 50, 50, 255)
	self.Color = Color (255, 255, 255, 255)
	
	self:SetDirectionalLight (BOX_TOP, Color (255, 255, 255))
	self:SetDirectionalLight (BOX_FRONT, Color (255, 255, 255))
	
	self.Hats = {}
	self.Weapons = {}
	
	-- clientsidemodel queue
	self.ClientsideModelCache = {}
	self.ClientsideModelQueue = {}
	
	-- material queue
	self.MaterialCache = {}
	self.MaterialQueue = {}
	self.MaterialsReady = {}
	
	self.LastPlayerModelUpdateTime = 0
	self:CreateRagdoll ()
	
	self.PlayerHeight = 0
	
	self.CameraRotation = 180
	
	-- buttons
	self.LeftButton = vgui.Create ("NNJGShopPreviewButton", self)
	self.LeftButton:SetText ("<")
	self.LeftButton:SetSize (32, 32)
	self.RightButton = vgui.Create ("NNJGShopPreviewButton", self)
	self.RightButton:SetText (">")
	self.RightButton:SetSize (32, 32)
	
	self.ModelLoadInterval = 0.02
	self.LastModelLoadTime = RealTime ()
	
	self.MaterialLoadInterval = 0.02
	self.LastMaterialLoadTime = RealTime ()
	
	self.LastThinkTime = RealTime ()
end

function PANEL:CreateHat (hat)
	if not self.Ragdoll then return end
	
	local model = hat:GetModel ()
	if not self:IsModelLoading (model) then
		if not self:IsValid () then return end
		if self.Hats [model] then return end
		
		self:QueueModelCreation (model, function (ent)
			self.Hats [model] = ent
			self.Hats [model]:SetNoDraw (true)
			self.Hats [model].ItemData = hat.ItemData
			self.Hats [model]:SetNWString ("item_id", hat:GetNWString ("item_id"))
			self.Hats [model]:SetOwner (self.Ragdoll)
			self.Hats [model].Draw = hat.Draw
		end)
	end
	return self.Hats [model]
end

function PANEL:CreateRagdoll ()	
	if not self:IsValid () then return end
	if not LocalPlayer () or not LocalPlayer ():IsValid () then return end
	
	if self.Ragdoll and self.Ragdoll:IsValid () then return end
	
	local mdl = LocalPlayer ():GetModel ()
	
	-- redirect hl2 human models to use playermodels instead.
	local toreplace = "models/humans"
	if mdl:sub (1, toreplace:len ()):lower () == toreplace:lower () then
		mdl = "models/player" .. mdl:sub (toreplace:len () + 1)
	end
	
	self:QueueModelCreation (mdl, function (ent)
		self.Ragdoll = ent
		self.Ragdoll:SetAngles (Angle (0, -15, 0))
		self.Ragdoll.LastAnimateTime = RealTime ()
		self.Ragdoll:SetNoDraw (true)
		
		local attachment = self.Ragdoll:GetAttachment (self.Ragdoll:LookupAttachment ("eyes"))
		if attachment then
			self.PlayerHeight = attachment.Pos.z
		else
			self.PlayerHeight = 80
		end
		
		function self.Ragdoll:UpdateSequence ()
			local sequence = LocalPlayer ():GetSequence ()
			if self:GetSequence () ~= sequence then
				self:ResetSequence (sequence)
			end
			self:FrameAdvance (RealTime () - self.LastAnimateTime * 1)
			self.LastAnimateTime = RealTime ()
		end
		
		function self.Ragdoll:Alive ()
			return LocalPlayer ():Alive ()
		end
		
		self.Ragdoll:UpdateSequence ()
	end)
end

local worldModels = {
	["models/weapons/v_crowbar.mdl"]			= "models/weapons/w_crowbar.mdl",
	["models/weapons/v_physcannon.mdl"]			= "models/weapons/w_physics.mdl",
	["models/weapons/v_superphyscannon.mdl"]	= "models/weapons/w_physics.mdl",
	["models/weapons/v_pistol.mdl"]				= "models/weapons/w_pistol.mdl",
	["models/weapons/v_357.mdl"]				= "models/weapons/w_357.mdl",
	["models/weapons/v_smg1.mdl"]				= "models/weapons/w_smg1.mdl",
	["models/weapons/v_irifle.mdl"]				= "models/weapons/w_irifle.mdl",
	["models/weapons/v_shotgun.mdl"]			= "models/weapons/w_shotgun.mdl",
	["models/weapons/v_crossbow.mdl"]			= "models/weapons/w_crossbow.mdl",
	["models/weapons/v_grenade.mdl"]			= "models/weapons/w_grenade.mdl",
	["models/weapons/v_rpg.mdl"]				= "models/weapons/w_rocket_launcher.mdl",
	["models/weapons/v_slam.mdl"]				= "models/weapons/w_slam.mdl"
}

function PANEL:CreateWeapon (weapon)
	if not self.Ragdoll then return end

	local model = weapon.WorldModel or weapon:GetModel ()
	model = model:lower ()
	if worldModels [model] then
		model = worldModels [model]
	end
	if not self:IsModelLoading (model) then
		if not self:IsValid () then return end
		if self.Weapons [model] then return end
		if model == "" or not file.Exists (model, "GAME") then return end
		
		self:QueueModelCreation (model, function (ent)
			self.Weapons [model] = ent
			self.Weapons [model].LastAnimateTime = RealTime ()
			self.Weapons [model]:SetNoDraw (true)
			self.Weapons [model]:SetParent (self.Ragdoll)
			self.Weapons [model]:SetOwner (self.Ragdoll)
			self.Weapons [model]:AddEffects (EF_BONEMERGE + EF_BONEMERGE_FASTCULL)
			
			self.Weapons [model].Update = function (self)
				if not LocalPlayer ():GetActiveWeapon () or not LocalPlayer ():GetActiveWeapon ():IsValid () then return end
				self:SetPos (LocalPlayer ():GetActiveWeapon ():GetPos () - LocalPlayer ():GetPos ())
				self:SetAngles (LocalPlayer ():GetActiveWeapon ():GetAngles () - LocalPlayer ():GetAngles ())
				if LocalPlayer ():GetActiveWeapon ():GetSkin () < self:SkinCount () then
					self:SetSkin (LocalPlayer ():GetActiveWeapon ():GetSkin ())
				end
				self:UpdateSequence ()
				self:SetupBones ()
			end
		
			self.Weapons [model].UpdateSequence = function (self)
				if self:GetSequence () ~= LocalPlayer ():GetActiveWeapon ():GetSequence () then
					-- self:ResetSequence (LocalPlayer ():GetActiveWeapon ():GetSequence ())
				end
				self:FrameAdvance (RealTime () - self.LastAnimateTime * 1)
				self.LastAnimateTime = RealTime ()
			end
			
			self.Weapons [model]:Update ()
		end)
	end
	return self.Weapons [model]
end

function PANEL:DrawEntities ()	
	-- pcall (ents.GetByIndex (0).DrawModel, ents.GetByIndex (0))
	
	if not self.Ragdoll or not self.Ragdoll:IsValid () then
		self:CreateRagdoll ()
		return
	end
	if LocalPlayer ():IsValid () and
	   self.Ragdoll:GetModel () ~= LocalPlayer ():GetModel () and
	   SysTime () - self.LastPlayerModelUpdateTime > 1 then
		self.Ragdoll:SetModel (LocalPlayer ():GetModel ())
		self.LastPlayerModelUpdateTime = SysTime ()
	end
	self.Ragdoll:UpdateSequence ()
	self.Ragdoll:SetupBones ()
	
	for _, v in ipairs (ents.GetAll ()) do
		if v:IsValid () and v:GetParent () == LocalPlayer () then
			if v:GetClass () == "pointshop_hat" or v:GetClass() == "pointshop_caster" then
				local hat = self:CreateHat (v)
				if hat then
					pcall (hat.Draw, hat)
				end
			elseif v:GetClass () == "env_spritetrail" then
				local mat = v:GetModel ()
				mat = self:GetMaterial (mat)
				if mat then
					render.SetMaterial (mat)
					self:DrawTrail (v)
				end
			end
		end
	end
	
	local weapon = LocalPlayer ():GetActiveWeapon ()
	if weapon and weapon:IsValid () then
		local drawn_weapon = self:CreateWeapon (weapon)
		if drawn_weapon then
			drawn_weapon:Update ()
			pcall (drawn_weapon.DrawModel, drawn_weapon)
		end
	end
	
	pcall (self.Ragdoll.DrawModel, self.Ragdoll)
end

function PANEL:DrawTrail (env_trail)
	if not env_trail or type (env_trail) ~= "Entity" or not env_trail:IsValid () then return end

	local segments = 8
	render.StartBeam (segments + 1)
	render.AddBeam (Vector (0, 0, 0), 15, 0 - RealTime () % 128, env_trail:GetColor () or Color (255, 255, 255, 255))
	
	pcall (self.DrawTrailSegments, self, env_trail, segments)
	
	render.EndBeam ()
end

function PANEL:DrawTrailSegments (env_trail, segments)
	local col = env_trail:GetColor ()
	local forward = Vector (0.707, 0.707, 0)
	if self.Ragdoll and self.Ragdoll:IsValid () then
		forward = self.Ragdoll:GetForward ()
	end
	for i = 1, segments do
		local fademultiplier = (segments - i) / (segments - 1)
		col.a = 255 * fademultiplier
		render.AddBeam (Vector (0, 0, 0) - forward * 1024 * i / segments, 15 * fademultiplier, 64 * i / segments - RealTime () % 128, col)
	end
end

function PANEL:GetMaterial (mat)
	if not self.MaterialsReady [mat] then
		if self.MaterialCache [mat] then return end
		self.MaterialQueue [mat] = true
	end
	return self.MaterialCache [mat]
end

function PANEL:GetViewEntity ()
	return ents.GetByIndex (0)
end

function PANEL:IsModelLoading (mdl)
	if self.ClientsideModelCache [mdl] or self.ClientsideModelQueue [mdl] then
		return true
	end
	return false
end

function PANEL:Log (msg)
end

function PANEL:Paint (w, h)
	draw.RoundedBox (4, 0, 0, w, h - 36, Vector (128, 128, 128, 255))

	if not LocalPlayer () or not LocalPlayer ():IsValid () then return end
	if not LocalPlayer ():Alive () or LocalPlayer ():GetObserverMode () ~= 0 then return end
	if not self.Ragdoll then
		self:CreateRagdoll ()
		return
	end

	local x, y = self:LocalToScreen (0, 0)
	local w, h = self:GetSize ()
	local rw, rh = w, h
	if w < h then
		rw, rh = h, h
	elseif h < w then
		rw, rh = w, w
	end
	local dx = (self:GetWide () - rw) * 0.5
	local dy = (self:GetTall () - rh) * 0.5
	
	local target = self.Ragdoll
	local targetpos = Vector (0, 0, 0)
	targetpos.z = targetpos.z + self.PlayerHeight * 0.5
	
	local angle = Angle (10, self.CameraRotation, 0)
	local campos = targetpos - angle:Forward () * 128
	
	cam.Start3D (campos, angle, self.FOV, x + dx, y + dy, rw, rh)
	cam.IgnoreZ (true)
	
	render.SuppressEngineLighting (true)
	render.SetLightingOrigin (targetpos)
	render.ResetModelLighting (self.AmbientLight.r / 255, self.AmbientLight.g / 255, self.AmbientLight.b / 255)
	render.SetColorModulation (self.Color.r / 255, self.Color.g / 255, self.Color.b / 255)
	render.SetBlend (self.Color.a / 255)
	
	for i = 0, 6 do
		local col = self.DirectionalLight [i]
		if col then
			render.SetModelLighting (i, col.r / 255, col.g / 255, col.b / 255)
		end
	end

	local _GetViewEntity = GetViewEntity
	GetViewEntity = self.GetViewEntity
	
	render.SetScissorRect (x, y, x + self:GetWide (), y + self:GetTall () - 36, true)
	pcall (self.DrawEntities, self)
	render.SetScissorRect (0, 0, 0, 0, false)
	
	GetViewEntity = _GetViewEntity
	
	render.SuppressEngineLighting (false)
	cam.IgnoreZ (false)
	cam.End3D ()
end

function PANEL:PerformLayout ()
	local padding = 0
	if self.LeftButton and self.RightButton then
		self.LeftButton:SetPos (padding, self:GetTall () - padding - self.LeftButton:GetTall ())
		self.RightButton:SetPos (self:GetWide () - padding - self.RightButton:GetWide (), self:GetTall () - padding - self.RightButton:GetTall ())
	end
end

function PANEL:ProcessMaterialQueue ()
	local mat = next (self.MaterialQueue, nil)
	if not mat then return end
	
	self.MaterialQueue [mat] = nil
	self.MaterialCache [mat] = Material (mat)
	self:Log (mat .. " loaded.\n")
	-- crashes occur if we try to do stuff with the materials right away
	-- or load materials in a drawing hook
	timer.Simple (self.MaterialLoadInterval, function ()
		self:Log (mat .. " ready.\n")
		self.MaterialsReady [mat] = true
	end)
end

function PANEL:ProcessModelQueue ()
	local mdl, callback = next (self.ClientsideModelQueue, nil)
	if not mdl then return end
	
	local ent = ClientsideModel (mdl)
	if not ent or not ent:IsValid () then
		return
	end
	self.ClientsideModelQueue [mdl] = nil
	self.ClientsideModelCache [mdl] = ent
	ent:SetNoDraw (true)
	self:Log (mdl .. " loaded.\n")
	-- crashes occur if we try to do stuff with the entities right away
	timer.Simple (self.ModelLoadInterval, function ()
		self:Log (mdl .. " ready.\n")
		callback (ent)
	end)
end

function PANEL:QueueModelCreation (mdl, callback)
	if self.ClientsideModelQueue [mdl] then return end
	if self.ClientsideModelCache [mdl] then return end
	self.ClientsideModelQueue [mdl] = callback
end

function PANEL:SetDirectionalLight (direction, color)
	self.DirectionalLight [direction] = color
end

function PANEL:Think ()
	local delta = RealTime () - self.LastThinkTime
	
	if self.LeftButton.Depressed then
		self.CameraRotation = self.CameraRotation - 90 * delta
	elseif self.RightButton.Depressed then
		self.CameraRotation = self.CameraRotation + 90 * delta
	end
	self.CameraRotation = self.CameraRotation % 360
	
	if RealTime () - self.LastModelLoadTime > self.ModelLoadInterval then
		self:ProcessModelQueue ()
		self.LastModelLoadTime = RealTime ()
	end
	if RealTime () - self.LastMaterialLoadTime > self.MaterialLoadInterval then
		self:ProcessMaterialQueue ()
		self.LastMaterialLoadTime = RealTime ()
	end
	self.LastThinkTime = RealTime ()
end

vgui.Register ("NNJGShopPreview", PANEL, "DPanel")

local PANEL = {}
function PANEL:Init ()
	self:SetFont ("TargetID")
end

function PANEL:ApplySchemeSettings ()
end

vgui.Register ("NNJGShopPreviewButton", PANEL, "NNJGShopButton")