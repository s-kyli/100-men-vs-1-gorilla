local c:Model = script.Parent
local h:Humanoid = c:WaitForChild("Humanoid")

h:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
--h:SetStateEnabled(Enum.HumanoidStateType.)

local RL = game:GetService("ReplicatedStorage")
local Remotes = RL:WaitForChild("Remotes")

local conn3 = Remotes:WaitForChild("FinalPlayer").OnClientEvent:Connect(function()
	h.WalkSpeed = 20
end)

local conn = Remotes:WaitForChild("SetPlatformStand").OnClientEvent:Connect(function(active)
	print("setting platformstand to " .. tostring(active))
	h:SetStateEnabled(Enum.HumanoidStateType.Jumping,not active)
	h.PlatformStand = active
	h.AutoRotate = not active
end)

local conn2 = Remotes:WaitForChild("ChangePos").OnClientEvent:Connect(function(cf)
	c.PrimaryPart.CFrame = cf
	h.PlatformStand = false
	h.AutoRotate = true
end)

--local ragdoll = c:WaitForChild("Ragdoll")
--ragdoll.ChildAdded:Connect(function(child)
--	if child.Name == "Radgoll" then
--		h.AutoRotate = false
--	end
--end)

--ragdoll.ChildRemoved:Connect(function(child)
--	if ragdoll:FindFirstChild("Ragdoll") then
--		return
--	end
--	if child.Name == "Radgoll" then
--		h.AutoRotate = true
--	end
--end)

--c:WaitForChild("InLobby").Changed:Once(function(val)
--	if not val then
--		game.Players.LocalPlayer.PlayerGui.SpectateGui.Enabled = false
--	end
--end)

h.Died:Once(function()
	conn2:Disconnect()
	conn3:Disconnect()
	conn:Disconnect()
end)
