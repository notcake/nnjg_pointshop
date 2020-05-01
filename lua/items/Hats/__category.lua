local CATEGORY = CATEGORY
CATEGORY.Name = "Hats"
CATEGORY.Icon = "add"
CATEGORY.NumAllowedEnabledItems = 1
CATEGORY.Enabled = true

CATEGORY.Functions = {
	OnGive = function(ply, item)
		CATEGORY.Hooks.PlayerSpawn(ply, item)
	end,

	OnTake = function(ply, item)
		CATEGORY.Hooks.PlayerDeath(ply, item)
	end
}

CATEGORY.Hooks = {
	PlayerSpawn = function(ply, item)
		ply.Hats = ply.Hats or {}
		if ply.Hats[item.ID] and not ply.Hats[item.ID]:IsValid () then
			ply.Hats[item.ID] = nil
		end
		ply.Hats[item.ID] = ply.Hats[item.ID] or ents.Create("pointshop_hat")
		ply.Hats[item.ID]:SetupHat(ply, item)
	end,
	
	PlayerDeath = function(ply, item)
		if ply.Hats and ply.Hats[item.ID] then
			if ply.Hats[item.ID]:IsValid() then
				ply.Hats[item.ID]:Remove()
			end
			ply.Hats[item.ID] = nil
		end
	end
}