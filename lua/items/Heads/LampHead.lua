ITEM.Name = "Lamp Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a Lamp head."
ITEM.Cost = 80
ITEM.Model = "models/props_wasteland/prison_lamp001c.mdl"

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
		pos = pos + (ang:Forward() * -4.2) + (ang:Up() * 4.5)
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