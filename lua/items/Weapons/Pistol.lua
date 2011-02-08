ITEM.Name = "Pistol"
ITEM.Enabled = true
ITEM.Description = "Get a pistol!"
ITEM.Cost = 200
ITEM.Model = "models/weapons/W_pistol.mdl"

ITEM.Functions = {
	OnGive = function(ply, item)
		item.Hooks.PlayerSpawn(ply, item)
	end,
	
	OnTake = function(ply, item)
		item.Hooks.PlayerDeath(ply, item)
	end
}

ITEM.Hooks = {
	PlayerSpawn = function(ply, item)
		ply:Give("weapon_pistol")
	end
}