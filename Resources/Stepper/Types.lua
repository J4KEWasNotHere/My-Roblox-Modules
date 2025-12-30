--!strict

export type MainConstructor = {
	Name: string,
	Method: string,
	
	Stopped: boolean,
	Functions: {[string]: (...any) -> ()},
	
	Connections: {RBXScriptConnection},
	_connection: RBXScriptConnection?,
	
	IsRunning: (self: MainConstructor) -> (boolean),
	GetFunctionIds: (self: MainConstructor) -> ({string}),
	GetFunctionCount: (self: MainConstructor) -> (number),
	Has: (self: MainConstructor, id: string) -> (boolean),
	
	Add: (self: MainConstructor, id: string, func: (...any) -> ()) -> (),
	Remove: (self: MainConstructor, id: string) -> (),

	Stop: (self: MainConstructor) -> (),
	Start: (self: MainConstructor) -> (),
	Destroy: (self: MainConstructor) -> (),

	_start: (self: MainConstructor) -> (),
	_stop: (self: MainConstructor) -> (),

	_update: (self: MainConstructor, dt: number) -> (),
}

export type Module = {
	New: (name: string, method: ("Heartbeat" | "RenderStepped" | "Stepped")) -> (MainConstructor),
	Remove: (name: string) -> (),
	
	Steppers: {MainConstructor},
	_steppersByName: {[string]: MainConstructor},
	
	StopAll: () -> (),
	StartAll: () -> (),
	DestroyAll: () -> (),
	
	Get: (name: string) -> (MainConstructor),
	WaitToGet: (name: string, timeout: number?) -> (MainConstructor?),
	GetAll: () -> {MainConstructor},
	GetAllNames: () -> {string},
	Exists: (name: string) -> (boolean),
	
	__index: Module,
}

return {}
