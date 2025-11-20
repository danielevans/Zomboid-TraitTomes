function InsertTraitOp(items, operation)
  for i=0,items:size()-1 do
    local item = items:get(i)
    if item:getType() == "TraitTome" then
        local modData = item:getModData()
        modData.traitDeltas = modData.traitDeltas or {}
        table.insert(modData.traitDeltas, operation)
    end
  end
end

function CanInsertTraitOp(item, operation)
  if item:getType() == "TraitTome" then
    local modData = item:getModData()
    if not modData.traitDeltas then
        return true
    end

    modData.traitDeltas = modData.traitDeltas or {}
    local traitDeltas = modData.traitDeltas

    for _i,delta in ipairs(traitDeltas) do
        if delta.trait == operation.trait then
            return false
        end
    end
  end
  return true
end

function AddOrganizedToTraitTome(items, result, player)
  InsertTraitOp(items, {op="+", trait="Organized"})
end

function CanAddOrganizedToTraitTome(item)
  return CanInsertTraitOp(item, {op="+", trait="Organized"})
end

function AddRemoveDisorganizedToTraitTome(items, result, player)
  InsertTraitOp(items, {op="-", trait="Disorganized"})
end

function CanAddRemoveDisorganizedToTraitTome(item)
  return CanInsertTraitOp(item, {op="-", trait="Disorganized"})
end




