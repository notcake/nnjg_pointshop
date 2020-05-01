ITEM.Name = "Roll the Dice Access"
ITEM.Enabled = true
ITEM.Description = "Say !rtd in chat to roll the dice."
ITEM.Cost = 500
ITEM.Material = "icon16/heart.png"

ITEM.Functions = {
		CanPlayerBuy = function(ply)
		if ply:IsUserGroup( "vip" ) or ply:IsUserGroup( "operator" ) or ply:IsUserGroup( "admin" ) or ply:IsUserGroup( "superadmin" ) then
			return true, ""
		end	
		return false, "This item is for VIPs only!"
	end
}