require "TimedActions/ISBaseTimedAction"

---@class ReadTraitTome : ISBaseTimedAction
ReadTraitTome = ISBaseTimedAction:derive("ReadTraitTome")


function ReadTraitTome:isValid()
	local vehicle = self.character:getVehicle()
	if vehicle and vehicle:isDriver(self.character) then return not vehicle:isEngineRunning() or vehicle:getSpeed2D() == 0 end
	return self.character:getInventory():contains(self.item)
end


function ReadTraitTome:start()
	self.item:setJobType(getText("ContextMenu_Read") ..' '.. self.item:getName())
	self:setAnimVariable("ReadType", "book")
	self:setActionAnim(CharacterActionAnims.Read)
	self:setOverrideHandModels(nil, self.item)

	self.character:setReading(true)
	self.character:reportEvent("EventRead")

	local logText = ISLogSystem.getGenericLogText(self.character)
end


function ReadTraitTome:forceStop()
	self.character:setReading(false)
	self.item:setJobDelta(0.0)
	if self.action then self.action:setLoopedAction(false) end
	self.character:playSound("CloseBook")
	ISBaseTimedAction.forceStop(self)
end

local traitLevelMap = {
	Stout={ Strength=6 },
	Strong={ Strength=9 },
	Fit={ Fitness=6 },
	Athletic={ Fitness=9 },
}

function ReadTraitTome:stop()
	self.character:setReading(false)
	self.character:playSound("CloseBook")
	ISBaseTimedAction.stop(self)
end

function adjustExperienceForTrait(character, trait)
   local levels = nil
   for k,leveling in pairs(traitLevelMap) do
	   if trait == k then
		   levels = leveling
	   end
   end

   if levels then
	   for perkName,minLevel in pairs(levels) do
	      local perk = PerkFactory.getPerkFromName(perkName)
		  local currentLevel = character:getPerkLevel(perk)
	      if currentLevel < minLevel then
			  print("[TraitTomes] Adjusting Experience for " .. perkName)
			  local xp = character:getXp()
			  repeat
			    -- setting the XP directly doesn't level up properly, leveling up a bit at a time correctly levels up
			    xp:AddXPNoMultiplier(perk, 100.0)
			  until character:getPerkLevel(perk) >= minLevel
			  -- strips off any "extra" XP left over from the leveling up
			  xp:setXPToLevel(perk, minLevel)
		  end
	   end
   end
end

function executeTraitDelta(character, operation)
    local trait = operation.trait
    local op = operation.op
	local hasTrait = character:HasTrait(trait)
	local playerTraits = character:getTraits()
	if op == "-" and hasTrait then
		print("[TraitTomes] Removing Trait From Player: " .. trait)
		playerTraits:remove(trait)
	elseif op == "+" and (not hasTrait) then
		adjustExperienceForTrait(character, trait)

		local traitList = TraitFactory:getTraits()
		local exclusiveTraitFound = nil
        for k=0,traitList:size()-1 do
			local factoryTrait = traitList:get(k)
			local exclusiveTraits = factoryTrait:getMutuallyExclusiveTraits()
			if factoryTrait:getType() == trait and exclusiveTraits and exclusiveTraits:size() > 0 then
				for i=0,playerTraits:size()-1 do
					for j=0,exclusiveTraits:size()-1 do
						if playerTraits:get(i) == exclusiveTraits:get(j) then
							local autoremovedTrait = playerTraits:get(i)
							print("[TraitTomes] removing mutually exclusive trait: " .. autoremovedTrait)
							playerTraits:remove(autoremovedTrait)
						end
					end
				end
			end
		end

		print("[TraitTomes] Adding Trait To Player: " .. trait)
		-- Prevent double adding automatic traits, like atheletic
		playerTraits = character:getTraits()
		local alreadyHave = false
		for i=0,playerTraits:size()-1 do
			if playerTraits:get(i) == trait then
				alreadyHave = true
			end
		end
		if not alreadyHave then
		  playerTraits:add(trait)
		end
	end
end

function ReadTraitTome:perform()
	local tomeModData = self.item:getModData()
	local steamId = getSteamIDFromUsername(getOnlineUsername())

	if not tomeModData.steamId then
		tomeModData.steamId = steamId
	end

	if not tomeModData.username then
		tomeModData.username = getOnlineUsername()
	end

	self.character:setReading(false)
	self.item:getContainer():setDrawDirty(true)

	for _,delta in pairs(tomeModData.traitDeltas) do
		executeTraitDelta(self.character, delta)
	end

	self.character:playSound("CloseBook")
	self.character:playSound("GainExperienceLevel")
	ISBaseTimedAction.perform(self)

	local itemType = self.item:getType()
	if itemType == "TraitScroll" then
		print("[TraitTomes] Deleting Scroll")
		local inventory = self.character:getInventory()
		inventory:Remove(self.item)
	end
end

function ReadTraitTome:new(character, item)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.item = item
	o.stopOnWalk = false
	o.stopOnRun = true
	o.loopedAction = false
	o.ignoreHandsWounds = true
	o.caloriesModifier = 0.5
	o.readTimer = 30
	o.forceProgressBar = true
	o.recipeIntervals = 0
	o.maxTime = 30
	o.haloTextDelay = 0

	return o
end
