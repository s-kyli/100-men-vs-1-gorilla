local RL = game:GetService("ReplicatedStorage")
local Remotes = RL:WaitForChild("Remotes")

local frame = script.Parent

Remotes:WaitForChild("NotifyNextGorilla").OnClientEvent:Connect(function(name:string)
	frame.Visible = true
	
	local oldText = frame.TextLabel.Text
	
	task.wait(0.6)
	
	frame.TextLabel.Text = frame.TextLabel.Text .. "."
	
	task.wait(0.6)
	
	frame.TextLabel.Text = frame.TextLabel.Text .. "."
	
	task.wait(0.6)
	
	frame.TextLabel.Text = frame.TextLabel.Text .. "."
	
	task.wait(1)
	
	frame.Next.Text = name
	
	task.wait(3)
	
	frame.Next.Text = ""
	frame.TextLabel.Text = oldText
	frame.Visible = false
end)
