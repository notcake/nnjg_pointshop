ITEM.Name = "Lamp Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a Lamp head."
ITEM.Cost = 80
ITEM.Model = "models/props_wasteland/prison_lamp001c.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	OnGive = function(ply, item)
		ply:PS_AddHat(item)
	end,
	
	OnTake = function(ply, item)
		ply:PS_RemoveHat(item)
	end,
					
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(0.7, 0.7, 0.7))
		pos = pos + (ang:Forward() * -4.2) + (ang:Up() * 4.5)
		ang:RotateAroundAxis(ang:Right(), 20)
		return ent, pos, ang
	end,
}

ITEM.Hooks = {
	PlayerInitialSpawn = function(ply, item)
		ply:PS_AddHat(item)
	end
}