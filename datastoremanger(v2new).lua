local Players = game:GetService("Players")
local DSM = require(game.ServerScriptService.DataStoreManager)

-- palyer joins
Players.PlayerAdded:Connect(function(player)
	local data = DSM.Load(player)

	print(player.Name .. " loaded")
	print("Coins:", data.coins, "Level:", data.level)

	-- example starter reward
	DSM.Increment(player, "coins", 100)
end)

-- Player leaves
Players.PlayerRemoving:Connect(function(player)
	DSM.Unload(player)
end)

local function giveCoins(player, amount)
	DSM.Increment(player, "coins", amount)
end
--test but gives coins every 10s
task.spawn(function()
	while true do
		task.wait(10)

		for _, player in ipairs(Players:GetPlayers()) do
			giveCoins(player, 5)
		end
	end
end)

-- final safety save when server closes
game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		DSM.Unload(player)
	end
	task.wait(2)
end)
