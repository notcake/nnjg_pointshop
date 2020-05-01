ITEM.Name = "Low Gravity"
ITEM.Enabled = true
ITEM.Description = "Each upgrade lowers your gravity by 50."
ITEM.Cost = 125
ITEM.Model = "models/weapons/w_toolgun.mdl"
ITEM.Maximum = 5

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
	end,
	
	UpdateGravity = function(ply, item)
		if not ply.OldGravity then
			ply.OldGravity = ply:GetGravity()
		end
		
		local gravity = 600
		local count = ply:PS_GetItemCount (item.ID)
		gravity = gravity - count * 50
		ply:SetGravity(gravity / 600)
	end
}

ITEM.Hooks = {
	OnPlayerHitGround = function(ply, item)
		item.Functions.UpdateGravity(ply, item)
	end,

	PlayerSpawn = function(ply, item)
		item.Functions.UpdateGravity(ply, item)
	end
}

ITEM.ConstantHooks = {
	Think = function(_, item)
		for _, ply in ipairs(player.GetAll()) do
			if ply:PS_HasItem(item.ID) and not ply:PS_IsItemDisabled(item.ID) then
				item.Functions.UpdateGravity(ply, item)
			end
		end
	end
}