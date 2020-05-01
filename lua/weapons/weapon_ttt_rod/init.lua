AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function SWEP:Initialize()
	self:InitHoldType()
	self:InitState()
	
	self.Bobber = nil
end

-- weapon actions
function SWEP:Deploy()
	self:SetBobberDeployed(false)
	self:CreateBobber()
end

function SWEP:Holster()
	self:DestroyBobber()
	return true
end

function SWEP:OnRemove()
	self:DestroyBobber()
end

function SWEP:SecondaryAttack()
	self.Bobber:DetachAllObjects()
end

-- bobber
function SWEP:CheckBobber()
	if self.Bobber and not self.Bobber:IsValid() then
		self.Bobber = nil
	end
	return self.Bobber ~= nil
end

function SWEP:CreateBobber()
	if self:CheckBobber() then return end
	
	self.Bobber = ents.Create("ttt_rod_bobber")
	self.Bobber:Spawn()
	self.Bobber:SetRod(self)
	self:AttachBobber()
end

function SWEP:DestroyBobber()
	if not self:CheckBobber() then return end
	
	self.Bobber:Destroy()
	self.Bobber = nil
end

function SWEP:Think()
	if not self:IsBobberDeployed() then
		if self:CheckBobber() then
			if self:GetRodTip() ~= self.Bobber:GetPos() then
				self.Bobber:SetPos(self:GetRodTip())
				
				local eyeAngles = self.Owner:EyeAngles()
				eyeAngles.r = 0
				self.Bobber:SetAngles(self.AttachAngles + eyeAngles)
				self.Bobber:WakeAttachedObjects()
			end
		end
	end
end

hook.Add("ShouldCollide", "RodBobberPlayerCollisions", function(e1, e2)
	local bobber = nil
	local ply = nil
	if e1:GetClass() == "ttt_rod_bobber" then
		bobber = e1
	end
	if e2:GetClass() == "ttt_rod_bobber" then
		bobber = e2
	end
	if e1:IsPlayer() then
		ply = e1
	end
	if e2:IsPlayer() then
		ply = e2
	end
	if not bobber or not ply then return end
	
	if bobber and ply then
		if not bobber:GetRod() then return end
		if bobber:GetRod().Owner == ply then
			if not bobber:GetRod():IsBobberDeployed() then
				return false
			end
		end
	end
end)

-- trajectory calculation
function SWEP:CalculateTrajectory(angle)
	local startpos = self.Bobber:GetPos()
	
	local tr = {}
	tr.start = self.Owner:EyePos()
	tr.endpos = tr.start + self.Owner:EyeAngles():Forward() * 32768
	tr.filter = self.Bobber:GetAttachedObjects()
	tr.filter[#tr.filter + 1] = self.Owner
	tr = util.TraceLine(tr)
	local endpos = tr.HitPos
	local hit = tr.Hit and not tr.HitSky
	local deltapos = endpos - startpos
	
	local v = Vector(0, 0, 100)
	local failed = false
	if hit then
		local y_start = 0
		local y_end = endpos.z - startpos.z
		local x_start = 0
		local x_end = math.sqrt(deltapos.x * deltapos.x + deltapos.y * deltapos.y)
		local x_dist = x_end - x_start
		
		-- see bottom of this file for details
		local sintheta = math.sin(math.rad(angle))
		local sin2theta = math.sin(math.rad(2 * angle))
		local costheta = math.cos(math.rad(angle))
		local g = -physenv.GetGravity().z
		local invvelsqr = (sin2theta / x_end - 2 * y_end / x_end / x_end * costheta * costheta) / g
		local velsqr = 1 / invvelsqr
		if velsqr < 0 then
			failed = true
		else
			local vel = math.sqrt(velsqr)
			local ang = Angle(-angle, math.deg(math.atan2(endpos.y - startpos.y, endpos.x - startpos.x)), 0)
			v = Vector(1, 0, 0) * vel
			v:Rotate(ang)
			
			--[[
			-- trace out the parabola for debugging
			local t_impact = x_end / vel / costheta
			local xfunc, yfunc = self:CreateParametricFunctions(g, vel, angle)
			local forward = Vector(endpos.x - startpos.x, endpos.y - startpos.y, 0)
			forward:Normalize()
			local function transform(x, y)
				local pos3d = Vector(0, 0, y)
				pos3d = pos3d + forward * x
				pos3d = pos3d + startpos
				return pos3d
			end
			
			for t_step = 0, t_impact, 0.1 do
				self:CreateMarker(transform(xfunc(t_step), yfunc(t_step)))
			end
			self:CreateMarker(transform(xfunc(t_impact), yfunc(t_impact)))
			]]
		end
	else
		failed = true
	end
	
	if failed then
		v = Vector(1, 0, 0)
		v:Rotate(self.Owner:EyeAngles())
		v = v + Vector(0, 0, 1)
		v = v * 700
	end
	
	return v
end

-- debugging functions
function SWEP:CreateMarker(pos)
	local code = [[
		H = H or {}
		O = ClientsideModel("models/combine_helicopter/helicopter_bomb01.mdl")
		H[#H + 1] = O
		O:SetModelScale(Vector(0.125, 0.125, 0.125))
		O:SetPos(Vector(]] .. tostring(pos.x) .. [[, ]] .. tostring(pos.y) .. [[, ]] .. tostring(pos.z) .. [[))
	]]
	BroadcastLua(code)
end

function SWEP:CreateParametricFunctions(g, v, theta)
	local sintheta = math.sin(math.rad(theta))
	local costheta = math.cos(math.rad(theta))
	return function(t)
		return v * t * costheta
	end, function(t)
		return v * t * sintheta - 0.5 * g * t * t
	end
end

--[[
	parametric equations, ignoring air resistance

	a_x = 0
	a_y = -g
	
	v_x = v * cos angle
	v_y = v * sin angle - gt
		
	x_x = v * t * cos angle
	x_y = v * t * sin angle - 0.5gt ^ 2
		
	solving x_x for x_end:
	
	x_end = v * t * cos angle
	t = x_end / (v * cos angle)
	
	at this t, x_y must be y_end
	
	y_end = v * x_end / v / cos angle * sin angle - 0.5gt^2
	      = x_end * tan angle - 0.5g x_end^2 / v^2 / cos^2 angle
	0.5g x_end^2 / v^2 / cos^2 angle = x_end * tan angle - y_end
	0.5g / v^2 / cos^2 angle = tan angle / x_end - y_end / x_end^2
	0.5g / v^2 = 0.5sin 2angle / x_end - y_end / x_end^2 * cos^2 angle
	1 / v^2 = sin 2 angle / (g * x_end) - 2y_end / (g * x_end^2) * cos^2 angle
	v^2 = 1 / ...
	v = sqrt(1 / ...)
	
	note that 2sin angle cos angle = sin 2angle
]]