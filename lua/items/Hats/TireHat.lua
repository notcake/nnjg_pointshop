ITEM.Name = "Tire Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a Tire Hat."
ITEM.Cost = 115
ITEM.Model = "models/props_vehicles/tire001c_car.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	OnGive = function(ply, item)
		ply:PS_AddHat(item)
	end,
	
	OnTake = function(ply, item)
		ply:PS_RemoveHat(item)
	end,
					
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(0.45, 0.45, 0.45))
		pos = pos + (ang:Forward() * -3) + (ang:Up() * 3.5)
		ang:RotateAroundAxis(ang:Right(), 90)
		return ent, pos, ang
	end,
}

ITEM.Hooks = {
	PlayerInitialSpawn = function(ply, item)
		ply:PS_AddHat(item)
	end
}