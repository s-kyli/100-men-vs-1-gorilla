local RL = game:GetService("ReplicatedStorage")
local Remotes = RL:WaitForChild("Remotes")

local frame = script.Parent
local template = frame:WaitForChild("Template")
local scrollingFrame = frame:WaitForChild("ScrollingFrame")

Remotes:WaitForChild("ShowDamages").OnClientEvent:Connect(function(damages : {[string] : number})
	
	--for plrName, damage in damages do
	--	local clone = template:Clone()
	--	clone.Damage.Text = tostring(damage)
	--	clone.NameLabel.Text = plrName
	--	clone.Visible = true
	--end
	
	-- Convert dictionary to a sorted array
	local sortedList = {}
	for name, damage in pairs(damages) do
		table.insert(sortedList, {Name = name, Score = damage})
	end

	table.sort(sortedList, function(a, b)
		return a.Score > b.Score -- highest score first
	end)

	-- Create the UI elements
	for _, entry in ipairs(sortedList) do
		local newFrame = template:Clone()
		newFrame.NameLabel.Text = entry.Name
		newFrame.Damage.Text = entry.Score
		newFrame.Visible = true
		newFrame.Parent = scrollingFrame
	end
	
	frame.Visible = true
end)

local function inivisbilize()
	frame.Visible = false

	for _, obj in scrollingFrame:GetChildren() do
		if obj:IsA("Frame") then
			obj:Destroy()
		end
	end
end

RL:WaitForChild("GameInfo"):WaitForChild("GameMode").Changed:Connect(function(val)
	if val == "GamePlaying" then
		inivisbilize()
	end
end)

frame:WaitForChild("ImageButton").Activated:Connect(inivisbilize)
