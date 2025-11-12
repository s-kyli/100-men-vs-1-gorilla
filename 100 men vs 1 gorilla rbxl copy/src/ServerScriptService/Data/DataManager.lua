local ServerStorage = game:GetService("ServerStorage")
local Melee = ServerStorage.Melee
local Firearms = ServerStorage.Firearms

local DataManager = {}

DataManager.Profiles = {}

function DataManager.IncrementWins(player:Player)
	local profile = DataManager.Profiles[player]
	if not profile then return end
	profile.Data.Wins += 1
	player.leaderstats.Wins.Value = profile.Data.Wins
end

function DataManager.IncrementRespawns(player:Player)
	local profile = DataManager.Profiles[player]
	if not profile then return end
	profile.Data.Respawns += 1
	game.ReplicatedStorage.Remotes.UpdateRespawn:FireClient(player,profile.Data.Respawns)
end

function DataManager.AddMonkeyBux(player:Player,amount:number)
	local profile = DataManager.Profiles[player]
	if not profile then return end
	profile.Data.MonkeyBux += amount
	-- replicate to client
end

function DataManager.AddToToolsOwned(player:Player, toolName:string)
	local profile = DataManager.Profiles[player]
	if not profile then return end
	if table.find(profile.Data.WeaponsOwned,toolName) then return end
	
	table.insert(profile.Data.WeaponsOwned, toolName)
end

function DataManager.ChangeCurrentTool(player,toolType:string, toolName:string)
	
	local profile = DataManager.Profiles[player]
	if not profile then return end
	
	local cont = false
	
	if toolType == "Melee" then
		for _, tool:Tool in Melee:GetChildren() do
			if tool.Name == toolName then
				cont = true
				break
			end
		end
	elseif toolType == "Ranged" then
		for _, tool:Tool in Firearms:GetChildren() do
			if tool.Name == toolName then
				cont = true
				break
			end
		end
	end
	
	if not cont then return end
	
	if not table.find(profile.Data.WeaponsOwned,toolName) then return end
	
	if toolType == "Melee" then
		profile.CurrentMelee = toolName
	elseif toolType == "Ranged" then
		profile.CurrentRanged = toolName	
	end
	
end

return DataManager
