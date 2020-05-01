ITEM.Name = "Corey's Trail"
ITEM.Enabled = true
ITEM.Description = "Reserved."
ITEM.Cost = 1
ITEM.Material = "trails/coreyrogerson"

ITEM.Functions = {
	OnGive = function(ply, item)
		item.Hooks.PlayerSpawn(ply, item)
	end,
	
	OnTake = function(ply, item)
		SafeRemoveEntity(ply.Trail)
	end,
	
	CanPlayerBuy = function(ply)
		if ply:SteamID() == "STEAM_0:0:24225449" then
			return true, ""
		end
		
		return false, "This item is restricted!"
	end
}

ITEM.Hooks = {
	PlayerSpawn = function(ply, item)
		if not ply.Trail then
			ply.Trail = util.SpriteTrail(ply, 0, Color(255, 255, 255, 255), false, 15, 1, 4, 0.125, "trails/coreyrogerson.vmt")
		end
	end
}