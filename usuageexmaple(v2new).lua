local DataStoreService = game:GetService("DataStoreService")

local DSM = {}
DSM.__index = DSM

local STORE_NAME = "PlayerData_v1"
local store = DataStoreService:GetDataStore(STORE_NAME)

-- default structure for every player
local DEFAULT_DATA = {
	coins = 0,
	level = 1,
	xp = 0,
}

local cache = {}
local savingDebounce = {}

-- deep copy helper
local function copyTable(t)
	local new = {}
	for k, v in pairs(t) do
		new[k] = v
	end
	return new
end

-- safe DataStore call with retries
local function retry(times, func)
	local lastError
	for i = 1, times do
		local success, result = pcall(func)
		if success then
			return true, result
		end
		lastError = result
		task.wait(1.5 * i)
	end
	return false, lastError
end

function DSM.Load(player)
	local key = "User_" .. player.UserId

	local success, data = retry(3, function()
		return store:GetAsync(key)
	end)

	if not success or not data then
		data = copyTable(DEFAULT_DATA)
	end

	cache[player] = data
	return data
end

function DSM.Get(player)
	return cache[player]
end

function DSM.Set(player, field, value)
	local data = cache[player]
	if not data then return end

	data[field] = value
end

function DSM.Increment(player, field, amount)
	local data = cache[player]
	if not data then return end

	data[field] = (data[field] or 0) + amount
end

function DSM.Save(player)
	local data = cache[player]
	if not data then return end

	-- debounce to prevent spam saving
	if savingDebounce[player] then return end
	savingDebounce[player] = true

	local key = "User_" .. player.UserId

	local success, err = retry(3, function()
		return store:SetAsync(key, data)
	end)

	if not success then
		warn("Failed to save:", player.Name, err)
	end

	task.delay(5, function()
		savingDebounce[player] = nil
	end)
end

function DSM.Unload(player)
	if cache[player] then
		DSM.Save(player)
		cache[player] = nil
	end
end

-- autosave loop (every 60 seconds)
task.spawn(function()
	while true do
		task.wait(60)
		for player, _ in pairs(cache) do
			DSM.Save(player)
		end
	end
end)

return DSM
