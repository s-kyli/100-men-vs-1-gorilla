local RL = game:GetService("ReplicatedStorage")
local Remotes = RL:WaitForChild("Remotes")

Remotes:WaitForChild("Knockback").OnClientEvent:Connect(function(character:Model,velocity:Vector3,t:number)
	
	if game.Players:GetPlayerFromCharacter(character) ~= game.Players.LocalPlayer then return end
	
	local knockback = Instance.new("BodyVelocity")
	knockback.MaxForce = Vector3.new(100000,100000,100000)
	knockback.Velocity = velocity
	knockback.Parent = character.PrimaryPart
	
	task.delay(t or 0.175,function()
		knockback:Destroy()
	end)
end)


