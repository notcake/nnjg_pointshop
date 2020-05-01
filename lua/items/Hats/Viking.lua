ITEM.Name = "Viking Helmet"
ITEM.Enabled = true
ITEM.Donator = true
ITEM.Description = "Genuine Viking Helmet"
ITEM.Cost = 500
ITEM.Model = "models/vikinghelmet/vikinghelmet.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -3.5)
		pos = pos + (ang:Up() * 2)
		ang:RotateAroundAxis(ang:Up(), 0)
		return ent, {Pos = pos, Ang = ang}
	end
}