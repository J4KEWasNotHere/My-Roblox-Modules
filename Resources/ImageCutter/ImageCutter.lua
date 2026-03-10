--!strict
--!optimize 2

local module = {}
local Types = require("@self/Types")

--> Utility

local function RoundVector2(vector2: Vector2): (Vector2)
	return Vector2.new(math.floor(vector2.X), math.floor(vector2.Y))
end

local function GetNormalizedPixelSize(cellSize: Vector2, normalizedSize: Vector2):  (Vector2)
	return Vector2.new(
		cellSize.X * normalizedSize.X,
		cellSize.Y * normalizedSize.Y
	)
end

--> Constructor

function module.new(Image: ImageLabel, Properties: Types.ImageCutterProperties)
	local internal = {
		Image = Image,
		CellSize = RoundVector2(Properties.CellSize),
		NormalizedImageSize = Properties.NormalizedImageSize or Vector2.one,
		Position = Vector2.zero,
		Index = 0,
	}
	
	local self = setmetatable({}, module)
	self._internal = internal
	
	Image.ScaleType = Enum.ScaleType.Crop
	
	Image.ImageRectSize = internal.CellSize
	Image.ImageRectOffset = internal.Position * internal.CellSize
	
	self.Position = Properties.CurrentCellPosition
	
	return self
end

--> Public

function module.Next(self: Types.ImageCutter)
	local grid = self.NormalizedImageSize
	local maxIndex = grid.X * grid.Y
	self.Index = (self.Index % maxIndex) + 1
	
	self:_update()
end

function module.Previous(self: Types.ImageCutter)
	local grid = self.NormalizedImageSize
	local maxIndex = grid.X * grid.Y
	self.Index = ((self.Index - 2) % maxIndex) + 1
	
	self:_update()
end

--> Private

function module._update(self: Types.ImageCutter)
	local cellSize = self.CellSize
	local gridSize = self.NormalizedImageSize
	local index = self.Index
	
	local width = math.floor(gridSize.X)
	
	local zeroIndex = index - 1
	local cellX = zeroIndex % width
	local cellY = math.floor(zeroIndex / width)
	
	local pos = Vector2.new(cellX, cellY)
	
	rawset(self :: any, "Position", pos)
	
	self.Image.ImageRectSize = cellSize
	self.Image.ImageRectOffset = pos * cellSize
end

--> Metatable

function module.__index(self: Types.ImageCutter, index): any
	if index == "Next" then return module.Next
	elseif index == "Previous" then return module.Previous
	elseif index == "_update" or index == "Update" then return module._update
	end
	
	local internal = rawget(self :: any, "_internal")
	if internal then return internal[index] end
	
	return nil
end

function module.__newindex(self: Types.ImageCutter, index, value: any)
	local internal = rawget(self :: any, "_internal")
	
	if index == "CellSize" then
		value = RoundVector2(value)
		internal.CellSize = value
		internal.Image.ImageRectSize = value
		internal.Image.ImageRectOffset = internal.Position * value
		
	elseif index == "Position" then
		local gridSize = internal.NormalizedImageSize
		local cellX = math.clamp(math.floor(value.X), 0, gridSize.X - 1)
		local cellY = math.clamp(math.floor(value.Y), 0, gridSize.Y - 1)
		local newPosition = Vector2.new(cellX, cellY)
		
		internal.Position = newPosition
		internal.Image.ImageRectOffset = newPosition * internal.CellSize
		internal.Index = cellY * gridSize.X + cellX + 1
		
	elseif index == "Index" then
		local gridSize = internal.NormalizedImageSize
		local width = math.floor(gridSize.X)
		local zeroIndex = value - 1
		
		local cellX = zeroIndex % width
		local cellY = zeroIndex % width
		
		local pos = Vector2.new(
			math.clamp(cellX, 0, gridSize.X - 1),
			math.clamp(cellY, 0, gridSize.Y - 1)
		)
		
		internal.Index = value
		internal.Position = pos
		internal.Image.ImageRectOffset = pos * internal.CellSize
		
	else
		rawset(self :: any, index, value)
	end
end

return module
