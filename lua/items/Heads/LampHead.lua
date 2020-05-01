ITEM.Name = "Lamp Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a Lamp head."
ITEM.Cost = 80
ITEM.Model = "models/props_wasteland/prison_lamp001c.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(0.7)
		pos = pos + (ang:Forward() * -4.2) + (ang:Up() * 4.5)
		ang:RotateAroundAxis(ang:Right(), 20)
		return ent, {Pos = pos, Ang = ang}
	end
}