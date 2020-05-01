AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/combine_helicopter/helicopter_bomb01.mdl")
	self:SetupPhysicsSphere(2)
	self:DrawShadow(false)
	
	-- rod data
	self.Rod = nil
	
	-- sticking data
	self.Mass = 1
	self.TotalAttachedMass = 0
	self.TotalMass = 1
	self.AttachedEntities = {}
	self.AttachedObjects = {}
	
	self.LastDetachTimes = {}
	
	-- debugging
	self.Trail = nil
end


-- physics
function ENT:SetupPhysicsSphere(radius)
	self.Radius = radius
	self:PhysicsInitSphere(radius)
	self:SetCollisionBounds(Vector(-radius, -radius, -radius), Vector(radius, radius, radius))
	
	local physObj = self:GetPhysicsObject()
	if physObj and physObj:IsValid() then
		physObj:Wake()
		
		-- make bobber trajectory calculations easier by removing air resistance
		physObj:EnableDrag(false)
		
		local _, angDamp = physObj:GetDamping()
		physObj:SetDamping(0, angDamp * 10)	-- need to increase angular damping so it stops rolling sooner
	end
end

function ENT:AddVelocity(vel)
	if not self:GetPhysicsObject() or not self:GetPhysicsObject():IsValid() then return end
	
	self:GetPhysicsObject():AddVelocity(vel)
	self:GetPhysicsObject():Wake()
	
	self:CheckAttachedObjects()
	-- apply same total momentum as vel * total mass, but
	-- distribute it so that the attached part gets slightly more
	for _, objectData in pairs(self.AttachedObjects) do
		if objectData.Entity and objectData.Entity:IsValid() then
			objectData.PhysicsObject:AddVelocity(vel)
			objectData.PhysicsObject:AddVelocity(vel * (objectData.TotalMass - objectData.PhysicsObject:GetMass()) / objectData.PhysicsObject:GetMass() * 0.1)
			if objectData.Entity and objectData.Entity:IsValid() then
				local physObjCount = objectData.Entity:GetPhysicsObjectCount()
				for i = 0, physObjCount - 1 do
					if objectData.PhysicsObjectId ~= i then
						local physObj = objectData.Entity:GetPhysicsObjectNum(i)
						if physObj and physObj:IsValid() then
							physObj:AddVelocity(vel * 0.9)
						end
					end
				end
			end
		end
	end
end

function ENT:GetVelocity()
	if not self:GetPhysicsObject() or not self:GetPhysicsObject():IsValid() then return end
	
	return self:GetPhysicsObject():GetVelocity()
end

function ENT:GetTotalAttachedMass()
	return self.TotalAttachedMass
end

function ENT:GetTotalMass()
	return self.TotalMass
end

function ENT:SetMass(mass)
	if not self:GetPhysicsObject() or not self:GetPhysicsObject():IsValid() then return end
	
	self:GetPhysicsObject():SetMass(mass)
end

function ENT:WakeAttachedObjects()
	for _, objectData in pairs(self.AttachedObjects) do
		self:WakeObject(objectData.Entity)
	end
end

function ENT:WakeObject(ent)
	if not ent or not ent:IsValid() then return end
	local physObjCount = ent:GetPhysicsObjectCount()
	for i = 0, physObjCount - 1 do
		local physObj = ent:GetPhysicsObjectNum(i)
		if physObj and physObj:IsValid() and physObj:IsAsleep() then
			physObj:Wake()
		end
	end
end

-- sticking
function ENT:StartTouch(ent)
	if not ent or not ent:IsValid() then return end
	if ent:IsPlayer() then return end
	
	if self:IsObjectAttached(ent) then return end
	if CurTime() - self:GetLastDetachTime(ent) < 1 then return end
	self:AttachObject(ent)
end

function ENT:EndTouch(ent)
	if not ent or not ent:IsValid() then return end
	if ent:IsPlayer() then return end
	
	if self:IsObjectAttached(ent) then return end
	self.LastDetachTimes [ent] = CurTime()
end

function ENT:AttachObject(ent)
	-- ignore objects that are already attached
	if self:IsObjectAttached(ent) then return end

	local physObjCount = ent:GetPhysicsObjectCount()
	
	local objectData = {}
	objectData.ID = #self.AttachedObjects + 1
	objectData.Entity = ent
	objectData.TotalMass = 0
	
	local closestPhysObjId = -1
	local closestDistanceSqr = 32768 * 32768
	for i = 0, physObjCount - 1 do
		local physObj = ent:GetPhysicsObjectNum(i)
		if physObj and physObj:IsValid() then
			objectData.TotalMass = objectData.TotalMass + physObj:GetMass()
			
			local distSqr = (physObj:GetPos() - self:GetPos()):LengthSqr()
			if distSqr < closestDistanceSqr then
				closestDistanceSqr = distSqr
				closestPhysObjId = i
				objectData.PhysicsObject = physObj
				objectData.PhysicsObjectId = i
			end
		end
	end
	
	if closestPhysObjId == -1 then return end
	
	self.AttachedEntities[ent] = objectData
	self.AttachedObjects[#self.AttachedObjects + 1] = objectData
	self.TotalAttachedMass = self.TotalAttachedMass + objectData.TotalMass
	self.TotalMass = self.TotalMass + objectData.TotalMass
	
	constraint.Weld(self, ent, 0, closestPhysObjId, 0, true)
	
	self:WakeObject(ent)
end

function ENT:CheckAttachedObjects()
	local invalidIds = {}
	for k, objectData in pairs(self.AttachedObjects) do
		if not objectData.Entity or not objectData.Entity:IsValid() then
			invalidIds[#invalidIds + 1] = k
			
			self.TotalAttachedMass = self.TotalAttachedMass - objectData.TotalMass
			self.TotalMass = self.TotalMass - objectData.TotalMass
		end
	end
	
	for _, id in ipairs(invalidIds) do
		self.AttachedObjects[id] = nil
	end
end

function ENT:DetachAllObjects()
	for ent, _ in pairs(self.AttachedEntities) do
		self.LastDetachTimes [ent] = CurTime()
	end

	self.AttachedEntities = {}
	self.AttachedObjects = {}
	
	constraint.RemoveConstraints(self, "Weld")	
	self.TotalAttachedMass = 0
	self.TotalMass = self.Mass
end

function ENT:GetAttachedObjects()
	local obj = {}
	for ent, _ in pairs(self.AttachedEntities) do
		if ent:IsValid() then
			obj [#obj + 1] = ent
		end
	end
	return obj
end

function ENT:GetLastDetachTime(ent)
	if self.LastDetachTimes[ent] then
		return self.LastDetachTimes[ent]
	end
	return 0
end

function ENT:IsObjectAttached(ent)
	if self.AttachedEntities [ent] then return true end
	return false
end

function ENT:Destroy()
	self:SetRod(nil)
	self:Remove()
end

function ENT:GetRod()
	return self.Rod
end

function ENT:SetRod(rod)
	self.Rod = rod
	self.dt.Rod = self.Rod or ents.GetByIndex(-2)
	self.dt.RodOwner = self.Rod and self.Rod.Owner or ents.GetByIndex(-2)
end

-- debugging
function ENT:AddTrail()
	if self.Trail and self.Trail:IsValid() then
		self.Trail:Remove()
	end
	self.Trail = util.SpriteTrail(self, 0, Color(255, 0, 0), false, 1, 1, 4, 1 / (15 + 1) * 0.5, "trails/laser.vmt")
end

function ENT:RemoveTrail()
	if not self.Trail or not self.Trail:IsValid() then return end
	self.Trail:Remove()
	self.Trail = nil
end

function ENT:OnRemove()
	self:RemoveTrail()
end