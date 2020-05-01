ITEM.Name = "Astronaut Helmet"
ITEM.Enabled = true
ITEM.Donator = true
ITEM.Description = "TO THE MOON!"
ITEM.Cost = 1000
ITEM.Model = "models/astronauthelmet/astronauthelmet.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -3.5)
		pos = pos + (ang:Up() * -5)
		ang:RotateAroundAxis(ang:Up(), 0)
		return ent, {Pos = pos, Ang = ang}
	end
}