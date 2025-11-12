local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local InsertService = game:GetService("InsertService")

local ServerConnections = require(ServerScriptService:WaitForChild("Connections"))

local RL = game:GetService("ReplicatedStorage")

local hatID = 18484353

local PlayerSizeModule = require(ServerScriptService:WaitForChild("ServerModules"):WaitForChild("PlayerSizeModule"))


local module = {}

module.turnIntoGorilla = function(character:Model)
	if character and character:FindFirstChild("Gorilla")  and game.Players:GetPlayerFromCharacter(character) then
		print("turnintogorilla")
		character.Gorilla.Value = true
		local head = character:FindFirstChild("Head")
		if not head then
			return "Error"
		end
		head.Transparency = 1
		PlayerSizeModule.makePlayerBigger(character,3)

		for _, obj in character:GetChildren() do
			if obj:IsA("Accessory") then
				obj:Destroy()
			elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("Configuration") then
				obj:Destroy()
			elseif obj:IsA("BasePart") then
				obj.Color = Color3.fromRGB(71, 68, 70)	
				local ballSocketConstraint = obj:FindFirstChildWhichIsA("BallSocketConstraint")
				if ballSocketConstraint then
					ballSocketConstraint:Destroy()
				end
			end
		end

		local humanoid = character:FindFirstChild("Humanoid")
		
		if not humanoid then return "Error" end
		
		
		humanoid.BreakJointsOnDeath = true
		humanoid.RequiresNeck = true

		local newPants = Instance.new("Pants")
		newPants.PantsTemplate = "http://www.roblox.com/asset/?id=515095767"
		newPants.Parent = character
		local newShirt = Instance.new("Shirt")
		newShirt.ShirtTemplate = "http://www.roblox.com/asset/?id=515095251"
		newShirt.Parent = character

		-- Load the hat accessory from the asset ID
		local success, accessory = pcall(function()
			return InsertService:LoadAsset(hatID)
		end)

		if success and accessory then
			local hat = accessory:FindFirstChildWhichIsA("Accessory")
			if hat then
				-- Parent the accessory to the character
				hat.Parent = character
				hat.Handle.Mesh.Scale = Vector3.new(3,3,3)
			else
				warn("No Accessory found in the asset.")
			end
		else
			warn("Failed to load accessory from InsertService.")
		end

		ServerConnections[character.Name .. " DiedConnection"] = character.Humanoid.Died:Once(function()
			
			ServerConnections[character.Name .. " DiedConnection"] = nil
			if not head then
				return
			end
			head.Transparency = 0
			
		end)
		
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return "Error"
		end

		local GorillaHandPart = RL.Assets.GorillaHandPart:Clone()
		GorillaHandPart.WeldConstraint.Part1 = character["Right Arm"]
		GorillaHandPart.CFrame = character["Right Arm"].CFrame
		GorillaHandPart.Transparency = 1
		GorillaHandPart.Parent = character["Right Arm"]

		local DangerZonePart = RL.Assets.DangerZone:Clone()
		DangerZonePart.WeldConstraint.Part1 = hrp
		DangerZonePart.Decal.Transparency = 1
		local posOffset =  Vector3.new(0,(-hrp.Size.Y / 2) - character["Right Leg"].Size.Y,0)
		local groundPosition = hrp.Position + posOffset 
			+ hrp.CFrame.LookVector * 6
		DangerZonePart.Position = groundPosition
		DangerZonePart.Parent = hrp

		local gorillaScript = ServerStorage.Scriptz.Gorilla:Clone()
		gorillaScript.Parent = character
	else
		return "Error"
	end
end

local marketplaceService = game:GetService("MarketplaceService")

module.giveHammer = function(char:Model)
	local player = Players:GetPlayerFromCharacter(char)
	
	if not player then return end
	
	local hammerClone = ServerStorage.Melee.Hammer:Clone()
	ServerStorage.Scriptz.HumanMelee:Clone().Parent = hammerClone
	hammerClone.Parent = player.Backpack
	

	
end

module.giveSword = function(char:Model)
	local player = Players:GetPlayerFromCharacter(char)
	
	if not player then return end
	
	local swordClone = ServerStorage.Melee.Sword:Clone()
	ServerStorage.Scriptz.HumanMelee:Clone().Parent = swordClone
	swordClone.Parent = player.Backpack
end

module.giveBearTrap = function(char:Model)
	
	local player = Players:GetPlayerFromCharacter(char)

	if not player then return end

	local bearTrapClone = ServerStorage.Traps.BearTrap:Clone()
	bearTrapClone.Parent = player.Backpack
end

return module
