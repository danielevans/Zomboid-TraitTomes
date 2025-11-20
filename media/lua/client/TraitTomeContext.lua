require "ISUI/ISInventoryPaneContextMenu"
require "ReadTraitTome"

local contextTT = {}

function contextTT.readItems(items, player)
	items = ISInventoryPane.getActualItems(items)
	for i,item in ipairs(items) do
		if item:getContainer() ~= nil then
			ISInventoryPaneContextMenu.transferIfNeeded(player, item)
		end
		ISTimedActionQueue.add(ReadTraitTome:new(player, item))
		break
	end
end


---@param context ISContextMenu
function contextTT.doContextMenu(playerID, context, items)
	local actualItems = ISInventoryPane.getActualItems(items)
	local player = getSpecificPlayer(playerID)

	for i,item in ipairs(actualItems) do
		if item:getType() == "TraitTome" then
			context:addOptionOnTop(getText("ContextMenu_Read"), actualItems, contextTT.readItems, player)
		end
	end
end


return contextTT
