local RL = game:GetService("ReplicatedStorage")



local imgIds = 
	{	"rbxassetid://17296841986",
		"rbxassetid://11818627057",
		"rbxassetid://11578612440",
		"rbxassetid://134648324801259",
		"rbxassetid://122354736220591",
		"rbxassetid://12995186653",
		"rbxassetid://11951601229"
	}

local screamimgIds = {
	Scream1 = "rbxassetid://35040946",
	Scream2 = "rbxassetid://1808008224",
	Scream3 = "rbxassetid://8263521965",
	Scream4 = "rbxassetid://866664289",
	Scream5 = "rbxassetid://12075892911",
	Scream6 = "rbxassetid://17326887131",
	Scream7 = "rbxassetid://17846418000",
	Scream8 = "rbxassetid://9560208105",
	Scream9 = "rbxassetid://9041070248",
	Scream10 = "rbxassetid://13942340745",
	Scream11 = "rbxassetid://13159630515",
	Scream12 = "rbxassetid://13214013487",
	Scream13 = "rbxassetid://13731290337",
}
local imgLabel = script.Parent:WaitForChild("ImageLabel")
imgLabel.Image = imgIds[math.random(1,#imgIds)]

RL:WaitForChild("Remotes"):WaitForChild("VineBoom").OnClientEvent:Connect(function(imgID)
	imgLabel.Image = imgID or imgIds[math.random(1,#imgIds)]
	imgLabel.BackgroundTransparency = 0
	imgLabel.ImageTransparency = 0
	
end)

RL.Remotes:WaitForChild("Gethit").OnClientEvent:Connect(function(screamName)
	imgLabel.Image = screamimgIds[screamName]
	imgLabel.BackgroundTransparency = 0
	imgLabel.ImageTransparency = 0
	game.TweenService:Create(imgLabel,TweenInfo.new(5),{ImageTransparency = 1,BackgroundTransparency = 1}):Play()
end)
