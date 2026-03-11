-- Refrenced off Suphi's Remote Function Module (https://devforum.roblox.com/t/suphis-remotefunction-module/2783829)
-- NOTE: CREATES INSTANCES IN .script

local USE_ENCRYPTION = false -- best if left true for full protection.
local ENCRYPTION_KEY: string? = nil -- doesnt change much, however, do not use random generators to produce a value.

local constructor, remoteEvent, remoteEvents = {}, {}, {}
local misc = require("@self/misc")

remoteEvent.__index = remoteEvent

-- Types
export type Constructor = {
	new: (name: string, event: (...any) -> ()?, isReliable: boolean?) -> RemoteEvent,
}

export type RemoteEvent = {
	Event: (...any) -> ()?,

	Fire: (self: RemoteEvent, ...any) -> (),

	FireClient: (self: RemoteEvent, player: Player, ...any) -> (),

	FireServer: (self: RemoteEvent, ...any) -> (),
	FireAll: (self: RemoteEvent, ...any) -> (),

	Destroy: (self: RemoteEvent) -> (),
}

-- Utility
local function FindFirstRemoteEvent(x: string): BaseRemoteEvent?
	for _, v: Instance in script:GetChildren() do
		local n = misc.ex1(v.Name, ENCRYPTION_KEY)
		if USE_ENCRYPTION and misc.ex1(v.Name, ENCRYPTION_KEY) == x and v:IsA("BaseRemoteEvent") then
			return v
		elseif v:IsA("BaseRemoteEvent") and v.Name == x then
			return v
		end
	end
	return nil
end

-- Main

if game:GetService("RunService"):IsServer() == true then
	local function Fire(event, player, ...)
		event:FireClient(player, ...)
	end

	local function FireAll(event, ...)
		event:FireAllClients(...)
	end

	local function FireServer(event, ...)
		event:FireAllClients(...)
	end

	function constructor.new(name, event, isReliable)
		local self = remoteEvents[name]
		if self == nil then
			self = {}
			self.Name = name
			self.Event = event
			self.IsReliable = isReliable ~= nil and isReliable or true
			self.Remote = FindFirstRemoteEvent(name) or Instance.new(self.IsReliable and "RemoteEvent" or "UnreliableRemoteEvent")
			self.Remote.Name = USE_ENCRYPTION and misc.ex0(name, ENCRYPTION_KEY) or name
			
			self.Remote.Parent = script
			self.Remote.OnServerEvent:Connect(function(player, ...)
				if self.Event ~= nil then
					self.Event(player, ...)
				end
			end)
			remoteEvents[name] = self
			return setmetatable(self, remoteEvent)
		else
			if event ~= nil then self.Event = event end
			return self
		end
	end

	function remoteEvent:Fire(player, ...)
		Fire(self.Remote, player, ...)
	end

	function remoteEvent:FireClient(player, ...)
		Fire(self.Remote, player, ...)
	end

	function remoteEvent:FireAll(...)
		FireAll(self.Remote, ...)
	end

	function remoteEvent:Destroy()
		remoteEvents[self.Name] = nil
		if self.Remote then
			self.Remote:Destroy()
		end
	end
else
	function constructor.new(name, event, isReliable)
		local self = remoteEvents[name]
		if self == nil then
			self = {}
			self.Name = name
			self.Event = event
			self.IsReliable = isReliable ~= nil and isReliable or true
			
			local remote = nil
			
			if USE_ENCRYPTION then
				repeat 
					remote = FindFirstRemoteEvent(name)
					task.wait(0.75)
				until remote ~= nil
			else
				remote = script:WaitForChild(name)
			end

			self.Remote = remote
			self.Connection = self.Remote.OnClientEvent:Connect(function(...)
				if self.Event ~= nil then
					self.Event(...)
				end
			end)
			remoteEvents[name] = self
			return setmetatable(self, remoteEvent)
		else
			if event ~= nil then self.Event = event end
			return self
		end
	end

	-- Client RemoteEvent
	function remoteEvent:Fire(...)
		if self.Remote then
			self.Remote:FireServer(...)
		else
			error(`RemoteEvent "{self.Name}" is not initialized`)
		end
	end

	function remoteEvent:FireAll(...)
		error(`{self.Name}:FireAll() is not available on the client, use {self.Name}:Fire() instead.`)
	end

	function remoteEvent:FireServer(...)
		error(`{self.Name}:FireServer() is not available on the client, use {self.Name}:Fire() instead.`)
	end

	function remoteEvent:Destroy()
		remoteEvents[self.Name] = nil
		if self.Connection then
			self.Connection:Disconnect()
		end
	end
end

return table.freeze(constructor) :: Constructor
