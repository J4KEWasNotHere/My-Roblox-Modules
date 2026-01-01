-- Refrenced off Suphi's Remote Function Module (https://devforum.roblox.com/t/suphis-remotefunction-module/2783829)
--[[
			  @jakeboygamer64
	|| (LOCALIZED) REMOTE EVENT ||
	This module keeps track of RemoteEvents and fires them to the server or client.
	This was created to prevent hackers from easily accessing RemoteEvents.
	
	Usage:
	
		Client
		------
		
		local RemoteEvent = require(path.to.RemoteEvent)
		
		local myEvent = RemoteEvent.new("ThisEvent", function(x: any?)
			print(`[CLIENT]: {x or "No data received!"}`)
		end)
		
		myEvent:Fire("Hello sever!")
		
		Server
		------
		
		local RemoteEvent = require(path.to.RemoteEvent)
		
		local myEvent = RemoteEvent.new("ThisEvent", function(player: Player, x: any?)
			print(`[SERVER]: {x or "No data received!"}`)
		end)
		
		myEvent:FireAll("Hello client!")
			
]]

local constructor, remoteEvent, remoteEvents = {}, {}, {}
remoteEvent.__index = remoteEvent

-- Types
export type Constructor = {
	new: (name: string, event: (...any) -> ()?, isReliable: boolean?) -> RemoteEvent,
}
export type RemoteEvent = {
	Event: (...any) -> ()?,
	Fire: (self: RemoteEvent, ...any) -> (),
	FireAll: (self: RemoteEvent, ...any) -> (),
	Destroy: (self: RemoteEvent) -> (),
}

if game:GetService("RunService"):IsServer() == true then
	local function Fire(event, player, ...)
		event:FireClient(player, ...)
	end

	local function FireAll(event, ...)
		event:FireAllClients(...)
	end
	
	function constructor.new(name, event, isReliable)
		local self = remoteEvents[name]
		if self == nil then
			self = {}
			self.Name = name
			self.Event = event
			self.IsReliable = isReliable ~= nil and isReliable or true
			self.Remote = Instance.new(self.IsReliable and "RemoteEvent" or "UnreliableRemoteEvent")
			self.Remote.Name = name
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
			
			local remote = script:WaitForChild(name)

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
		error(`{self.Name}:FireAll() is not available on the client.`)
	end

	function remoteEvent:Destroy()
		remoteEvents[self.Name] = nil
		if self.Connection then
			self.Connection:Disconnect()
		end
	end
end

return table.freeze(constructor) :: Constructor
