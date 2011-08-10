ITEM.Name = "Afro"
ITEM.Enabled = true
ITEM.Description = "Gives you a hip afro."
ITEM.Cost = 200
ITEM.Model = "models/dav0r/hoverball.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(1.6, 1.6, 1.6))
		ent:SetMaterial("models/weapons/v_stunbaton/w_shaft01a")
		pos = pos + (ang:Forward() * -7) + (ang:Up() * 8)
		ang:RotateAroundAxis(ang:Right(), 90)
		return ent, {Pos = pos, Ang = ang}
	end
}