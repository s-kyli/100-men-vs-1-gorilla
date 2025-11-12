script.Parent.Touched:Connect(function(otherPart)
	
	local player = game.Players:GetPlayerFromCharacter(otherPart.Parent)
	
	if player then
		
		game.MarketplaceService:PromptProductPurchase(player,3277598684)
	end
	
end)

script.Parent.Parent:WaitForChild("NextGorillaPart").Touched:Connect(function(otherPart)
	
	local player = game.Players:GetPlayerFromCharacter(otherPart.Parent)
	
	if player and game.ReplicatedStorage.GameInfo.NextGorilla.Value == "" then
		game.MarketplaceService:PromptProductPurchase(player,3278258413)
	end
	
end)

script.Parent.Parent:WaitForChild("IncChance").Touched:Connect(function(otherPart)
	
	local player = game.Players:GetPlayerFromCharacter(otherPart.Parent)
	
	if player then
		game.MarketplaceService:PromptProductPurchase(player,3277598447)
	end
	
end)
