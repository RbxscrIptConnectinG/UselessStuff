--Modules--

local ConnectionsContainer = nil -- path to ConnectionsContainer here.

--Logic--

local container = ConnectionsContainer.new()
for i = 1,20 do
	local debris, newIndex = Instance.new("Part"), nil
	debris.Position=Vector3.new(0,30,0)
	debris.CanCollide=false
	debris.AssemblyLinearVelocity=Vector3.new(math.random(-50,50),math.random(20,50),math.random(-50,50))
	debris.Name="_debris"

	debris, newIndex = container:Add(debris,`debris-{i}`)
	
	local debrisTouch, touchNewIndex
	
	debrisTouch, touchNewIndex = container:Add(debris.Touched:Connect(function(otherPart:BasePart)
		if otherPart.Name=="_debris" then return end
		container:RemoveAndDestroy({newIndex,touchNewIndex})
		print(`removed {i}`)
	end),`debrisTouched-{i}`)
	
	debris.Parent=workspace
	
end
task.wait(0.65)
--removing all left over debris if they didn't hit ground in time--
print("before SemiDestroy",container)
container:SemiDestroy()
print("after SemiDestroy",container)
task.wait(2)
--destroying container if we don't need it anymore.--
container:Destroy()
print(container)
--finishing it--
container=nil
print(container)
