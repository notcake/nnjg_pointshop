include("shared.lua")

function SWEP:Initialize()
	self:InitHoldType()
	self:InitState()
end

function SWEP:Deploy()
	self:SetBobberDeployed(false)
end

function SWEP:Holster()
	self:SetBobberDeployed(false)
end

-- bobber calculations
function SWEP:GetRodTip()
	return self:GetAttachment(1).Pos
end

-- debugging
function SWEP:ShowTargetMarker()
	if self.TargetMarker and self.TargetMarker:IsValid() then return end
	
	self.TargetMarker = ClientsideModel("models/combine_helicopter/helicopter_bomb01.mdl")
	self.TargetMarker:SetModelScale(Vector(0.125, 0.125, 0.125))
end

function SWEP:HideTargetMarker()
	if not self.TargetMarker or not self.TargetMarker:IsValid() then return end
	self.TargetMarker:Remove()
end

function SWEP:Think()
	if not self.TargetMarker or not self.TargetMarker:IsValid() then return end
	
	local tr = {}
	tr.start = self.Owner:EyePos()
	tr.endpos = tr.start + self.Owner:EyeAngles():Forward() * 32768
	tr.filter = ents.FindByClass("ttt_rod_bobber")
	tr.filter[#tr.filter + 1] = self.Owner
	tr = util.TraceLine(tr)
	self.TargetMarker:SetPos(tr.HitPos)
end