ITEM.Name = "Clock Mask"
ITEM.Enabled = true
ITEM.Description = "Gives you a clock mask."
ITEM.Cost = 50
ITEM.Model = "models/props_c17/clock01.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	OnGive = function(ply, item)
		ply:PS_AddHat(item)
	end,
	
	OnTake = function(ply, item)
		ply:PS_RemoveHat(item)
	end,
	
	ModifyHat = function(ent, pos, ang)
		ang:RotateAroundAxis(ang:Right(), -90)
		return ent, pos, ang
	end
}

ITEM.Hooks = {
	PlayerInitialSpawn = function(ply, item)
		ply:PS_AddHat(item)
	end
}