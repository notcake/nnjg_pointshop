ITEM.Name = "Snowman Head"
ITEM.Enabled = true
ITEM.Description = "WINTER SPECIAL: Gives you a snowman head."
ITEM.Cost = 200
ITEM.Model = "models/props/cs_office/Snowman_face.mdl"

ITEM.Functions = {	
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -2.2)
		ang:RotateAroundAxis(ang:Up(), -90)
		return ent, {Pos = pos, Ang = ang}
	end,
	
	CanPlayerBuy = function(ply)
		if os.date("%m") == 12 then
			return true, ""
		end
		
		return false, "it isn't winter yet!"
	end
}