require "ISUI/ISToolTipInv"

local ISToolTipInv_render = ISToolTipInv.render
function ISToolTipInv:render()
    local itemtype = self.item:getType()
    if not (itemType == "TraitTome" or itemType == "TraitScroll") then
        return ISToolTipInv_render(self)
    end

	if not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck then
		local itemObj = self.item
		local player = self.tooltip:getCharacter()
        local traitTomeModData = itemObj:getModData()
        local text = ""

        if traitTomeModData.steamId == getSteamIDFromUsername(getOnlineUsername()) then
            text = text .. getText("TraitTomes_BoundSelf")
        elseif traitTomeModData.steamId then
            text = text .. getText("TraitTomes_BoundOther")
        else
            text = text .. getText("TraitTomes_Unbound")
        end
        text = text .. "\n"

        -- text = text .. "Player Access Level: " .. player:getAccessLevel() .. "\n"
        if player:getAccessLevel() == "admin" or getDebugOptions then
            if traitTomeModData.username then
                text = text .. "Bound to Steam Account of: " .. traitTomeModData.username .. " (" .. traitTomeModData.steamId .. ")\n"
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

