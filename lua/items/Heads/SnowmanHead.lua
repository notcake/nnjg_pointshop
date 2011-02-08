ITEM.Name = "Snowman Head"
ITEM.Enabled = true
ITEM.Description = "WINTER SPECIAL: Gives you a snowman head."
ITEM.Cost = 200
ITEM.Model = "models/props/cs_office/Snowman_face.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	OnGive = function(ply, item)
		ply:PS_AddHat(item)
	end,
	
	OnTake = function(ply, item)
		ply:PS_RemoveHat(item)
	end,
	
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -2.2)
		ang:RotateAroundAxis(ang:Up(), -90)
		return ent, pos, ang
	end,
	
	CanPlayerBuy = function(ply)
		if os.date("%m") == "12" then
			return true, ""
		end
		
		return false, "it isn't winter!"
	end
}

ITEM.Hooks = {
	PlayerInitialSpawn = function(ply, item)
		ply:PS_AddHat(item)
	end
}