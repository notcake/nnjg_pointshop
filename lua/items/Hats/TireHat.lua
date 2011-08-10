ITEM.Name = "Tire Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a Tire Hat."
ITEM.Cost = 115
ITEM.Model = "models/props_vehicles/tire001c_car.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(0.45, 0.45, 0.45))
		pos = pos + (ang:Forward() * -3) + (ang:Up() * 3.5)
		ang:RotateAroundAxis(ang:Right(), 90)
		return ent, {Pos = pos, Ang = ang}
	end,
}