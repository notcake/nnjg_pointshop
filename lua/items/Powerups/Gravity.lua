ITEM.Name = "Low Gravity"
ITEM.Enabled = true
ITEM.Description = "Each upgrade lowers your gravity by 100."
ITEM.Cost = 125
ITEM.Model = "models/weapons/w_toolgun.mdl"
ITEM.Maximum = 4

ITEM.Functions = {
	GetName = function(ply, item)
		return "Low Gravity " .. tostring (ply:PS_GetItemCount(item.ID))
	end,
	
	GetShopName = function(ply, item)
		return "Low Gravity " .. tostring (ply:PS_GetItemCount(item.ID) + 1)
	end,

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
		
		local gravity = 600
		local count = ply:PS_GetItemCount (item.ID)
		gravity = gravity - count * 100
		ply:SetGravity(gravity / 600)
	end
}