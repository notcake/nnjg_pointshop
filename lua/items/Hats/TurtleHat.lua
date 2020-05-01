ITEM.Name = "Turtle Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a turtle hat."
ITEM.Cost = 100
ITEM.Model = "models/props/de_tides/Vending_turtle.mdl"

ITEM.Functions = {
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -3)
		ang:RotateAroundAxis(ang:Up(), -90)
		return ent, {Pos = pos, Ang = ang}
	end
}