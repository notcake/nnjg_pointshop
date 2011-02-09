ITEM.Name = "Extra Credit"
ITEM.Enabled = true
ITEM.Description = "Gives you an extra credit as a traitor or detective."
ITEM.Cost = 1250
ITEM.Model = "models/weapons/w_toolgun.mdl"

ITEM.Hooks = {
	ApplyDefaultCreditBonuses = function(ply, item)
		if ply:GetTraitor() or ply:GetDetective() then
			ply:SetCredits(ply:GetCredits() + 1)
		end
	end
}