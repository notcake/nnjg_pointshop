include('shared.lua')

ENT.RenderGroup 		= RENDERGROUP_BOTH

function ENT:Draw()
	if not self.ItemData then
		if POINTSHOP.FindItemByID(self:GetNWString("item_id")) then
			self.ItemData = POINTSHOP.FindItemByID(self:GetNWString("item_id"))
			return
		end
	end
	
	local owner = self:GetOwner()
	
	if owner == LocalPlayer() and GetViewEntity():GetClass() == "player" then return end
	if LocalPlayer ():GetObserverMode () == OBS_MODE_IN_EYE and LocalPlayer ():GetObserverTarget () == owner then return end
	
	if owner and owner:IsValid() and owner:Alive() then
		local attach = owner:GetAttachment(owner:LookupAttachment("eyes"))
		if not attach then attach = owner:GetAttachment(owner:LookupAttachment("head")) end
		
		if attach then
			if self.ItemData then
				if self.ItemData.Functions and self.ItemData.Functions.ModifyHat then
					self, attach = self.ItemData.Functions.ModifyHat(self, attach.Pos, attach.Ang)
				end
				
				self:SetColor(owner:GetColor())
				self:SetRenderOrigin( attach.Pos )
				self:SetRenderAngles( attach.Ang )
				self:SetupBones()
				self:DrawModel()
				self:SetRenderOrigin()
				self:SetRenderAngles()
			end
		end
	end
end

ENT.DrawTranslucent = ENT.Draw