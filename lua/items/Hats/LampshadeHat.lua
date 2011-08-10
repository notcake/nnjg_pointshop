ITEM.Name = "Lampshade Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a lampshade hat."
ITEM.Cost = 100
ITEM.Model = "models/props_c17/lampShade001a.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(0.7, 0.7, 0.7))
		pos = pos + (ang:Forward() * -3.5) + (ang:Up() * 4)
		ang:RotateAroundAxis(ang:Right(), 10)
		return ent, {Pos = pos, Ang = ang}
	end,
}