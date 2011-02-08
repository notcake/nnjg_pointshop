ITEM.Name = "Afro"
ITEM.Enabled = true
ITEM.Description = "Gives you a hip afro."
ITEM.Cost = 200
ITEM.Model = "models/dav0r/hoverball.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	OnGive = function(ply, item)
		ply:PS_AddHat(item)
	end,
	
	OnTake = function(ply, item)
		ply:PS_RemoveHat(item)
	end,
	
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(1.6, 1.6, 1.6))
		ent:SetMaterial("models/weapons/v_stunbaton/w_shaft01a")
		pos = pos + (ang:Forward() * -7) + (ang:Up() * 8)
		ang:RotateAroundAxis(ang:Right(), 90)
		return ent, pos, ang
	end
}

ITEM.Hooks = {
	PlayerInitialSpawn = function(ply, item)
		ply:PS_AddHat(item)
	end
}