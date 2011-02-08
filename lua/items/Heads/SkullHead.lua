ITEM.Name = "Skull Head"
ITEM.Enabled = true
ITEM.Description = "Gives you a skull head."
ITEM.Cost = 150
ITEM.Model = "models/Gibs/HGIBS.mdl"

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
		pos = pos + (ang:Forward() * -2.5)
		ang:RotateAroundAxis(ang:Right(), -15)
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