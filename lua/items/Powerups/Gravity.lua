ITEM.Name = "Low Gravity"
ITEM.Enabled = true
ITEM.Description = "Each upgrade lowers your gravity by 100."
ITEM.Cost = 125
ITEM.Model = "models/weapons/w_toolgun.mdl"
ITEM.Maximum = 4

local function GetStackTrace(pre)
	local trace = {pre}
	local offset = offset or 0
	local exit = false
	local i = 0
	local shown = 0
	while not exit do
		local t = debug.getinfo (i)
		if not t or shown == levels then
			exit = true
		else
			local name = t.name
			local src = t.short_src
			src = src or "<unknown>"
			if i >= offset then
				shown = shown + 1
				if name then
					trace [#trace + 1] = tostring (i) .. ": " .. name .. " (" .. src .. ": " .. tostring (t.currentline) .. ")"
				else
					if src and t.currentline then
						trace [#trace + 1] = tostring (i) .. ": (" .. src .. ": " .. tostring (t.currentline) .. ")"
					else
						trace [#trace + 1] = tostring (i)
					end
				end
			end
		end
		i = i + 1
	end
	
	return trace
end

ITEM.Functions = {
	GetName = function(ply, item)
		return "Low Gravity " .. tostring (ply:PS_GetItemCount(item.ID))
	end,
	
	GetShopName = function(ply, item)
		return "Low Gravity " .. tostring (ply:PS_GetItemCount(item.ID) + 1)
	end,

	OnGive = function(ply, item)
		item.Hooks.PlayerSpawn(ply, item)
	end,
	
	OnTake = function(ply, item)
		local grav = ply.OldGravity or 1
		ply:SetGravity(grav)
		
		item.StackTraces [#item.StackTraces + 1] = GetStackTrace(tostring(ply))
	end
}

ITEM.Hooks = {
	PlayerSpawn = function(ply, item)
		if not ply.OldGravity then
			ply.OldGravity = ply:GetGravity()
		end
		
		local gravity = 600
		local count = ply:PS_GetItemCount (item.ID)
		gravity = gravity - count * 149
		ply:SetGravity(gravity / 600)
	end
}

if SERVER then
	local traces = {}
	ITEM.StackTraces = traces

	concommand.Add("ps_gravity_dump", function(ply)
		for _, v in ipairs(player.GetAll()) do
			ply:PrintMessage(HUD_PRINTCONSOLE, v:Name() .. ": " .. tostring (v:PS_GetItemCount("gravity")) .. " upgrades, " .. (v:PS_IsItemDisabled("gravity") and "disabled" or "enabled") .. ", " .. tostring (v:GetGravity()) .. " relative gravity.")
		end
	end)
	
	concommand.Add("ps_gravity_dump2", function(ply)
		for k, trace in ipairs(traces) do
			if k > 20 then
				ply:PrintMessage(HUD_PRINTCONSOLE, "Too many entries!")
				return
			end
			for _, line in ipairs(trace) do
				ply:PrintMessage(HUD_PRINTCONSOLE, line)
			end
			ply:PrintMessage(HUD_PRINTCONSOLE, "")
		end
	end)
	
	local traces2 = {}
	_R.Entity.OldSetGravity = _R.Entity.OldSetGravity or _R.Entity.SetGravity
	function _R.Entity:SetGravity (gravity)
		self:OldSetGravity (gravity)
		
		if self:IsPlayer() then
			traces2 [#traces2 + 1] = GetStackTrace(tostring(self) .. " to " .. tostring(gravity))
		end
	end
	
	concommand.Add("ps_gravity_dump3", function(ply)
		for k, trace in ipairs(traces2) do
			if k > 20 then
				ply:PrintMessage(HUD_PRINTCONSOLE, "Too many entries!")
				return
			end
			for _, line in ipairs(trace) do
				ply:PrintMessage(HUD_PRINTCONSOLE, line)
			end
			ply:PrintMessage(HUD_PRINTCONSOLE, "")
		end
	end)	
end