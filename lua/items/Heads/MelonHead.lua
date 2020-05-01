ITEM.Name = "Melon Head"
ITEM.Enabled = true
ITEM.Description = "Gives you a melon head."
ITEM.Cost = 100
ITEM.Model = "models/props_junk/watermelon01.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -2)
		return ent, {Pos = pos, Ang = ang}
	end
}