--!nocheck
--_scriptType="module"
--[[

	--made in T10-Studio by: "t10_kol"--
	
	--rules--
	
	"module is free to use and edit, i don't care"
	
	--dev commentary--
	
	(t10_kol): "it works, it looks bad, but still works."


--]]

local instancelib

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Utils = script.Parent

instancelib = {}
local _game={
	["FindFirstAncestorWhichIsA"]=game.FindFirstAncestorWhichIsA,
	["FindFirstAncestorOfClass"]=game.FindFirstAncestorOfClass,
	["FindFirstChildWhichIsA"]=game.FindFirstChildWhichIsA,
	["FindFirstDescendant"]=game.FindFirstDescendant,
	["IsPropertyModified"]=game.IsPropertyModified,
	["FindService"]=game.FindService,
	["GetStyled"]=game.GetStyled,
	["GetActor"]=game.GetActor,
	["RemoveTag"]=game.RemoveTag,
	["GetTags"]=game.GetTags,
	["HasTag"]=game.HasTag,
	["AddTag"]=game.AddTag,
	["ClearAllChildren"]=game.ClearAllChildren,
	["GetAttributeChangedSignal"]=game.GetAttributeChangedSignal,
	["GetAttributes"]=game.GetAttributes,
	["SetAttribute"]=game.SetAttribute,
	["GetAttribute"]=game.GetAttribute,
	["Remove"]=game.Remove,
	["IsLoaded"]=game.IsLoaded,
	["GetPropertyChangedSignal"]=game.GetPropertyChangedSignal,
	["GetFullName"]=game.GetFullName,
	["GetDescendants"]=game.GetDescendants,
	["GetChildren"]=game.GetChildren,
	["Destroy"]=game.Destroy,
	["Clone"]=game.Clone,
	["GetService"]=game.GetService,
	["FindFirstChildOfClass"]=game.FindFirstChildOfClass,
	["FindFirstChild"]=game.FindFirstChild,
	["WaitForChild"]=game.WaitForChild,
	["FindFirstAncestor"]=game.FindFirstAncestor,
	["IsA"]=game.IsA,
	["IsDescendantOf"]=game.IsDescendantOf,
	["IsAncestorOf"]=game.IsAncestorOf,
	["IsChildOf"]=function(self:Instance,parent:Instance)
		assert(instancelib.IsAInstance(self),"first argument is not instance")
		assert(instancelib.IsAInstance(parent),"second argument is not instance")
		return (self.Parent==parent)
	end,
}
_game=setmetatable(_game,{__index=game})
local game=_game

function instancelib.PropertyExists(instance, property:string)
	local partHasProperty, Input = pcall(function()
		local t = instance[property]
		return t
	end)
	return partHasProperty,Input
end
function instancelib.AttributeExists(instance:Instance, attribute:string)
	local partHasProperty, Input = pcall(function()
		local t = instance:GetAttribute(attribute)
		return t
	end)
	return partHasProperty,Input
end

function instancelib.setAdditions(any:any,additions)
	local Success,Output = pcall(function()
		for index,value in pairs(additions) do
			any[index]=value
		end
	end)
	if not Success then
		warn("failed to apply Additions")
		warn(Output)
	end
	return Success,Output
end

function instancelib.defaultRemove(_task,instance:Instance)
	assert(instancelib.PropertyExists(instance,"Destroy"),"Second argument doesn't have Destroy function")
	instance:Destroy()
	instance=nil
	if (_task) then
		task.cancel(_task)
	end
	_task=nil
end

function instancelib.IsChildOf(child:Instance,parent:Instance)
	assert(instancelib.IsAInstance(child),"first argument is not instance")
	assert(instancelib.IsAInstance(parent),"second argument is not instance")
	return _game.IsChildOf(child,parent)
end

function instancelib.IsAInstance(object:any)
	return typeof(object)=="Instance"
end

function instancelib.getrandomInstance(tbl)
	assert(tbl,"table is not valid")
	return tbl[math.random(1,#tbl)] or false
end

function instancelib.eventOnEmptyInstance(instance:Instance) : (RBXScriptSignal,()->())
	assert(instance,"instance is not valid")
	assert(typeof(instance)=="Instance","this value is not instance type")
	
	local _event = Instance.new("BindableEvent")
	local _connection:RBXScriptConnection
	_connection=instance.ChildRemoved:Connect(function(c)
		if #instance:GetChildren()<=0 then
			_connection:Disconnect()
			_connection=nil
			_event:Fire()
		end
	end)
	local _destroy
	function _destroy()
		_destroy=nil
		if (_connection) then
			_connection:Disconnect()
		end
		_connection=nil
		_event:Destroy()
		_event=nil
	end
	return _event.Event,_destroy
end

function instancelib.removeInstanceOnTime(Instance:Instance,RemoveTime:number)
	assert(instancelib.PropertyExists(Instance,"Destroy"),"First argument doesn't have Destroy function")
	local _task
	_task=task.delay(RemoveTime,instancelib.defaultRemove,_task,Instance)
end

function instancelib.makeattachmentOn(Parent:CFrame|Instance) : (Attachment,()->())
	assert(Parent,"Parent is not valid")
	local Attachment = Instance.new("Attachment")
	Attachment.Name="GeneratedAttachment-"..HttpService:GenerateGUID(false)
	if instancelib.typeof(Parent,"CFrame") then
		Attachment.WorldCFrame=Parent
	end
	local removefunc
	removefunc=function()
		Attachment:Destroy()
		Attachment=nil
		removefunc=nil
	end
	Attachment.Parent= instancelib.typeof(Parent,"CFrame") and workspace.Terrain or Parent
	return Attachment,removefunc
end

function instancelib.grabWorldCFrame(instance)
	assert(instancelib.IsAInstance(instance),"first argument is not instance")
	if instancelib.PropertyExists(instance,"WorldCFrame") then
		return instance.WorldCFrame
	elseif instancelib.PropertyExists(instance,"CFrame") then
		return instance.CFrame
	else
		assert("first argument doesn't have any CFrame like properties")
		return nil
	end
end

function instancelib.typeof(value:any,type:string|"CFrame"|"Instance"|any)
	return typeof(value)==type
end

return instancelib
