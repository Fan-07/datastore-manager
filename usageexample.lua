local Players  = game:GetService("Players")
local DSM      = require(game.ServerScriptService.DataStoreManager)

Players.PlayerAdded:Connect(function(player)
  local data = DSM.Load(player)
  print(player.Name, "loaded — coins:", data.coins) --data to be saved (coins in this case)
end)

Players.PlayerRemoving:Connect(function(player)
  DSM.Unload(player)  -- saves then clears cache
end)

-- Giving coins from anywhere on the server
DSM.Increment(player, "coins", 50)

-- Reading data
local data = DSM.Get(player)
print(data.level, data.xp)

-- Setting a field directly
DSM.Set(player, "level", 5)

-- Manual save 
DSM.Save(player)

-- Binding to GameClose so Studio tests don't lose data:
game:BindToClose(function()
  for _, player in ipairs(Players:GetPlayers()) do
    DSM.Unload(player)
  end
end)
