ITEM.Name = "Barney"
ITEM.Enabled = true
ITEM.Description = "At least it isn't a purple dinosaur. Restricted item."
ITEM.Cost = 0
ITEM.Model = "models/player/barney.mdl"

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
		if ply:SteamID() == "STEAM_0:1:36094299" then
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