ITEM.Name = "Incendiary Ammo"
ITEM.Enabled = true
ITEM.Description = "Sets targets on fire, dealing 5 damage over 5 seconds."
ITEM.Cost = 1000
ITEM.Model = "models/weapons/w_snip_scout.mdl"

ITEM.ConstantHooks = {
	EntityTakeDamage = function(target, item, damageInfo)
		local weapon = nil
		if damageInfo:GetAttacker ():IsPlayer() then
			weapon = damageInfo:GetAttacker ():GetActiveWeapon()
		end
		if weapon and weapon:IsValid() and weapon:GetClass() == "weapon_zm_rifle" then
			if not damageInfo:GetAttacker ():PS_HasItem(item.ID) or damageInfo:GetAttacker ():PS_IsItemDisabled(item.ID) then
				return
			end
			if not target:IsOnFire () then
				target.Igniter = damageInfo:GetAttacker ()
				target:Ignite(5, 0)
				timer.Simple(6, function()
					if target:IsValid() then
						target.Igniter = nil
						target.LastFireHurtTime = nil
					end
				end)
			end
		elseif damageInfo:GetInflictor ():GetClass() == "entityflame" then
			if target:IsOnFire() and target.Igniter and target.Igniter:IsValid() then
				damageInfo:GetAttacker():SetDamageOwner(target.Igniter)
				damageInfo:SetInflictor(target.Igniter)
				damageInfo:SetAttacker(target.Igniter)
				
				local LastHurtTime = target.LastFireHurtTime or 0
				if CurTime() - LastHurtTime < 1 then
					damageInfo:SetDamage(0)
				else
					target.LastFireHurtTime = CurTime()
				end
			end
		end
	end
}