ITEM.Name = "100 Health"
ITEM.Enabled = false
ITEM.Description = "Gives you 100 more health."
ITEM.Cost = 100
ITEM.Model = "models/props_combine/health_charger001.mdl"

ITEM.Functions = {
	OnGive = function(ply, item)
		item.Hooks.PlayerSpawn(ply, item)
	end,
	
	OnTake = function(ply, item)
		if ply:Health() > 100 then
			ply:SetHealth(ply:Health() - 100)
		end
	end
}

ITEM.Hooks = {
	PlayerSpawn = function(ply, item)
		ply:SetHealth(ply:Health() + 100)
	end
}