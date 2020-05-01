ITEM.Name = "Cone Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a cone head."
ITEM.Cost = 100
ITEM.Model = "models/props_junk/TrafficCone001a.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(0.8)
		pos = pos + (ang:Forward() * -7) + (ang:Up() * 12)
		ang:RotateAroundAxis(ang:Right(), 20)
		return ent, {Pos = pos, Ang = ang}
	end
}