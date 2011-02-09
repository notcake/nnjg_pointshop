ITEM.Name = "Incendiary Ammo"
ITEM.Enabled = true
ITEM.Description = "Sets targets on fire, dealing 5 damage over 5 seconds."
ITEM.Cost = 1200
ITEM.Model = "models/weapons/w_snip_scout.mdl"

ITEM.ConstantHooks = {
	EntityTakeDamage = function(target, item, inflictor, attacker, amount, damage)
		local weapon = nil
		if attacker:IsPlayer() then
			weapon = attacker:GetActiveWeapon()
		end
		if weapon and weapon:IsValid() and weapon:GetClass() == "weapon_zm_rifle" then
			if not attacker:PS_HasItem(item.ID) or attacker:PS_IsItemDisabled(item.ID) then
				return
			end
			if not target:IsOnFire () then
				target.Igniter = attacker
				target:Ignite(5, 0)
				timer.Simple(6, function()
					if target:IsValid() then
						target.Igniter = nil
						target.LastFireHurtTime = nil
					end
				end)
			end
		elseif inflictor:GetClass() == "entityflame" then
			if target:IsOnFire() and target.Igniter and target.Igniter:IsValid() then
				damage:GetAttacker():SetDamageOwner(target.Igniter)
				damage:SetInflictor(target.Igniter)
				damage:SetAttacker(target.Igniter)
				
				local LastHurtTime = target.LastFireHurtTime or 0
				if CurTime() - LastHurtTime < 1 then
					damage:SetDamage(0)
				else
					target.LastFireHurtTime = CurTime()
				end
			end
		end
	end
}