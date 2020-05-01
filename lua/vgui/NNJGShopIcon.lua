local PANEL = {}

function PANEL:Init ()
	self.Image = nil
	self.ModelPanel = nil
end

function PANEL:SetMaterial (material)
	if self.ModelPanel then
		self.ModelPanel:SetVisible (false)
	end
	if not self.Image then
		self.Image = vgui.Create ("Material", self)
		self.Image.AutoSize = false
	end
	self.Image:SetVisible (true)
	self.Image:SetMaterial (material)
end

function PANEL:SetModel (model)
	if self.Image then
		self.Image:SetVisible (false)
	end
	if not self.ModelPanel then
		self.ModelPanel = vgui.Create ("DModelPanel", self)
		
		self.ModelPanel.dir = 200
		self.ModelPanel:SetCamPos (Vector (0, 30, 0))
		self.ModelPanel:SetLookAt (Vector (0, 0, 0))
		
		self.ModelPanel.LayoutEntity = self.ModelPanel_LayoutEntity		
		self.ModelPanel.Paint = self.ModelPanel_Paint
		self.ModelPanel.Render_SetBlend = self.Render_SetBlend
	end
	self.ModelPanel:SetVisible (true)
	self.ModelPanel:SetModel (model)
	
	if self.ModelPanel.Entity and self.ModelPanel.Entity:IsValid () then
		local bboxMin, bboxMax = self.ModelPanel.Entity:GetRenderBounds ()
		self.ModelPanel:SetCamPos (bboxMin:Distance (bboxMax) * Vector (0.6, 0.6, 0.3))
		self.ModelPanel:SetLookAt ((bboxMax + bboxMin) * 0.5)
	end
end

function PANEL:ModelPanel_LayoutEntity (ent)
	if self:GetAnimated () then
		self:RunAnimation ()
	end
end

function PANEL:ModelPanel_Paint (w, h)
	local left, top = 0, 0
	local right, bottom = ScrW (), ScrH ()
	local alpha = 1
	
	local panel = self
	while panel and panel:IsValid () do
		local panelLeft, panelTop = panel:LocalToScreen (0, 0)
		local panelRight = panelLeft + panel:GetWide ()
		local panelBottom = panelTop + panel:GetTall ()
		
		if panelLeft > left		then left	= panelLeft		end
		if panelRight < right	then right	= panelRight	end
		if panelTop > top		then top	= panelTop		end
		if panelBottom < bottom	then bottom	= panelBottom	end
		alpha = alpha * panel:GetAlpha () / 255
		
		panel = panel:GetParent ()
	end
	
	self.colColor.a = alpha * 255
	render.SetScissorRect (left, top, right, bottom, true)	
	DModelPanel.Paint (self, w, h)
	render.SetScissorRect (0, 0, ScrW (), ScrH (), false)
end

function PANEL:PerformLayout ()
	if self.Image then
		self.Image:SetPos (0, 0)
		self.Image:SetSize (self:GetWide (), self:GetTall ())
	end
	if self.ModelPanel then
		self.ModelPanel:SetPos (0, 0)
		self.ModelPanel:SetSize (self:GetWide (), self:GetTall ())
	end
end

function PANEL.Render_SetBlend (alpha)
end

vgui.Register ("NNJGShopIcon", PANEL, "DPanel")