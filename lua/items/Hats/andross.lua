ITEM.Name = "Andross Mask"
ITEM.Enabled = true
ITEM.Donator = true
ITEM.Description = "What the fuck?"
ITEM.Cost = 500
ITEM.Model = "models/gmod_tower/androssmask.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -3)
		pos = pos + (ang:Up() * -2.5)
		ang:RotateAroundAxis(ang:Up(), 0)
		return ent, {Pos = pos, Ang = ang}
	end
}