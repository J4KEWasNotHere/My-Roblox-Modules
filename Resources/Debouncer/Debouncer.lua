--!strict
--!optimize 2

local Types = require("@self/Types")

local Debounce = {}
Debounce.__index = Debounce

local Types = require(script.Types)

function Debounce.new()
	local self = {_states = {}}
	return setmetatable(self, Debounce)
end

-- Runs a function if the key isn't in an active debounce
function Debounce.Run(self: Types.Class, key: string, delayTime: number, fn: () -> ())
	if self:IsActive(key) then
		return false
	end
	
	self._states[key] = {
		timer = task.delay(delayTime, function()
			self._states[key] = nil
		end)
	}

	fn()
	return true
end

-- Checks if a debounce is active for the given key
function Debounce.IsActive(self: Types.Class, key: string)
	return self._states[key] ~= nil
end

-- Cancels a running debounce
function Debounce.Skip(self: Types.Class, key: string)
	local state = self._states[key]
	if state and state.timer then pcall(task.cancel, state.timer) end
	self._states[key] = nil
end

-- Cancels all debounces and clears the table.
function Debounce.Clean(self: Types.Class)
	for key, state in pairs(self._states) do
		if state.timer then pcall(task.cancel, state.timer) end
		self._states[key] = nil
	end
	table.clear(self._states)
end

return Debounce
