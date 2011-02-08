ITEM.Name = "Pokeball"
ITEM.Enabled = true
ITEM.Description = "GO, TRAIL! I CHOOSE YOU!"
ITEM.Cost = 500
ITEM.Material = "trails/pokeball"

ITEM.Functions = {
	OnGive = function(ply, item)
		item.Hooks.PlayerSpawn(ply, item)
	end,
	
	OnTake = function(ply, item)
		SafeRemoveEntity(ply.Trail)
	end
}

ITEM.Hooks = {
	PlayerSpawn = function(ply, item)
		if not ply.Trail then
			ply.Trail = util.SpriteTrail(ply, 0, Color(255, 255, 255, 255), false, 15, 1, 4, 0.125, "trails/pokeball.vmt")
		end
	end
}