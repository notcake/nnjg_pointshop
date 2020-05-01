ITEM.Name = "Orange"
ITEM.Enabled = true
ITEM.Description = "I have heard rumors of those casting orange magic seem to set fire to their enemies..."
ITEM.Cost = 5000
ITEM.Material = "icon16/heart.png"

ITEM.Functions = {
	CanPlayerBuy = function(ply)
		if ply:IsUserGroup("vip") or ply:IsUserGroup("operator") or ply:IsAdmin() then
			return true, ""
		end	
		return false, "This item is for VIPs only!"
	end,

	OnGive = function(ply, item)
		item.Hooks.PlayerSpawn(ply, item)
	end,
	
	OnTake = function(ply, item)
		if ply.Hat then
			ply.Hat:Remove()
		end
	end,
	
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -3)
		ang:RotateAroundAxis(ang:Up(), -90)
		return ent, {Pos = pos, Ang = ang}
	end,
}

ITEM.Hooks = {
	PlayerSpawn = function(ply, item)
		ply.Hat = ents.Create("pointshop_caster")
		ply.Hat:SetupHat(ply, item)
		ply:SetNWInt( "CasterColorRed", 200 )
		ply:SetNWInt( "CasterColorGreen", 100 )
		ply:SetNWInt( "CasterColorBlue", 0 )
		ply:SetWalkSpeed( 240 )
	end,
	
	PlayerDeath = function(ply, item)
		if ply.Hat and ply.Hat:IsValid() then
			ply.Hat:Remove()
			ply.Hat = nil
		end
	end
}

ITEM.ConstantHooks = {
	EntityTakeDamage = function(target, item, damageInfo)
		local weapon = nil
		if damageInfo:GetAttacker ():IsPlayer() then
			weapon = damageInfo:GetAttacker ():GetActiveWeapon()
		end
		if weapon and weapon:IsValid() then
			if not damageInfo:GetAttacker ():PS_HasItem(item.ID) or damageInfo:GetAttacker ():PS_IsItemDisabled(item.ID) then
				return
			end
			if GetRoundState() != ROUND_ACTIVE then
				return
			end
			if not target:IsOnFire () then
				target.Igniter = damageInfo:GetAttacker ()
				target:Ignite(2, 0)
				timer.Simple(3, function()
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