--// Variables \\--

local ragdollFolder = script.Parent
local characterSubject:Model = ragdollFolder.Parent
local player = game.Players:GetPlayerFromCharacter(characterSubject)
local characterStates = characterSubject:FindFirstChild("States")

local RL = game:GetService("ReplicatedStorage")
local Remotes = RL:WaitForChild("Remotes")

--local ClientRagdoll = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClientRagdoll")

local Humanoid:Humanoid = characterSubject:WaitForChild("Humanoid")
local HRP = characterSubject.PrimaryPart

local jointPreset = script:WaitForChild("Ragdoll Joint")
local boxPreset = script:WaitForChild("Ragdoll Colission")

local ragdollSetup = false
local ragdolled = false

Humanoid.BreakJointsOnDeath = false
Humanoid.RequiresNeck = false

local allCollisionBoxes = {}
local allJoints = {}
local allMotorJoints = {}

local limbNames = {
	"Left Leg",
	"Right Leg",
	"Left Arm",
	"Right Arm"
}

--// Functions \\--

local function detectGround()

	--// Detecting until hit ground \\--

	local detectingGround = coroutine.wrap(function()

		--// Creating parameters \\--

		local characterTorso = characterSubject:WaitForChild("Torso")
		local additionalSize = Vector3.new(1.5, 1, 1.5)

		local overlapParameters = OverlapParams.new()
		overlapParameters.FilterType = Enum.RaycastFilterType.Include
		overlapParameters.MaxParts = 1
		overlapParameters.RespectCanCollide = true
		overlapParameters.FilterDescendantsInstances = {
			workspace.Obstacles
		}

		local detecting

		--// Heartbeat \\--

		detecting = game["Run Service"].Heartbeat:Connect(function()
			
			local continueLoop = true

			--// Pre Checking \\--

			if not characterStates:FindFirstChild("Ragdolled") then
				continueLoop = false
				detecting:Disconnect()
			end

			--// Detecting ground \\--

			if continueLoop == true then				
				for i, v in pairs(game.Workspace:GetPartBoundsInBox(characterTorso.CFrame, characterTorso.Size + additionalSize, overlapParameters)) do

					detecting:Disconnect()

					--// Performing \\--

					local hitGround = Instance.new("BoolValue")
					hitGround.Name = "Hit Ground"
					hitGround.Parent = characterStates

					local soundTypes = {
						"rbxassetid://7446606796",
						"rbxassetid://7446607140",
						"rbxassetid://7446607091",
						"rbxassetid://7446607037",
						"rbxassetid://7446606925",
						"rbxassetid://7446609932"
					}

					--// Sound Effect \\--

					local soundEffect = Instance.new("Sound", HRP)
					soundEffect.Name = "Hit Ground"
					soundEffect.PlaybackSpeed = math.random(80,120) / 100
					soundEffect.Volume = 0.25

					soundEffect.RollOffMode = Enum.RollOffMode.LinearSquare
					soundEffect.RollOffMinDistance = 10
					soundEffect.RollOffMaxDistance = 50

					soundEffect.SoundId = soundTypes[math.random(1,#soundTypes)]
					soundEffect:Play()
					game.Debris:AddItem(soundEffect, 2)

					--// Breaking loop \\--

					break

				end				
			end

		end)

	end)

	detectingGround()

end

local function setupJoints(character)
	
	--// Setting up colission boxes \\--
	
	for i, v in pairs(character:GetChildren()) do
		if table.find(limbNames, v.Name) then
			
			local newBox = boxPreset:Clone()
			newBox.Anchored = false
			newBox:FindFirstChildOfClass("Weld").Part0 = v
			newBox.Parent = v
			newBox.Name = tostring(v.Name .. " Ragdoll Colission")
			
			table.insert(allCollisionBoxes, newBox)
			
		end
	end
	
	--// Setting up joints \\--
	
	for i, v in pairs(character:FindFirstChild("Torso"):GetChildren()) do
		if v:IsA("Motor6D") and table.find(limbNames, v.Part1.Name) then
			
			table.insert(allMotorJoints, v)
			
			--// Creating attachments \\--
			
			local targetLimb = v.Part1
			
			local attachment0 = Instance.new("Attachment")
			attachment0.Name = tostring("Attachment0 of ".. targetLimb.Name.. " joint")
			attachment0.Position = v.C0.Position
			attachment0.Parent = character:FindFirstChild("Torso")
			
			local attachment1 = Instance.new("Attachment")
			attachment1.Name = tostring("Attachment1 of ".. targetLimb.Name .. " joint")
			attachment1.Position = v.C1.Position
			attachment1.Parent = targetLimb
			
			--// Creating joint \\--
			
			local newJoint = jointPreset:Clone()
			newJoint.Name = tostring("Ragdoll Joint of ".. targetLimb.Name)
			
			newJoint.Attachment0 = attachment0
			newJoint.Attachment1 = attachment1
			
			table.insert(allJoints, newJoint)	
			newJoint.Parent = targetLimb
			
		end
	end
	
	--// Clearing presets \\--
	
	ragdollSetup = true
	--print("Ragdoll was set up for ".. character.Name)
	
	for i, v in pairs(script:GetChildren()) do
		v:Destroy()
	end
	
end

local connection:RBXScriptConnection = nil

local function adjustRagdoll(state)
	if ragdolled ~= state and ragdollSetup == true then
		
		--// Adjusting value \\--

		ragdolled = state

		--// Adding ragdoll state \\--

		if state == true then

			local ragdolled = Instance.new("BoolValue")
			ragdolled.Name = "Ragdolled"
			ragdolled.Parent = characterStates
			
			--// Fall Velocity \\--

			local Velocity = Instance.new("BodyVelocity", characterSubject:FindFirstChild("Torso"))
			Velocity.Name = "Death Velocity"
			Velocity.MaxForce = Vector3.new(8500,0,8500)
			Velocity.Velocity = Vector3.new(math.random(-50,50) / 10, 0, math.random(-50,50) / 10)
			game.Debris:AddItem(Velocity, 0.15)
			
			--// Ground Detect \\--

			detectGround()
			
		else

			--// Invulnerability \\--

			local Invulnerable = Instance.new("BoolValue")
			Invulnerable.Name = "Invulnerable"
			Invulnerable.Parent = characterStates
			game.Debris:AddItem(Invulnerable, 0.5)

			--// Clearing state \\--

			for i, v in pairs(characterStates:GetChildren()) do
				if v.Name == "Ragdolled" or v.Name == "Hit Ground" then				
					v:Destroy()				
				end
			end
			
		end

		--// Enabling humanoid activity \\--
		

		
		if state == false then
					
			local newPosition = HRP.Position + Vector3.new(0,1.5,0)		
			HRP.CFrame = CFrame.new(newPosition.X, newPosition.Y, newPosition.Z) * CFrame.Angles(math.rad(0), math.rad(HRP.Orientation.Y), math.rad(0))
			
		end

		
		--// Adjusting ragdoll joints & colissions \\--

		for i, v in pairs(allCollisionBoxes) do

			v.Massless = not state
			v.CanCollide = state

		end


		for i, v in pairs(allMotorJoints) do

			v.Enabled = not state

		end

		for i, v in pairs(allJoints) do

			v.Enabled = state

		end
		
		if state then
			--Humanoid.PlatformStand = true
			Remotes.SetPlatformStand:FireClient(player,true)
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = characterSubject.HumanoidRootPart
			weldConstraint.Part1 = characterSubject.Torso
			weldConstraint.Name = "RagdollWeld"
			weldConstraint.Parent = characterSubject.HumanoidRootPart
			
			
			characterSubject.HumanoidRootPart.RootJoint.Enabled = false
		else
			Remotes.SetPlatformStand:FireClient(player,false)
			--Humanoid.PlatformStand = false
			characterSubject.HumanoidRootPart.RootJoint.Enabled = true

			if characterSubject.HumanoidRootPart:FindFirstChild("RagdollWeld") then
				characterSubject.HumanoidRootPart.RagdollWeld:Destroy()
			end
		end
		
		--if state then
		--	for _, v in characterSubject:GetChildredn() do
		--		if v:IsA("BasePart") then
		--			v:SetNetworkOwner(nil)
		--		end
		--	end
		--else
		--	for _, v in characterSubject:GetChildren() do
		--		if v:IsA("BasePart") then
		--			v:SetNetworkOwnershipAuto()
		--		end
		--	end
		--end		
	end
end

setupJoints(characterSubject)

--// Ragdoll on death \\--

Humanoid.Died:Connect(function()
	
	--// Creating new ragdoll \\--
	
	if characterSubject.Ragdoll:FindFirstChild("Ragdoll") then
		return
	end
	
	local newRagdoll = Instance.new("BoolValue")
	newRagdoll.Name = "Ragdoll"
	newRagdoll.Parent = ragdollFolder
	
end)

--// Detecting children added \\--

ragdollFolder.ChildAdded:Connect(function(newChild)
	if newChild:IsA("BoolValue") and newChild.Name == "Ragdoll" and ragdolled == false then
		adjustRagdoll(true)
		
	end
end)

ragdollFolder.ChildRemoved:Connect(function(removedChild)
	if removedChild:IsA("BoolValue") and removedChild.Name == "Ragdoll" and ragdolled == true and not ragdollFolder:FindFirstChild("Ragdoll") then

		adjustRagdoll(false)

	end
end)