--DISCONTINUED, GO TO https://github.com/RbxscrIptConnectinG/Container

--!nocheck
--_scriptType="module"
--[[

	--made in T10-Studio by: t10_kol|ID:3264445159|"RbxscrIptConnectinG"--
	
	Copyright©: None, feel free to use, edit, sell and distribute this util 
				anywhere you want and any time you want ;)
	
	--dev commentary--
	
	(t10_kol): "unreadable."

	--info--

	Version: 0.0.6
	
	Container.new() = {
		Validate: function(Indexes) -> checks if indexes in "_connections"|"_any" are available. returns ...boolean (found: true, not found: false)
		Get: function(Indexes) -> gets items in "_connections"|"_any" if available. returns ...any
		IsItIn: function(Index,"Connections"|"Any") -> checks if index is from "_connections"|"_any". returns boolean, value
		IsIt: function(Index,type) -> type checking for value of that index. returns boolean

		Add: function(connection|any,CustomIndex) -> adds connection|any into "_connections" if RBXScriptConnection or "_any" if anything else. returns connection|any, newindex
		Remove: function(Indexes) -> removes connection|any from "_connections"|"_any" if found. returns nothing
		RemoveAndDestroy: function(Indexes) -> removes connection|any from "_connections"|"_any" and destroys|disconnects it. if found. returns nothing
		
		RemoveAllIn: function("Connections"|"Any"|"Both") -> removes everything from selected table. returns nothing
		RemoveAndDestroyAllIn: function("Connections"|"Any"|"Both") -> removes and destroys|disconnects everything from selected table. returns nothing
		
		DisconnectAll: function(nil) -> disconnects everything in "_connections". returns nothing
		DestroyAllAny: function(nil) -> destroys everything in "_any". returns nothing
		SemiDestroy: function(nil) -> disconnects|destroys everything. returns nothing
		Destroy: function(nil) -> disconnects|destroys everything and makes self empty. returns nothing
	}
	
	--examples--
	
	local newContainer = Container.new()
	
	--two variants of getting a part and removing it after--
	
	1 = {
		local Part,NewIndex = newContainer:Add(Instance.new("Part"),"CoolPart") 
		
		newContainer:Remove(NewIndex)
	}
	2 = {
		newContainer:Add(Instance.new("Part"),"CoolPart") 
		local Part = newContainer.CoolPart
		
		newContainer:Remove("CoolPart")
	}

--]]
local printPrefix = "[CONTAINER]"
local function quickPropertyChecker(instance: Instance, Property: string)
	local success, output = pcall(function()
		return instance[Property]
	end)
	return success and output ~= nil
end
local function isConnection(value: any?): (any: RBXScriptConnection | any) -> boolean
	return typeof(value) == "RBXScriptConnection"
end

local Container = {}

Container._functions = {
	_sort = function(self, index, value)
		return rawset(self[isConnection(value) and "_connections" or "_any"], index, value)
	end,
	Validate = function(self, ...)
		local results = {}
		local indexes = typeof(...) ~= "table" and { ... } or ...
		local function indexOperation(slot, index)
			results[slot] = self._connections[index] ~= nil or self._any[index] ~= nil or false
		end
		if typeof(indexes) == "table" then
			for slot, index in indexes do
				indexOperation(slot, index)
			end
		else
			indexOperation(indexes)
		end
		indexes = nil
		return table.unpack(results)
	end,
	Get = function(self, ...)
		local results = {}
		local indexes = typeof(...) ~= "table" and { ... } or ...
		local function indexOperation(slot, index)
			results[slot] = self._connections[index] or self._any[index]
		end
		if typeof(indexes) == "table" then
			for slot, index in indexes do
				indexOperation(slot, index)
			end
		else
			indexOperation(indexes)
		end
		indexes = nil
		return table.unpack(results)
	end,
	Set = function(self, index, any, destroy)
		local indexFoundIn = self._connections[index] ~= nil and "_connections"
			or self._any[index] ~= nil and "_any"
			or nil
		if indexFoundIn == nil then
			return self:Add(any, index), nil, nil
		else
			local oldindex, oldvalue = index, self[indexFoundIn][index]
			self[destroy and "RemoveAndDestroy" or "Remove"](self, index)
			return self:Add(any, index), oldindex, oldvalue
		end
	end,
	IsItIn = function(self, index, In)
		In = In == "Connections" and "_connections" or In == "Any" and "_any" or nil
		assert(In ~= nil, "In is nil")
		return self[In][index] ~= nil, self[In][index]
	end,
	IsIt = function(self, index, type)
		type = type == "Connection" and "RBXScriptConnection" or type
		local indexFound = self._connections[index] or self._any[index] or nil
		if indexFound == nil then
			return nil
		end
		return typeof(indexFound) == type
	end,
	Add = function(self, any, index)
		index = index or #self[isConnection(any) and "_connections" or "_any"] + 1
		self:_sort(index, any)
		return any, index
	end,
	Remove = function(self, ...)
		debug.profilebegin("Container->Remove()")
		local indexes = typeof(...) ~= "table" and { ... } or ...
		local function indexOperation(index)
			local indexFoundIn = self._connections[index] ~= nil and "_connections"
				or self._any[index] ~= nil and "_any"
				or nil
			--assert(indexFoundIn ~= nil, `can't find {tostring(index)} in "_connections" and "_any"`)
			--^ uhh... just forget about that. maybe
			rawset(self[indexFoundIn], index, nil)
		end
		if typeof(indexes) == "table" then
			for _, index in indexes do
				indexOperation(index)
			end
		else
			indexOperation(indexes)
		end
		indexes = nil
		debug.profileend()
	end,
	RemoveAndDestroy = function(self, ...) -- unoriginal name №2
		debug.profilebegin("Container->RemoveAndDestroy()")
		local indexes = typeof(...) ~= "table" and { ... } or ...
		local function indexOperation(index)
			local indexFoundIn = self._connections[index] ~= nil and "_connections"
				or self._any[index] ~= nil and "_any"
				or nil
			--assert(indexFoundIn ~= nil, `can't find {tostring(index)} in "_connections" and "_any"`)
			--^ just no.
			if indexFoundIn == nil then
				return
			end
			if quickPropertyChecker(self[indexFoundIn][index], "Destroy") then
				self[indexFoundIn][index]:Destroy()
			elseif isConnection(self[indexFoundIn][index]) then
				self[indexFoundIn][index]:Disconnect()
			elseif typeof(self[indexFoundIn][index]) == "thread" then
				local task_success, task_output = pcall(task.cancel, self[indexFoundIn][index])
				local coroutine_success, coroutine_output = pcall(coroutine.close, self[indexFoundIn][index])
				if not task_success and not coroutine_success then
					warn(printPrefix, "ERROR IN DestroyAllAny()->coroutine.close & task.cancel")
					warn(printPrefix, "TASK OUTPUT")
					warn(printPrefix, task_output)
					warn(printPrefix, "COROUTINE OUTPUT")
					warn(printPrefix, coroutine_output)
				end
			end
			rawset(self[indexFoundIn], index, nil)
		end
		if typeof(indexes) == "table" then
			for _, index in indexes do
				indexOperation(index)
			end
		else
			indexOperation(indexes)
		end
		indexes = nil
		debug.profileend()
	end,
	RemoveAllIn = function(self, locationName: "Connections" | "Any" | "Both") -- unoriginal name №1
		assert(typeof(locationName) == "string", "not a string")
		debug.profilebegin("Container->RemoveAllIn()")
		local tbl = `_{string.lower(locationName)}` -- oh.. that works too.
		if tbl == "_both" then --both
			--//CHANGEME i might going to use something else instead of task.spawn in the future.
			task.spawn(function()
				for _connections_index, _connections_value in pairs(self["_connections"]) do
					self:Remove(_connections_index)
				end
			end)
			task.spawn(function()
				for _any_index, _any_value in pairs(self["_any"]) do
					self:Remove(_any_index)
				end
			end)
		else
			for index, _ in pairs(self[tbl]) do
				self:Remove(index)
			end
		end
		debug.profileend()
	end,
	RemoveAndDestroyAllIn = function(self, locationName: "Connections" | "Any" | "Both") -- unoriginal name №3
		assert(typeof(locationName) == "string", "not a string")
		debug.profilebegin("Container->RemoveAndDestroyAllIn()")
		local tbl = `_{string.lower(locationName)}`
		if tbl == "_both" then --both
			task.spawn(function()
				for _connections_index, _connections_value in pairs(self["_connections"]) do
					self:RemoveAndDestroy(_connections_index)
				end
			end)
			task.spawn(function()
				for _any_index, _any_value in pairs(self["_any"]) do
					self:RemoveAndDestroy(_any_index)
				end
			end)
		else
			for index, _ in pairs(self[tbl]) do
				self:RemoveAndDestroy(index)
			end
		end
		debug.profileend()
	end,
	DisconnectAll = function(self) --oh..
		debug.profilebegin("Container->DisconnectAll()")
		self:RemoveAndDestroyAllIn("Connections")
		debug.profileend()
	end,
	DestroyAllAny = function(self) --uh..
		debug.profilebegin("Container->DestroyAllAny()")
		self:RemoveAndDestroyAllIn("Any")
		debug.profileend()
	end,
	SemiDestroy = function(self) -- are you serious right now t10_kol?.
		self:RemoveAndDestroyAllIn("Both")
		return self
	end,
	Destroy = function(self)
		self:SemiDestroy()
		table.clear(self)
		return self
	end,
}

-- Чувствуешь брат?, связь с typechecking?

export type containerTableSelection = "Connections" | "Any" | "Both"

export type ContainerType = {
	Validate: (self: any, ...any) -> ...boolean,
	Get: (self: any, ...any) -> ...any,
	Set: (self: any, index: any, any: any, useDestroy: boolean) -> (any, any, any | nil, any | nil),
	IsItIn: (self: any, index: any, In: "Connections" | "Any") -> (boolean, any),
	IsIt: (self: any, index: any, type: string) -> boolean,

	Add: (self: any, any: any, index: any) -> (any, any),
	Remove: (self: any, ...any) -> nil,
	RemoveAndDestroy: (self: any, ...any) -> nil,

	RemoveAllIn: (self: any, locationName: containerTableSelection) -> nil,
	RemoveAndDestroyAllIn: (self: any, locationName: containerTableSelection) -> nil,

	DisconnectAll: (self: any) -> nil,
	DestroyAllAny: (self: any) -> nil,
	SemiDestroy: (self: any) -> nil,
	Destroy: (self: any) -> nil,
	[any]: any,
}

function Container.new(preAddTable: { [any]: any } | nil): ContainerType
	local selfBase = {
		_className = "Container",
		_connections = {},
		_any = {},
	}

	local meta = { -- meta here.
		__newindex = function(tbl, index, value)
			return tbl:_sort(index, value)
		end,
		__index = function(tbl, index)
			--rawget fixes C stack overflow error.
			--_connections has more priority in __index function.
			--so think twice when before inserting 2 things with exact same name but with different types
			return rawget(tbl["_connections"], index)
				or rawget(tbl["_any"], index)
				or rawget(Container._functions, index)
				or rawget(tbl, index)
		end,
	}
	local self = setmetatable(selfBase, meta)

	if preAddTable ~= nil and typeof(preAddTable) == "table" then -- pre-add stuff. cool... isn't it?
		for index, value in pairs(preAddTable) do
			self:Add(value, index)
		end
		table.clear(preAddTable)
		preAddTable = nil
	end

	return self
end

return Container :: { new: (preAddTable: { [any]: any } | nil) -> ContainerType }
