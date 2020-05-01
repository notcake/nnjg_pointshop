ITEM.Name = "Fedora"
ITEM.Enabled = true
ITEM.Donator = true
ITEM.Description = "Wearing this instantly makes you a detective."
ITEM.Cost = 600
ITEM.Model = "models/gmod_tower/fedorahat.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -3.5)
		pos = pos + (ang:Up() * 2.3)
		ang:RotateAroundAxis(ang:Up(), 0)
		return ent, {Pos = pos, Ang = ang}
	end
}