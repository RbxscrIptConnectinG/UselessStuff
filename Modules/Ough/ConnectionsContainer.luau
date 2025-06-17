--!nocheck
--_scriptType="module"
--[[

	--made in T10-Studio by: "t10_kol"--
	
	--rules--
	
	"module is free to use and edit, i don't care"
	
	--dev commentary--
	
	(t10_kol): "unreadable."

	--info--

	Version: 0.0.4++
	
	ConnectionsContainer.new() = {
		Add: function(connection|any,CustomIndex) -> adds connection|any into "_connections" if RBXScriptConnection or "_any" if anything else. returns connection|any, newindex
		Remove: function(Indexes) -> removes connection|any from "_connections"|"_any" if found. returns nothing
		RemoveAndDestroy: function(Indexes) -> removes connection|any from "_connections"|"_any" and destroys|disconnects it. if found. returns nothing
		
		DisconnectAll: function(nil) -> disconnects everything in "_connections". returns nothing
		DestroyAllAny: function(nil) -> destroys everything in "_any". returns nothing
		SemiDestroy: function(nil) -> disconnects|destroys everything. returns nothing
		Destroy: function(nil) -> disconnects|destroys everything and makes self empty. returns nothing
	}
	
	--examples--
	
	local newContainer = ConnectionsContainer.new()
	
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

local function quickPropertyChecker(instance:Instance,Property:string)
	local success,output = pcall(function()
		return instance[Property]
	end)
	return success and output~=nil
end
ConnectionsContainer = {}
export type ConnectionsContainerType = ({
	Add:(self:any,any:any,index:any)->(any),
	Remove:(self:any,indexes:{any}|any)->(),
	RemoveAndDestroy:(self:any,indexes:{any}|any)->(),

	DisconnectAll:(self:any)->(),
	DestroyAllAny:(self:any)->(),
	SemiDestroy:(self:any)->(),
	Destroy:(self:any)->(),
	[any]:any,
})
function ConnectionsContainer.new() : ConnectionsContainerType

	local selfBase = {
		_className="ConnectionsContainer",
		_connections={},
		_any={},
		_sort=function(self,index,value)
			if self["_className"] and self["_className"]=="ConnectionsContainer" then
				rawset(self[typeof(value)=="RBXScriptConnection" and "_connections" or "_any"],index,value)
			else
				rawset(self,index,value)
			end
		end,
		Add=function(self,any,index)
			index = index or #self[typeof(any)=="RBXScriptConnection" and "_connections" or "_any"]+1
			self:_sort(index,any)
			return any,index
		end,
		Remove=function(self,...)
			local indexes = typeof(...)~="table" and {...} or ...
			local function indexOperation(index)
				local indexFoundIn = self._connections[index] and "_connections" or self._any[index] and "_any" or nil
				assert((indexFoundIn),`can't find {index} in "_connections" and "_any"`)
				rawset(self[indexFoundIn],index,nil)
				--print("successfully set it to nil.")
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
		end,
		RemoveAndDestroy=function(self,...)
			local indexes = typeof(...)~="table" and {...} or ...
			local function indexOperation(index)
				local indexFoundIn = self._connections[index] and "_connections" or self._any[index] and "_any" or nil
				assert((indexFoundIn),`can't find {index} in "_connections" and "_any"`)
				if quickPropertyChecker(self[indexFoundIn][index],"Destroy") then
					self[indexFoundIn][index]:Destroy()
				elseif typeof(self[indexFoundIn][index])=="RBXScriptConnection" then
					self[indexFoundIn][index]:Disconnect()
				elseif typeof(self[indexFoundIn][index])=="thread" then
					local task_success,task_output = pcall(task.cancel,self[indexFoundIn][index])
					local coroutine_success,coroutine_output = pcall(coroutine.close,self[indexFoundIn][index])
					if not task_success and not coroutine_success then
						warn("ERROR IN DestroyAllAny()->coroutine.close & task.cancel")
						warn("TASK OUTPUT")
						warn(task_output)
						warn("COROUTINE OUTPUT")
						warn(coroutine_output)
					end
				end
				rawset(self[indexFoundIn],index,nil)
				--print("successfully deleted it.")
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
		end,
		DisconnectAll=function(self)
			debug.profilebegin("ConnectionsContainer->DisconnectAll()")
			for Index,Value in self._connections do --That works too.
				self:RemoveAndDestroy(Index)
			end
			debug.profileend()
		end,
		DestroyAllAny=function(self)
			debug.profilebegin("ConnectionsContainer->RemoveAllAny()")
			for Index,Value in self._any do
				self:RemoveAndDestroy(Index)
			end
			debug.profileend()
		end,
		SemiDestroy=function(self)
			self:DisconnectAll()
			self:DestroyAllAny()
			--print("debug, destroyed")
			return self
		end,
		Destroy=function(self)
			self:SemiDestroy()
			table.clear(self)
			--print("debug, fully destroyed")
			return self
		end,
	}

	local meta = {
		__newindex = function(tbl,index,value)
			if rawget(tbl,"_sort") then
				tbl:_sort(index,value)
			else
				rawset(tbl,index,value)
			end
		end,
		__index = function(tbl,index)
			--rawget fixes C stack overflow error.
			if tbl["_connections"] and tbl["_connections"][index]~=nil then

				return rawget(tbl["_connections"],index)

			elseif tbl["_any"] and tbl["_any"][index]~=nil then

				return rawget(tbl["_any"],index)

			end
			return rawget(tbl, index)
		end,
	}
	local self = setmetatable(selfBase,meta)
	return self
end

return ConnectionsContainer
