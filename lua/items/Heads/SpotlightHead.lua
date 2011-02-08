ITEM.Name = "Spotlight Head"
ITEM.Enabled = true
ITEM.Description = "Gives you a spotlight head."
ITEM.Cost = 100
ITEM.Model = "models/props_wasteland/light_spotlight01_lamp.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	OnGive = function(ply, item)
		ply:PS_AddHat(item)
	end,
	
	OnTake = function(ply, item)
		ply:PS_AddHat(item)
	end
}

ITEM.Hooks = {
	PlayerInitialSpawn = function(ply, item)
		ply:PS_AddHat(item)
	end
}