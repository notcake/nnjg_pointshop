ITEM.Name = "Cute Lolita"
ITEM.Enabled = true
ITEM.UdaneOnly = true
ITEM.Description = "Ima pedo, ima pedo, ima pedo. Udane made this image! [RESTRICTED]"
ITEM.Cost = 1000
ITEM.Material = "trails/cutezpure1"

ITEM.Functions = {
	OnGive = function(ply, item)
		item.Hooks.PlayerSpawn(ply, item)
	end,
	
	OnTake = function(ply, item)
		SafeRemoveEntity(ply.Trail)
	end,
	
	CanPlayerBuy = function(ply)
		if ply:SteamID() == "STEAM_0:1:16289295" then
			return true, ""
		end
		
		return false, "This item is restricted!"
	end
}

ITEM.Hooks = {
	PlayerSpawn = function(ply, item)
		if not ply.Trail then
			ply.Trail = util.SpriteTrail(ply, 0, Color(255, 255, 255, 255), false, 15, 1, 4, 0.125, "trails/cutezpure1.vmt")
		end
	end
}