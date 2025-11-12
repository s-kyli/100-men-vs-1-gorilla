local RL = game:GetService("ReplicatedStorage")
local Remotes = RL:WaitForChild("Remotes")
local WeaponConfigurations = RL:WaitForChild("WeaponConfigurations")
local GorillaConfiguration = RL:WaitForChild("GorillaConfigurations")

Remotes:WaitForChild("GorillaHitHuman").OnServerEvent:Connect(function(player,humanoid:Humanoid)
	
	if not humanoid then return end
	local eCharacter:Model = humanoid.Parent
	local character = player.Character
	
	if (character.PrimaryPart.Position - eCharacter.PrimaryPart.Position).Magnitude > 25  then
		warn("gorilla hit sanity check failed for " .. character.Name .. " and " .. eCharacter.Name)
		return
	end
	
	if not character.Gorilla.Value then return end
	if eCharacter.InLobby.Value then return end
	if character.InLobby.Value then return end
	if eCharacter.Gorilla.Value then return end
	if eCharacter.Ragdoll:FindFirstChild("Ragdoll") then
		return
	end
	
	humanoid:TakeDamage(GorillaConfiguration.AttackDamage.Value)
	character["Right Arm"].GorillaHandPart.Hit:Play()
	
	local ragdollVal = Instance.new("BoolValue")
	ragdollVal.Name = "Ragdoll"
	ragdollVal.Parent = eCharacter.Ragdoll
	
	local staggerVal = Instance.new("BoolValue")
	staggerVal.Name = "Stagger"
	staggerVal.Parent = eCharacter
	
	task.delay(GorillaConfiguration.RagdollTime.Value,function()
		ragdollVal:Destroy()
	end)
	
	task.delay(0.5,function()
		staggerVal:Destroy()
	end)
	
	local knockbackVelocity = (character.HumanoidRootPart.CFrame * CFrame.Angles(0,0,0)).LookVector * 85
	
	local ePlayer = game.Players:GetPlayerFromCharacter(eCharacter)
	if ePlayer then
		
		local hrp = eCharacter.PrimaryPart
		local rando = math.random(1,12)
		for _, obj in hrp:GetChildren() do
			if obj:IsA("Sound") and obj.Name == "Scream" .. tostring(rando) then
				obj:Play()
				Remotes.Gethit:FireClient(ePlayer,obj.Name)
				break
			end
		end
		
		if humanoid.Health <= 0 then
			local knockback = Instance.new("BodyVelocity")
			knockback.MaxForce = Vector3.new(100000,100000,100000)
			knockback.Velocity = knockbackVelocity
			knockback.Parent = eCharacter.HumanoidRootPart

			task.delay(0.175,function()
				knockback:Destroy()
			end)
		else
			Remotes.Knockback:FireClient(ePlayer,eCharacter,knockbackVelocity,0.175)
		end
	else
		local knockback = Instance.new("BodyVelocity")
		knockback.MaxForce = Vector3.new(100000,100000,100000)
		knockback.Velocity = knockbackVelocity
		knockback.Parent = eCharacter.HumanoidRootPart
		
		task.delay(0.175,function()
			knockback:Destroy()
		end)
	end
	
end)

Remotes:WaitForChild("GorillaSmashHumans").OnServerEvent:Connect(function(player,eCharacters:{Model},groundPos:Vector3)
	
	local character = player.Character
	if not character.Gorilla.Value then return end
	
	local knockbacks:{BodyVelocity} = {}
	local ragdollVals:{BoolValue} = {}
	local staggerVals:{BoolValue} = {}
	
	for _, eChar in eCharacters do
		
		if eChar == nil then continue end
		local gorilla:BoolValue = eChar:FindFirstChild("Gorilla")
		if not gorilla then continue end
		if gorilla.Value then continue end
		if eChar.InLobby.Value then return end
		
		if (character.PrimaryPart.Position - eChar.PrimaryPart.Position).Magnitude > 30  then
			warn("smash sanity check failed for " .. character.Name .. " and " .. eChar.Name)
			continue
		end
		
		local humanoid = eChar:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then return end
		humanoid:TakeDamage(GorillaConfiguration.SpecialAttackDamage.Value)
		
		local ragdollVal = Instance.new("BoolValue")
		ragdollVal.Name = "Ragdoll"
		ragdollVal.Parent = eChar.Ragdoll
		
		table.insert(ragdollVals,ragdollVal)
		
		local staggerVal = Instance.new("BoolValue")
		staggerVal.Name = "Stagger"
		staggerVal.Parent = eChar

		table.insert(staggerVals,staggerVal)
		
		local knockbackVelocity = (eChar.PrimaryPart.Position - groundPos).Unit * 90
		
		local ePlayer = game.Players:GetPlayerFromCharacter(eChar)
		if ePlayer then
			
			local hrp = eChar.PrimaryPart
			local rando = math.random(1,12)
			for _, obj in hrp:GetChildren() do
				if obj:IsA("Sound") and obj.Name == "Scream" .. tostring(rando) then
					obj:Play()
					Remotes.Gethit:FireClient(ePlayer,obj.Name)
					break
				end
			end
			
			if humanoid.Health <= 0 then
				local knockback = Instance.new("BodyVelocity")
				knockback.MaxForce = Vector3.new(100000,100000,100000)
				knockback.Velocity = knockbackVelocity
				knockback.Parent = eChar.HumanoidRootPart

				task.delay(0.175,function()
					knockback:Destroy()
				end)
			else
				Remotes.Knockback:FireClient(ePlayer,eChar,knockbackVelocity,0.175)
			end		
		else
			local knockback = Instance.new("BodyVelocity")
			knockback.MaxForce = Vector3.new(100000,100000,100000)
			knockback.Velocity = knockbackVelocity
			knockback.Parent = eChar.PrimaryPart

			table.insert(knockbacks,knockback)
		end
	end
	
	if #knockbacks > 0  then
		task.delay(0.175,function()
			for _, knockback in knockbacks do
				knockback:Destroy()
			end
		end)
	end

	if #ragdollVals > 0 then
		task.delay(GorillaConfiguration.RagdollTime.Value,function()
			for _, ragdollVal in ragdollVals do 
				ragdollVal:Destroy()
			end
		end)
	end
	
	if #staggerVals > 0 then
		task.delay(0.5,function()
			for _, staggerVal in staggerVals do 
				staggerVal:Destroy()
			end
		end)
	end
end)

Remotes:WaitForChild("HumanHitGorilla").OnServerEvent:Connect(function(player,humanoid:Humanoid)
	
	if not humanoid then return end
	local eCharacter = humanoid.Parent
	local character = player.Character
	if character.Gorilla.Value then return end
	local tool = character:FindFirstChildWhichIsA("Tool")
	
	if not tool then return end
	
	-- sanity check for distance
	if (character.PrimaryPart.Position - eCharacter.PrimaryPart.Position).Magnitude > 25  then
		warn("human hit sanity check failed for " .. character.Name .. " and " .. eCharacter.Name)
		return
	end
	
	local config = WeaponConfigurations:FindFirstChild(tool.Name)
	if not config then return end
	
	if eCharacter.InLobby.Value then return end
	--if character.InLobby.Value then return end
	if not eCharacter.Gorilla.Value then return end 
	
	humanoid:TakeDamage(config.Damage.Value)
	player.Damage.Value += config.Damage.Value
	tool.Hitbox.Hit:Play()
	
end)

Remotes:WaitForChild("PlaySound").OnServerEvent:Connect(function(player,sound:Sound)
	if sound then
		sound:Play()
	end
end)

Remotes:WaitForChild("DangerZoneIndicator").OnServerEvent:Connect(function(player,transparency:number)
	
	local character = player.Character
	
	character.PrimaryPart.DangerZone.Decal.Transparency = transparency
	
end)

Remotes:WaitForChild("SetTrap").OnServerEvent:Connect(function(player,trap:Tool)

	local character = trap.Parent
	if game.Players:GetPlayerFromCharacter(character) == player 
		and #workspace.Traps:GetChildren() < RL.GameConfiguration.MaxTraps.Value then
		local trapModel:Model = trap.BearTrapModel:Clone()
		character.Humanoid:UnequipTools()
		trap:Destroy()

		trapModel.Set.Value = true
		trapModel.Hitbox.Anchored = true
		trapModel.Parent = workspace.Traps
		trapModel.Server.Enabled = true
	end

	
end)

Remotes:WaitForChild("UnTrap").OnServerEvent:Connect(function(player,trap)
	local character = player.Character
	trap:Destroy()
	task.delay(3,function()
		character.TrapDB.Value = false
	end)
end)
