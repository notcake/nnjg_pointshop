ITEM.Name = "No Entry Mask"
ITEM.Enabled = true
ITEM.Description = "Gives you a no entry sign mask."
ITEM.Cost = 50
ITEM.Model = "models/props_c17/streetsign004f.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(0.7, 0.7, 0.7))
		pos = pos + (ang:Forward() * 3)
		ang:RotateAroundAxis(ang:Up(), -90)
		return ent, {Pos = pos, Ang = ang}
	end,
}