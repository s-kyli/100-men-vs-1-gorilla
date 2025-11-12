local HumanMelee = {}

local RL = game:GetService("ReplicatedStorage")
local Remotes = RL:WaitForChild("Remotes")
local OSModules = RL:WaitForChild("OSModules")
local jMod = require(OSModules:WaitForChild("Janitor"))

local Modules = script.Parent
local hitDetectionMod = require(Modules:WaitForChild("HitDetection"))

function HumanMelee.new(tool : Tool,character : Model)
	
	local self = setmetatable({}, {__index = HumanMelee})
	
	self.tool = tool
	self.player = game.Players.LocalPlayer
	self.character = character
	self.humanoid = character:WaitForChild("Humanoid")
	self.debounce = false
	self.hitbox = nil
	
	self.janitor = jMod.new()
	
	self.janitor:Add(self.tool.Equipped:Connect(function()
		
		self.anims.Idle:Play()
		
	end),"Disconnect")
	
	self.janitor:Add(self.tool.Unequipped:Connect(function()

		self.anims.Idle:Stop()

	end),"Disconnect")
	
	self.janitor:Add(self.tool.Activated:Connect(function()
		
		if self.debounce then return end
		if self.character.Ragdoll:FindFirstChild("Ragdoll") then return end
		
		self.debounce = true
		task.delay(RL.WeaponConfigurations[tool.Name].SwingCooldown.Value,function()
			self.debounce = false
		end)
		
		self.anims.Attack:Play()
		
	end))
	
	local anims:{[string] : AnimationTrack} = {}
	self.anims = anims
	
	for _, animation:Animation in RL.Assets.Animations[tool.Name]:GetChildren() do
		local animationTrack:AnimationTrack = self.humanoid.Animator:LoadAnimation(animation)
		self.anims[animation.Name] = animationTrack
	end
	
	hitDetectionMod.hitInit(self,tool.Hitbox)
	
	self.janitor:Add(self.anims.Attack:GetMarkerReachedSignal("Attack"):Connect(function()
		self.hitbox:HitStart()
		Remotes.PlaySound:FireServer(tool.Hitbox.Swing)
	end),"Disconnect")
	
	self.janitor:Add(self.anims.Attack.Stopped:Connect(function()
		self.hitbox:HitStop()
	end),"Disconnect")
	
	return self
end

function HumanMelee:Destroy()
	
	self.janitor:Destroy()
	
	for _, anim in self.anims do
		anim:Destroy()
	end
	
	table.clear(self::never)
	setmetatable(self,nil)
	self = nil
end

return HumanMelee
