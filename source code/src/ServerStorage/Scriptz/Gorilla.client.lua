local RL = game:GetService("ReplicatedStorage")
local Modules = RL:WaitForChild("Modules")

local tool:Tool = script.Parent
local player = game.Players.LocalPlayer
local character = player.Character

local GorillaModule = require(Modules:WaitForChild("Gorilla"))

local gorilla = GorillaModule.new(character)

character:WaitForChild("Humanoid").Died:Once(function()
	player.PlayerGui.VineBoom.ImageLabel.ImageTransparency = 1
	player.PlayerGui.VineBoom.ImageLabel.BackgroundTransparency = 1
	gorilla:Destroy()
end)
