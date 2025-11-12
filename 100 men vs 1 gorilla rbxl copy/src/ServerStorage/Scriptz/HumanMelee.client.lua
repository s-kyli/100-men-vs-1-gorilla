local RL = game:GetService("ReplicatedStorage")
local Modules = RL:WaitForChild("Modules")

local tool:Tool = script.Parent
local player = game.Players.LocalPlayer
local character = player.Character

local HumanMelee = require(Modules:WaitForChild("HumanMelee"))

local melee = HumanMelee.new(tool,character)

character:WaitForChild("Humanoid").Died:Once(function()
	melee:Destroy()
end)
