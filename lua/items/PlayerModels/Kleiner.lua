ITEM.Name = "Kleiner"
ITEM.Enabled = true
ITEM.Description = "Spawn as the Kleiner model."
ITEM.Cost = 200
ITEM.Model = "models/player/kleiner.mdl"

ITEM.Functions = {
	OnGive = function(ply, item)
		item.Hooks.PlayerSpawn(ply, item)
	end,
	
	OnTake = function(ply, item)
		if ply._OldModel then
			ply:SetModel(ply._OldModel)
		end
	end
}

ITEM.Hooks = {
	PlayerSpawn = function(ply, item)
		if not ply._OldModel then
			ply._OldModel = ply:GetModel()
		end
		timer.Simple(1, function() ply:SetModel(item.Model) end)
	end
}