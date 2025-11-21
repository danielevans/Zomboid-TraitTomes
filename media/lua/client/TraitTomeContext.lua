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


function traitRefusedReason(item, trait, operation)
  local t = trait:getType()
  local modData = item:getModData()
  local exclusiveTraits = trait:getMutuallyExclusiveTraits()
  if modData and modData.traitDeltas then
	  for i,delta in pairs(modData.traitDeltas) do
		  if delta.trait == t then
			  return "Already Added"
		  end
		  if operation.op == "+" then
			for j=0,exclusiveTraits:size()-1 do
				local exclusiveTrait = exclusiveTraits:get(j)
				if delta.trait == exclusiveTrait and delta.op == "+" then
				return "Mutually Exlclusive with " .. exclusiveTrait
				end
			end
		  end
	  end
  end
  return nil
end

function traitOperation(trait)
  local op = "+"
  if trait:getCost() < 0 then
	  op = "-"
  end
  return { op=op, trait=trait:getType(), label=trait:getLabel() }
end

function contextTT.InsertTraitOp(item, operation)
    print("testing")
	local modData = item:getModData()
	modData.traitDeltas = modData.traitDeltas or {}
	table.insert(modData.traitDeltas, operation)
end

---@param context ISContextMenu
function contextTT.doContextMenu(playerID, context, items)
	local actualItems = ISInventoryPane.getActualItems(items)
	local player = getSpecificPlayer(playerID)

	for i,item in ipairs(actualItems) do
		if item:getType() == "TraitTome" then
			if player:getAccessLevel() == "admin" or getDebugOptions then
				local option = context:addOption("Add Traits to Tome", actualItems, contextTT.readItems, player)
				local subMenu = ISContextMenu:getNew(context)

				subMenu:addOptionOnTop("Add Traits to Tome 1", actualItems, contextTT.readItems, player)
				subMenu:addOptionOnTop("Add Traits to Tome 2", actualItems, contextTT.readItems, player)

				for i=0,TraitFactory:getTraits():size()-1 do
					local trait = TraitFactory:getTraits():get(i)
					local operation = traitOperation(trait)
					local traitRefused = traitRefusedReason(item, trait, operation)

					local text = operation.op .. operation.label .. "  (" .. operation.trait .. ") [".. trait:getCost() .."]"

					local subOption = subMenu:addOption(text, item, contextTT.InsertTraitOp, operation)

					if traitRefused then
						subOption.notAvailable = true
						local tooltip = ISInventoryPaneContextMenu.addToolTip()
						tooltip.description = traitRefused
						subOption.toolTip = tooltip
					end
				end


			    context:addSubMenu(option, subMenu)

			end

			context:addOptionOnTop(getText("ContextMenu_Read"), actualItems, contextTT.readItems, player)
		end
	end
end



return contextTT
