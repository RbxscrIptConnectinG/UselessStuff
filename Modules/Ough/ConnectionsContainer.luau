--!nocheck
--_scriptType="module"
--[[

	--made in T10-Studio by: "t10_kol"--
	
	--rules--
	
	"module is free to use and edit, i don't care"
	
	--dev commentary--
	
	(t10_kol): "unreadable."

	--info--
	
	Version: 0.0.3
	
	ConnectionsContainer.new() = {
		Add: function(connection|any,CustomIndex) -> adds connection|any into "_connections" if RBXScriptConnection or "_any" if anything else. returns connection|any, newindex
		Remove: function(Index) -> removes connection|any from "_connections"|"_any" if found. returns nothing
		RemoveAndDestroy: function(Index) -> removes connection|any from "_connections"|"_any" and destroys it if found. returns nothing
		
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
ConnectionsContainer._sort = function(tbl,index,value)
	if tbl["_className"] and tbl["_className"]=="ConnectionsContainer" then
		tbl[typeof(value)=="RBXScriptConnection" and "_connections" or "_any"][index]=value
	else
		tbl[index]=value
	end
end
ConnectionsContainer._selfBase = {
	_className="ConnectionsContainer",
	_connections={},
	_any={},
	_sort=ConnectionsContainer._sort,
	Add=function(self,any,index)
		index = index or #self[typeof(any)=="RBXScriptConnection" and "_connections" or "_any"]+1
		self._sort(self,index,any)
		return any,index
	end,
	Remove=function(self,index)
		local indexFoundIn = self._connections[index] and "_connections" or self._any[index] and "_any" or nil
		assert((indexFoundIn),`can't find {index} in "_connections" and "_any"`)
		self[indexFoundIn][index]=nil
		--print("successfully set it to nil.")
	end,
	RemoveAndDestroy=function(self,index)
		local indexFoundIn = self._connections[index] and "_connections" or self._any[index] and "_any" or nil
		assert((indexFoundIn),`can't find {index} in "_connections" and "_any"`)
		if quickPropertyChecker(self[indexFoundIn][index],"Destroy") then
			self[indexFoundIn][index]:Destroy()
			self[indexFoundIn][index]=nil
		else
			self[indexFoundIn][index]=nil
		end
		--print("successfully deleted it.")
	end,
	DisconnectAll=function(self)
		debug.profilebegin("ConnectionsContainer->DisconnectAll()")
		for Index = 1,#self._connections do
			self._connections[Index]:Disconnect()
			self._connections[Index]=nil
		end
		debug.profileend()
	end,
	DestroyAllAny=function(self)
		debug.profilebegin("ConnectionsContainer->RemoveAllAny()")
		for Index = 1,#self._any do
			if quickPropertyChecker(self._any[Index],"Destroy") then
				self._any[Index]:Destroy()
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
ConnectionsContainer._meta = {
	__newindex = function(tbl,index,value)
		if tbl["_sort"] then
			tbl._sort(tbl,index,value)
		else
			tbl[index]=value
		end
	end,
	__index = function(tbl,index)
		if tbl["_className"] and tbl["_className"]=="ConnectionsContainer" then
			if tbl["_connections"] and tbl["_connections"][index] then
				return tbl["_connections"][index]
			elseif tbl["_any"] and tbl["_any"][index] then
				return tbl["_any"][index]
			end
		end
		-- lord have mercy.
		if table.find(tbl,index) then
			return tbl[index]
		else
			-- If you don't like it. switch it to commentary.
			warn(`index "{index}" not found anywhere in`,tbl)
			return nil
		end
	end,
}

function ConnectionsContainer.new() : 
	({
		Add:(self:any,any:any,index:any)->(any),
		Remove:(self:any,index:any)->(),
		RemoveAndDestroy:(self:any,index:any)->(),
		
		DisconnectAll:(self:any)->(),
		DestroyAllAny:(self:any)->(),
		SemiDestroy:(self:any)->(),
		Destroy:(self:any)->(),
		[any]:any,
	})
	return setmetatable(ConnectionsContainer._selfBase,ConnectionsContainer._meta)
end

return ConnectionsContainer
