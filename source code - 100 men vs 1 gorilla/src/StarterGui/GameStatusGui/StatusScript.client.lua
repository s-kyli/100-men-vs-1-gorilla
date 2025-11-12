local gui = script.Parent
local statusBar = gui:WaitForChild("StatusBar")
local healthBar = gui:WaitForChild("HealthBar")
local gorillaChance = gui:WaitForChild("GorillaChanceFrame")

local RL = game:GetService("ReplicatedStorage")
local Remotes = RL:WaitForChild("Remotes")
local gameInfo = RL:WaitForChild("GameInfo")

local MarketplaceService = game:GetService("MarketplaceService")

local function updateHealthBar()
	local gorillaHealth = gameInfo.GorillaHealth.Value
	local gorillaMaxHealth = gameInfo.GorillaMaxHealth.Value

	healthBar.Health.Text = tostring(gorillaHealth) 
		.. "/" .. tostring(gorillaMaxHealth)
	healthBar.ProgressBar.Size = UDim2.fromScale(gorillaHealth/gorillaMaxHealth,1)
end

gameInfo:WaitForChild("GorillaHealth").Changed:Connect(updateHealthBar)
gameInfo:WaitForChild("GorillaMaxHealth").Changed:Connect(updateHealthBar)

local function formatTime(seconds:number)
	local minutes = math.floor(seconds/60)
	local remainingSeconds = seconds%60
	return string.format("%02d:%02d",minutes,remainingSeconds)
end

gameInfo:WaitForChild("TimeLeft").Changed:Connect(function(val)
	statusBar.TimeLeft.Text = formatTime(val)
end)

gameInfo:WaitForChild("HumansAlive").Changed:Connect(function(val)
	statusBar.HumansAlive.Text = tostring(val)
end)

local function update(gameMode:string)
	if gameMode == "GamePlaying" then
		healthBar.Visible = true
		statusBar.GameMode.Text = "Time Left:"
	elseif gameMode == "Intermission" then
		healthBar.Visible = false
		statusBar.GameMode.Text = "Intermission:"
	elseif gameMode == "WaitingForPlayers" then
		healthBar.Visible = false
		statusBar.GameMode.Text = "Waiting for 4 or more players..."
	end
end
gameInfo:WaitForChild("GameMode").Changed:Connect(update)

if gameInfo.GameMode.Value == "GamePlaying" then
	healthBar.Visible = true
	statusBar.GameMode.Text = "Time Left:"
elseif gameInfo.GameMode.Value == "Intermission" then
	healthBar.Visible = false
	statusBar.GameMode.Text = "Intermission:"
elseif gameInfo.GameMode.Value == "WaitingForPlayers" then
	healthBar.Visible = false
	statusBar.GameMode.Text = "Waiting for 4 or more players..."
end

Remotes:WaitForChild("WinMessage").OnClientEvent:Connect(function(winner:string)
	if winner == "GorillaWin" then
		healthBar.Visible = false
		statusBar.GameMode.Text = "Gorilla Wins!"
	elseif winner == "HumansWin" then
		healthBar.Visible = false
		statusBar.GameMode.Text = "Players win!"
	elseif winner == "Tie" then
		healthBar.Visible = false
		statusBar.GameMode.Text = "Tie!"
	end
end)

local chance:number = Remotes:WaitForChild("GetGorillaChance"):InvokeServer()
gorillaChance:WaitForChild("TextLabel").Text = "Gorilla chance: " ..  tostring(chance) .. "%"

Remotes:WaitForChild("UpdateGorillaChance").OnClientEvent:Connect(function(percent:number)
	gorillaChance.TextLabel.Text = "Gorilla chance: " .. tostring(percent) .. "%"
end)


gorillaChance:WaitForChild("invite").Activated:Connect(function()
 	game:GetService("SocialService"):PromptGameInvite(game.Players.LocalPlayer)
end)


local GORILLA_CHANCE_PRODUCT_ID = 3277598447

gorillaChance:WaitForChild("TextButton").Activated:Connect(function()
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer,GORILLA_CHANCE_PRODUCT_ID)
end)

local becomeNextGorillaButton = gorillaChance:WaitForChild("BecomeNextGorillaButton")

becomeNextGorillaButton.Activated:Connect(function()
	if gameInfo.NextGorilla.Value == "" then
		MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer,3278258413)
	else
		local oldText = becomeNextGorillaButton.Text
		becomeNextGorillaButton.Text = "Someone is already the next gorilla!"
		becomeNextGorillaButton.Active = false
		task.wait(2)
		becomeNextGorillaButton.Text = oldText
		becomeNextGorillaButton.Active = true
	end	
end)

local respawnButton = gorillaChance:WaitForChild("RespawnButton")

respawnButton.Activated:Connect(function()
	Remotes.RequestRespawn:FireServer()
end)

local initialRespawns = Remotes:WaitForChild("GetRespawns"):InvokeServer()

if initialRespawns then
	gorillaChance:WaitForChild("Respawns").Text = "Respawns: ".. tostring(initialRespawns)
end


Remotes:WaitForChild("UpdateRespawn").OnClientEvent:Connect(function(val)
	gorillaChance.Respawns.Text =  "Respawns: " .. tostring(val)
end)

local musicMuted = false

gorillaChance:WaitForChild("MuteMusic").Activated:Connect(function()
	musicMuted = not musicMuted
	
	if musicMuted then
		gorillaChance.MuteMusic.Text = "Unmute Music"
	else
		gorillaChance.MuteMusic.Text = "Mute Music"
	end
	
	local music = workspace:FindFirstChildWhichIsA("Sound")
	if music then
		if musicMuted then
			music.Volume = 0
			
		else
			
			music.Volume = 0.1
		end
	end
end)

workspace.ChildAdded:Connect(function(child)
	if child:IsA("Sound") then
		if musicMuted then
			child.Volume = 0
		else
			child.Volume = 0.1
		end
	end
end)

local function isPrivateServer()
	if game.PrivateServerId ~= "" then
		return true
	else
		return false
	end
end


local soundMuted = false

gorillaChance:WaitForChild("MuteSounds").Activated:Connect(function()
	soundMuted = not soundMuted
	
	
	if soundMuted then
		gorillaChance.MuteSounds.Text = "Unmute Sounds"
	else
		gorillaChance.MuteSounds.Text = "Mute Sounds"
	end
	
	local players = game.Players:GetPlayers()
	
	for _, char in workspace.HumansAlive:GetChildren() do
		local hrp:BasePart = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			for _, obj:Instance in hrp:GetChildren() do
				if obj:IsA("Sound") then
					if soundMuted then
						obj.Volume = 0
					else
						obj.Volume = 0.5
					end
				end
			end
			print("gwent thru")
		else
			print("hrp is  nil")
		end
		
	end
end)

workspace:WaitForChild("HumansAlive").ChildAdded:Connect(function(char:Model)
	local hrp:BasePart = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		for _, obj:Instance in hrp:GetChildren() do
			if obj:IsA("Sound") then
				if soundMuted then
					obj.Volume = 0
				else
					obj.Volume = 0.5
				end
			end
		end
		print("gwent thru")
	else
		warn("hrp is nil")
	end
end)
