POINTSHOP.Items = {}

local _, categoryDirectories = file.Find("items/*", "LUA")
for _, fname in pairs(categoryDirectories) do
	if #file.Find("items/" .. fname .. "/__category.lua", "LUA") > 0 then
		CATEGORY = {}
		if SERVER then AddCSLuaFile("items/" .. fname .. "/__category.lua") end
		include("items/" .. fname .. "/__category.lua")
		
		if not POINTSHOP.Items[CATEGORY.Name] then
			CATEGORY.Items = {}
			POINTSHOP.Items[CATEGORY.Name] = CATEGORY
		end
		
		for _, name in pairs(file.Find("items/" .. fname .. "/*.lua", "LUA")) do
			if name ~= "__category.lua" then
				ITEM = {}
				ITEM.Category = CATEGORY.Name
				ITEM.ID = string.lower(string.sub(name, 1, -5))
				ITEM.Maximum = 1
				if SERVER then AddCSLuaFile("items/" .. fname .. "/" .. name) end
				include("items/" .. fname .. "/" .. name)
				ITEM.ID = string.lower(string.sub(name, 1, -5))	-- assign it again here in case it got overwritten
				ITEM.Functions = ITEM.Functions or {}
				ITEM.Functions.GetName = ITEM.Functions.GetName or function(ply, item) return item.Name end
				ITEM.Functions.GetShopName = ITEM.Functions.GetShopName or function(ply, item) return item.Name end
				POINTSHOP.Items[CATEGORY.Name].Items[ITEM.ID] = ITEM
			end
		end
	end
end