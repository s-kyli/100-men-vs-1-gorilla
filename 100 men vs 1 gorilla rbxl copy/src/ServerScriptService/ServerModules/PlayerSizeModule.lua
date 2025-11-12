local module = {}




-- Function to make player bigger
module.makePlayerBigger = function(character, scaleFactor)
	
	-- 0.5 is half size, 2 is double size
	local Width = scaleFactor -- How wide your shoulders are
	local Height = scaleFactor -- How tall you are
	local Depth = scaleFactor -- How fat you are
	local Head = nil -- Head size, auto calculated if set to nil (R15 only)
	local Vector = Vector3.new(Width, Height, Depth)
	
	local Motors = {}
	table.insert(Motors, character.HumanoidRootPart.RootJoint)
	for i,Motor in pairs(character.Torso:GetChildren()) do
		if Motor:IsA("Motor6D") == false then continue end
		table.insert(Motors, Motor)
	end
	for i,v in pairs(Motors) do
		v.C0 = CFrame.new((v.C0.Position * Vector)) * (v.C0 - v.C0.Position)
		v.C1 = CFrame.new((v.C1.Position * Vector)) * (v.C1 - v.C1.Position)
	end
	
	local leftShoulder:Motor6D = character.Torso["Left Shoulder"]
	leftShoulder.C1 = leftShoulder.C1 * CFrame.new(0,0.5,0) * CFrame.Angles(0,0,math.rad(20))
	local rightShoulder:Motor6D = character.Torso["Right Shoulder"]
	rightShoulder.C1 = rightShoulder.C1 * CFrame.new(0,0.5,0) * CFrame.Angles(0,0,math.rad(-20))
	
	local rootJoint = character.HumanoidRootPart.RootJoint
	rootJoint.C0 = rootJoint.C0 * CFrame.new(0,0,-1)
	rootJoint.C1 = rootJoint.C1 * CFrame.Angles(math.rad(-10),0,0)

	for i,Part in pairs(character:GetChildren()) do
		if Part:IsA("BasePart") == false then continue end
		Part.Size *= Vector
		local ragdollPart = Part:FindFirstChild(Part.Name .. " Ragdoll Colission")
	end
	if character.Head.Mesh.MeshId ~= "" then
		character.Head.Mesh.Scale *= Vector
	end

	for i,Accessory in pairs(character:GetChildren()) do
		if Accessory:IsA("Accessory") == false then continue end

		Accessory.Handle.AccessoryWeld.C0 = CFrame.new((Accessory.Handle.AccessoryWeld.C0.Position * Vector)) * (Accessory.Handle.AccessoryWeld.C0 - Accessory.Handle.AccessoryWeld.C0.Position)
		Accessory.Handle.AccessoryWeld.C1 = CFrame.new((Accessory.Handle.AccessoryWeld.C1.Position * Vector)) * (Accessory.Handle.AccessoryWeld.C1 - Accessory.Handle.AccessoryWeld.C1.Position)
		Accessory.Handle:FindFirstChildOfClass("SpecialMesh").Scale *= Vector	
	end
	
end

return module
