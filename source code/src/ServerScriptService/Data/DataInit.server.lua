local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = script.Parent.Parent

local ProfileStore = require(ServerScriptService.ProfileStore)

local function GetStoreName()
	return RunService:IsStudio() and "Test" or "Live"
end

local Template = require(ServerScriptService.Data.Template)
local DataManager = require(ServerScriptService.Data.DataManager)
local ServerConnections = require(ServerScriptService.Connections)

local PlayerStore = ProfileStore.New(GetStoreName(),Template)

-- when data is all loaded:
local function initialize(player:Player,profile:typeof(PlayerStore:StartSessionAsync()))
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Value = profile.Data.Wins
	wins.Parent = leaderstats
	
	game.ReplicatedStorage.Remotes.UpdateRespawn:FireClient(player,profile.Data.Respawns)
	-- replicate to client
	
end

local function PlayerAdded(player:Player)
	
	local profile = PlayerStore:StartSessionAsync("Player_" .. player.UserId,{
		Cancel = function()
			return player.Parent ~= Players
		end,
	})
	
	if profile == nil then
		player:Kick("Data error occured, please rejoin.")
		return
	end
	
	profile:AddUserId(player.UserId)
	profile:Reconcile()
	
	profile.OnSessionEnd:Connect(function()
		DataManager.Profiles[player] = nil
		player:Kick("Data error occured, please rejoin.")
	end)
	
	if player.Parent == Players then
		DataManager.Profiles[player] = profile
		initialize(player,profile)
	else
		profile:EndSession()
	end
end

for _, player in Players:GetPlayers() do
	task.spawn(PlayerAdded,player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	
	for key:string, connection:RBXScriptConnection in ServerConnections do
		if string.find(key,player.Name) then
			connection:Disconnect()
			ServerConnections[key] = nil
		end
	end
	
	local profile = DataManager.Profiles[player]
	if profile ~= nil then
		profile:EndSession()
		DataManager.Profiles[player] = nil
	end
end)
