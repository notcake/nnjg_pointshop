ITEM.Name = "Pan Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a pan hat."
ITEM.Cost = 100
ITEM.Model = "models/props_interiors/pot02a.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -3) + (ang:Up() * 2) + (ang:Right() * 5.5)
		ang:RotateAroundAxis(ang:Right(), 180)
		return ent, {Pos = pos, Ang = ang}
	end,
}