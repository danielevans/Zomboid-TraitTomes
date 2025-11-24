require "ISUI/ISInventoryPaneContextMenu"
require "ISUI/ISContextMenu"
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

local function traitOperation(trait)
  local op = "+"
  if trait:getCost() < 0 then
	  op = "-"
  end
  return { op=op, trait=trait:getType(), label=trait:getLabel() }
end

function contextTT.InsertTraitOp(item, operation, player)
	local modData = item:getModData()
	modData.traitDeltas = modData.traitDeltas or {}
	table.insert(modData.traitDeltas, operation)

	item:setName(item:getName() .. " - " .. operation.label)
	local pdata = getPlayerData(player:getPlayerNum())
	if pdata then
		pdata.playerInventory:refreshBackpacks()
		pdata.lootInventory:refreshBackpacks()
	end
end

---@param context ISContextMenu
function contextTT.doContextMenu(playerID, context, items)
	local actualItems = ISInventoryPane.getActualItems(items)
	local player = getSpecificPlayer(playerID)

	for i,item in ipairs(actualItems) do
		local itemType = item:getType()
		if (itemType == "TraitTome") or (itemType == "TraitScroll") then
			local isAdmin = getAccessLevel() == "admin"
			local itemModData = item:getModData()
			local traitDeltas = itemModData.traitDeltas
			local traitsPresent = traitDeltas
			if isAdmin and (not traitsPresent) then
				local option = context:addOption("Add Traits to Tome", actualItems, contextTT.readItems, player)
				local subMenu = ISContextMenu:getNew(context)

				local traitOptions = {}

				for i=0,TraitFactory:getTraits():size()-1 do
					local trait = TraitFactory:getTraits():get(i)
					if trait:getCost() > 0 then
						table.insert(traitOptions, trait)
					end
				end

				table.sort(traitOptions, function(l,r)
					return l:getCost() < r:getCost()
				end)

				for j,trait in pairs(traitOptions) do
					local operation = traitOperation(trait)

					local text = trait:getCost() .. "pts: " .. operation.label
					local subOption = subMenu:addOption(text, item, contextTT.InsertTraitOp, operation, player)
				end

			    context:addSubMenu(option, subMenu)
			end

			if traitsPresent then
				if (itemModData.steamId == nil) or (getSteamIDFromUsername(getOnlineUsername()) == itemModData.steamId) then
					context:addOptionOnTop(getText("ContextMenu_Read"), actualItems, contextTT.readItems, player)
				end
			end
		end
	end
end

return contextTT
