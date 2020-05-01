ITEM.Name = "Drink Cap"
ITEM.Enabled = true
ITEM.Donator = true
ITEM.Description = "One of a kind."
ITEM.Cost = 1000
ITEM.Model = "models/gmod_tower/drinkcap.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -3.5)
		pos = pos + (ang:Up() * 2)
		ang:RotateAroundAxis(ang:Up(), 0)
		return ent, {Pos = pos, Ang = ang}
	end
}