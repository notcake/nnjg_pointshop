ITEM.Name = "Pot Head"
ITEM.Enabled = true
ITEM.Description = "Gives you a Pot head."
ITEM.Cost = 95
ITEM.Model = "models/props_junk/terracotta01.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	OnGive = function(ply, item)
		ply:PS_AddHat(item)
	end,
	
	OnTake = function(ply, item)
		ply:PS_RemoveHat(item)
	end,
					
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(0.55, 0.55, 0.55))
		pos = pos + (ang:Forward() * -5.4) + (ang:Up() * 7.1)
		ang:RotateAroundAxis(ang:Right(), 200)
		return ent, pos, ang
	end,
}

ITEM.Hooks = {
	PlayerInitialSpawn = function(ply, item)
		ply:PS_AddHat(item)
	end
}
