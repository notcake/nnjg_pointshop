ITEM.Name = "Afro"
ITEM.Enabled = true
ITEM.Description = "Gives you a hip afro."
ITEM.Cost = 200
ITEM.Model = "models/dav0r/hoverball.mdl"

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
		ent:SetModelScale(Vector(1.6, 1.6, 1.6))
		ent:SetMaterial("models/weapons/v_stunbaton/w_shaft01a")
		pos = pos + (ang:Forward() * -7) + (ang:Up() * 8)
		ang:RotateAroundAxis(ang:Right(), 90)
		return ent, {Pos = pos, Ang = ang}
	end
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