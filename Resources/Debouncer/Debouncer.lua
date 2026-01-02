--!optimize 2

--[[
	|| Debouncer
	
	|| Used for delaying certain events and functions, for a certin amount of time.
	|| By: @jakeboygamer64
	
	|| Usage:
	||	local Debouncer = require(path.to.Debouncer)
	||	local db = Debouncer.new()
	||
	||	game:GetService("RunService").Heartbeat:Connect(function()
	||		db:Run("MyFunction", 2, function()
	||			print("Hello World!")
	||		end)
	||	end)
	||
	||	task.delay(5, function() 
	||		db:Skip("MyFunction") -- Cancels the debounce for "MyFunction"
	||	end)
	||
	||	db:Destroy() -- Destroys the debounce object and clears all active timers
]]

local Debounce = {}
Debounce.__index = Debounce

function Debounce.new()
	local self = setmetatable({}, Debounce)
	self._states = {} -- Tracks active debounce timers
	return self
end

-- Runs a function if the key isn't in an active debounce
function Debounce:Run(key, delayTime, fn)
	if self:IsActive(key) then
		return false
	end

	local state = {}
	self._states[key] = state

	state.timer = task.delay(delayTime, function()
		if self._states[key] == state then
			self._states[key] = nil
		end
	end)

	fn()
	return true
end

-- Checks if a debounce is active for the given key
function Debounce:IsActive(key)
	return self._states[key] ~= nil
end

-- Cancels a running debounce
function Debounce:Skip(key)
	local state = self._states[key]
	if state and state.timer then
		pcall(task.cancel, state.timer)
	end
	self._states[key] = nil
end

-- Cancels all debounces and clears the table
function Debounce:Destroy()
	for key, state in pairs(self._states) do
		if state.timer then
			pcall(task.cancel, state.timer)
		end
		self._states[key] = nil
	end
	table.clear(self._states)
end

return Debounce.new()
