local RL = game:GetService("ReplicatedStorage")
local Remotes = RL:WaitForChild("Remotes")
local gameInfo = RL:WaitForChild("GameInfo")
local GameConfiguration = RL:WaitForChild("GameConfiguration")
local GorillaConfiguration = RL:WaitForChild("GorillaConfigurations")

local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = script.Parent
local itemGiver = require(ServerScriptService.ServerModules.ItemGiver)

local Players = game:GetService("Players")

local HumansAliveFolder = workspace:WaitForChild("HumansAlive")
local DeadFolder = workspace:WaitForChild("Dead")
local GorillaFolder = workspace:WaitForChild("Gorilla")

local DataManager = require(ServerScriptService.Data.DataManager)

local gorillaSpawn:BasePart = nil
-- Get all spawn points into a table
local spawnPoints = workspace:WaitForChild("Spawns"):GetChildren()
for i, spawnpoint in spawnPoints do
	if spawnpoint.Name == "GorillaSpawn" then
		gorillaSpawn = spawnpoint
		table.remove(spawnPoints,i)
		break
	end
end

-- Function to shuffle a table
local function shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

-- Function to assign players to spawn points randomly
local function distributePlayersToSpawnPoints()
	local players = Players:GetPlayers()
	local shuffledSpawns = shuffle(spawnPoints)

	local gorillaPos = workspace.Spawns.GorillaSpawn.Position
	
	for _, player in ipairs(players) do
		local character = player.Character
		if not character then warn("cont1") continue end
		local gorillaVal = character:WaitForChild("Gorilla")
		
		if character.Parent == workspace.Gorilla then
			
			Remotes.UpdateGorillaChance:FireClient(player,getGorillaChance(player))
			gorillaVal.Value = true
			
			local cf = gorillaSpawn.CFrame  * CFrame.new(0,1,0)
			Remotes.ChangePos:FireClient(player,cf)
			gorillaPos = cf.Position
			break
		end
	end

	for i, player in ipairs(players) do
		local character = player.Character
		if not character then warn(player.Name .. "continue 1") continue end
		
		
		local gorillaVal = character:FindFirstChild("Gorilla")
		local inLobbyVal = character:FindFirstChild("InLobby")
		if not gorillaVal or not inLobbyVal then continue end
		inLobbyVal.Value = false
		
		if not gorillaVal.Value then
			if i <= #shuffledSpawns then
				
				--local hrp:BasePart = character:FindFirstChild("HumanoidRootPart")
				
				
				local spawnPos = shuffledSpawns[i].Position + Vector3.new(0, 3, 0)				
				
				itemGiver.giveHammer(player.Character)
				itemGiver.giveBearTrap(player.Character)
				--print(player.Name .. "moving to pos")
				local cf = CFrame.new(spawnPos, gorillaPos)
				
				Remotes.ChangePos:FireClient(player,cf)
			end
		else
			--print("gng")
			local result = itemGiver.turnIntoGorilla(character)
			if result == "Error" then
				return "Error"
			end
			local humanoid:Humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				
				local numHumans = #HumansAliveFolder:GetChildren()
				local maxHealth = GorillaConfiguration.BaseHealth.Value + 175 * (numHumans - 1)
				humanoid.MaxHealth = maxHealth
				humanoid.Health = maxHealth
				gameInfo.GorillaMaxHealth.Value = maxHealth
				gameInfo.GorillaHealth.Value = maxHealth
			end
		end
	end
end

local function bringPlayersBackToLobby()
	
	for _, character in GorillaFolder:GetChildren() do
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			player:LoadCharacter()
		end
	end
	
	for _, character in HumansAliveFolder:GetChildren() do
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			player:LoadCharacter()
		end
	end
	
end

-- Table to store each player's gorilla weight
local gorillaWeights = {}
local bonusWeights = {}

local GORILLA_CHANCE_PRODUCT_ID = 3277598447

-- Initialize or reset a player's weight
local function initializePlayer(player)
	if not gorillaWeights[player.UserId] then
		gorillaWeights[player.UserId] = 1
	end
	if not bonusWeights[player.UserId] then
		bonusWeights[player.UserId] = 0
	end
end



-- Returns the chance (0-100) that the given player will become the gorilla
function getGorillaChance(player)
	initializePlayer(player)

	local totalWeight = 0
	for _, p in ipairs(Players:GetPlayers()) do
		initializePlayer(p)
		local normal = gorillaWeights[p.UserId]
		local bonus = bonusWeights[p.UserId]
		totalWeight += normal + bonus
	end

	local playerWeight = gorillaWeights[player.UserId] + bonusWeights[player.UserId]
	if totalWeight == 0 then
		return 0
	end

	local rawChance = (playerWeight / totalWeight) * 100
	local clampedChance = math.clamp(rawChance, 0, 100)
	return math.floor(clampedChance * 100 + 0.5) / 100 -- round to 2 decimal places
end


local function selectGorilla()
	local totalWeight = 0
	local playerList = Players:GetPlayers()

	-- Initialize and sum total weight (normal + bonus)
	for _, player in ipairs(playerList) do
		initializePlayer(player)
		totalWeight += gorillaWeights[player.UserId] + bonusWeights[player.UserId]
	end

	local rand = math.random() * totalWeight
	local cumulative = 0
	
	local nextGorillaName = gameInfo.NextGorilla.Value
	
	local function giveGorilla(player:Player)
		-- Reset normal weight, keep bonus weight
		gorillaWeights[player.UserId] = 1
		gameInfo.NextGorilla.Value = ""
		player.Character.Parent = workspace.Gorilla

		for _, otherPlayer in ipairs(playerList) do
			if otherPlayer ~= player then

				if otherPlayer.Character then
					gorillaWeights[otherPlayer.UserId] += 1
					otherPlayer.Character.Parent = workspace.HumansAlive
					Remotes.UpdateGorillaChance:FireClient(otherPlayer,getGorillaChance(otherPlayer))
				end
			end
		end
	end
	
	local nextGorilla = false
	
	for _, player in ipairs(playerList) do
		if player.Name == nextGorillaName then
			giveGorilla(player)
			nextGorilla = true	
			return player
		end
	end

	if not nextGorilla then
		for _, player in ipairs(playerList) do
			local effectiveWeight = gorillaWeights[player.UserId] + bonusWeights[player.UserId]
			cumulative += effectiveWeight
			if rand <= cumulative then
				giveGorilla(player)
				return player
			end
		end
	end
	return nil
end


Players.PlayerAdded:Connect(function(player)
	initializePlayer(player)
	for _, plr in Players:GetPlayers() do
		local chance = getGorillaChance(plr)
		Remotes.UpdateGorillaChance:FireClient(plr,chance)
	end
end)

-- Cleanup when a player leaves
Players.PlayerRemoving:Connect(function(player)
	gorillaWeights[player.UserId] = nil
	
	for _, plr in Players:GetPlayers() do
		if plr == player then continue end
		local chance = getGorillaChance(plr)
		Remotes.UpdateGorillaChance:FireClient(plr,chance)
	end
end)

Remotes:WaitForChild("GetGorillaChance").OnServerInvoke = getGorillaChance

Remotes:WaitForChild("GetRespawns").OnServerInvoke = function(player)
	
	local profile = DataManager.Profiles[player]
	if not profile then return end
	return profile.Data.Respawns
	
end

Remotes:WaitForChild("RequestRespawn").OnServerEvent:Connect(function(player)
	local profile = DataManager.Profiles[player]
	if not profile then return end
	
	local character = player.Character
	
	if not character then return end
	
	if profile.Data.Respawns > 0 and gameInfo.GameMode.Value == "GamePlaying" and character.Parent == workspace.Dead then
		respawnPlayer(player)
	else
		MarketplaceService:PromptProductPurchase(player,3277598684)
	end
end)

workspace:WaitForChild("HumansAlive").ChildRemoved:Connect(function()
	gameInfo.HumansAlive.Value -= 1
end)

-- Utility: Get all spawn points in the folder
local function getAllSpawnPoints()
	local spawns = {}
	for _, part in ipairs(workspace.Spawns:GetChildren()) do
		if part:IsA("BasePart") and part.Name == "PlayerSpawn" then
			table.insert(spawns, part)
		end
	end
	return spawns
end

-- Utility: Choose a random spawn part
local function getRandomSpawn()
	local spawns = getAllSpawnPoints()
	if #spawns > 0 then
		return spawns[math.random(1, #spawns)]
	end
	return nil
end

-- Teleport the player to a random spawn point
local function teleportToRandomSpawn(player)
	

	local character = player.Character or player.CharacterAdded:Wait()
	
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local spawnPoint = getRandomSpawn()
	if hrp and spawnPoint then
		local cf = spawnPoint.CFrame + Vector3.new(0, 3, 0)

		Remotes.ChangePos:FireClient(player,cf)
	end
end


function respawnPlayer(player:Player)

	
	if gameInfo.GameMode.Value ~= "GamePlaying" then return end
	local character = player.Character
	if not character then return end
	if character.Parent ~= workspace.Dead then return end
	local humanoid:Humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	if humanoid.Health <= 0 then return end

	itemGiver.giveHammer(character)
	itemGiver.giveBearTrap(character)

	local inLobbyVal = character:WaitForChild("InLobby")
	inLobbyVal.Value = false

	character.Parent = HumansAliveFolder
	
	teleportToRandomSpawn(player)
	
	local profile = DataManager.Profiles[player]
	if not profile then return end
	profile.Data.Respawns -= 1
	game.ReplicatedStorage.Remotes.UpdateRespawn:FireClient(player,profile.Data.Respawns)

	
end


MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if receiptInfo.ProductId == GORILLA_CHANCE_PRODUCT_ID then
		initializePlayer(player)

		-- Give bonus weight (e.g., +5)
		bonusWeights[player.UserId] += 9
		
	for _, plr in Players:GetPlayers() do
			Remotes.UpdateGorillaChance:FireClient(plr,getGorillaChance(plr))
	end
	-- Optionally notify the player
	print(player.Name .. " purchased increased gorilla chance!")
	elseif receiptInfo.ProductId == 3277598684 then
		DataManager.IncrementRespawns(player)
	elseif receiptInfo.ProductId == 3278258413 then
		
		gameInfo.NextGorilla.Value = player.Name
		
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

local function damageReport()
	
	local players = Players:GetPlayers()
	
	local damages = {}
	
	for _, plr in players do
		
		local dmgVal:NumberValue = plr:FindFirstChild("Damage")
		if dmgVal then
			damages[plr.DisplayName] = dmgVal.Value
			dmgVal.Value = 0
		end
	end
	
	Remotes.ShowDamages:FireAllClients(damages)
	
end

local gorillaHealthChangedConnection:RBXScriptConnection = nil

local function waitForPlayers()
	gameInfo.TimeLeft.Value = GameConfiguration.IntermissionLength.Value
	local playersList = Players:GetPlayers()
	if #playersList <= 1 then
		gameInfo.GameMode.Value = "WaitingForPlayers"
		repeat
			task.wait(0.5)
			playersList = Players:GetPlayers()
		until #playersList > 1
	end
end



while true do
	
	if not game["Run Service"]:IsStudio() then
		waitForPlayers()
	end
	
	gameInfo.GameMode.Value = "Intermission"
	
	
	
	local timeLeft = GameConfiguration.IntermissionLength.Value
	if game["Run Service"]:IsStudio() then
		timeLeft = 10
	end
	gameInfo.TimeLeft.Value = timeLeft
	
	repeat
		task.wait(1)

		
		if not game["Run Service"]:IsStudio() then
			
			local playersList = Players:GetPlayers()
			if #playersList <= 1 then
				timeLeft = GameConfiguration.IntermissionLength.Value
			end
			waitForPlayers()
		end
		
		gameInfo.GameMode.Value = "Intermission"
		timeLeft -= 1
		gameInfo.TimeLeft.Value = timeLeft
	until timeLeft <= 0
	
	
	local gorillaPlayer:Player = selectGorilla()
	if not gorillaPlayer then
		repeat
			gorillaPlayer = selectGorilla()
			task.wait(1)
		until gorillaPlayer
	end

	Remotes.NotifyNextGorilla:FireAllClients(gorillaPlayer.DisplayName)
	
	task.wait(6)
	
	local gorillaChar = gorillaPlayer.Character
	local gorillaHum:Humanoid = nil
	if gorillaChar then
		gorillaHum = gorillaChar:FindFirstChild("Humanoid")
		
		local healthScript = gorillaChar:FindFirstChild("Health")
		if healthScript then
			healthScript:Destroy()
		end
	end
	
	
	if gorillaHum then
		gorillaHealthChangedConnection = gorillaHum.HealthChanged:Connect(function(health)
			gameInfo.GorillaHealth.Value = math.floor(health + 0.5)
		end)
	end
	
	

	
	local result = distributePlayersToSpawnPoints()
	gameInfo.HumansAlive.Value = #workspace.HumansAlive:GetChildren()
	gameInfo.GameMode.Value = "GamePlaying"
	
	local timeLeft = GameConfiguration.RoundLength.Value
	gameInfo.TimeLeft.Value = timeLeft
	
	--Remotes.PlayIntro:FireAllClients()
	
	--task.wait(30)
	
	local exit = false
	
	if gorillaChar and gorillaHum and result ~= "Error" then
		repeat
			task.wait(1)
			timeLeft -= 1
			gameInfo.TimeLeft.Value = timeLeft

			local gorillas = GorillaFolder:GetChildren()
			local alivePlayers = HumansAliveFolder:GetChildren()

			if game["Run Service"]:IsStudio() then continue end

			if #gorillas <= 0 then
				exit = true

				if timeLeft >= GameConfiguration.RoundLength.Value - 10 then
					Remotes.WinMessage:FireAllClients("Tie")
				else
					Remotes.WinMessage:FireAllClients("HumansWin")

					for _, char in alivePlayers do
						local player = Players:GetPlayerFromCharacter(char)
						if player then
							DataManager.AddMonkeyBux(player,50)
							DataManager.IncrementWins(player)
						end
					end
				end
			elseif #alivePlayers <= 0 then
				exit = true
				Remotes.WinMessage:FireAllClients("GorillaWin")

				if timeLeft >= GameConfiguration.RoundLength.Value - 10 then
					Remotes.WinMessage:FireAllClients("Tie")
				else
					for _, char in alivePlayers do
						local player = Players:GetPlayerFromCharacter(char)
						if player then
							DataManager.AddMonkeyBux(player,10)
							DataManager.IncrementWins(player)
						end
					end
				end
			end
		until timeLeft <= 0 or exit
	end
	
	if not exit then
		Remotes.WinMessage:FireAllClients("Tie")
	end
	
	--gameInfo.HumansAlive.Value = 0
	gameInfo.TimeLeft.Value = 0
	gameInfo.GorillaHealth.Value = 0
	gameInfo.GorillaMaxHealth.Value = 0
	gameInfo.GameMode.Value = "AfterGame"
	
	for _, trap:Model in workspace.Traps:GetChildren() do
		trap:Destroy()
	end
	
	damageReport()
	
	task.wait(5)
	
	bringPlayersBackToLobby()
end

