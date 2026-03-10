--!strict

type DebounceState = {
	timer: thread?
}

export type Class = {
	_states: {[string]: DebounceState},
	
	Run: (self: Class, key: string, delayTime: number, fn: () -> ()) -> (boolean),
	IsActive: (self: Class, key: string) -> (boolean),
	
	Skip: (self: Class, key: string) -> (),
	
	Destroy: (self: Class) -> (),
}

return {}
