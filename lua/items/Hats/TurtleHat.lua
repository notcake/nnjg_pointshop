ITEM.Name = "Turtle Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a turtle hat."
ITEM.Cost = 100
ITEM.Model = "models/props/de_tides/Vending_turtle.mdl"

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
		pos = pos + (ang:Forward() * -3)
		ang:RotateAroundAxis(ang:Up(), -90)
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