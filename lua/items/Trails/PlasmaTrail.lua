ITEM.Name = "Plasma Trail"
ITEM.Enabled = true
ITEM.Description = "Green plasma!"
ITEM.Cost = 200 -- Was 200
ITEM.Material = "trails/plasma"

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
			ply.Trail = util.SpriteTrail(ply, 0, team.GetColor(ply:Team()), false, 15, 1, 4, 0.125, "trails/plasma.vmt")
		end
	end
}