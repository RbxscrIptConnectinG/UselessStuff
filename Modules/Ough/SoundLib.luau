--!nocheck
--_scriptType="module"
--[[

	--made in T10-Studio by: "t10_kol"--
	
	--rules--
	
	"module is free to use and edit, i don't care"
	
	--dev commentary--
	
	(t10_kol): "emit the sound.. and remove it..."


--]]

local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local SoundLib = {}

local InstanceLib = script.Parent:FindFirstChild("InstanceLib") and require(script.Parent:FindFirstChild("InstanceLib"))

if (InstanceLib) then
	function SoundLib.defaultRemove(_task,instance:Instance)
		instance:Destroy()
		instance=nil
		if (_task) then
			task.cancel(_task)
		end
		_task=nil
	end
end
function SoundLib.localEmitSound(Sound:Sound)
	assert(RunService:IsClient(),"non client sided script")
	assert(Sound,"sound is not valid")
	SoundService:PlayLocalSound(Sound)
end
function SoundLib.emitSound(sound:Sound,parent:Instance,Additions:{[string]:any}|nil)
	assert(sound,"sound is not valid")
	assert(parent,"parent is not valid")

	local clone = sound:Clone()::Sound
	
	if (Additions) and (InstanceLib) then
		InstanceLib.setAdditions(clone,Additions)
	
	end
	local _task
	if InstanceLib.typeof(parent,"CFrame") then
		local attachment,removeattachment = InstanceLib.makeattachmentOn(parent)
		clone.Parent=attachment
		local event,_destroy = InstanceLib.eventOnEmptyInstance(attachment)
		local _event_connection:RBXScriptConnection
		_event_connection=event:Connect(function()
			_event_connection:Disconnect()
			_event_connection=nil
			_destroy()
			_destroy=nil
			removeattachment()
			removeattachment=nil
			attachment=nil
		end)
	else
		clone.Parent=parent
	end
	clone:Play()
	_task=task.delay(clone.TimeLength/clone.PlaybackSpeed,InstanceLib and InstanceLib.defaultRemove or SoundLib.defaultRemove,_task,clone)
	return clone,_task
end

return SoundLib
