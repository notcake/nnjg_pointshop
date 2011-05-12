CATEGORY.Name = "Trails"
CATEGORY.Icon = "palette"
CATEGORY.Enabled = true

CATEGORY.Functions = {
	OnTake = function(ply, item)
		if ply.Trail and not ply.Trail:IsValid () then
			ply.Trail = nil
		end
	end
}

CATEGORY.PreHooks = {
	PlayerSpawn = function(ply, item)
		if ply.Trail then
			if ply.Trail:IsValid() then
				ply.Trail:Remove()
			end
			ply.Trail = nil
		end
	end
}

CATEGORY.ConstantHooks = {
	TTTBeginRound = function(_, item)
		if GetRoundState() == ROUND_POST then
			return
		end
		if not item.Hooks or not item.Hooks.PlayerSpawn then
			return
		end
		for _, ply in ipairs(player.GetAll()) do
			if ply:PS_HasItem(item.ID) and not ply:PS_IsItemDisabled(item.ID) then
				item.Hooks.PlayerSpawn(ply, item)
			end
		end
	end
}

hook.Add("Tick", "PointShop_RemoveTrails", function()
	for _, v in pairs( player.GetAll() ) do
		if v.Trail then
			if not v:Alive() or v:IsObserver() then
				SafeRemoveEntity( v.Trail )
				v.Trail = nil
				
				if v.Trails then
					for _, trail in pairs( v.Trails ) do
						SafeRemoveEntity( trail )
					end
					v.Trails = nil
				end
			elseif not v.Trail:IsValid () then
				v.Trail = nil
			end
		end
	end
end)