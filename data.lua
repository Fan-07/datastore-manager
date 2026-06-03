local DataStoreService = game:GetService("DataStoreService")
local RunService      = game:GetService("RunService")

local DataStoreManager = {}
DataStoreManager.__index = DataStoreManager

local MAX_RETRIES   = 3
local RETRY_DELAY   = 2   -- seconds between retries (keep low)
local AUTO_SAVE_INT = 60  -- autosaves every N seconds

local store    = DataStoreService:GetDataStore("PlayerData")
local cache    = {}
local dirty    = {}

local function retry(fn, ...)
  local args = {...}
  for attempt = 1, MAX_RETRIES do
    local ok, result = pcall(fn, table.unpack(args))
    if ok then
      return result
    end
    warn("[DataStore] Attempt", attempt, "failed:", result)
    if attempt < MAX_RETRIES then
      task.wait(RETRY_DELAY)
    end
  end
  return nil
end

local function defaultData()
  return {
    coins   = 0,
    level   = 1, --add more of your data here as you please, as long as you store it properly, itll work
  }
end

function DataStoreManager.Load(player)
  local key  = "Player_" .. player.UserId
  local data = retry(function()
    return store:GetAsync(key)
  end)

  if data == nil then
    data = defaultData()  -- for first time player
  else
    
    for k, v in pairs(defaultData()) do
      if data[k] == nil then data[k] = v end
    end
  end

  cache[player.UserId]  = data
  dirty[player.UserId]  = false
  return data
end

function DataStoreManager.Get(player)
  return cache[player.UserId]
end

function DataStoreManager.Set(player, key, value)
  local data = cache[player.UserId]
  if not data then return end
  data[key]               = value
  dirty[player.UserId]    = true
end

function DataStoreManager.Increment(player, key, amount)
  local data = cache[player.UserId]
  if not data then return end
  data[key]               = (data[key] or 0) + (amount or 1)
  dirty[player.UserId]    = true
end

function DataStoreManager.Save(player)
  if not dirty[player.UserId] then return end
  local key  = "Player_" .. player.UserId
  local data = cache[player.UserId]
  retry(function()
    store:SetAsync(key, data)
  end)
  dirty[player.UserId] = false
end

function DataStoreManager.Unload(player)
  DataStoreManager.Save(player)
  cache[player.UserId] = nil
  dirty[player.UserId] = nil
end

if RunService:IsServer() then
  task.spawn(function()
    while true do
      task.wait(AUTO_SAVE_INT)
      for _, player in ipairs(game.Players:GetPlayers()) do
        DataStoreManager.Save(player)
      end
    end
  end)
end

return DataStoreManager
