ITEM.Name = "Pot Head"
ITEM.Enabled = true
ITEM.Description = "Gives you a Pot head."
ITEM.Cost = 95
ITEM.Model = "models/props_junk/terracotta01.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(0.55)
		pos = pos + (ang:Forward() * -5.4) + (ang:Up() * 7.1)
		ang:RotateAroundAxis(ang:Right(), 200)
		return ent, {Pos = pos, Ang = ang}
	end
}