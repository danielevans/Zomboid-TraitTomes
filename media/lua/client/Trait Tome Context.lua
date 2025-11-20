require "ISUI/ISInventoryPaneContextMenu"
require "Trait Tome Reading"

local contextTT = {}

---@param context ISContextMenu
function contextTT.postContextMenu(playerID, context, items)
	local recipeName = getRecipeDisplayName("Transcribe Journal")
	local option = context:getOptionFromName(recipeName)
	if not option then return end
	local subOption = option.subOption and context:getSubMenu(option.subOption)
	if not subOption then return end
	local actualOption = subOption:getOptionFromName(getText("ContextMenu_One"))
	if not actualOption then return end
	option.onSelect = actualOption.onSelect
	option.target = actualOption.target
	option.param1 = actualOption.param1
	option.param2 = actualOption.param2
	option.param3 = actualOption.param3
	option.param4 = actualOption.param4
	option.param5 = actualOption.param5
	option.param6 = actualOption.param6
	option.param7 = actualOption.param7
	option.param8 = actualOption.param8
	option.param9 = actualOption.param9
	option.param10 = actualOption.param10
	option.subOption = nil
end


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
		if item:getType() == "TraitTomesScrollOrganized" then
			local readOption = context:addOptionOnTop(getText("ContextMenu_Read"), actualItems, contextTT.readItems, player)
		end
	end
end


return contextTT
