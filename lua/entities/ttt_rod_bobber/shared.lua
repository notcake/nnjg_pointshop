ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Rod Bobber"
ENT.Author = "!cake"
ENT.Spawnable = false
ENT.AdminSpawnable = false

-- rod attachment
function ENT:Attach()
	self.dt.Attached = true
end

function ENT:Detach()
	self.dt.Attached = false
end

function ENT:IsAttachedToRod()
	return self.dt.Attached
end

-- networking
function ENT:SetupDataTables()
	self:DTVar("Bool", 0, "Attached");
	self:DTVar("Entity", 0, "Rod");
	self:DTVar("Entity", 1, "RodOwner");
end