ITEM.Name = "Dunce"
ITEM.Enabled = true
ITEM.Donator = true
ITEM.Description = "You fucking dumbass"
ITEM.Cost = 50
ITEM.Model = "models/duncehat/duncehat.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -3.5)
		ang:RotateAroundAxis(ang:Up(), 0)
		return ent, {Pos = pos, Ang = ang}
	end
}