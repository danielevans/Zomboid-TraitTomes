local contextTT = require "TraitTomeContext"
if contextTT then
    Events.OnPreFillInventoryObjectContextMenu.Add(contextTT.doContextMenu)
end
