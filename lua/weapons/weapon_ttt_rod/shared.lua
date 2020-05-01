SWEP.Author 				= "!cake"
SWEP.Contact 				= "cakenotfound@gmail.com"
SWEP.Purpose 				= "Fun"
SWEP.Instructions 			= "Left click to deploy and retract, right click to drop items"
SWEP.PrintName 				= "Magneto Rod"

SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true

SWEP.Base					= "weapon_tttbase"

SWEP.ViewModel				= Model("models/weapons/v_stunbaton.mdl")
SWEP.WorldModel				= Model("models/weapons/w_stunbaton.mdl")

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

-- TTT data
SWEP.Kind					= (WEAPON_ROLE or 0) + 2	-- this category should be unique
SWEP.InLoadoutFor			= {ROLE_INNOCENT, ROLE_TRAITOR, ROLE_DETECTIVE}

SWEP.NoSights				= true
SWEP.IsSilent				= true

SWEP.AutoSpawnable			= false

SWEP.AllowDelete			= false
SWEP.AllowDrop				= false

if CLIENT then
	SWEP.Slot 					= 9
	SWEP.SlotPos 				= 1
	SWEP.DrawAmmo				= false
	SWEP.DrawCrosshair			= false
	SWEP.ViewModelFOV			= 70
	SWEP.ViewModelFlip			= false
end

if SERVER then
	SWEP.Weight					= 5
	SWEP.AutoSwitchTo			= false
	SWEP.AutoSwitchFrom			= false
end

function SWEP:InitHoldType()
	if self.SetWeaponHoldType then
		self:SetWeaponHoldType("pistol")
	end
end

function SWEP:InitState()
	self:SetBobberDeployed(false)
	
	self.LastPrimaryAttack = 0
	self.WaitingForRelease = false
	
	self.AttachAngles = Angle(0, 0, 0)
end

function SWEP:SetupDataTables()
	self:DTVar("Bool",0,"BobberDeployed");
end

-- state
function SWEP:IsBobberDeployed()
	return self.dt.BobberDeployed
end

function SWEP:SetBobberDeployed(bobberDeployed)
	self.dt.BobberDeployed = bobberDeployed
end

-- bobber
function SWEP:AttachBobber()
	if SERVER then
		self.Bobber:Attach()
		
		-- the bobber cannot be parented to the rod otherwise all the weld constraints would be disabled
		
		self.Bobber:SetNotSolid(true)
		self.Bobber:GetPhysicsObject():EnableMotion(false)
		self.Bobber:GetPhysicsObject():EnableGravity(false)
		self.Bobber:GetPhysicsObject():Sleep()
		
		self.Bobber:WakeAttachedObjects() -- otherwise they may be stationary whilst the player moves
	end
	self.AttachAngles = self.Bobber:GetAngles()
	self.AttachAngles.p = self.AttachAngles.p - self.Owner:EyeAngles().p
	self.AttachAngles.y = self.AttachAngles.y - self.Owner:EyeAngles().y
end

function SWEP:DetachBobber()
	if SERVER then
		self.Bobber:Detach()
		self.Bobber:SetNotSolid(false)
		self.Bobber:GetPhysicsObject():EnableMotion(true)
		self.Bobber:GetPhysicsObject():EnableGravity(true)
		self.Bobber:GetPhysicsObject():Wake()
	end
end

-- bobber calculations
function SWEP:GetRodTip()
	local att = self.Owner:GetAttachment(self.Owner:LookupAttachment("anim_attachment_RH"))
	local deltapos = Vector(4, 2, 18)
	deltapos:Rotate(att.Ang)
	return att.Pos + deltapos
end

function SWEP:GetRodTipAngles()
	local att = self.Owner:GetAttachment(self.Owner:LookupAttachment("anim_attachment_RH"))
	return att.Ang
end

function SWEP:OnDrop()
	self:Remove()
end

-- actions
function SWEP:PrimaryAttack()
	if self:IsWaitingForRelease() then
		if not self:IsReleased() then
			self.LastPrimaryAttack = CurTime()
			return
		end
		self:StopWaitingForRelease()
	end
	self.LastPrimaryAttack = CurTime()
	
	if not self:IsBobberDeployed() then
		self:SetBobberDeployed(true)
		self:DetachBobber()
		
		self:EmitSound("weapons/ar2/fire1.wav", 45, 100)
		
		if SERVER then
			local v = self:CalculateTrajectory(45)
			self.Bobber:AddVelocity(v)
			
			-- apply recoil, pitch only
			self.Owner:ViewPunch(Angle(-math.Clamp(math.sqrt(self.Bobber:GetTotalMass()) * math.max(math.pow(v:Length(), 0.4), 1), -45, 45), 0, 0))
		end
		self:WaitForRelease()
	else
		if SERVER then
			local dest = self:GetRodTip()
			local deltapos = dest - self.Bobber:GetPos()
			local dist = deltapos:Length()
			if dist < 4 then
				self:WaitForRelease()
				self:SetBobberDeployed(false)
				self:AttachBobber()
			else
				local targetvel = deltapos:GetNormalized()
				dist = dist * 4
				targetvel = targetvel * dist
				local deltav = targetvel - self.Bobber:GetVelocity()
				if deltav:Length() > 64 then
					deltav = deltav:GetNormalized() * 64
				end
				deltav = deltav + Vector(0, 0, 15) -- constant for gravity determined by experiment.
				self.Bobber:AddVelocity(deltav)
			end
		else
			self:WaitForRelease()
		end
	end
end

-- primary attack delays
function SWEP:IsReleased()
	return CurTime() - self.LastPrimaryAttack > 0.2
end

function SWEP:IsWaitingForRelease()
	return self.WaitingForRelease
end

function SWEP:StopWaitingForRelease()
	self.WaitingForRelease = false
end

function SWEP:WaitForRelease()
	self.WaitingForRelease = true
end