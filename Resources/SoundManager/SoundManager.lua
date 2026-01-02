--[[
	||	Sound Manager
	
	||	Creates and manages sounds, including '3D' spatial sounds.
	||	By: @jakeboygamer64
	
	||	Documentation
	
	||	Constructor: Sound3D(SoundId: string)
	||		- SoundId: Sound identifier
	||		
	||	Methods:
	||		- Play(parent: Instance?, createClone: boolean?, speedRandomness: number?, volumeRandomness: number?)
	||			- parent: Parent of the sound instance
	||			- createClone: Create a clone of the sound instance
	||			- speedRandomness: Randomize the playback speed between 1 and this number
	||			- volumeRandomness: Randomize the volume between 1 and this number
	||			
	||		- Play3d(parent: Instance?, createClone: boolean?, speedRandomness: number?, volumeRandomness: number?, properties: {[string]: any})
	||			- parent: Parent of the sound instance
	||			- createClone: Create a clone of the sound instance
	||			- speedRandomness: Randomize the playback speed between 1 and this number
	||			- volumeRandomness: Randomize the volume between 1 and this number
	||			- properties: Table of properties to be applied to the sound instance
	||		
	||		- Get(): Sound
	||		- Destroy()
	(NOTE: YOU CAN PLAY A SOUND WITH OT WITHOUT THE '3D' EFFECTS WITHOUT USING THE CONSTRUCTOR - READ MORE IN THE MODULE)

	(EDIT: Beta Feature is now Full Release.)
	WARNING : THIS MAY NOT WORK CORRECTLY AS ATTACHMENTS ARENT PARENTED TO A BASE-PART (BETA FEATURE MUST BE ENABLED);
			  OTHERWISE, IMPLEMENT IT USING A PART AND POSSIBLY A WELD-CONSTRAINT FOR SIMPLE IMPLEMENTATION.
]]

--!strict
--!optimize 2

local SoundModule = {RANDOM = Random.new()}
SoundModule.__index = SoundModule

--> Services
local RunService = game:GetService("RunService")

--> Objects
local DebrisFolder = workspace:FindFirstChild("Debris") or workspace

--> Types
type Properties3d = {
	RollOffMin: number?,
	RollOffMax: number?,
	RollOffMode: Enum.RollOffMode?,
	Position: number?,
	PlaybackSpeed: number?,
	Volume: number?,
	Looped: boolean?,
}

type Experimental3dProperties = {
	Pitch: number?, -- 0.5 to 2 (clamped)
	Distortion: number?, -- 0 to 1
	Muffle: number?, -- 0 to 1
	Reverb: number? -- 0 to 1
}

type Constructor = {
	Sound: Sound?,
	Properties: {SoundId: string} | {[any]: any},

	Play: (self: Constructor, parent: Instance?, createClone: boolean?, speedRandomness: number?, volumeRandomness: number?) -> (),
	Play3d: (self: Constructor, parent: Instance?, createClone: boolean?, speedRandomness: number?, volumeRandomness: number?, properties: Experimental3dProperties?) -> (),
	
	Get: (self: Constructor) -> (Sound),
	
	Destroy: (self: Constructor) -> (),
}

--> Utility

local function fetch(tb: {[any]: any}, index: any?, defualt: any?): any?
	return type(tb) == "table" and tb[index] or defualt
end

local function _pcall(func: (...any) -> ...any, ...): (boolean, ...any)
	return pcall(func, ...)
end

local function applyProperties(instance, properties: {[any]: any} | {} | nil)
	if not properties then return end
	for name, value in properties do
		local success, result = _pcall(function() 
			instance[name] = value 
		end)
	end
end

local function apply3dSoundEffects(sound: Instance, Pitch: number?, Distortion: number?, Muffle: number?, Reverb: number?)
	local pitchShift = sound:FindFirstChildOfClass("PitchShiftSoundEffect") or Instance.new("PitchShiftSoundEffect")
	local muffleReduction = Muffle and Muffle*0.33 or 0
	pitchShift.Octave = Pitch and math.clamp(Pitch-muffleReduction, 0.5, 2) or 1
	
	local distortion = sound:FindFirstChildOfClass("DistortionSoundEffect") or Instance.new("DistortionSoundEffect")
	distortion.Level = Distortion and math.max(Distortion, 0) or 0
	
	local equalizer = sound:FindFirstChildOfClass("EqualizerSoundEffect") or Instance.new("EqualizerSoundEffect")
	equalizer.MidGain = Muffle and math.lerp(0,-40,Muffle) or 0
	equalizer.HighGain = Muffle and equalizer.MidGain or 0
	equalizer.LowGain = Muffle and -3*equalizer.MidGain or 0 -- 120
	
	local reverb = sound:FindFirstChildOfClass("ReverbSoundEffect") or Instance.new("ReverbSoundEffect")
	reverb.DecayTime = Reverb and math.lerp(0, 2, Reverb) or 0
	reverb.Density = Reverb and math.lerp(0, 1, Reverb) or 0
	reverb.Diffusion = Reverb and reverb.Density or 0
	reverb.DryLevel = -reverb.DecayTime
	reverb.WetLevel = Reverb and math.lerp(-80, 10, Reverb) or -80
	
	pitchShift.Parent = sound
	distortion.Parent = sound
	equalizer.Parent = sound
	reverb.Parent = sound
	
	if not sound:HasTag("Sound3D") then sound:AddTag("Sound3D") end
	return pitchShift, distortion, equalizer, reverb
end

local function createPositionalEntity(position: Vector3, parent: Instance?, name: string?): Attachment
	local entity = Instance.new("Attachment")
	entity.Parent = parent or DebrisFolder
	entity.WorldPosition = position
	entity.Name = `{name}_3DSoundEntity`
	return entity
end

--> Module
function SoundModule.get(soundId: string, properties:{[string]: any}?)
	local Properties = properties or {}
	Properties.SoundId = soundId
	
	local sound = Instance.new("Sound")
	applyProperties(sound, Properties)
	
	return sound
end

function SoundModule.play(sound: Sound?, speedRandomness: number?, volumeRandomness: number?): RBXScriptSignal
	if not sound then return RunService.Stepped end
	if speedRandomness or volumeRandomness then
		local rnd = (SoundModule.RANDOM:NextNumber() - 0.5) * 2
		if speedRandomness then sound.PlaybackSpeed = 1 + (speedRandomness * rnd) end
		if volumeRandomness then sound.Volume = sound.Volume * (1 - math.abs(volumeRandomness * rnd)) end
	end sound:Play()
	return sound.Ended
end

function SoundModule.create3d(sound: Instance | string, mainProperties: Properties3d, properties: Experimental3dProperties?): (Sound?, {[string]: SoundEffect} | {})
	local sound3d = (typeof(sound) == "Instance" and sound:IsA("Sound")) and sound:Clone() or typeof(sound) == "string" and SoundModule.get(sound) or nil
	if not sound3d then return nil, {} end
	return SoundModule.apply3dEffects(sound3d, mainProperties, properties)
end

function SoundModule.apply3dEffects(sound: Instance, mainProperties: Properties3d?, properties: Experimental3dProperties?): (Sound?, {[string]: SoundEffect} | {})
	if not (typeof(sound) == "Instance" and sound:IsA("Sound")) then return nil, {} end
	local MainProperties: Properties3d = typeof(mainProperties) == "table" and mainProperties or {}
	applyProperties(sound, MainProperties)
	local Properties: Experimental3dProperties = typeof(properties) == "table" and properties or {}
	local pitchShift, distortion, equalizer, reverb = apply3dSoundEffects(sound, Properties.Pitch, Properties.Distortion, Properties.Muffle, Properties.Reverb)
	return sound, {Pitch = pitchShift, Distortion = distortion, Eq = equalizer, Reverb = reverb}
end

function SoundModule.create3dAtPosition(position: Vector3, sound: Instance | string, mainProperties: Properties3d?, properties: Experimental3dProperties?, parent: Instance?): (Attachment?, Sound?, {[string]: SoundEffect} | {})
	local MainProperties: Properties3d = typeof(mainProperties) == "table" and mainProperties or {}
	local sound3d, effects = SoundModule.create3d(sound, MainProperties, properties)
	if not sound3d then return nil, nil, {} end
	local entity = createPositionalEntity(position, parent, sound3d.Name)
	sound3d.Parent = entity
	return entity, sound3d, effects
end

function SoundModule.play3dAtPosition(position: Vector3, sound: Instance | string, mainProperties: Properties3d?, properties: Experimental3dProperties?, parent: Instance?): (Attachment?, Sound?, {[string]: SoundEffect} | {})
	local MainProperties: Properties3d? = typeof(mainProperties) == "table" and mainProperties or {}
	local entity, sound3d, effects = SoundModule.create3dAtPosition(position, sound, MainProperties, properties, parent)
	if not entity then return nil, nil, {} end
	task.defer(function() SoundModule.play(sound3d, 0.05, 0.1):Once(function() entity:Destroy() end) end)
	return entity, sound3d, effects
end

--> Constructor

function SoundModule.new(soundId: string, properties: {[string]: any}?): Constructor
	local self = {Properties = properties or {}} :: Constructor
	self.Properties["SoundId"] = soundId
	
	function self:Get(): Sound
		local sound = Instance.new("Sound")
		sound.SoundId = self.Properties["SoundId"]
		applyProperties(sound, self.Properties)
		
		return sound
	end
	
	function self:Play(parent: Instance?, createClone: boolean?, speedRandomness: number?, volumeRandomness: number?)
		if not self.Sound then return warn("Sound is not loaded.") end
		parent = typeof(parent) == "Instance" and parent or nil
		if not parent then return end
		
		if createClone then
			local SoundClone: Sound = self.Sound:Clone()
			SoundClone.Name = `PLAYING_{soundId}`

			SoundClone.Ended:Once(function() SoundClone:Destroy() end)
			SoundClone.Parent = parent
			SoundModule.play(SoundClone, speedRandomness, volumeRandomness)
		else
			self.Sound.Parent = parent
			SoundModule.play(self.Sound, speedRandomness, volumeRandomness)
			self.Sound.Ended:Once(function() self.Sound.Parent = nil end)
		end
	end
	
	function self:Play3d(parent: Instance?, createClone: boolean?, speedRandomness: number?, volumeRandomness: number?, properties: Experimental3dProperties?)
		if not self.Sound then return warn("Sound is not loaded.") end
		parent = typeof(parent) == "Instance" and parent or nil
		if not parent then return end
		
		local sound3d: Sound?
		if createClone then
			sound3d = self.Sound:Clone()
			sound3d.Name = `PLAYING_{soundId}`
		else
			sound3d = self.Sound
		end
		
		sound3d.Parent = parent
		SoundModule.apply3dEffects(sound3d, {}, properties)
		
		SoundModule.play(sound3d, speedRandomness, volumeRandomness):Once(function()
			if not sound3d then return end
			sound3d.Parent = nil
		end)
	end
	
	function self:Destroy()
		if self.Sound then
			self.Sound:Destroy()
			self.Sound = nil
		end
	end
	
	self.Sound = self:Get()
	
	return self
end

return SoundModule
