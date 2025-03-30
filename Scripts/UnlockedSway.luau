--services--
_UserInputService 	= game:GetService("UserInputService")
_ReplicatedStorage 	= game:GetService("ReplicatedStorage")
_RunService			    = game:GetService("RunService")

--functions--
function _RoundClampVector(vec:(Vector3)&{x:number,y:number,z:number}, maxMagnitude:number)
	assert(vec,"bro, where's the vector3?")
	assert(maxMagnitude,"bro, where's the maxMagnitude?")
	local magnitude = math.sqrt(
		vec.x 
			* vec.x 
			+ vec.y 
			* vec.y 
			+ vec.z 
	)
	if magnitude > maxMagnitude then
		local scale = maxMagnitude / magnitude
		return vec.z and Vector3.new(
			vec.x 
				* scale,
			vec.y 
				* scale,
			vec.z 
				* scale
		) 
	end
	return vec
end
_mousedelta_reduction = 150
function _M() -- mousedelta
	local delta=_UserInputService:GetMouseDelta()
	
	local x,y,z=
	 delta.X / _mousedelta_reduction
	,delta.Y / _mousedelta_reduction
	,0
	
	return Vector3.new(-y,-x,z)
end

--vars--
_camera = workspace.CurrentCamera

_viewmodel = _ReplicatedStorage:WaitForChild("Viewmodel",5)
_viewmodel.Parent=_camera

_free_move_clamp = math.rad(15)
_free_move_vec3=Vector3.zero
_free_move_cframe=CFrame.new()

function _render(dt:number)
	local lerpDT = dt*60
	
	local mouse_delta = _M()
	
	_free_move_vec3=_RoundClampVector(_free_move_vec3 + mouse_delta,_free_move_clamp)
	_free_move_cframe = CFrame.Angles(_free_move_vec3.X,_free_move_vec3.Y,0)
	_viewmodel.PrimaryPart.CFrame=
		_camera.CFrame
		*
		CFrame.new(0,-1.5,0)
		*
		_free_move_cframe
end
_RunService:BindToRenderStep("_vm_render",Enum.RenderPriority.Camera.Value+1,_render)
