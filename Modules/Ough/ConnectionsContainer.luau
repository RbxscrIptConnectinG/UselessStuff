--!nocheck
--_scriptType="module"
--[[

	--made in T10-Studio by: "t10_kol"--
	
	--rules--
	
	"module is free to use and edit, i don't care"
	
	--dev commentary--
	
	(t10_kol): "unreadable."

	--info--
	
	ConnectionsContainer.new() = {
		Add: function(connection|any,CustomIndex) -> adds connection|any into "_connections" (if RBXScriptConnection) or "_any" if anything else
		Destroy: function(nil) -> disconnects|destroys everything and makes table empty
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
		self._sort(self,index or #self[typeof(any)=="RBXScriptConnection" and "_connections" or "_any"]+1,any)
	end,
	Destroy=function(self)
		for Index = 1,#self._connections do
			self._connections[Index]:Disconnect()
			self._connections[Index]=nil
		end
		for Index = 1,#self._any do
			if quickPropertyChecker(self._any[Index],"Destroy") then
				self._any[Index]:Destroy()
				self._any[Index]=nil
			else
				self._any[Index]=nil
			end

		end
		table.clear(self)
		return self
	end,
}
ConnectionsContainer._meta = {__newindex = function(tbl,index,value)
	if tbl["_sort"] then
		tbl._sort(tbl,index,value)
	else
		tbl[index]=value
	end
end,}

function ConnectionsContainer.new()
	return setmetatable(ConnectionsContainer._selfBase,ConnectionsContainer._meta)
end

return ConnectionsContainer
