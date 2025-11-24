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
                text = text .. "Bound to: " .. tostring(traitTomeModData.username) .. " (" .. tostring(traitTomeModData.steamId) .. ")\n"
            end
        end

        local traitDeltas = traitTomeModData.traitDeltas
        text = text .. "Trait: "
        if traitDeltas then
            for _,delta in pairs(traitDeltas) do
              text = text .. "  " .. delta.label
            end
            text = text .. "\n"
        end

        self.item:setTooltip(text)

        local mx = getMouseX() + 24;
        local my = getMouseY() + 24;
        if not self.followMouse then
            mx = self:getX()
            my = self:getY()
            if self.anchorBottomLeft then
                mx = self.anchorBottomLeft.x
                my = self.anchorBottomLeft.y
            end
        end

        self.tooltip:setX(mx+11);
        self.tooltip:setY(my);

        self.tooltip:setWidth(50)
        self.tooltip:setMeasureOnly(true)
        self.item:DoTooltip(self.tooltip);
        self.tooltip:setMeasureOnly(false)
        local myCore = getCore();
        local maxX = myCore:getScreenWidth();
        local maxY = myCore:getScreenHeight();

        local tw = self.tooltip:getWidth();
        local th = self.tooltip:getHeight();

        self.tooltip:setX(math.max(0, math.min(mx + 11, maxX - tw - 1)));
        if not self.followMouse and self.anchorBottomLeft then
            self.tooltip:setY(math.max(0, math.min(my - th, maxY - th - 1)));
        else
            self.tooltip:setY(math.max(0, math.min(my, maxY - th - 1)));
        end

        self:setX(self.tooltip:getX() - 11);
        self:setY(self.tooltip:getY());
        self:setWidth(tw + 11);
        self:setHeight(th);

        if self.followMouse then
            self:adjustPositionToAvoidOverlap({ x = mx - 24 * 2, y = my - 24 * 2, width = 24 * 2, height = 24 * 2 })
        end

        self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
        self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
        self.item:DoTooltip(self.tooltip);
    end
end


