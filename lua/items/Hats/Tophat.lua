ITEM.Name = "Top Hat"
ITEM.Enabled = true
ITEM.Donator = true
ITEM.Description = "Indeed."
ITEM.Cost = 1000
ITEM.Model = "models/gmod_tower/tophat.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -3.5)
		ang:RotateAroundAxis(ang:Up(), 0)
		return ent, {Pos = pos, Ang = ang}
	end
}