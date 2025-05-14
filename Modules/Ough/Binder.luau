--!nocheck
--_scriptType="module"
--[[

	--made in T10-Studio by: "t10_kol"--
	
	--rules--
	
	"module is free to use and edit, i don't care"
	
	--dev commentary--
	
	(t10_kol): "bind stuff."


--]]

local ContextActionService = game:GetService("ContextActionService")
local Binder = {}
Binder.__index = Binder

local function FastRemove(t, i)
	local n = #t
	t[i] = t[n]
	t[n] = nil
end

function Binder.newbinder()
	local self = setmetatable({},Binder)
	self._binds={}
	function self:getActionNamefromID(id:string)
		local _string= string.gsub(id,"^_bind.","")
		return _string
	end
	function self:bind(actionName,functionToBind,createTouchButton,...)
		local _id = "_bind."..actionName
		assert(not (self._binds[_id]),"bind with that name already exist")
		ContextActionService:BindAction(actionName,functionToBind,createTouchButton,...)
		self._binds[_id] = actionName
		local function unbind()
			self:unbind(actionName)
		end
		return unbind
	end
	function self:bindatPriority(actionName,functionToBind,createTouchButton,priorityLevel:number,...)
		local _id = "_bind."..actionName
		assert(not (self._binds[_id]),"bind with that name already exist")
		ContextActionService:BindActionAtPriority(actionName,functionToBind,createTouchButton,priorityLevel,...)
		self._binds[_id] = actionName
		local function unbind()
			self:unbind(actionName)
		end
		return unbind
	end
	function self:unbind(actionName)
		local _id = "_bind."..actionName
		assert((self._binds[_id]),"bind with that name doesn't exist")
		ContextActionService:UnbindAction(actionName)
		FastRemove(self._binds,_id)
		return
	end
	function self:unbindall()
		for index,value in pairs(self._binds) do
			self:unbind(self:getActionNamefromID(index))
		end
	end
	return self
end


return Binder
