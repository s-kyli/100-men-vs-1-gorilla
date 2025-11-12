local tool = script.Parent

local player:Player = tool.Parent.Parent
local character = player.Character

repeat
	
	character = player.Character
	task.wait()
until character

local m6d = Instance.new("Motor6D")
m6d.Part0 = character["Right Arm"]
m6d.Part1 = tool:WaitForChild("Hold")
m6d.C0 = CFrame.new(-0.073, -1.015, 0) * CFrame.Angles(0,math.rad(180),0)
m6d.Name = "Hold"
m6d.Parent = character["Right Arm"]


