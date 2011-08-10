ITEM.Name = "Saw Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a Saw blade hat."
ITEM.Cost = 110
ITEM.Model = "models/props_junk/sawblade001a.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(0.8, 0.8, 0.8))
		pos = pos + (ang:Forward() * -4) + (ang:Up())
		ang:RotateAroundAxis(ang:Right(), 20)
		return ent, {Pos = pos, Ang = ang}
	end,
}