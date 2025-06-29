--!nocheck
--_scriptType="module"
--[[

	--made in T10-Studio by: t10_kol|ID:3264445159|"RbxscrIptConnectinG"--
	
	Copyright©: None, feel free to use, edit, sell and distribute
				this util anywhere you want and any time you want ;)
	
	--dev commentary--
	
	(t10_kol): "unreadable."

	--info--

	Version: 0.0.6
	
	Container.new() = {
		Validate: function(Indexes) -> checks if indexes in "_connections"|"_any" are available. returns booleans (found: true, not found: false)

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
local function quickPropertyChecker(instance:Instance,Property:string)
	local success,output = pcall(function()
		return instance[Property]
	end)
	return success and output~=nil
end
Container = {}

-- Чувствуешь брат?, связь с typechecking?

export type containerTableSelection = "Connections"|"Any"|"Both"

export type ContainerType = ({
	Validate:(self:any,...any)->(boolean),
	
	Add:(self:any,any:any,index:any)->(any),
	Remove:(self:any,...any)->(),
	RemoveAndDestroy:(self:any,...any)->(),

	RemoveAllIn:(self:any,Where:containerTableSelection) -> (),
	RemoveAndDestroyAllIn:(self:any,Where:containerTableSelection) -> (),

	DisconnectAll:(self:any)->(),
	DestroyAllAny:(self:any)->(),
	SemiDestroy:(self:any)->(),
	Destroy:(self:any)->(),
	[any]:any,
})
local function isConnection(value:any?) : (any:RBXScriptConnection|any) -> (boolean)
	return typeof(value)=="RBXScriptConnection"
end
function Container.new() : ContainerType

	local selfBase = {
		_className="Container",
		_connections={},
		_any={},
		_sort=function(self,index,value)
			return rawset(self[isConnection(value) and "_connections" or "_any"],index,value)
		end,
		Validate=function(self,...)
			local results = {}
			local indexes = typeof(...)~="table" and {...} or ...
			local function indexOperation(slot,index)
				results[slot] = self._connections[index]~=nil or self._any[index]~=nil or false
			end
			if typeof(indexes)=="table" then
				for slot, index in indexes do
					indexOperation(slot,index)
				end
			else
				indexOperation(indexes)
			end
			table.clear(indexes)
			indexes=nil
			return table.unpack(results)
		end,
		Add=function(self,any,index)
			index = index or #self[isConnection(any) and "_connections" or "_any"]+1
			self:_sort(index,any)
			return any,index
		end,
		Remove=function(self,...)
			debug.profilebegin("Container->Remove()")
			local indexes = typeof(...)~="table" and {...} or ...
			local function indexOperation(index)
				local indexFoundIn = 
					self._connections[index]~=nil
					and 
					"_connections"
					or
					self._any[index]~=nil 
					and 
					"_any"
					or nil

				assert(indexFoundIn~=nil,`can't find {tostring(index)} in "_connections" and "_any"`)
				rawset(self[indexFoundIn],index,nil)
			end
			if typeof(indexes)=="table" then
				for _, index in indexes do
					indexOperation(index)
				end
			else
				indexOperation(indexes)
			end
			table.clear(indexes)
			indexes=nil
			debug.profileend()
		end,
		RemoveAllIn=function(self,Where:"Connections"|"Any"|"Both")
			debug.profilebegin("Container->RemoveAllIn()")
			local tbl = `_{string.lower(Where)}` -- oh.. that works too.
			if tbl=="_both" then --both
				--//CHANGEME i might going to use something else instead of task.spawn in the future.
				task.spawn(function()
					for _connections_index,_connections_value in pairs(self["_connections"]) do
						self:Remove(_connections_index)
					end
				end)
				task.spawn(function()
					for _any_index,_any_value in pairs(self["_any"]) do
						self:Remove(_any_index)
					end
				end)
			else
				for index,value in pairs(self[tbl]) do
					self:Remove(index)
				end
			end
			debug.profileend()
		end,
		RemoveAndDestroy=function(self,...)
			debug.profilebegin("Container->RemoveAndDestroy()")
			local indexes = typeof(...)~="table" and {...} or ...
			local function indexOperation(index)
				local indexFoundIn = self._connections[index]~=nil and "_connections" or self._any[index]~=nil and "_any" or nil
				assert(indexFoundIn~=nil,`can't find {tostring(index)} in "_connections" and "_any"`)
				if quickPropertyChecker(self[indexFoundIn][index],"Destroy") then
					self[indexFoundIn][index]:Destroy()
				elseif isConnection(self[indexFoundIn][index]) then
					self[indexFoundIn][index]:Disconnect()
				elseif typeof(self[indexFoundIn][index])=="thread" then
					local task_success,task_output = pcall(task.cancel,self[indexFoundIn][index])
					local coroutine_success,coroutine_output = pcall(coroutine.close,self[indexFoundIn][index])
					if not task_success and not coroutine_success then
						warn(printPrefix,"ERROR IN DestroyAllAny()->coroutine.close & task.cancel")
						warn(printPrefix,"TASK OUTPUT")
						warn(printPrefix,task_output)
						warn(printPrefix,"COROUTINE OUTPUT")
						warn(printPrefix,coroutine_output)
					end
				end
				rawset(self[indexFoundIn],index,nil)
			end
			if typeof(indexes)=="table" then
				for _, index in indexes do
					indexOperation(index)
				end
			else
				indexOperation(indexes)
			end
			table.clear(indexes)
			indexes=nil
			debug.profileend()
		end,
		RemoveAndDestroyAllIn=function(self,Where:"Connections"|"Any"|"Both")
			debug.profilebegin("Container->RemoveAndDestroyAllIn()")
			local tbl = `_{string.lower(Where)}`
			if tbl=="_both" then --both
				task.spawn(function()
					for _connections_index,_connections_value in pairs(self["_connections"]) do
						self:RemoveAndDestroy(_connections_index)
					end
				end)
				task.spawn(function()
					for _any_index,_any_value in pairs(self["_any"]) do
						self:RemoveAndDestroy(_any_index)
					end
				end)
			else
				for index,value in pairs(self[tbl]) do
					self:RemoveAndDestroy(index)
				end
			end
			debug.profileend()
		end,
		DisconnectAll=function(self) --oh..
			debug.profilebegin("Container->DisconnectAll()")
			self:RemoveAndDestroyAllIn("Connections")
			debug.profileend()
		end,
		DestroyAllAny=function(self) --uh..
			debug.profilebegin("Container->DestroyAllAny()")
			self:RemoveAndDestroyAllIn("Any")
			debug.profileend()
		end,
		SemiDestroy=function(self) -- are you serious right now t10_kol?.
			self:RemoveAndDestroyAllIn("Both")
			return self
		end,
		Destroy=function(self)
			self:SemiDestroy()
			table.clear(self)
			return self
		end,
	}

	local meta = {
		__newindex = function(tbl,index,value)
			return tbl:_sort(index,value)
		end,
		__index = function(tbl,index)
			--rawget fixes C stack overflow error.
			--_connections has more priority in __index function.
			--so think twice when before inserting 2 things with exact same name but with different types
			return 
				rawget(tbl,"_connections")~=nil 
				and 
				rawget(tbl["_connections"],index)~=nil 
				and 
				rawget(tbl["_connections"],index)
				or 
				rawget(tbl,"_any")~=nil 
				and 
				rawget(tbl["_any"],index)~=nil 
				and 
				rawget(tbl["_any"],index)
				or 
				rawget(tbl,index)
		end,
	}
	local self = setmetatable(selfBase,meta)
	return self
end

return Container
