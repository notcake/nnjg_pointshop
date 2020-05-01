ITEM.Name = "Cat Ears"
ITEM.Enabled = true
ITEM.Donator = true
ITEM.Description = "\"If you're not a girl, don't wear cat ears.\""
ITEM.Cost = 200
ITEM.Model = "models/gmod_tower/catears.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -3.5)
		ang:RotateAroundAxis(ang:Up(), 0)
		return ent, {Pos = pos, Ang = ang}
	end
}