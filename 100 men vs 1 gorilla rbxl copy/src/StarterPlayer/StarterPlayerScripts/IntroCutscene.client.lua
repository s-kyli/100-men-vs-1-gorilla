-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CodesOtaku = ReplicatedStorage:WaitForChild("CodesOtaku")
local CutsceneModule = CodesOtaku:WaitForChild("CutsceneModule")

repeat wait() until workspace.CurrentCamera -- Wait until camera is found
-- Constructor

local Camera = workspace.CurrentCamera
local Looping = false
local Speed = 1
local FreezeControls = true

-- Loading
local CutsceneFolder = workspace.Cutscenes:WaitForChild("Intro") -- The folder that contains the cutscene data (Cameras...)
local Destroy = true -- Destroy folder after loading? you don't want your player to see your cameras floating around!
local NoYield = false -- Generally you want this to be set to false, because loading takes a little bit of time, and you don't want to interact with the cutscene when it's not loaded
local SafeMode = true -- This is adviced to be turned on, especially if the cutscene folder data is too big to load at one frame. when turned on, it loads a camera every frame, not all at once.

local Cutscene = require(CutsceneModule)

local Demo = Cutscene.new(Camera, Looping, Speed, FreezeControls) -- Create cutscene
Demo:Load(CutsceneFolder, Destroy, NoYield, SafeMode) -- Load cutscene data from folder

local PlayOnPartTouch = script:FindFirstChild("PlayOnPartTouch")
local PlayOnPlayerJoin = script:FindFirstChild("PlayOnPlayerJoin")
local PlayOnCharacterAdded = script:FindFirstChild("PlayOnCharacterAdded")
local PlayOnCharacterDied = script:FindFirstChild("PlayOnCharacterDied")
local PlayOnEventFire = script:FindFirstChild("PlayOnEventFire")
local PlayOnRemoteEventFire = script:FindFirstChild("PlayOnRemoteEventFire")
local ProtectTheCharacterWhilePlaying = script:FindFirstChild("ProtectTheCharacterWhilePlaying")
local CharacterProtector = script:FindFirstChild("CharacterProtector")
local Music = script:FindFirstChild("Music")
local StopMusicWhenFinished = script:FindFirstChild("StopMusicWhenFinished")
local StopOnEventFire = script:FindFirstChild("StopOnEventFire")
local StopOnRemoteEventFire = script:FindFirstChild("StopOnRemoteEventFire")
local PlayOnce = script:FindFirstChild("PlayOnce")
local Debounce = script:FindFirstChild("Cooldown")
local OnFinishedRemove = script:FindFirstChild("OnFinishedRemove")
local bin = true
local Player = game:GetService("Players").LocalPlayer
local CutsceneGui = script:FindFirstChild("Cutscene")

-- Cutscene duration in seconds
local duration = Demo:GetDuration()
-- Check the module script for more functions and then do like this "Demo:FunctionName()" like the above example of duration

-- a better alternative implementation for the wait function
function wait_time(duration)
    local start = tick()
    local Heartbeat = game:GetService("RunService").Heartbeat
    repeat Heartbeat:Wait() until (tick() - start) >= duration
    return (tick() - start)
end
local skipped = false
-- Support for debounce
function PlayCutscene()
	if bin then
		bin = false
		Music:Play()
		if ProtectTheCharacterWhilePlaying and ProtectTheCharacterWhilePlaying.Value and Player.Character then
			CharacterProtector.Parent = Player.Character
		end
		
		--Player.PlayerGui.SpectateGui.Enabled = false
		Player.PlayerGui.GameStatusGui.Enabled = false
		Demo:Play()
		
		local cutsceneTexts = Player.PlayerGui.CutsceneTexts
		
		cutsceneTexts.Presents.UIStroke.Transparency = 1
		cutsceneTexts.Presents.TextTransparency = 1
		cutsceneTexts.Presents.Visible = true
		TweenService:Create(cutsceneTexts.Presents,TweenInfo.new(7),{TextTransparency = 0}):Play()
		TweenService:Create(cutsceneTexts.Presents.UIStroke,TweenInfo.new(7),{Transparency = 0}):Play()
		
		local song = workspace:FindFirstChildWhichIsA("Sound")
		if song then song.Volume = 0 end
		
		task.defer(function()
			task.wait(16)

			if skipped then return end

			cutsceneTexts.Presents.Visible = false		
			cutsceneTexts.HunnedPlayers.Visible = true

			task.wait(4)
			
			if skipped then return end

			cutsceneTexts.VS.Visible = true

			task.wait(4)
			
			if skipped then return end

			cutsceneTexts.Gorilla.Visible = true

			task.wait(8)

			for _, text in cutsceneTexts:GetChildren() do
				text.Visible = false
			end
		end)
		

		
	end
end

Demo.EStop.Event:Connect(function()
	
	--Player.PlayerGui.SpectateGui.Enabled = true
	Player.PlayerGui.GameStatusGui.Enabled = true
	workspace.CurrentCamera.FieldOfView = 70
	
	wait_time(Debounce.Value)
	CharacterProtector.Parent = nil
	if PlayOnce then
		if not PlayOnce.Value then
			bin = true
		end
	else
		bin = true
	end
	
	
	
	if StopMusicWhenFinished and StopMusicWhenFinished.Value then
		
		local tween = TweenService:Create(Music,TweenInfo.new(2),{Volume = 0})
		tween:Play()
		tween.Completed:Once(function()
			Music:Stop()
		end)
		
		if OnFinishedRemove then
			for i,v in pairs(OnFinishedRemove:GetChildren()) do
				if v:IsA("ObjectValue") then
					if v.Value then
						v.Value:Destroy()
					end
				end
			end
		end
	end
end)

-- Update the cutscene every render frame
RunService.RenderStepped:Connect(function(Delta)
	Demo:Update(Delta)
end)

local gameInfo = ReplicatedStorage:WaitForChild("GameInfo")
local played = false
if PlayOnPlayerJoin and PlayOnPlayerJoin.Value  then
	-- Play the cutscene
	played = true
	PlayCutscene()
	
end

if PlayOnPartTouch then
	local part = script.PlayOnPartTouch.Value
	if part and part:IsA("BasePart") then
		part.Touched:Connect(function(hit)
			if hit.Parent == Player.Character then
				PlayCutscene()
			end
		end)
	end
	PlayOnPartTouch:Destroy()
end

if PlayOnEventFire then
	local e = PlayOnEventFire.Value
	if e and e:IsA("BindableEvent") then
		e.Event:Connect(function()
			PlayCutscene()
		end)
	end
	PlayOnEventFire:Destroy()
end

if PlayOnRemoteEventFire then
	local e = PlayOnRemoteEventFire.Value
	if e and e:IsA("RemoteEvent") then
		e.OnClientEvent:Connect(PlayCutscene)
	end
	PlayOnRemoteEventFire:Destroy()
end

if StopOnRemoteEventFire then
	local e = StopOnRemoteEventFire.Value
	if e and e:IsA("RemoteEvent") then
		e.OnClientEvent:Connect(function()
			Demo:Stop()
		end)
	end
	StopOnRemoteEventFire:Destroy()
end

if StopOnRemoteEventFire then
	local e = StopOnRemoteEventFire.Value
	if e and e:IsA("RemoteEvent") then
		e.OnClientEvent:Connect(function()
			Demo:Stop()
		end)
	end
	StopOnRemoteEventFire:Destroy()
end
if CutsceneGui and played then
	CutsceneGui.Parent = Player:WaitForChild("PlayerGui")
	local SkipCutsceneButton = CutsceneGui:FindFirstChild("SkipCutscene", true)
	local PlayCutsceneButton = CutsceneGui:FindFirstChild("PlayCutscene", true)
	
	if SkipCutsceneButton and SkipCutsceneButton:IsA("GuiButton") then
		SkipCutsceneButton.MouseButton1Click:Connect(function()
			Music:Stop()
			Demo:Stop()
			skipped = true
			
			local song = workspace:FindFirstChildWhichIsA("Sound")
			if song then
				TweenService:Create(song,TweenInfo.new(8),{Volume = 0.5}):Play()
			end
			
			for _, text in Player.PlayerGui.CutsceneTexts:GetChildren() do
				text.Visible = false
			end
		end)
	end
	
	if PlayCutsceneButton and PlayCutsceneButton:IsA("GuiButton") then
		PlayCutsceneButton.MouseButton1Click:Connect(function()
			PlayCutscene()
		end)
	end
	Demo.EStop.Event:Connect(function()
		CutsceneGui.Enabled = false
	end)
end

local Character = Player.Character or Player.CharacterAdded:Wait()

if PlayOnCharacterAdded and PlayOnCharacterAdded.Value then
	PlayCutscene()
end
if PlayOnCharacterDied and PlayOnCharacterDied.Value then
	local Humanoid = Character:WaitForChild("Humanoid")
	Character:WaitForChild("Humanoid").Died:Connect(function()
		PlayCutscene()
	end)
end
PlayOnCharacterAdded:Destroy()