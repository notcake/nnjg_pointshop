include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 84))
end

--local matGlow = Material("sprites/light_glow02_add")
local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	if not DISPLAYHATS then return end
	local owner = self:GetOwner()
	if not owner:IsValid() or owner == MySelf and not (NOX_VIEW or GetViewEntity() ~= MySelf) and owner:Alive() then return end

	if owner:GetRagdollEntity() then
		owner = owner:GetRagdollEntity()
	elseif not owner:Alive() then return end

	local col = owner:GetColor()
	if col.a < 200 then return end

	local coltouse = COLOR_CYAN
	if col.r+col.g+col.b ~= 765 then
		coltouse = col
	end

	local realtime = RealTime() * 5

	render.SetMaterial(matGlow)
	for i=0, 25, 2 do
		local bone = owner:GetBoneMatrix(i)
		if bone then
			local pos2 = bone:GetTranslation()
			render.DrawSprite(pos2, 15, 15, color_white)
			render.DrawSprite(pos2, 22 + math.Rand(5, 7), 22 + math.Rand(5, 7), coltouse)
		end
	end
end
