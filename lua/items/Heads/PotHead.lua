ITEM.Name = "Pot Head"
ITEM.Enabled = true
ITEM.Description = "Gives you a Pot head."
ITEM.Cost = 95
ITEM.Model = "models/props_junk/terracotta01.mdl"

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
		ent:SetModelScale(Vector(0.55, 0.55, 0.55))
		pos = pos + (ang:Forward() * -5.4) + (ang:Up() * 7.1)
		ang:RotateAroundAxis(ang:Right(), 200)
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