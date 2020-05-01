ITEM.Name = "Aviators"
ITEM.Enabled = true
ITEM.Donator = true
ITEM.Description = "Instant badass."
ITEM.Cost = 1000
ITEM.Model = "models/gmod_tower/aviators.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -1.7)
		ang:RotateAroundAxis(ang:Up(), 0)
		return ent, {Pos = pos, Ang = ang}
	end
}