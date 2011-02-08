ITEM.Name = "Tube Trail"
ITEM.Enabled = true
ITEM.Description = "Fwoosh!"
ITEM.Cost = 400
ITEM.Material = "trails/tube"

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
			ply.Trail = util.SpriteTrail(ply, 0, team.GetColor(ply:Team()), false, 15, 1, 4, 0.125, "trails/tube.vmt")
		end
	end
}