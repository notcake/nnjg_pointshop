ITEM.Name = "Magneto-Rod"
ITEM.Enabled = true
ITEM.Description = "What's more fun than fishing for dead bodies?"
ITEM.Cost = 2500
ITEM.Model = "models/weapons/W_stunbaton.mdl"
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
		ply:Give("weapon_ttt_rod")
	end
}