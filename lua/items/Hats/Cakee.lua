ITEM.Name = "Cake"
ITEM.Enabled = true
ITEM.Donator = true
ITEM.Description = "Is this really a lie?"
ITEM.Cost = 1000
ITEM.Model = "models/cakehat/cakehat.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -3.5)
		ang:RotateAroundAxis(ang:Up(), 0)
		return ent, {Pos = pos, Ang = ang}
	end
}