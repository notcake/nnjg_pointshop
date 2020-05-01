ITEM.Name = "TV Head"
ITEM.Enabled = true
ITEM.Description = "Gives you a TV head."
ITEM.Cost = 100
ITEM.Model = "models/props_c17/tv_monitor01.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(0.8)
		pos = pos + (ang:Right() * -2) + (ang:Forward() * -3) + (ang:Up() * 0.5)
		return ent, {Pos = pos, Ang = ang}
	end
}