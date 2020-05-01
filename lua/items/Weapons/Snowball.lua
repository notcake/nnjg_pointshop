ITEM.Name = "Snowball"
ITEM.Enabled = true
ITEM.Description = "Left click to throw, right click to cheer. (Restricted item)"
ITEM.Cost = 0
ITEM.Material = "vgui/entities/real_snowball_swep"
ITEM.Respawnable = 0

ITEM.Functions = {
	CanPlayerBuy = function(ply)
		if ply:SteamID() == "STEAM_0:1:28509590" or ply:SteamID() == "STEAM_0:1:38699491" then
			return true, ""
		end	
		return false, "This item is restricted"
	end,

	--OnGive = function(ply, item)
		--item.Hooks.PlayerLoadout(ply, item)
	--end,
	
	Respawn = function(ply, item)
		--item.Functions.OnGive(ply, item)
		ply:PS_Notify( "Respawning is disabled for the Snowball!" )
	end
}

ITEM.Hooks = {
	PlayerLoadout = function(ply, item)
		ply:Give("weapon_ttt_snowball")
	end
}