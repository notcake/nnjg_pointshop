ITEM.Name = "Fox McCloud"
ITEM.Enabled = false
ITEM.Description = "What Dum person would want this?"
ITEM.Cost = 1
ITEM.Model = "models/fox_mccloud/fox_mccloud.mdl"

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
		if ply:SteamID() == "STEAM_0:1:28509590" then
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