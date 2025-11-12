------------| Anti Fly Hacks |-------------
--Made by: kevo1ution
--Discord: hC3k63D
--Youtube Video Explanation: https://youtu.be/gui74u4oGkA

--Description: This script is supposed to be under game.StarterPlayer.StarterPlayerScripts
--			   This script is client side for efficiency, but you can modify the script so that it works
--			   on the server. Watch the Youtube video if you are confused about how the script works!

local player = game.Players.LocalPlayer
local sitcount = 0
local maxsit = 2 --max amount of times a person can sit in 1 second

spawn(function() 
	while wait(1) do
		if sitcount > maxsit then
			player:Kick('Kicked for Fly Hacks')
		end
		sitcount = 0
	end
end)

player.CharacterAdded:connect(function(Character)
	Character.Humanoid.StateChanged:connect(function(oldstate, newstate)
		if newstate == Enum.HumanoidStateType.Seated then
			sitcount = sitcount + 1
		end
	end)
end)