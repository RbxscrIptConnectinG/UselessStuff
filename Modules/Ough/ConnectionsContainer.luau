--!nocheck
--_scriptType="module"
--[[

	--made in T10-Studio by: "t10_kol"--
	
	--rules--
	
	"module is free to use and edit, i don't care"
	
	--dev commentary--
	
	(t10_kol): "unreadable."

	--info--
	
	Version: 0.0.3p+++
	
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
	return (pcall(function()
		return instance[Property]
	end))
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
				self[typeof(value)=="RBXScriptConnection" and "_connections" or "_any"][index]=value
			else
				self[index]=value
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
				self[indexFoundIn][index]=nil
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
					self[indexFoundIn][index]=nil
				elseif typeof(self[indexFoundIn][index])=="RBXScriptConnection" then
					self[indexFoundIn][index]:Disconnect()
					self[indexFoundIn][index]=nil
				else
					self[indexFoundIn][index]=nil
				end
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
			for Index,Connection in self._connections do
				Connection:Disconnect()
				self._connections[Index]=nil
			end
			debug.profileend()
		end,
		DestroyAllAny=function(self)
			debug.profilebegin("ConnectionsContainer->RemoveAllAny()")
			for Index,Value in self._any do
				if quickPropertyChecker(Value,"Destroy") then
					Value:Destroy()
					self._any[Index]=nil
				else
					self._any[Index]=nil
				end
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
			if tbl["_sort"] then
				tbl:_sort(index,value)
			else
				tbl[index]=value
			end
		end,
		__index = function(tbl,index)
			if tbl["_className"]=="ConnectionsContainer" then
				if tbl["_connections"] and tbl["_connections"][index] then
					return tbl["_connections"][index]
				elseif tbl["_any"] and tbl["_any"][index] then
					return tbl["_any"][index]
				end
			end
			-- lord have mercy.
			return tbl[index]
		end,
	}
	local self = setmetatable(selfBase,meta)
	return self
end

return ConnectionsContainer
