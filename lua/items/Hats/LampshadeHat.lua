ITEM.Name = "Lampshade Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a lampshade hat."
ITEM.Cost = 100
ITEM.Model = "models/props_c17/lampShade001a.mdl"

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
		ent:SetModelScale(Vector(0.7, 0.7, 0.7))
		pos = pos + (ang:Forward() * -3.5) + (ang:Up() * 4)
		ang:RotateAroundAxis(ang:Right(), 10)
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
