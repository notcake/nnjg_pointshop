include('shared.lua')

function ENT:Initialize()
	self:SetModelScale(0.125, 0)
	
	self.VisibleProp = ClientsideModel(self:GetModel())
	self.VisibleProp:AddEffects(EF_NODRAW)
	self.VisibleProp:SetModelScale(0.125, 0)
	self.VisibleProp:SetPos(self:GetPos())
	self.VisibleProp:SetAngles(self:GetAngles())
	
	-- need to expand render bounds, otherwise flickering will occur when the player turns / moves too fast
	self:SetRenderBounds(Vector(-128, -128, -128), Vector(128, 128, 128))
	
	self.DoneAttaching = true
end

--[[
	Rendering
	
	Pretty messy; players will see the bobber drawn at an interpolated position
	since thirdperson and firstperson bobber positions do not match
	When the bobber is very close to its retracted position, interpolation stops
	so that it appears attached to the rod properly, instead of gliding around when
	players move / rotate
]]
function ENT:Draw()	
	local owner = self:GetRodOwner()
	local thirdperson = LocalPlayer():ShouldDrawLocalPlayer()
	local isViewModel = false
	
	if owner == LocalPlayer() and not thirdperson then
		isViewModel = true
	end
	
	if self:IsAttachedToRod() then
		self:DrawAttached(isViewModel)
	else
		self:DrawMoving(isViewModel)
	end
end

function ENT:DrawAttached(isViewModel)
	local viewModel = LocalPlayer():GetViewModel()
	local att = nil
	
	local targetPos = self:GetPos()
	local targetAngles = self:GetAngles()
	if isViewModel then
		local att = viewModel:GetAttachment(1)
		targetPos = att.Pos + att.Ang:Up() * 2
		targetAngles = att.Ang
	else
		if self:GetRod() then
			targetPos = self:GetRod():GetRodTip()
			targetAngles = self:GetRod():GetRodTipAngles()
		end
	end
	
	-- check if the drawn bobber is close enough to the target position
	-- if so, turn off interpolation
	if not self.DoneAttaching then
		if (targetPos - self.VisibleProp:GetPos()):Length() < 1 then
			self.DoneAttaching = true
		end
	end
	
	if self.DoneAttaching then
		self:DrawStatic(targetPos, targetAngles)
	else
		self:DrawLerping(targetPos, targetAngles)
	end
end

-- draws the bobber when not retracted
function ENT:DrawMoving(isViewModel)
	self.DoneAttaching = false
	self:DrawLerping(self:GetPos(), self:GetAngles())
end

-- draws bobber in between the given position and its last drawn position
function ENT:DrawLerping(targetPos, targetAngles)
	self.VisibleProp:SetPos((self.VisibleProp:GetPos() + targetPos) / 2)
	self.VisibleProp:SetAngles(targetAngles)
	self.VisibleProp:DrawModel()
end

-- draws bobber at the given position
function ENT:DrawStatic(targetPos, targetAngles)
	self.VisibleProp:SetPos(targetPos)
	self.VisibleProp:SetAngles(targetAngles)
	self.VisibleProp:DrawModel()
end

function ENT:GetRod()
	local rod = self.dt.Rod
	if not rod or not rod:IsValid() then return nil end
	
	return rod
end

function ENT:GetRodOwner()
	local owner = self.dt.RodOwner
	if not owner or not owner:IsValid() then return nil end
	
	return owner
end

function ENT:OnRemove()
	self.VisibleProp:Remove()
	self.VisibleProp = nil
end