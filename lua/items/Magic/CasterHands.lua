ITEM.Name = "Blue"
ITEM.Enabled = true
ITEM.Description = "It is said that those who use blue magic inherit the legs of Mario."
ITEM.Cost = 5000
ITEM.Material = "icon16/heart.png"

ITEM.Functions = {
	CanPlayerBuy = function(ply)
		if ply:IsUserGroup("vip") or ply:IsUserGroup("operator") or ply:IsAdmin() then
			return true, ""
		end	
		return false, "This item is for VIPs only!"
	end,

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
		ply.Hat = ents.Create("pointshop_caster")
		ply.Hat:SetupHat(ply, item)
		ply:SetNWInt( "CasterColorRed", 62 )
		ply:SetNWInt( "CasterColorGreen", 255 )
		ply:SetNWInt( "CasterColorBlue", 255 )
	end,
	
	PlayerDeath = function(ply, item)
		if ply.Hat and ply.Hat:IsValid() then
			ply.Hat:Remove()
			ply.Hat = nil
		end
	end
}