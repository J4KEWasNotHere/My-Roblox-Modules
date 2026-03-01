--[[

		   @jakeboygamer64
	<|		Stepper Module		|>
	
	This module centralizes the creation and management of RunService steppers.
	It ensures only one stepper exists per name and method, and provides a convenient way to manage them - 
	Aiming to reduce the amount of RunService steppers and callbacks.
	
	Usage:
		local Stepper = require(path.to.Stepper)

		-- task.wait(5) -- Simulating delay for Usage 2
		
		local myStepper = Stepper.New("MyStepper", "Heartbeat")
		
		myStepper:Add("ThisPrinter", function(dt)
			print("Hello its currently ", math.floor(dt*100)/100, "seconds since the last step!")
		end)
		
		task.wait(2)
		
		myStepper:Remove("ThisPrinter")
	
	Usage 2: -- another Script of the same RunContext...
		local Stepper = require(path.to.Stepper)
		
		local x0 = os.clock()
		local myLostStepper = Stepper.WaitToGet("MyStepper", 10)
		local x1 = os.clock()
		
		myLostStepper:Add("Timer", function()
			print("Ive been waiting for ", math.floor(x1 - x0), " seconds!")
		end)
]]

--!strict
--!optimize 2

--> Services
local RunService = game:GetService("RunService")

--> Modules
local Types = require("@self/Types")

--> Variables

-- Valid stepper methods
local VALID_METHODS = {
	RenderStepped = RunService.RenderStepped,
	Heartbeat = RunService.Heartbeat,
	Stepped = RunService.Stepped

	-- you can add more..
} :: {[string]: RBXScriptSignal}

--> Module
local stepper = {Steppers = {}, _steppersByName = {}} :: Types.Module
stepper.__index = stepper

--> Utility

local function tableKeys(tb: {[any]: any})
	local keys = {}
	for key, _ in tb do
		table.insert(keys, key)
	end
	return keys
end

local function PCALL(func: (...any) -> (...any), ... : any) : (boolean, any)
	return pcall(func, ...)
end

--==== Module Functions ====

--> Constructor

function stepper.New(name: string, method: ("Heartbeat" | "RenderStepped" | "Stepped")) : Types.MainConstructor
	assert(type(name) == "string" and name ~= "", "Name must be a non-empty string")
	assert(VALID_METHODS[method], "Method must be one of: " .. table.concat(tableKeys(VALID_METHODS), ", "))
	assert(not stepper._steppersByName[name], "Stepper with name '" .. name .. "' already exists")
	
	local self = setmetatable({}, {__index = stepper}) :: Types.MainConstructor
	self.Name = name
	self.Method = method
	self.Connections = {}
	self.Functions = {}
	self.Stopped = false
	self._connection = nil
	
	table.insert(stepper.Steppers, self)
	stepper._steppersByName[name] = self
	
	function self:Destroy()
		self:_stop()
		self.Functions = {}

		for i, stepperObj in stepper.Steppers do
			if stepperObj == self then
				table.remove(stepper.Steppers, i)
				break
			end
		end
		stepper._steppersByName[self.Name] = nil
	end
	
	--> Secondary Constructor
	
	function self:Add(id: string, func: (...any) -> ())
		local self: Types.MainConstructor = self

		assert(type(id) == "string" and id ~= "", "ID must be a non-empty string")
		assert(type(func) == "function", "Function must be a function")
		assert(not self.Functions[id], "Function with ID '" .. id .. "' already exists in stepper '" .. self.Name .. "'")
		assert(not self.Stopped, "Cannot add functions to a stopped stepper")

		self.Functions[id] = func

		if not self._connection then
			self:_start()
		end
	end
	
	function self:Remove(id: string)
		local self: Types.MainConstructor = self

		if self.Functions[id] == nil then return end
		assert(type(id) == "string", "ID must be a string")

		self.Functions[id] = nil

		if next(self.Functions) == nil then
			self:_stop()
		end
	end
	
	--> Controllers

	function self:_start()
		local self: Types.MainConstructor = self

		if self._connection or self.Stopped then return end

		local event : RBXScriptSignal = VALID_METHODS[self.Method]
		self._connection = event:Connect(function(...)
			local arg1, arg2 = ...
			local delta = self.Method == "Stepped" and arg2 or arg1
			delta = math.min(delta, 1)

			for id, func in self.Functions do
				local success, result = PCALL(func, ...)
				if not success then
					warn("Error in stepper '" .. self.Name .. "' function '" .. id .. "': " .. tostring(result))
				end
			end
		end)
	end

	function self:_stop()
		local self: Types.MainConstructor = self

		if self._connection then
			self._connection:Disconnect()
			self._connection = nil
		end
	end

	--

	function self:Stop()
		local self: Types.MainConstructor = self

		if self.Stopped then return end

		self.Stopped = true
		self:_stop()
	end

	function self:Start()
		local self: Types.MainConstructor = self

		if not self.Stopped then return end

		self.Stopped = false

		if next(self.Functions) then
			self:_start()
		end
	end
	
	--> Checkers / Fetchers

	function self:Has(id: string): boolean
		local self: Types.MainConstructor = self
		return self.Functions[id] ~= nil
	end

	function self:GetFunctionCount(): number
		local self: Types.MainConstructor = self
		
		local count = 0
		for _ in self.Functions do
			count = count + 1
		end
		return count
	end

	function self:GetFunctionIds(): {string}
		local self: Types.MainConstructor = self
		
		local ids = {}
		for id in self.Functions do
			table.insert(ids, id)
		end
		return ids
	end

	function self:IsRunning(): boolean
		local self: Types.MainConstructor = self
		return self._connection ~= nil and not self.Stopped
	end
	
	return self :: Types.MainConstructor
end

function stepper.Remove(name: string)
	local existing = stepper._steppersByName[name]
	if existing then
		existing:Destroy()
	end
end

--> Global

function stepper.StopAll()
	for _, stepperObj in stepper.Steppers do
		stepperObj:Stop()
	end
end

function stepper.StartAll()
	for _, stepperObj in stepper.Steppers do
		stepperObj:Start()
	end
end

function stepper.DestroyAll()
	for i = #stepper.Steppers, 1, -1 do
		stepper.Steppers[i]:Destroy()
	end
end

--> [Global] Checkers / Fetchers

function stepper.Get(name: string)
	return stepper._steppersByName[name]
end

function stepper.WaitToGet(name: string, timeout: number?) : Types.MainConstructor?
	assert(type(name) == "string" and name ~= "", "Name must be a non-empty string")
	local existing = stepper._steppersByName[name]
	if existing then
		return existing
	end
	
	local timeoutConnection
	local timedOut = false
	
	if timeout and timeout > 0 then
		timeoutConnection = task.delay(timeout, function()
			timedOut = true
		end)
	end
	
	while not stepper._steppersByName[name] and not timedOut do
		coroutine.yield()
	end
	print("done")
	
	if timeoutConnection then
		task.cancel(timeoutConnection)
	end
	
	return stepper._steppersByName[name]
end

function stepper.GetAll(): {Types.MainConstructor}
	return stepper.Steppers
end

function stepper.GetAllNames(): {string}
	local names = {}
	for name in stepper._steppersByName do
		table.insert(names, name)
	end
	return names
end

function stepper.Exists(name: string): boolean
	return stepper._steppersByName[name] ~= nil
end

return stepper :: Types.Module
