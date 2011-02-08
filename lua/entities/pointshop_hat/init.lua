AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	
	self:SetMoveType( MOVETYPE_NONE )
	self:PhysicsInit( SOLID_VPHYSICS )
	

	// Wake the physics object up. It's time to have fun!
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
end

function ENT:SetupHat(ply, item)
	if item.Model then
		self:SetModel(item.Model)
	end
	
	self:SetOwner(ply)
	self:DrawShadow(false)
	
	self:SetParent(ply)
	self:SetPos(ply:GetShootPos())
	
	self.ItemData = item
	
	self:Spawn()
	
	self:SetSolid( SOLID_NONE )
	self:SetNWString("item_id", item.ID)
end