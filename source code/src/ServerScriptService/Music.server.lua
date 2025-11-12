local currentSong:Sound = nil

while true do

	local songs = script:GetChildren()
	currentSong = songs[math.random(1,#songs)]

	for _, obj in workspace:GetChildren() do
		if obj:IsA("Sound") then
			obj.Parent = script
		end
	end
	
	currentSong.Parent = workspace
	currentSong:Play()
	currentSong.Ended:Wait()
	--task.wait(10)

end
