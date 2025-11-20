local contextTT = require "Trait Tome Context"
if contextTT then
    Events.OnPreFillInventoryObjectContextMenu.Add(contextTT.doContextMenu)
    Events.OnFillInventoryObjectContextMenu.Add(contextTT.postContextMenu)
end
