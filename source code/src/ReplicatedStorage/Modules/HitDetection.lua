local module = {}

local OSModules = script.Parent.Parent:WaitForChild("OSModules")
local RCHitboxV4 = require(OSModules:WaitForChild("RaycastHitboxV4"))



local RL = game:GetService("ReplicatedStorage")
local Remotes = RL:WaitForChild("Remotes")
local GorillaConfiguration = RL:WaitForChild("GorillaConfigurations")

local function checkHit(selfObj, humanoid:Humanoid,isGorilla)
	
	if not humanoid then return end
	
	if selfObj.humanoid == humanoid then return end
	
	local character = humanoid.Parent
	if not isGorilla and not character.Gorilla.Value then return end
	if isGorilla and character.Gorilla.Value then return end
	
	if isGorilla then
		Remotes.GorillaHitHuman:FireServer(humanoid)
	else
		Remotes.HumanHitGorilla:FireServer(humanoid)
	end	
end

module.hitInit = function(selfObj,hitbox:BasePart)
	
	local rcParams = RaycastParams.new()
	rcParams.FilterDescendantsInstances = {selfObj.character}
	
	local rcHitbox = RCHitboxV4.new(hitbox)
	rcHitbox.RaycastParams = rcParams
	
	selfObj.janitor:Add(rcHitbox.OnHit:Connect(function(hit:BasePart,humanoid:Humanoid)
		checkHit(selfObj,humanoid,hitbox.Name == "GorillaHandPart")
	end),"Disconnect")
	
	selfObj.janitor:Add(rcHitbox,"Destroy")
	selfObj.hitbox = rcHitbox
end

module.checkSmashHit = function(selfObj)
	
	local posOffset =  Vector3.new(0,(-selfObj.character.HumanoidRootPart.Size.Y / 2) - selfObj.character["Right Leg"].Size.Y,0)
	local groundPosition = selfObj.character.HumanoidRootPart.Position + posOffset 
		+ selfObj.character.HumanoidRootPart.CFrame.LookVector * 6
	
	local overlapParams = OverlapParams.new()
	overlapParams.FilterDescendantsInstances = {selfObj.character}
	local partsInRadius = workspace:GetPartBoundsInRadius(groundPosition,GorillaConfiguration.SpecialAttackRange.Value,overlapParams)
	
	local charactersHit:{Model} = {}
	
	for _, part in partsInRadius do
		if part.Name ~= "HumanoidRootPart" then continue end
		
		local eChar:Model = part.Parent
		local gorilla = eChar:FindFirstChild("Gorilla")
		if not gorilla then continue end
		if gorilla.Value then continue end
		
		table.insert(charactersHit,eChar)
	end
	
	Remotes.GorillaSmashHumans:FireServer(charactersHit,groundPosition)
	
end

return module
