ITEM.Name = "Hipster Glasses"
ITEM.Enabled = true
ITEM.Donator = true
ITEM.Description = "I bought these glasses first!"
ITEM.Cost = 100
ITEM.Model = "models/gmod_tower/klienerglasses.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -1.5)
		ang:RotateAroundAxis(ang:Up(), 0)
		return ent, {Pos = pos, Ang = ang}
	end
}