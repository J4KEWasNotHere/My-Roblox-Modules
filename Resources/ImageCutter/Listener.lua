local module = {}

--> Services
local RunService = game:GetService("RunService")

--> Modules
local Signal = require("./Signal")

--> Variables
local IsClient = RunService:IsClient()
local RunServiceMode = IsClient and "RenderStepped" or "Heartbeat"

--> Constructor

function module.new()
	local self = {
		__listeners = {},
		__active = {}
	}

	RunService[RunServiceMode]:Connect(function()
		for key, active in pairs(self.__active) do
			local callback = active.callback
			
			local value = callback()
			if value == active.last_value then
				continue
			end
			
			active.last_value = value
			
			task.spawn(function()
				active.signal:Fire(value)
			end)
		end
	end)
	
	--> Listener Connection
	
	function self:Listen(key: string, callback: () -> any)
		if self.__listeners[key] then
			self:StopListening(key)
		end
		
		local signal = Signal.new()
		
		self.__listeners[key] = signal
		self.__active[key] = {
			signal = signal,
			callback = callback,
			last_value = callback()
		}

		return signal
	end
	
	function self:StopListening(key: string)
		if not self.__listeners[key] then
			return
		end

		self.__listeners[key]:DisconnectAll()
		self.__listeners[key] = nil
		self.__active[key] = nil
	end
	
	function self:Destroy()
		for key, signal in pairs(self.__listeners) do
			signal:DisconnectAll()
			self.__listeners[key] = nil
		end
		self.__listeners = nil
		self.__active = nil
		self = nil
	end
	
	return self
end

return module
