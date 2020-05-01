ITEM.Name = "Alyx"
ITEM.Enabled = true
ITEM.Description = "Hand-crafted with the best of bribes, made from authentic human. Restricted item."
ITEM.Cost = 0
ITEM.Model = "models/player/alyx.mdl"

ITEM.Functions = {
	OnGive = function(ply, item)
		item.Hooks.PlayerSpawn(ply, item)
	end,
	
	OnTake = function(ply, item)
		if ply._OldModel then
			ply:SetModel(ply._OldModel)
		end
	end,
	
		CanPlayerBuy = function(ply)
		if ply:SteamID() == "STEAM_0:0:39518691" then
			return true, ""
		end
		
		return false, "This item is restricted!"
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