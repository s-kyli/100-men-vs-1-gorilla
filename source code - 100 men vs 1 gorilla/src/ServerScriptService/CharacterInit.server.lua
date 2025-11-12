local ServerScriptService = script.Parent
local ServerStorage = game:GetService("ServerStorage")
local PlayerService = game:GetService("Players")
local RL = game:GetService("ReplicatedStorage")
local Remotes = RL:WaitForChild("Remotes")

local function isPrivateServer()
	if game.PrivateServerId ~= "" then
		return true
	else
		return false
	end
end

PlayerService.PlayerAdded:Connect(function(player)
	
	local damageVal = Instance.new("NumberValue")
	damageVal.Name = "Damage"
	damageVal.Parent = player
	
	player.CharacterAdded:Connect(function(character)
		
		character.PrimaryPart = character.HumanoidRootPart
		Remotes.SetPlatformStand:FireClient(player,false)
		
		for _, obj in character:GetChildren() do
			if obj:IsA("BasePart") then
				obj.CollisionGroup = "Players"
			end
		end
		
		for _, obj in ServerStorage.AddToPlayer:GetChildren() do
			local clone = obj:Clone()
			if obj.Name == "Screams" then
				for _, sound in clone:GetChildren() do
					sound.Parent = character.PrimaryPart
					--if isPrivateServer() and sound.Name == "Scream12" then
					--	sound.Looped = true
					--	sound:Play()
					--end
				end
			else
				clone.Parent = character
			end
		end
		
		character.Parent = workspace.Dead
		
		local humanoid:Humanoid = character:WaitForChild("Humanoid")
		
		humanoid.Died:Once(function()
			character.Parent = workspace.Dead
		end)
		
	end)
	
end)
