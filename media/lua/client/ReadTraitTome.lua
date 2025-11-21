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


function ReadTraitTome:stop()
	self.character:setReading(false)
	self.character:playSound("CloseBook")
	ISBaseTimedAction.stop(self)
end

function executeTraitDelta(character, operation)
    local trait = operation.trait
    local op = operation.op
	local hasTrait = character:HasTrait(trait)
	local playerTraits = character:getTraits()
	if op == "-" and hasTrait then
		playerTraits:remove(trait)
	elseif op == "+" and (not hasTrait) then
		playerTraits:add(trait)
	end
end

function ReadTraitTome:perform()
	local tomeModData = self.item:getModData()
	local steamId = self.character:getSteamID()
	local username = self.character:getUsername()

	if not tomeModData.steamId then
		tomeModData.steamId = steamId
	end

	if not tomeModData.username then
		tomeModData.username = username
	end

	self.character:setReading(false)
	self.item:getContainer():setDrawDirty(true)

	for _i,delta in ipairs(tomeModData.traitDeltas) do
		executeTraitDelta(self.character, delta)
	end

	self.character:playSound("CloseBook")
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
	o.loopedAction = false
	o.ignoreHandsWounds = true
	o.caloriesModifier = 0.5
	o.readTimer = 30
	o.forceProgressBar = true
	o.learnedRecipes = {}
	o.recipeIntervals = 0
	o.maxTime = 30
	o.haloTextDelay = 0

	return o
end
