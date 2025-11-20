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



function ReadTraitTome:perform()
	self.character:setReading(false)
	self.item:getContainer():setDrawDirty(true)
	local logText = ISLogSystem.getGenericLogText(self.character)
	local playerTraits = self.character:getTraits()


	local hasOrganized = self.character:HasTrait("Organized")


	if hasOrganized == false then
		playerTraits:add("Organized")
	end
	ISBaseTimedAction.perform(self)
end

function ReadTraitTome:new(character, item)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.item = item
	o.stopOnWalk = false
	o.stopOnRun = true
	o.loopedAction = true
	o.ignoreHandsWounds = true
	o.caloriesModifier = 0.5
	o.readTimer = -30
	o.forceProgressBar = true
	o.learnedRecipes = {}
	o.recipeIntervals = 0
	o.maxTime = 10
	o.haloTextDelay = 0

	return o
end
