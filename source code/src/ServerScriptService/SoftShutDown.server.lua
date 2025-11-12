--PUT INSIDE SERVERSCRIPTSERVICE--

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

if (game.VIPServerId ~= "" and game.VIPServerOwnerId == 0) then

	local m = Instance.new("Message")
	m.Text = "[Update System] This is a temporary lobby, teleporting back to game in a second..."
	m.Parent = workspace

	local waitTime = 0

	Players.PlayerAdded:connect(function(player)
		wait(waitTime)
		waitTime = waitTime / 2
		TeleportService:Teleport(game.PlaceId, player)
	end)

	for _,player in pairs(Players:GetPlayers()) do
		TeleportService:Teleport(game.PlaceId, player)
		wait(waitTime)
		waitTime = waitTime / 2
	end
else
	game:BindToClose(function()
		if (#Players:GetPlayers() == 0) then
			return
		end

		if (game:GetService("RunService"):IsStudio()) then
			return
		end

		local m = Instance.new("Message")
		m.Text = "[Update System] Restarting for updates and/or hotfixes..."
		m.Parent = workspace
		wait(5)
		local reservedServerCode = TeleportService:ReserveServer(game.PlaceId)

		for _,player in pairs(Players:GetPlayers()) do
			TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerCode, { player })
		end
		Players.PlayerAdded:connect(function(player)
			TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerCode, { player })
		end)
		while (#Players:GetPlayers() > 0) do
			wait(1)
		end
	end)
end