local tool = script.Parent

local player:Player = tool.Parent.Parent
local character = player.Character

local m6d = Instance.new("Motor6D")
m6d.Part0 = character["Right Arm"]
m6d.Part1 = tool.Hold
m6d.C0 = CFrame.new(0.05, -1.05, 0.2) * CFrame.Angles(0,math.rad(90),math.rad(-90))
m6d.Name = "Hold"
m6d.Parent = character["Right Arm"]
