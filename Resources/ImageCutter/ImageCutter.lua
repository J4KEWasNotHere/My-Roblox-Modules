local module = {}

--> Modules
local Listener = require("@self/Listener")

--> Types
export type ImageCutterProperties = {
	CellSize: Vector2,
	CurrentCellPosition: Vector2,

}

--> Utility

local function RoundVector2(vector2: Vector2)
	return Vector2.new(math.floor(vector2.X), math.floor(vector2.Y))
end

local function GetNormalizedPixelSize(cellSize: Vector2, normalizedSize: Vector2)
	return Vector2.new(
		cellSize.X * normalizedSize.X,
		cellSize.Y * normalizedSize.Y
	)
end

local function GetCellPosition(cellSize: Vector2, pixelPosition: Vector2, pixelSize: Vector2)
	local cellGridWidth = math.floor(pixelSize.X / cellSize.X)
	local cellGridHeight = math.floor(pixelSize.Y / cellSize.Y)
	
	local clampedX = math.max(0, math.min(pixelPosition.X, pixelSize.X - 1))
	local clampedY = math.max(0, math.min(pixelPosition.Y, pixelSize.Y - 1))
	
	local cellX = math.floor(clampedX / cellSize.X)
	local cellY = math.floor(clampedY / cellSize.Y)
	
	cellX = math.max(0, math.min(cellX, cellGridWidth - 1))
	cellY = math.max(0, math.min(cellY, cellGridHeight - 1))
	
	local cellPosition = Vector2.new(cellX, cellY)
	local index = cellY * cellGridWidth + cellX + 1
	
	return cellPosition, index
end

function module.new(Image: ImageLabel, Properties: ImageCutterProperties)
	local LISTENER = Listener.new()
	local self = {
		Image = Image,
		
		CellSize = Properties.CellSize,
		NormalizedImageSize = Properties.NormalizedImageSize or Vector2.one,
		
		Position = Properties.CurrentCellPosition or Vector2.zero,
		Index = 0,
		
		_listener = LISTENER,
	}
	
	Image.ScaleType = Enum.ScaleType.Crop
	Image.ImageRectSize = self.CellSize
	
	local pixelSize = GetNormalizedPixelSize(self.CellSize, self.NormalizedImageSize)
	local gridSize = self.NormalizedImageSize
	
	local cellX = math.clamp(math.floor(self.Position.X), 0, gridSize.X - 1)
	local cellY = math.clamp(math.floor(self.Position.Y), 0, gridSize.Y - 1)
	
	local initialCellPosition = Vector2.new(cellX, cellY)
	local initialPixelOffset = initialCellPosition * self.CellSize
	
	Image.ImageRectOffset = initialPixelOffset
	self.Position = initialCellPosition
	self.Index = cellY * gridSize.X + cellX + 1
	
	--> Functions
	
	function self:Destroy()
		self._listener:Destroy()
		self = nil
	end
	
	function self:Next()
		local maxIndex = gridSize.X * gridSize.Y
		self.Index = (self.Index + 1) % maxIndex
	end
	
	function self:Previous()
		local maxIndex = gridSize.X * gridSize.Y
		self.Index = (self.Index - 1) % maxIndex
	end
	
	--> Connections (Listeners)
	
	LISTENER:Listen("Position", function()
		return self.Position
	end):Connect(function(new: Vector2)
		if typeof(new) ~= "Vector2" then return end

		local pixelSize = GetNormalizedPixelSize(self.CellSize, self.NormalizedImageSize)
		local gridSize = self.NormalizedImageSize

		local cellX = math.clamp(math.floor(self.Position.X), 0, gridSize.X - 1)
		local cellY = math.clamp(math.floor(self.Position.Y), 0, gridSize.Y - 1)

		local initialCellPosition = Vector2.new(cellX, cellY)
		local initialPixelOffset = initialCellPosition * self.CellSize

		Image.ImageRectOffset = initialPixelOffset

		self.Index = cellY * gridSize.X + cellX + 1
	end)

	LISTENER:Listen("CellSize", function()
		return self.CellSize
	end):Connect(function(new: Vector2)
		if typeof(new) ~= "Vector2" then return end

		self.CellSize = RoundVector2(new)
		self.Image.ImageRectSize = self.CellSize
		self.Image.ImageRectOffset = self.Position * self.CellSize
	end)

	LISTENER:Listen("Index", function()
		return self.Index
	end):Connect(function(new: number)
		if typeof(new) ~= "number" then return end
		local gridSize = self.NormalizedImageSize
		local cellGridWidth = math.floor(gridSize.X)

		local zeroIndex = new - 1
		local cellX = zeroIndex % cellGridWidth
		local cellY = math.floor(zeroIndex / cellGridWidth)

		cellX = math.max(0, math.min(cellX, gridSize.X - 1))
		cellY = math.max(0, math.min(cellY, gridSize.Y - 1))

		local newPosition = Vector2.new(cellX, cellY)
		self.Position = newPosition
		self.Image.ImageRectOffset = newPosition * self.CellSize
	end)
	
	return self
end
return module
