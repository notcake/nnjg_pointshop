ITEM.Name = "M16 Speed Upgrade"
ITEM.Enabled = true
ITEM.Description = "Each upgrade increases firing speed by 2%."
ITEM.Cost = 200
ITEM.Model = "models/weapons/w_rif_m4a1.mdl"
ITEM.Maximum = 5

ITEM.Functions = {
	GetName = function(ply, item)
		return "M16 Speed Upgrade " .. tostring (ply:PS_GetItemCount(item.ID))
	end,
	
	GetShopName = function(ply, item)
		return "M16 Speed Upgrade " .. tostring (ply:PS_GetItemCount(item.ID) + 1)
	end
}

ITEM.Hooks = {
	ModifyPrimaryFireDelay = function(ply, item, weapon, delay)
		if weapon:GetClass() == "weapon_ttt_m16" then
			return delay * (1 - 0.02 * ply:PS_GetItemCount(item.ID))
		end
	end
}