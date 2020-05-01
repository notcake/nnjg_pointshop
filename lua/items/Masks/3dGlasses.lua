ITEM.Name = "3D Glasses"
ITEM.Enabled = true
ITEM.Donator = true
ITEM.Description = "I'm just going to sit here and watch you die. In 3D."
ITEM.Cost = 100
ITEM.Model = "models/gmod_tower/3dglasses.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -1.5)
		ang:RotateAroundAxis(ang:Up(), 0)
		return ent, {Pos = pos, Ang = ang}
	end
}