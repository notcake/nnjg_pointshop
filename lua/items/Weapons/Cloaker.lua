ITEM.Name = "Cloaker"
ITEM.Enabled = true
ITEM.Description = "Get a cloaker!"
ITEM.Cost = 1500
ITEM.Model = "models/weapons/W_slam.mdl"
ITEM.Respawnable = -1

ITEM.Functions = {
	OnGive = function(ply, item)
		item.Hooks.PlayerLoadout(ply, item)
	end,
	
	Respawn = function(ply, item)
		item.Functions.OnGive(ply, item)
	end
}

ITEM.Hooks = {
	PlayerLoadout = function(ply, item)
		ply:Give("weapon_ttt_cloaker")
		ply:ConCommand("use weapon_zm_improvised")
	end
}