local Players = game:GetService("Players")

local model = script.Parent
local hitbox = model.Hitbox

task.wait(0.25)

model.Parent = workspace.Traps

local connection:RBXScriptConnection = nil
connection = hitbox.Touched:Connect(function(otherPart)
	local char:Model = otherPart.Parent
	local player = Players:GetPlayerFromCharacter(char)
	
	if player and char.Gorilla.Value and not char.TrapDB.Value then
		print(player.Name .. " got trapped")
		char.TrapDB.Value = true
		model.Close.Transparency = 0
		model.Open.Transparency = 1
		model.Trapped.Value = true
		hitbox.Sound:Play()
		game.ReplicatedStorage.Remotes.GetTrapped:FireClient(player,model)
		game.ReplicatedStorage.Remotes.VineBoom:FireClient(player)
		connection:Disconnect()
		
	end
end)

