--!nocheck
--_scriptType="module"
--[[

	-- WARNING. THIS MODULE WAS WRITTEN IN A HURRY SO THERE MAY BE ERRORS --
	
	-- check out https://github.com/Quenty/NevermoreEngine for "StepUtils" and "Signal" module

--]]

local RunService = game:GetService("RunService")

local IsAClient = RunService:IsClient()
local IsAServer = not IsAClient

local StepUtils = require(script.Parent:WaitForChild("StepUtils"))
local Signal = require(script.Parent:WaitForChild("Signal"))
local Timer
Timer = {
	Format=function(Int)
		return string.format("%02i", Int)
	end,
	-- convert to Hours,Minutes,Seconds
	convertToHMS=function(Seconds)
		local OLD_SECONDS = Seconds
		local Minutes = (Seconds - Seconds%60)/60
		Seconds = Seconds - Minutes*60
		local Hours = (Minutes - Minutes%60)/60
		Minutes = Minutes - Hours*60
		local minutesACTIVE = false
		local hoursACTIVE = false
		if OLD_SECONDS >= 60 then
			minutesACTIVE=true
		end
		if OLD_SECONDS >= 3600 then
			hoursACTIVE=true
		end
		local result=Timer.Format(Seconds)
		if minutesACTIVE then
			result = Timer.Format(Minutes)..":"..result
		end
		if hoursACTIVE then
			result = Timer.Format(Hours)..":"..result
		end
		return result
	end,
	TimerHandler = function(time)
		local handler = {}
		handler._oldtime = nil
		handler._staticTime=time
		handler.Time = handler._staticTime
		handler.Enabled = false
		handler.AllowFloats = true
		local LocalTick = tick()
		handler.TimerUpdated = Signal.new()
		handler.TimerEnded = Signal.new()
		--IsAClient and "bindToRenderStep" or IsAServer and "bindToStepped"
		local Connect,Disconnect = StepUtils["bindToStepped"](function(DT)
			if handler.Enabled then
				local _time = math.clamp((handler.AllowFloats and (tick()-LocalTick) or math.floor((tick()-LocalTick))),0,math.huge)
				if handler._staticTime-_time<=0 then
					handler:Disable()
					handler._oldtime=handler.Time
					handler.Time=0
					handler.TimerUpdated:Fire(handler.Time)
					handler.TimerEnded:Fire(handler.Time)
				else
					if not ((handler._staticTime-_time)==handler._oldtime) then
						handler.Time=handler._staticTime-_time
						handler._oldtime=handler.Time
						handler.TimerUpdated:Fire(handler.Time)
					end
				end
				return handler.Enabled
			else
				LocalTick=tick()
				return handler.Enabled
			end
		end)
		handler.RenderDisconnect = Disconnect
		function handler:Destroy()
			handler.TimerUpdated:DisconnectAll()
			handler.TimerEnded:DisconnectAll()
			handler.RenderDisconnect()
		end
		function handler:Enable()
			handler.Enabled=true
			Connect()
		end
		function handler:Disable()
			handler.Enabled=false
		end
		local function Time_Operation(number)
			local _time = math.clamp((handler.AllowFloats and (tick()-LocalTick) or math.floor((tick()-LocalTick))),0,math.huge)
			return handler._staticTime-_time
		end
		function handler:AddTime(number)
			handler._staticTime+=number
			handler.Time=Time_Operation(number)
			--handler.TimerUpdated:Fire(handler.Time)
		end
		function handler:RemoveTime(number)
			handler._staticTime-=number
			handler.Time=Time_Operation(number)
			--handler.TimerUpdated:Fire(handler.Time)
		end
		return handler
	end,

}
return Timer
