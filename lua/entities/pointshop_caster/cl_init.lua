include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 84))
end

local matGlow = Material("sprites/glow04_noz")
local matGlow2 = Material("effects/yellowflare")
function ENT:Draw()
	if not self.ItemData then
		if POINTSHOP.FindItemByID(self:GetNWString("item_id")) then
			self.ItemData = POINTSHOP.FindItemByID(self:GetNWString("item_id"))
			return
		end
	end
	local owner = self:GetOwner()
	if owner == LocalPlayer() and GetViewEntity():GetClass() == "player" then return end
	if !owner:Alive() then return end
	--if owner:GetObserverMode() == OBS_MODE_ROAMING then return end
	if LocalPlayer ():GetObserverMode () == OBS_MODE_IN_EYE and LocalPlayer ():GetObserverTarget () == owner then return end

	local a = owner:GetColor().a
	local red = owner:GetNWInt( "CasterColorRed" )
	local green = owner:GetNWInt( "CasterColorGreen" )
	local blue = owner:GetNWInt( "CasterColorBlue" )
	if a < 200 then return end

	local usecol = Color( tonumber(red), tonumber(green), tonumber(blue) )

	render.SetMaterial(matGlow)
	local iRHBone = owner:LookupBone("ValveBiped.Bip01_R_Hand")
	local iLHBone = owner:LookupBone("ValveBiped.Bip01_L_Hand")
	local RBonePos, RBoneAng = owner:GetBonePosition(iRHBone)
	local LBonePos, LBoneAng = owner:GetBonePosition(iLHBone)
	render.DrawSprite(RBonePos, 24 + math.Rand(8, 14), 24 + math.Rand(8, 14), usecol )
	render.DrawSprite(LBonePos, 24 + math.Rand(8, 14), 24 + math.Rand(8, 14), usecol )

	render.SetMaterial(matGlow2)
	RBoneAng:RotateAroundAxis(RBoneAng:Right(), RealTime() * 360)
	render.DrawSprite(RBonePos + RBoneAng:Forward() * 8, 8, 8, usecol )
	LBoneAng:RotateAroundAxis(LBoneAng:Right(), RealTime() * 360)
	render.DrawSprite(LBonePos + LBoneAng:Forward() * 8, 8, 8, usecol )
end

ENT.DrawTranslucent = ENT.Draw