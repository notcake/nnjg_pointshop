ITEM.Name = "Mystery Box"
ITEM.Enabled = true
ITEM.Description = "Contains a random item from the shop."
ITEM.Cost = 250
ITEM.Model = "models/items/item_item_crate.mdl"
ITEM.HideInInventory = true
ITEM.Maximum = 2

ITEM.Functions = {
	OnBuy = function(ply, item)
		local this_id = item.ID
		local items = {}
		for id, category in pairs(POINTSHOP.Items) do
			if category.Enabled then
				for item_id, item in pairs(category.Items) do
					if item.Enabled and
						item_id ~= this_id and
						ply:PS_GetItemCount(item_id) < item.Maximum then
						items [#items + 1] = item_id
					end
				end
			end
		end
		local item_id = items [math.random(1, #items)]
		local item = POINTSHOP.FindItemByID(item_id)
		ply:PS_GiveItem(item_id)
		ply:PS_Notify("You received: " .. item.Functions.GetName (ply, item))
	end
}