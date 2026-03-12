<h1 align="center">🧰 KLRN Modules</h1>

<p align="center">
  <b>A collection of modules handcrafted by me</b> - free for you to use.<br>
  Released under the MIT License. Credit is appreciated ✨
</p>

---

<h2>⚙️ Features/Changes To Add</h2>
No more to add!

---

<b><h2>Resource Hierarchy</h2></b>
- Add 

| Module | Description |
|---|-------------|
| 📡[**RemoteEvent**](https://github.com/J4KEWasNotHere/My-Roblox-Modules/blob/main/Resources/RemoteEvent/RemoteEvent.lua) | This module manages RemoteEvents, allowing a more secure communication between server and client, with an attempt to prevent unauthorized access, by centralizing them and (optionally) encrypting naming. |
| 🔊[**SoundManager**](https://github.com/J4KEWasNotHere/My-Roblox-Modules/blob/main/Resources/SoundManager/SoundManager.lua) | This module implements a Sound Manager that creates and manages sounds, including 3D spatial sounds. It provides methods for playing sounds, applying effects, and creating sound entities. |
| ⏱️[**Stepper**](https://github.com/J4KEWasNotHere/My-Roblox-Modules/blob/main/Resources/Stepper/Stepper.lua) | This module centralizes the creation and management of RunService steppers, ensuring only one stepper exists per name and method. It provides a convenient way to manage steppers, aiming to reduce the number of RunService steppers and callbacks. |
| 🚦[**Debouncer**](https://github.com/J4KEWasNotHere/My-Roblox-Modules/blob/main/Resources/Debouncer/Debouncer.lua) | This module implements a Debouncer class for managing event delays and function executions. |
| ✂️[**ImageCutter**](https://github.com/J4KEWasNotHere/My-Roblox-Modules/blob/main/Resources/ImageCutter/ImageCutter.lua) | This module manages large images and cuts it up into a usable form, useful for sprites. |

---

<p align="center">
  Love my resources? Why not 🎁<a href=https://www.roblox.com/games/94334209861308/Donations-Exchange><b>Donate To Me</b></a> so I can continue working hard to make more for you! 😉
</p>

---

<div align="center">

# 📚 Documentation

</div>

---

<details>
<summary><h2>✂️ ImageCutter</h2></summary>

This module is used to separate images that are all combined into a grid in order to either create animations or effectively eliminate the endless hours of uploading and obtaining several individual images. Sprite-sheets are typically used for animation or gathering. 

You can get direct access to the [**File(s) Here**](https://github.com/J4KEWasNotHere/My-Roblox-Modules/blob/main/Resources/ImageCutter/ImageCutter.lua).

### 👷 Usage
```lua
--[[
	NOTE: The module reacts to these changes:
		- CutterClass.Position :: Vector2
		- CutterClass.Index :: number
		- CutterClass.CellSize :: Vector2
		- CutterClass.NormalizedImageSize :: Vector2
]]

local ImageCutterModule = require("./ImageCutter")

local InputPromptsImage: ImageLabel -- must be defined..

local InputPromptsImageCutter = ImageCutterModule.new(
	InputPromptsImage,
	
	{
		CellSize = Vector2.new(32, 32), -- Size of cell in pixels
		NormalizedImageSize = Vector2.new(2, 2), -- Grid cells layout (Total Size = 2 x 2 / 64 x 64) )
		
	}
)

task.wait(1)

--> Manual Movement

InputPromptsImageCutter:Next() -- moves to next icon (from left-right and top-down)

task.wait(1)

InputPromptsImageCutter:Previous() -- moves to previous icon

--> Manual Use case

task.wait(1)

local FPS = 1 / 12
local MAX_FRAMES = 100

for i = 1, MAX_FRAMES do
	task.wait(FPS)
	InputPromptsImageCutter.Index += 1 -- once exceeded it will simply just reset.
end

task.wait(1)

for i = 0, 20 do
	InputPromptsImageCutter.Position = Vector2.new(
		math.random(0,1),
		math.random(0,1)
	)
	
	task.wait(0.5)
end
```

### 📩 API Reference

#### `ImageCutter.new(Image: ImageLabel, Properties: ImageCutterProperties) -> ImageCutter`
Creates a new ImageCutter instance.

**Parameters:**
- `Image`: The ImageLabel to apply the cutter to
- `Properties`: Table containing:
  - `CellSize: Vector2` - Size of each cell in pixels
  - `CurrentCellPosition: Vector2` - Starting cell position
  - `NormalizedImageSize: Vector2` - Grid layout (e.g., 2x2 for a 4-cell grid)

#### `ImageCutter:Next() -> ()`
Moves to the next cell in the grid (left-to-right, top-to-bottom).

#### `ImageCutter:Previous() -> ()`
Moves to the previous cell in the grid.

#### Properties
- `Position: Vector2` - Current cell position (clamped to grid bounds)
- `Index: number` - Current cell index (1-indexed, wraps around)
- `CellSize: Vector2` - Size of each cell (read/write)
- `NormalizedImageSize: Vector2` - Grid dimensions (read/write)

</details>

---

<details>
<summary><h2>🚦 Debouncer</h2></summary>

A debouncer module used for delaying certain events and functions for a certain amount of time. Prevents function execution until the debounce delay has elapsed.

You can get direct access to the [**File(s) Here**](https://github.com/J4KEWasNotHere/My-Roblox-Modules/blob/main/Resources/Debouncer/Debouncer.lua).

### 👷 Usage
```lua
local Debouncer = require(path.to.Debouncer)
local db = Debouncer.new()

game:GetService("RunService").Heartbeat:Connect(function()
	db:Run("MyFunction", 2, function()
		print("Hello World!")
	end)
end)

task.delay(5, function() 
	db:Skip("MyFunction") -- Cancels the debounce for "MyFunction"
end)

db:Destroy() -- Destroys the debounce object and clears all active timers
```

### 📩 API Reference

#### `Debouncer.new() -> Debounce`
Creates a new Debouncer instance.

**Returns:** A new debounce object

#### `Debounce:Run(key: string, delayTime: number, fn: function) -> boolean`
Runs a function if the key isn't currently in an active debounce.

**Parameters:**
- `key: string` - Unique identifier for this debounce
- `delayTime: number` - Delay in seconds before the debounce expires
- `fn: function` - Function to execute immediately

**Returns:** `true` if function executed, `false` if debounce was active

#### `Debounce:IsActive(key: string) -> boolean`
Checks if a debounce is active for the given key.

**Parameters:**
- `key: string` - Debounce key to check

**Returns:** `true` if debounce is active, `false` otherwise

#### `Debounce:Skip(key: string) -> ()`
Cancels a running debounce for the given key.

**Parameters:**
- `key: string` - Debounce key to skip

#### `Debounce:Destroy() -> ()`
Cancels all debounces and clears the debouncer instance.

</details>

---

<details>
<summary><h2>📡 RemoteEvent</h2></summary>

A module that keeps track of RemoteEvents and fires them to the server or client. Created to prevent hackers from easily accessing RemoteEvents by centralizing them <b>- supports naming encryption.</b>

You can get direct access to the [**File(s) Here**](https://github.com/J4KEWasNotHere/My-Roblox-Modules/blob/main/Resources/RemoteEvent/RemoteEvent.lua).

### 👷 Usage

#### Client-Side
```lua
local RemoteEvent = require(path.to.RemoteEvent)

local myEvent = RemoteEvent.new("ThisEvent", function(x: any?)
	print(`[CLIENT]: {x or "No data received!"}`)
end)

myEvent:Fire("Hello server!")
```

#### Server-Side
```lua
local RemoteEvent = require(path.to.RemoteEvent)

local myEvent = RemoteEvent.new("ThisEvent", function(player: Player, x: any?)
	print(`[SERVER]: {x or "No data received!"}`)
end)

myEvent:FireAll("Hello client!")
```

### 📩 API Reference

#### `RemoteEvent.new(name: string, event: function?, isReliable: boolean?) -> RemoteEvent`
Creates a new RemoteEvent instance or retrieves an existing one.

**Parameters:**
- `name: string` - Unique name for this remote event
- `event: function?` - Callback function (receives player + data on server, just data on client)
- `isReliable: boolean?` - Whether to use RemoteEvent (true) or UnreliableRemoteEvent (false, default: true)

**Returns:** A new or existing RemoteEvent instance

#### `RemoteEvent:Fire(...any) -> ()`
Sends data to the server (client) or to a specific player (server).

**Server Usage:**
```lua
myEvent:Fire(player, data1, data2, ...)
```

**Client Usage:**
```lua
myEvent:Fire(data1, data2, ...)
```

#### `RemoteEvent:FireClient(player: Player, ...any) -> ()` *(Server only)*
Sends data to a specific client.

**Parameters:**
- `player: Player` - Target player
- `...any` - Data to send

#### `RemoteEvent:FireAll(...any) -> ()` *(Server only)*
Sends data to all connected clients.

**Parameters:**
- `...any` - Data to send

#### `RemoteEvent:FireServer(...any) -> ()` *(Client only - Use :Fire() instead)*
This method exists for API completeness but should use `:Fire()` on the client.

#### `RemoteEvent:Destroy() -> ()`
Destroys the RemoteEvent and disconnects all connections.

### 🪪 Encryption

#### `USE_ENCRYPTION: boolean`
Disable or Enable naming encryption.

#### `ENCRYPTION_KEY: string?`
Unique idenifier to correctly decrypt encrypted strings. Do not use random generators as the values they produce will be different across scripts.

</details>

---

<details>
<summary><h2>🔊 SoundManager</h2></summary>

A module that creates and manages sounds, including 3D spatial sounds with advanced audio effects. Provides methods for playing sounds with randomization and spatial audio capabilities.

You can get direct access to the [**File(s) Here**](https://github.com/J4KEWasNotHere/My-Roblox-Modules/blob/main/Resources/SoundManager/SoundManager.lua).

### 👷 Usage

#### Basic Sound Playback
```lua
local SoundManager = require(path.to.SoundManager)

local mySound = SoundManager.new("rbxassetid://12345678")

mySound:Play(workspace, true, 0.2, 0.1)
-- parent: workspace
-- createClone: true (creates a clone so original isn't modified)
-- speedRandomness: 0.2 (randomize speed ±20%)
-- volumeRandomness: 0.1 (randomize volume ±10%)
```

#### 3D Spatial Sound
```lua
local SoundManager = require(path.to.SoundManager)

local mySound = SoundManager.new("rbxassetid://12345678")

mySound:Play3d(workspace, true, 0.15, 0.05, {
	RollOffMin = 10,
	RollOffMax = 500,
	RollOffMode = Enum.RollOffMode.Inverse,
	Pitch = 1.2,
	Distortion = 0.1,
	Muffle = 0.3,
	Reverb = 0.5
})
```

#### Advanced: Play Sound at Position
```lua
local SoundManager = require(path.to.SoundManager)

local position = Vector3.new(0, 5, 0)
local entity, sound, effects = SoundManager.play3dAtPosition(
	position,
	"rbxassetid://12345678",
	{
		RollOffMin = 5,
		RollOffMax = 100,
	},
	{
		Pitch = 0.8,
		Distortion = 0.2,
		Muffle = 0.1,
		Reverb = 0.2
	},
	workspace
)
```

### 📩 API Reference

#### Constructor Methods

##### `SoundManager.new(soundId: string, properties: {[string]: any}?) -> Constructor`
Creates a new sound manager instance.

**Parameters:**
- `soundId: string` - Roblox asset ID for the sound
- `properties: table?` - Additional Sound properties (Volume, Looped, etc.)

**Returns:** A sound manager instance

#### Instance Methods

##### `soundManager:Get() -> Sound`
Returns a new Sound instance with the configured properties.

##### `soundManager:Play(parent: Instance?, createClone: boolean?, speedRandomness: number?, volumeRandomness: number?) -> ()`
Plays the sound.

**Parameters:**
- `parent: Instance?` - Parent for the sound instance
- `createClone: boolean?` - Clone the sound before playing (default: false)
- `speedRandomness: number?` - Randomize playback speed (0-1, multiplied by ±100%)
- `volumeRandomness: number?` - Randomize volume (0-1, multiplied by ±100%)

##### `soundManager:Play3d(parent: Instance?, createClone: boolean?, speedRandomness: number?, volumeRandomness: number?, properties: table?) -> ()`
Plays the sound with 3D spatial audio effects.

**Parameters:**
- `parent: Instance?` - Parent for the sound instance
- `createClone: boolean?` - Clone the sound before playing
- `speedRandomness: number?` - Randomize playback speed
- `volumeRandomness: number?` - Randomize volume
- `properties: table?` - Audio effect properties:
  - `Pitch: number` - Pitch shift (0.5 to 2)
  - `Distortion: number` - Distortion level (0 to 1)
  - `Muffle: number` - Muffle/mute effect (0 to 1)
  - `Reverb: number` - Reverb amount (0 to 1)

##### `soundManager:Destroy() -> ()`
Destroys the sound manager and cleans up resources.

#### Module Methods

##### `SoundManager.get(soundId: string, properties: {[string]: any}?) -> Sound`
Creates a new Sound instance.

##### `SoundManager.play(sound: Sound, speedRandomness: number?, volumeRandomness: number?) -> RBXScriptSignal`
Plays a sound with optional randomization.

**Returns:** The sound's Ended signal

##### `SoundManager.create3d(sound: Sound | string, mainProperties: table?, properties: table?) -> (Sound?, table)`
Creates a 3D sound with effects.

**Returns:** Sound instance and effects table

##### `SoundManager.apply3dEffects(sound: Sound, mainProperties: table?, properties: table?) -> (Sound?, table)`
Applies 3D effects to an existing sound.

##### `SoundManager.create3dAtPosition(position: Vector3, sound: Sound | string, mainProperties: table?, properties: table?, parent: Instance?) -> (Attachment?, Sound?, table)`
Creates a 3D sound at a specific world position.

**Returns:** Attachment entity, sound instance, and effects table

##### `SoundManager.play3dAtPosition(position: Vector3, sound: Sound | string, mainProperties: table?, properties: table?, parent: Instance?) -> (Attachment?, Sound?, table)`
Creates and immediately plays a 3D sound at a specific position. Auto-cleans up when finished.

</details>

---

<details>
<summary><h2>⏱️ Stepper</h2></summary>

A module that centralizes the creation and management of RunService steppers. Ensures only one stepper exists per name and method, and reduces the total number of RunService connections needed in your game.

You can get direct access to the [**File(s) Here**](https://github.com/J4KEWasNotHere/My-Roblox-Modules/blob/main/Resources/Stepper/Stepper.lua).

### 👷 Usage

#### Basic Setup
```lua
local Stepper = require(path.to.Stepper)

local myStepper = Stepper.New("MyStepper", "Heartbeat")

myStepper:Add("ThisPrinter", function(dt)
	print("Hello! It's currently ", math.floor(dt*100)/100, "seconds since the last step!")
end)

task.wait(2)

myStepper:Remove("ThisPrinter")
```

#### Multi-Script Usage
```lua
-- Script 1
local Stepper = require(path.to.Stepper)
local myStepper = Stepper.New("MyStepper", "Heartbeat")
myStepper:Add("Function1", function() print("Running!") end)

-- Script 2 (different script in same context)
local Stepper = require(path.to.Stepper)
local myStepper = Stepper.WaitToGet("MyStepper", 10) -- Waits up to 10 seconds for the stepper
if myStepper then
	myStepper:Add("Function2", function() print("Also running!") end)
end
```

### 📩 API Reference

#### `Stepper.New(name: string, method: "Heartbeat" | "RenderStepped" | "Stepped") -> MainConstructor`
Creates a new stepper instance.

**Parameters:**
- `name: string` - Unique name for this stepper
- `method: string` - RunService method to use ("Heartbeat", "RenderStepped", or "Stepped")

**Returns:** A new stepper instance

#### Instance Methods

##### `stepper:Add(id: string, func: function) -> ()`
Adds a function to the stepper.

**Parameters:**
- `id: string` - Unique identifier for this function
- `func: function` - Function to execute each step (receives delta time as first argument)

##### `stepper:Remove(id: string) -> ()`
Removes a function from the stepper.

**Parameters:**
- `id: string` - Function ID to remove

##### `stepper:Has(id: string) -> boolean`
Checks if a function exists in the stepper.

**Returns:** `true` if function exists, `false` otherwise

##### `stepper:GetFunctionCount() -> number`
Returns the number of functions in the stepper.

##### `stepper:GetFunctionIds() -> {string}`
Returns a table of all function IDs.

##### `stepper:IsRunning() -> boolean`
Checks if the stepper is actively running.

**Returns:** `true` if running, `false` otherwise

##### `stepper:Stop() -> ()`
Pauses the stepper without removing functions.

##### `stepper:Start() -> ()`
Resumes a stopped stepper.

##### `stepper:Destroy() -> ()`
Destroys the stepper and removes it from the global registry.

#### Module Methods

##### `Stepper.Get(name: string) -> MainConstructor?`
Retrieves an existing stepper by name.

**Returns:** The stepper instance, or nil if not found

##### `Stepper.WaitToGet(name: string, timeout: number?) -> MainConstructor?`
Waits for a stepper to be created (useful for multi-script scenarios).

**Parameters:**
- `name: string` - Stepper name to wait for
- `timeout: number?` - Maximum time to wait in seconds (optional)

**Returns:** The stepper instance when created, or nil if timeout

##### `Stepper.Exists(name: string) -> boolean`
Checks if a stepper exists.

**Returns:** `true` if stepper exists, `false` otherwise

##### `Stepper.GetAll() -> {MainConstructor}`
Returns all stepper instances.

##### `Stepper.GetAllNames() -> {string}`
Returns all stepper names.

##### `Stepper.Remove(name: string) -> ()`
Removes and destroys a stepper by name.

#### Global Control Methods

##### `Stepper.StopAll() -> ()`
Stops all steppers without destroying them.

##### `Stepper.StartAll() -> ()`
Starts all stopped steppers.

##### `Stepper.DestroyAll() -> ()`
Destroys all steppers.

</details>

---

<p align="center">
  Love my resources? Why not 🎁<a href=https://www.roblox.com/games/94334209861308/Donations-Exchange><b>Donate To Me</b></a> so I can continue working hard to make more for you! 😉
</p>

---
