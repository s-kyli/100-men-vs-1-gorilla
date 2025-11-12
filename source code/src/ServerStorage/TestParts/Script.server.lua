local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local InsertService = game:GetService("InsertService")

local ServerConnections = require(ServerScriptService:WaitForChild("Connections"))

local RL = game:GetService("ReplicatedStorage")

local hatID = 18484353

local ItemGiver = require(ServerScriptService.ServerModules.ItemGiver)

local folder = script.Parent


folder:WaitForChild("Gorilla").Touched:Connect(function(otherPart)
	
	local character = otherPart.Parent
	
	if not character.Gorilla.Value then
		ItemGiver.turnIntoGorilla(character)
	end
end)

folder:WaitForChild("Hammer").Touched:Connect(function(otherPart)
	local char:Model = otherPart.Parent
	ItemGiver.giveHammer(char)
end)

folder:WaitForChild("Sword").Touched:Connect(function(otherPart)
	local char:Model = otherPart.Parent
	ItemGiver.giveSword(char)
end)

--folder:WaitForChild("Gun").Touched:Connect(function(otherPart)
--	local char:Model = otherPart.Parent

--	if Players:GetPlayerFromCharacter(char) then
--		-- give Gun
--	end
--end)

folder:WaitForChild("BearTrap").Touched:Connect(function(otherPart)
	local char:Model = otherPart.Parent
	ItemGiver.giveBearTrap(char)
end)
