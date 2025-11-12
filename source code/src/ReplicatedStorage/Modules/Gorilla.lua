local Gorilla = {}

local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")

local RL = game:GetService("ReplicatedStorage")
local Remotes = RL:WaitForChild("Remotes")
local OSModules = RL:WaitForChild("OSModules")
local jMod = require(OSModules:WaitForChild("Janitor"))

local GorillaConfiguration = RL:WaitForChild("GorillaConfigurations")

local Modules = script.Parent
local hitDetectionMod = require(Modules:WaitForChild("HitDetection"))

function Gorilla.new(character:Model)
	
	local self = setmetatable({}, {__index = Gorilla})
	
	self.player = game.Players.LocalPlayer
	self.character = character
	self.humanoid = character:WaitForChild("Humanoid")
	self.debounce = false
	self.specialDebounce = false
	self.humanoid.JumpHeight = 0
	self.humanoid.WalkSpeed = GorillaConfiguration.Speed.Value
	self.hitbox = nil
	self.GorillaHandPart = character["Right Arm"].GorillaHandPart
	self.trappedGui = script.TrappedGui:Clone()
	self.trappedGui.Parent = self.player.PlayerGui
	self.trap = nil
	self.controlsGui = script.ControlsGui:Clone()
	self.controlsGui.Parent = self.player.PlayerGui

	
	self.janitor = jMod.new()
	
	local anims:{[string] : AnimationTrack} = {}
	self.anims = anims

	for _, animation:Animation in RL.Assets.Animations.Gorilla:GetChildren() do
		local animationTrack:AnimationTrack = self.humanoid.Animator:LoadAnimation(animation)
		self.anims[animation.Name] = animationTrack
	end
	
	self.janitor:Add(UIS.InputBegan:Connect(function(input,gpe)
		if gpe then return end
		
		if input.KeyCode == Enum.KeyCode.E then
			self:Special()
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:Attack()		
		end
	end),"Disconnect")
	
	self.janitor:Add(self.anims.Attack:GetMarkerReachedSignal("Attack"):Connect(function()
		
		self.hitbox:HitStart()
		Remotes.PlaySound:FireServer(self.GorillaHandPart.Swing)

	end),"Disconnect")
	
	self.janitor:Add(self.anims.Attack.Stopped:Connect(function()

		self.hitbox:HitStop()

	end),"Disconnect")
	
	hitDetectionMod.hitInit(self,character["Right Arm"].GorillaHandPart)
	
	self.janitor:Add(self.anims.Smash:GetMarkerReachedSignal("Smash"):Connect(function()
		
		Remotes.PlaySound:FireServer(self.GorillaHandPart.Swing)

	end),"Disconnect")

	self.janitor:Add(self.anims.Smash.Stopped:Connect(function()
		
		hitDetectionMod.checkSmashHit(self)
		
		Remotes.PlaySound:FireServer(self.GorillaHandPart.Hit2)
		
		Remotes.DangerZoneIndicator:FireServer(1)
		
		self.humanoid.WalkSpeed = GorillaConfiguration.Speed.Value

	end),"Disconnect")
	
	self.janitor:Add(Remotes.GetTrapped.OnClientEvent:Connect(function(trap)
		self:GetTrapped(trap)
	end),"Disconnect")
	
	if UIS.TouchEnabled then
		self.mobileUI = script.GorillaMobileUI:Clone()
		self.mobileUI.Parent = self.player.PlayerGui
		
		self.janitor:Add(self.mobileUI.Attack.InputBegan:Connect(function(input)
			if input.UserInputState == Enum.UserInputState.Begin and input.UserInputType == Enum.UserInputType.Touch then
				self:Attack()
			end
		end),"Disconnect")
		
		self.janitor:Add(self.mobileUI.Special.InputBegan:Connect(function(input)
			if input.UserInputState == Enum.UserInputState.Begin and input.UserInputType == Enum.UserInputType.Touch then
				self:Special()
			end
		end),"Disconnect")
	end
	
	
	
	return self
end

function Gorilla:Attack()
	
	if self.debounce then return end
	if self.trappedGui.Enabled then return end
	
	self.debounce = true
	
	task.defer(function()
		
		local timeLeft = RL.GorillaConfigurations.AttackCooldown.Value
		self.controlsGui.Frame.Attack.Text = "Attack: Click - " .. tostring(math.floor(timeLeft * 10 + 0.5) / 10) .. "s"
		repeat
			task.wait(0.1)
			timeLeft -= 0.1
			self.controlsGui.Frame.Attack.Text = "Attack: Click - " .. tostring(math.floor(timeLeft * 10 + 0.5) / 10) .. "s"
		until timeLeft <= 0
		
		self.controlsGui.Frame.Attack.Text = "Attack: Click"
		
		self.debounce = false
	end)
	
	self.anims.Attack:Play()
end

function Gorilla:Special()
	
	if self.specialDebounce then return end
	if self.trappedGui.Enabled then return end
	self.specialDebounce = true
	task.defer(function()

		local timeLeft = RL.GorillaConfigurations.SpecialAttackCooldown.Value
		self.controlsGui.Frame.Special.Text = "Smash: E - " .. tostring(math.floor(timeLeft * 10 + 0.5) / 10) .. "s"
		repeat
			task.wait(0.1)
			timeLeft -= 0.1
			self.controlsGui.Frame.Special.Text = "Smash: E - " .. tostring(math.floor(timeLeft * 10 + 0.5) / 10) .. "s"
		until timeLeft <= 0

		self.controlsGui.Frame.Special.Text = "Smash: E"

		self.specialDebounce = false
	end)
	
	Remotes.DangerZoneIndicator:FireServer(0)
	
	self.humanoid.WalkSpeed = GorillaConfiguration.ChargingSpeed.Value
	
	self.anims.Smash:Play()
	
end

function Gorilla:GetTrapped(trap)
	self.trap = trap
	self.trappedGui.Enabled = true
	self.humanoid.WalkSpeed = 0
	self.humanoid.AutoRotate = false
	local clicksNeeded = 25
	if UIS.TouchEnabled then
		clicksNeeded = 10
	end
	
	local clicks = 0
	
	local uisConnection:RBXScriptConnection = nil
	uisConnection = UIS.InputBegan:Connect(function(input)
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			clicks += 1
			self.trappedGui.Frame.ProgressBar.Size = UDim2.fromScale(clicks/clicksNeeded,1)
			if clicks >= clicksNeeded then
				self.trappedGui.Enabled = false
				uisConnection:Disconnect()
				Remotes.UnTrap:FireServer(self.trap)
				self.humanoid.WalkSpeed = GorillaConfiguration.Speed.Value
				self.humanoid.AutoRotate = true
				self.trap = nil
				self.player.PlayerGui.VineBoom.ImageLabel.ImageTransparency = 1
				self.player.PlayerGui.VineBoom.ImageLabel.BackgroundTransparency = 1
			end
		end
	end)
	
end

function Gorilla:Destroy()
	
	self.janitor:Destroy()
	
	for _, anim in self.anims do
		anim:Destroy()
	end
	
	table.clear(self::never)
	setmetatable(self,nil)
	self = nil	

end



return Gorilla
