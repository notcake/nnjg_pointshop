ITEM.Name = "Upgraded Disguiser"
ITEM.Enabled = true
ITEM.Description = "Allows you to impersonate someone using the disguiser."
ITEM.Cost = 1000
ITEM.Model = "models/weapons/w_toolgun.mdl"

ITEM.Functions = {
	OnTake = function(ply, item)
		ply:SetNWString("disguisename", "")
	end
}

ITEM.ConstantHooks = {
	CanPlayerImpersonate = function(ply, item)
		return ply:PS_HasItem(item.ID) and not ply:PS_IsItemDisabled(item.ID)
	end
}

if CLIENT then
	local item_id = ITEM.ID
	hook.Add("CanPlayerImpersonate", "PointShop_DisguiserUpgrade", function(ply)
		return ply:PS_HasItem(item_id) and not ply:PS_IsItemDisabled(item_id)
	end)
end