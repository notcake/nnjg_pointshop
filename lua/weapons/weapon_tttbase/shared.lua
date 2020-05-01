-- Custom weapon base, used to derive from CS one, still very similar

if SERVER then
   AddCSLuaFile( "shared.lua" )
end

if CLIENT then
   SWEP.DrawCrosshair       = false
   SWEP.ViewModelFOV        = 82
   SWEP.ViewModelFlip       = true
   SWEP.CSMuzzleFlashes = true
end

-- this must be set in derived weapons for weapon carrying limits to work properly
SWEP.Kind = WEAPON_NONE

-- if this table contains ROLE_TRAITOR and/or ROLE_DETECTIVE, those players are
-- allowed to purchase it
-- (just setting to nil here to document its existence)
SWEP.CanBuy = nil

if CLIENT then
   -- if this is a buyable weapon (ie. CanBuy is not nil) this table must
   -- contain some information to show in the Equipment Menu. See equipment
   -- weapons for examples.
   SWEP.EquipMenuData = nil

   -- this sets the icon shown for the weapon in the DNA sampler, search window,
   -- equipment menu (if buyable), etc
   SWEP.Icon = "VGUI/ttt/icon_nades" -- most generic icon
end

SWEP.Category           = "TTT"
SWEP.Spawnable          = false
SWEP.AdminSpawnable     = false

SWEP.AutoSpawnable      = false
SWEP.IsGrenade = false

SWEP.Weight             = 5
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false

SWEP.Primary.Sound          = Sound( "Weapon_Pistol.Empty" )
SWEP.Primary.Recoil         = 1.5
SWEP.Primary.Damage         = 1
SWEP.Primary.NumShots       = 1
SWEP.Primary.Cone           = 0.02
SWEP.Primary.Delay          = 0.15

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"

SWEP.Secondary.ClipSize     = 1
SWEP.Secondary.DefaultClip  = 1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"

SWEP.StoredAmmo = 0

SWEP.AllowDrop = true
SWEP.IsSilent = false

SWEP.IsDropped = false

SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnim = ACT_VM_RELOAD

SWEP.fingerprints = {}

local sparkle = CLIENT and CreateConVar("ttt_crazy_sparks", "0", FCVAR_ARCHIVE)

-- crosshair
if CLIENT then
   local sights_opacity = CreateConVar("ttt_ironsights_crosshair_opacity", "0.6")

   local disable_crosshair = CreateConVar("ttt_disable_crosshair", "0", FCVAR_ARCHIVE)


   function SWEP:DrawHUD()
      if disable_crosshair:GetBool() then return end

      local x = ScrW() / 2.0
      local y = ScrH() / 2.0
      local scale = math.max(0.2,  10 * self.Primary.Cone)
      
      local LastShootTime = self.Weapon:GetNetworkedFloat( "LastShootTime", 0 )
      scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))
      
      local alphafactor = self.Weapon:GetNWBool("Ironsights", false) and sights_opacity:GetFloat() or 1
      
      if self.Owner.is_traitor then
         surface.SetDrawColor( 255, 50, 50, 255 * alphafactor)
      else
         surface.SetDrawColor( 0, 255, 0, 255 * alphafactor)
      end
      
      local gap = 20 * scale
      local length = gap + 20 * scale
      surface.DrawLine( x - length, y, x - gap, y )
      surface.DrawLine( x + length, y, x + gap, y )
      surface.DrawLine( x, y - length, x, y - gap )
      surface.DrawLine( x, y + length, x, y + gap )

   end
end

-- Shooting functions largely copied from weapon_cs_base
function SWEP:PrimaryAttack(worldsnd)

   self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not self:CanPrimaryAttack() then return end
   
   if not worldsnd then
      self.Weapon:EmitSound( self.Primary.Sound )
   else
      WorldSound(self.Primary.Sound, self:GetPos())
   end

   self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
   
   self:TakePrimaryAmmo( 1 )
   
   if not ValidEntity(self.Owner) or self.Owner:IsNPC() or not self.Owner.ViewPunch then return end
   
   self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
   
   if ( (SinglePlayer() and SERVER) or CLIENT ) then
      self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
   end

end

function SWEP:DryFire(setnext)
   if CLIENT and LocalPlayer() == self.Owner then
      self:EmitSound( "Weapon_Pistol.Empty" )
   end

   setnext(self, CurTime() + 0.2)

   self:Reload()
end

function SWEP:CanPrimaryAttack()
   if self.Weapon:Clip1() <= 0 then
      self:DryFire(self.SetNextPrimaryFire)
      return false
   end
   return true
end

function SWEP:CanSecondaryAttack()
   if self.Weapon:Clip2() <= 0 then
      self:DryFire(self.SetNextSecondaryFire)
      return false
   end
   return true
end

local function Sparklies(attacker, tr, dmginfo)
   if tr.HitWorld and tr.MatType == MAT_METAL then
      local eff = EffectData()
      eff:SetOrigin(tr.HitPos)
      eff:SetNormal(tr.HitNormal)
      util.Effect("cball_bounce", eff)
   end
end

function SWEP:ShootBullet( dmg, recoil, numbul, cone )
   local sights = self.Weapon:GetNWBool("Ironsights", false)

   numbul = numbul or 1
   cone   = cone   or 0.01
   
   -- 10% accuracy bonus when sighting
   cone = sights and (cone * 0.9) or cone

   local bullet = {}
   bullet.Num    = numbul
   bullet.Src    = self.Owner:GetShootPos()
   bullet.Dir    = self.Owner:GetAimVector()
   bullet.Spread = Vector( cone, cone, 0 )
   bullet.Tracer = 4
   bullet.Force  = 5
   bullet.Damage = dmg
   if CLIENT and sparkle:GetBool() then
      bullet.Callback = Sparklies
   end
   --bullet.Attacker = self.Owner
   
   self.Owner:FireBullets( bullet )
   self.Weapon:SendWeaponAnim(self.PrimaryAnim)
   
   -- Owner can die after firebullets, giving an error at muzzleflash
   if not IsValid(self.Owner) or not self.Owner:Alive() then return end
   
   self.Owner:MuzzleFlash()
   self.Owner:SetAnimation( PLAYER_ATTACK1 )
   
   if self.Owner:IsNPC() then return end
   
   if ((SinglePlayer() and SERVER) or
       ((not SinglePlayer()) and CLIENT and IsFirstTimePredicted() )) then
      
      -- reduce recoil if ironsighting
      recoil = sights and (recoil * 0.75) or recoil

      local eyeang = self.Owner:EyeAngles()
      eyeang.pitch = eyeang.pitch - recoil
      self.Owner:SetEyeAngles( eyeang )
      
   end

end

function SWEP:DrawWeaponSelection() end

function SWEP:SetIronsights( b )
   if ValidEntity(self.Weapon) then
      self.Weapon:SetNetworkedBool( "Ironsights", b )

      -- Obsessive optimization: cache ironsight state so server can get at it
      -- faster
      self.sighting = b
   end
end

function SWEP:GetIronsights()
   if SERVER then
      return self.sighting
   else
      return self.Weapon:GetNWBool("Ironsights", false)
   end
end

function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   --if self:GetNextSecondaryFire() > CurTime() then return end
   
   self:SetIronsights(not self:GetIronsights())
   
   self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:Deploy()
   self:SetIronsights(false)
   return true
end

function SWEP:Reload()
   self.Weapon:DefaultReload(self.ReloadAnim)
   self:SetIronsights( false )
end


function SWEP:OnRestore()
   self.NextSecondaryAttack = 0
   self:SetIronsights( false )
end

function SWEP:Ammo1()
   return ValidEntity(self.Owner) and self.Owner:GetAmmoCount(self.Primary.Ammo) or false
end

-- The OnDrop() hook is useless for this as it happens AFTER the drop. OwnerChange
-- does not occur when a drop happens for some reason. Hence this thing.
function SWEP:PreDrop()
   if SERVER and ValidEntity(self.Owner) and self.Primary.Ammo != "none" then
      local ammo = self:Ammo1()

      -- Do not drop ammo if we have another gun that uses this type
      for _, w in pairs(self.Owner:GetWeapons()) do
         if ValidEntity(w) and w != self and w:GetPrimaryAmmoType() == self:GetPrimaryAmmoType() then
            ammo = 0
         end
      end
      
      self.StoredAmmo = ammo

      if ammo > 0 then
         self.Owner:RemoveAmmo(ammo, self.Primary.Ammo)
      end
   end
end

function SWEP:DampenDrop()
   -- For some reason gmod drops guns on death at a speed of 400 units, which
   -- catapults them away from the body. Here we want people to actually be able
   -- to find a given corpse's weapon, so we override the velocity here and call
   -- this when dropping guns on death.
   local phys = self:GetPhysicsObject()
   if IsValid(phys) then
      phys:SetVelocityInstantaneous(Vector(0,0,-75) + phys:GetVelocity() * 0.001)
      phys:AddAngleVelocity(phys:GetAngleVelocity() * -0.99)
   end
end

function SWEP:Equip(newowner)
   if SERVER then
      if self:IsOnFire() then
         self:Extinguish()
      end

      self.fingerprints = self.fingerprints or {}

      if not table.HasValue(self.fingerprints, newowner) then
         table.insert(self.fingerprints, newowner)
      end
   end

   if SERVER and IsValid(newowner) and self.StoredAmmo > 0 and self.Primary.Ammo != "none" then
      local ammo = newowner:GetAmmoCount(self.Primary.Ammo)
      local given = math.min(self.StoredAmmo, self.Primary.ClipMax - ammo)

      newowner:GiveAmmo( given, self.Primary.Ammo)
      self.StoredAmmo = 0
   end
end

function SWEP:Initialize()
   if CLIENT and self.Weapon:Clip1() == -1 then
      self.Weapon:SetClip1(self.Primary.DefaultClip)
   elseif SERVER then
      self:SetWeaponHoldType( self.HoldType )

      self.fingerprints = {}
   end
   
   self.Weapon:SetNetworkedBool( "Ironsights", false )
end

function SWEP:Think()
end

function SWEP:DyingShot()
   local fired = false
   if self.Weapon:GetNWBool("Ironsights", false) then
      self:SetIronsights(false)

      if self.Weapon:GetNextPrimaryFire() > CurTime() then
         return fired
      end

      -- Owner should still be alive here
      if ValidEntity(self.Owner) then
         local punch = self.Primary.Recoil or 5

         -- Punch view to disorient aim before firing dying shot
         local eyeang = self.Owner:EyeAngles()
         eyeang.pitch = eyeang.pitch - math.Rand(-punch, punch)
         eyeang.yaw = eyeang.yaw - math.Rand(-punch, punch)
         self.Owner:SetEyeAngles( eyeang )

         MsgN(self.Owner:Nick() .. " fired his DYING SHOT")

         self.Owner.dying_wep = self.Weapon

         self:PrimaryAttack(true)

         fired = true
      end
   end

   return fired
end

-- weapon_cs_base copypasting ahoy
local IRONSIGHT_TIME = 0.25
function SWEP:GetViewModelPosition( pos, ang )
   if not self.IronSightsPos then return pos, ang end

   local bIron = self.Weapon:GetNetworkedBool( "Ironsights" )
   
   if bIron != self.bLastIron then
      self.bLastIron = bIron 
      self.fIronTime = CurTime()
      
      if bIron then 
         self.SwayScale = 0.3
         self.BobScale = 0.1
      else 
         self.SwayScale = 1.0
         self.BobScale = 1.0
      end
      
   end
   
   local fIronTime = self.fIronTime or 0
   if not bIron and fIronTime < CurTime() - IRONSIGHT_TIME then 
      return pos, ang 
   end
   
   local mul = 1.0
   
   if fIronTime > CurTime() - IRONSIGHT_TIME then
      
      mul = math.Clamp( (CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1 )
      
      if not bIron then mul = 1 - mul end
      
   end

   local offset = self.IronSightsPos
   
   if self.IronSightsAng then
      ang = ang * 1
      ang:RotateAroundAxis( ang:Right(),    self.IronSightsAng.x * mul )
      ang:RotateAroundAxis( ang:Up(),       self.IronSightsAng.y * mul )
      ang:RotateAroundAxis( ang:Forward(),  self.IronSightsAng.z * mul )
   end

   pos = pos + offset.x * ang:Right() * mul
   pos = pos + offset.y * ang:Forward() * mul
   pos = pos + offset.z * ang:Up() * mul

   return pos, ang
end
