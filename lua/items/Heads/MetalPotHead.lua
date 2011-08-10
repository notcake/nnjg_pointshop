ITEM.Name = "Metal Pot Head"
ITEM.Enabled = true
ITEM.Description = "Gives you a Metal Pot head."
ITEM.Cost = 90
ITEM.Model = "models/props_c17/metalPot001a.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(0.7, 0.7, 0.7))
		pos = pos + (ang:Forward() * -3) + (ang:Up() * 2)
		ang:RotateAroundAxis(ang:Right(), 200)
		return ent, {Pos = pos, Ang = ang}
	end,
}