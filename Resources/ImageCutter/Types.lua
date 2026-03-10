--!strict

export type ImageCutterProperties = {
	CellSize: Vector2,
	CurrentCellPosition: Vector2,
	NormalizedImageSize: Vector2,
}

type ImageCutterInternal = {
	Image: ImageLabel,
	CellSize: Vector2,
	NormalizedImageSize: Vector2,
	Position: Vector2,
	Index: number,
}

export type ImageCutter = {
	_internal: ImageCutterInternal,
	
	_update: (self: ImageCutter) -> (),
	Next: (self: ImageCutter) -> (),
	Previous: (self: ImageCutter) -> (),
	
	Image: ImageLabel,
	CellSize: Vector2,
	NormalizedImageSize: Vector2,
	Position: Vector2,
	Index: number,
}

return {}
