ITEM.Name = "Health Upgrade"
ITEM.Enabled = true
ITEM.Description = "Gives you 3 more health per upgrade."
ITEM.Cost = 125
ITEM.Model = "models/props_combine/health_charger001.mdl"
ITEM.Maximum = 12

ITEM.Functions = {
	GetName = function(ply, item)
		return "Health Upgrade " .. tostring (ply:PS_GetItemCount(item.ID))
	end,
	
	GetShopName = function(ply, item)
		return "Health Upgrade " .. tostring (ply:PS_GetItemCount(item.ID) + 1)
	end,
	
	--OnGive = function(ply, item, count)
		--local givehealth = ply:Health() == ply:GetMaxHealth()
		--ply:SetMaxHealth(100 + 3 * ply:PS_GetItemCount(item.ID))
		--if givehealth then
		--	ply:SetHealth(ply:Health() + 3 * count)
		--end
	--end,
	
	OnTake = function(ply, item)
		ply:SetMaxHealth(100)
		if ply:Health() > ply:GetMaxHealth() then
			ply:SetHealth(ply:GetMaxHealth())
		end
	end
}

ITEM.Hooks = {
	PlayerSpawn = function(ply, item)
		ply:SetMaxHealth(100 + 3 * ply:PS_GetItemCount(item.ID))
		ply:SetHealth (ply:GetMaxHealth ())
	end
}