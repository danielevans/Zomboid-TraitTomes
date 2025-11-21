require "ISUI/ISToolTipInv"


function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local fontDict = { ["Small"] = UIFont.NewSmall, ["Medium"] = UIFont.NewMedium, ["Large"] = UIFont.NewLarge, }
local fontBounds = { ["Small"] = 28, ["Medium"] = 32, ["Large"] = 42, }

local ISToolTipInv_render = ISToolTipInv.render
function ISToolTipInv:render()
    if not (self.item:getType() == "TraitTome") then
        return ISToolTipInv_render(self)
    end

	if not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck then
		---@type InventoryItem
		local itemObj = self.item
		---@type IsoPlayer|IsoGameCharacter|IsoMovingObject
		local player = self.tooltip:getCharacter()
        local traitTomeModData = itemObj:getModData()
        local text = ""

        if traitTomeModData.steamId == player:getSteamID() and traitTomeModData.username == player:getUsername() then
            text = text .. getText("TraitTomes_BoundSelf")
        elseif traitTomeModData.steamId or traitTomeModData.username then
            text = text .. getText("TraitTomes_BoundOther")
        else
            text = text .. getText("TraitTomes_Unbound")
        end

        text = text .. "\n"

        if player:getAccessLevel() == "admin" or getDebugOptions then
            if traitTomeModData.steamId then
                text = text .. "SteamID: " .. traitTomeModData.steamId .. "\n"
            end
            if traitTomeModData.username then
                text = text .. "Username: " .. traitTomeModData.username .. "\n"
            end
        end


        local traitDeltas = traitTomeModData.traitDeltas
        text = text .. "Traits Added:\n"
        if traitDeltas then
            for _,delta in pairs(traitDeltas) do
              text = text .. "  " .. delta.op .. delta.label .. "\n"
            end
        end

        local mx = getMouseX() + 24;
        local my = getMouseY() + 24;

        self.item:setTooltip(text)

        self.tooltip:setX(mx);
        self.tooltip:setY(my);

        self.item:DoTooltip(self.tooltip)
	end
end

