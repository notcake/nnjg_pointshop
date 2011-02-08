ITEM.Name = "Tire Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a Tire Hat."
ITEM.Cost = 115
ITEM.Model = "models/props_vehicles/tire001c_car.mdl"

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
		ent:SetModelScale(Vector(0.45, 0.45, 0.45))
		pos = pos + (ang:Forward() * -3) + (ang:Up() * 3.5)
		ang:RotateAroundAxis(ang:Right(), 90)
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