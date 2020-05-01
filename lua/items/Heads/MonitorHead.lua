ITEM.Name = "Monitor Head"
ITEM.Enabled = true
ITEM.Description = "Gives you a monitor head."
ITEM.Cost = 100
ITEM.Model = "models/props_lab/monitor02.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(0.6)
		pos = pos + (ang:Forward() * -5) + (ang:Up() * -5)
		return ent, {Pos = pos, Ang = ang}
	end
}