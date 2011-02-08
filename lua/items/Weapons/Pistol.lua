ITEM.Name = "Pistol"
ITEM.Enabled = false
ITEM.Description = "Get a pistol!"
ITEM.Cost = 200
ITEM.Model = "models/weapons/W_pistol.mdl"
ITEM.Respawnable = -1

ITEM.Functions = {
	OnGive = function(ply, item)
		item.Hooks.PlayerSpawn(ply, item)
	end,
	
	Respawn = function(ply, item)
		item.Functions.OnGive(ply, item)
	end
}

ITEM.Hooks = {
	PlayerSpawn = function(ply, item)
		ply:Give("weapon_pistol")
	end
}