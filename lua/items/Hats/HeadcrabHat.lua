ITEM.Name = "Headcrab Hat"
ITEM.Enabled = true
ITEM.AdminOnly = false
ITEM.Description = "Gives you a Headcrab hat."
ITEM.Cost = 100
ITEM.Model = "models/headcrabclassic.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(0.7)
		pos = pos + (ang:Forward() * 2)
		ang:RotateAroundAxis(ang:Right(), 20)
		return ent, {Pos = pos, Ang = ang}
	end
}