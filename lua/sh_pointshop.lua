POINTSHOP = {}

function POINTSHOP.FindItemByID(item_id)
	for id, category in pairs(POINTSHOP.Items) do
		if category.Enabled then
			for name, item in pairs(category.Items) do
				if item.Enabled then
					if name == item_id then
						return item
					end
				end
			end
		end
	end
	
	return false
end

function POINTSHOP.FindCategoryByItemID(item_id)
	for id, category in pairs(POINTSHOP.Items) do
		for name, item in pairs(category.Items) do
			if name == item_id then
				return category
			end
		end
	end
	
	return false
end

function POINTSHOP.ValidateItems(items)
	for k, item_id in pairs(items) do
		if not POINTSHOP.FindItemByID(item_id) then
			table.remove(items, k)
		end
	end
	return items
end

function POINTSHOP.ValidateItemCounts(ply, itemcounts)
	local toremove = {}
	for item_id, _ in pairs(itemcounts) do
		if not ply:PS_HasItem(item_id) then
			toremove[#toremove + 1] = item_id
		end
	end
	for _, item_id in ipairs(toremove) do
		itemcounts[item_id] = nil
	end
	return itemcounts
end

function POINTSHOP.FindPlayerByName(name)
	local found = {}
	
	for _, ply in pairs(player.GetAll()) do
		if string.find(string.lower(ply:Nick()), string.lower(name)) then
			table.insert(found, ply)
		end
	end
	
	if #found < 1 then
		return false
	elseif #found > 1 then
		return true
	else
		return found[1]
	end
end