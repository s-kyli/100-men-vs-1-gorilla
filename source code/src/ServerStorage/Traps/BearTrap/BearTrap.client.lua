local RL = game:GetService("ReplicatedStorage")
local GameInfo = RL.GameInfo
local config = RL.WeaponConfigurations.BearTrap

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local tool = script.Parent

local player:Player = game.Players.LocalPlayer
local character = player.Character
local humanoid:Humanoid = character:WaitForChild("Humanoid")

local animator:Animator = humanoid.Animator
local SetUpTrack = animator:LoadAnimation(RL.Assets.Animations.BearTrap.SetUp)
local SetUpInProgressTrack = animator:LoadAnimation(RL.Assets.Animations.BearTrap.SetUpInProgress)
local IdleTrack = animator:LoadAnimation(RL.Assets.Animations.BearTrap.Idle)

local gui = script:WaitForChild("BearTrapUI")
gui.Parent = player.PlayerGui

local connections:{RBXScriptConnection} = {}

local equipped = false
local settingUp = false
local tween = TweenService:Create(gui:WaitForChild("Frame"):WaitForChild("ProgressBar"),TweenInfo.new(config:WaitForChild("SetUpTime").Value),{
	Size = UDim2.fromScale(1,1)
})

local equippedConnection = tool.Equipped:Connect(function()
	gui.Enabled = true
	equipped = true
	IdleTrack:Play()
end)

table.insert(connections,equippedConnection)

local unequippedConnection = tool.Unequipped:Connect(function()
	gui.Enabled = false
	equipped = false
	IdleTrack:Stop()
	tween:Cancel()
end)

table.insert(connections,unequippedConnection)

local setTrapButtonConnnection = gui:WaitForChild("SetTrapButton").Activated:Connect(function()
	
	if #workspace.Traps:GetChildren() >= RL.GameConfiguration.MaxTraps.Value then
		gui.Sound:Play()
		gui.MaxTrapsNotification.Visible = true
		return
	end
	
	if not equipped then return end
	
	tween:Play()
	SetUpTrack:Play()
	gui.Frame.Visible = true
	gui.SetTrapButton.Visible = false
	
	local setUpTrackFinishedConnection = SetUpTrack.Stopped:Once(function()
		SetUpInProgressTrack:Play()
	end)
	
	local originalWalkspeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0
	local originalJumpHeight = humanoid.JumpHeight
	humanoid.JumpHeight = 0
	
	local staggerAddedConnection = character.ChildAdded:Connect(function(child)
		if child.Name == "Stagger" then
			tween:Cancel()
		end
	end)
	
	local cancelConnection = gui.Frame.CancelButton.Activated:Connect(function()
		tween:Cancel()
	end)
	
	tween.Completed:Once(function(playbackstate)
		
		cancelConnection:Disconnect()
		setUpTrackFinishedConnection:Disconnect()
		SetUpTrack:Stop()
		SetUpInProgressTrack:Stop()
		gui.Frame.Visible = false
		gui.SetTrapButton.Visible = true
		gui.Frame.ProgressBar.Size = UDim2.fromScale(0,1)
		
		if playbackstate == Enum.PlaybackState.Completed then
			
			if #workspace.Traps:GetChildren() < RL.GameConfiguration.MaxTraps.Value then
				RL.Remotes.SetTrap:FireServer(tool)
				for _, connection in connections do
					connection:Disconnect()
				end



				IdleTrack:Stop()
				IdleTrack:Destroy()
				SetUpTrack:Destroy()
				SetUpInProgressTrack:Destroy()
				script.Enabled = false
				gui:Destroy()
				print("firing")
				RL.Remotes.SetTrap:FireServer(tool)
			end
		end

		humanoid.WalkSpeed = originalWalkspeed
		humanoid.JumpHeight = originalJumpHeight
		
		staggerAddedConnection:Disconnect()
	end)
	
end)

table.insert(connections,setTrapButtonConnnection)

local notificationConnection = gui:WaitForChild("MaxTrapsNotification").Activated:Connect(function()
	gui.MaxTrapsNotification.Visible = false
end)
