local tool = script.Parent

local player:Player = tool.Parent.Parent
local character = player.Character

local m6d = Instance.new("Motor6D")
m6d.Part0 = character["Right Arm"]
m6d.Part1 = tool.Hold
m6d.C0 = CFrame.new(0, -1.019, 0.048) --* CFrame.Angles(0,math.rad(90),math.rad(-90))
m6d.Name = "Hold"
m6d.Parent = character["Right Arm"]

script.Parent:WaitForChild("Hitbox"):WaitForChild("idle"):Play()

local hitbox = tool:WaitForChild("Hitbox")
local hit = hitbox:WaitForChild("Hit")
local swing = hitbox:WaitForChild("Swing")
local idle = hitbox:WaitForChild("idle")

idle.Volume = 0
swing.Volume = 0
hit.Volume = 0

tool.Equipped:Connect(function()
	idle.Volume = 0.5
	swing.Volume = 0.5
	hit.Volume = 0.5
end)

tool.Unequipped:Connect(function()
	idle.Volume = 0
	swing.Volume = 0
	hit.Volume = 0
end)
