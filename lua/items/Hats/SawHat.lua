ITEM.Name = "Saw Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a Saw blade hat."
ITEM.Cost = 110
ITEM.Model = "models/props_junk/sawblade001a.mdl"

ITEM.Functions = {
	OnGive = function(ply, item)
		item.Hooks.PlayerSpawn(ply, item)
	end,
					
	OnTake = function(ply, item)
		if ply.Hat then
				ply.Hat:Remove()
		end
	end,
					
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(0.8, 0.8, 0.8))
		pos = pos + (ang:Forward() * -4) + (ang:Up())
		ang:RotateAroundAxis(ang:Right(), 20)
		return ent, {Pos = pos, Ang = ang}
	end,
}

ITEM.Hooks = {
	PlayerSpawn = function(ply, item)
		ply.Hat = ents.Create("pointshop_hat")
		ply.Hat:SetupHat(ply, item)
	end,
	
	PlayerDeath = function(ply, item)
		if ply.Hat and ply.Hat:IsValid() then
			ply.Hat:Remove()
			ply.Hat = nil
		end
	end
}