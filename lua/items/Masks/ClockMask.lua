ITEM.Name = "Clock Mask"
ITEM.Enabled = true
ITEM.Description = "Gives you a clock mask."
ITEM.Cost = 50
ITEM.Model = "models/props_c17/clock01.mdl"

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
		ang:RotateAroundAxis(ang:Right(), -90)
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