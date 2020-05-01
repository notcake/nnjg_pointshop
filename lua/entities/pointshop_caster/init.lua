AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

--ENT.NoRemoveOnDeath = true

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Think()
end

function ENT:SetupHat(ply, item)	
	self:SetOwner(ply)
	self:DrawShadow(false)
	
	self:SetParent(ply)
	self:SetPos(ply:GetShootPos())
	
	self.ItemData = item
	
	self:Spawn()
	
	self:SetSolid( SOLID_NONE )
	self:SetNWString("item_id", item.ID)
end