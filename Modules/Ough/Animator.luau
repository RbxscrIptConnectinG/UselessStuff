--!nocheck
--_scriptType="module"
--[[

	--made in T10-Studio by: "t10_kol"--
	
	--rules--
	
	"module is free to use and edit, i don't care"
	
	--dev commentary--
	
	(t10_kol): "such a useless module ig.."


--]]

local Animator = {}
Animator.__index = Animator

function Animator.new(animator:Animator)
	local self = setmetatable({},Animator)
	self.Animator = animator::Animator
	self._animations={}
	function self:makeAnimationFromId(animid:string|number)
		local pre = if tonumber(animid) then "rbxassetid://" else ""
		local Animation = Instance.new("Animation")
		Animation.AnimationId=pre..animid
		return Animation
	end
	function self:loadAnimation(animation:Animation,settings:{[any]:any},Tag:string|nil)
		local anim = self.Animator:LoadAnimation(animation)::AnimationTrack
		for index,value in pairs(settings) do
			anim[index]=value
		end
		self._animations[Tag or animation] = anim
		return self._animations[Tag or animation]
	end
	function self:unloadAnimation(animation:Animation,fadetime:number)
		for Index,Anim:AnimationTrack in pairs(self.Animator:GetPlayingAnimationTracks()) do
			if Anim.Animation==animation then
				Anim:Stop(fadetime)
				self.Animator:GetPlayingAnimationTracks()[Index]=nil
				break
			end
		end
	end
	function self:playAnimation(animationOrTag:Animation|string,fadetime:number,weight:number,speed:number)
		self._animations[animationOrTag]:Play(fadetime,weight,speed)
		return self._animations[animationOrTag]
	end
	function self:stopAnimation(animationOrTag:Animation|string,fadetime:number)
		self._animations[animationOrTag]:Stop(fadetime)
		return self._animations[animationOrTag]
	end
	function self:getAnimation(animationOrTag:Animation|string)
		return self._animations[animationOrTag]
	end
	function self:stopAllAnimations(fadetime:number)
		for Index,Anim in pairs(self._animations) do
			Anim:Stop(fadetime)
		end
	end
	function self:unloadAllAnimations(fadetime:number)
		for Index,Anim:AnimationTrack in pairs(self.Animator:GetPlayingAnimationTracks()) do
			Anim:Stop(fadetime)
			self.Animator:GetPlayingAnimationTracks()[Index]=nil
		end
	end
	return self
end


return Animator
