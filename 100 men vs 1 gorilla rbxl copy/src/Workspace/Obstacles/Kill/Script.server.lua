script.Parent.Touched:Connect(function(otherPart)
	
	local char = otherPart.Parent
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	
	if humanoid then
		humanoid.Health = 0
	end
	
end)
