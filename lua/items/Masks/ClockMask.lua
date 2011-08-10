ITEM.Name = "Clock Mask"
ITEM.Enabled = true
ITEM.Description = "Gives you a clock mask."
ITEM.Cost = 50
ITEM.Model = "models/props_c17/clock01.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		ang:RotateAroundAxis(ang:Right(), -90)
		return ent, {Pos = pos, Ang = ang}
	end
}