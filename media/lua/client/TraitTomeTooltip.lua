require "ISUI/ISToolTipInv"

local ISToolTipInv_render = ISToolTipInv.render
function ISToolTipInv:render()
    local itemType = self.item:getType()
    if not (itemType == "TraitTome" or itemType == "TraitScroll") then
        return ISToolTipInv_render(self)
    end

	if not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck then
		local itemObj = self.item
		local player = self.tooltip:getCharacter()
        local traitTomeModData = itemObj:getModData()
        local text = ""

        if itemType == "TraitTome" then
            if traitTomeModData.steamId == getSteamIDFromUsername(getOnlineUsername()) then
                text = text .. "Tethered to You"
            elseif traitTomeModData.steamId then
                text = text .. "Tethered to Another"
            else
                text = text .. "Untethered to a Soul"
            end
            text = text .. "\n"
        end

        -- text = text .. "Player Access Level: " .. player:getAccessLevel() .. "\n"
        if getAccessLevel() == "admin" then
            if traitTomeModData.username then
                text = text .. "Bound to Steam Account of: " .. tostring(traitTomeModData.username) .. " (" .. tostring(traitTomeModData.steamId) .. ")\n"
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

