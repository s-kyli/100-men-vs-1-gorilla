local contentProvider = game:GetService("ContentProvider")
local RL = game:GetService("ReplicatedStorage")

local assets = {
	RL:WaitForChild("Assets"):WaitForChild("DangerZone"):WaitForChild("Decal"),
}

local imgIds = 
	{	"rbxassetid://17296841986",
		"rbxassetid://11818627057",
		"rbxassetid://11578612440",
		"rbxassetid://134648324801259",
		"rbxassetid://122354736220591",
		"rbxassetid://12995186653",
		"rbxassetid://11951601229"
	}

for _, id in imgIds do
	local img = Instance.new("Decal")
	img.Texture = id
	table.insert(assets,img)	
end

contentProvider:PreloadAsync(assets)
print("preloaded")