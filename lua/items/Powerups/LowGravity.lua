ITEM.Name = "Low Gravity"
ITEM.Enabled = false
ITEM.Description = "Sets low gravity on yourself when you spawn."
ITEM.Cost = 200
ITEM.Model = "models/weapons/w_toolgun.mdl"

ITEM.Functions = {
	OnGive = function(ply, item)
		item.Hooks.PlayerSpawn(ply, item)
	end,
	
	OnTake = function(ply, item)
		local grav = ply.OldGravity or 1
		ply:SetGravity(grav)
	end
}

ITEM.Hooks = {
	PlayerSpawn = function(ply, item)
		if not ply.OldGravity then
			ply.OldGravity = ply:GetGravity()
		end
		
		ply:SetGravity(0.3)
	end
}