ITEM.Name = "Mac 10 Damage"
ITEM.Enabled = true
ITEM.Description = "Each upgrade increases damage by 1."
ITEM.Cost = 200
ITEM.Model = "models/weapons/w_smg_mac10.mdl"
ITEM.Maximum = 4

ITEM.Functions = {
	GetName = function(ply, item)
		return "Mac 10 Damage " .. tostring (ply:PS_GetItemCount(item.ID))
	end,
	
	GetShopName = function(ply, item)
		return "Mac 10 Damage " .. tostring (ply:PS_GetItemCount(item.ID) + 1)
	end
}

ITEM.Hooks = {
	ModifyPrimaryFireDamage = function(ply, item, weapon, damage)
		if weapon:GetClass() == "weapon_zm_mac10" then
			return damage + ply:PS_GetItemCount(item.ID)
		end
	end
}