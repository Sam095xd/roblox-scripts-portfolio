
local DataStoreService = game:GetService("DataStoreService")
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")


local function onPlayerAdded(player)
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	
	local coins = Instance.new("IntValue")
	coins.Name = "Monedas"
	coins.Value = 0
	coins.Parent = leaderstats

	
	local dataKey = "Player_" .. player.UserId
	local success, savedCoins = pcall(function()
		return PlayerDataStore:GetAsync(dataKey)
	end)

	if success and savedCoins then
		coins.Value = savedCoins
		print("[DataStore] Datos cargados para: " .. player.Name)
	else
		print("[DataStore] Jugador nuevo o sin datos previos: " .. player.Name)
	end
end


local function onPlayerRemoving(player)
	local dataKey = "Player_" .. player.UserId
	local coinsToSave = player.leaderstats.Monedas.Value

	local success, errorMessage = pcall(function()
		PlayerDataStore:SetAsync(dataKey, coinsToSave)
	end)

	if success then
		print("[DataStore] Datos guardados exitosamente para: " .. player.Name)
	else
		warn("[DataStore] Error al guardar datos de " .. player.Name .. ": " .. tostring(errorMessage))
	end
end


game.Players.PlayerAdded:Connect(onPlayerAdded)
game.Players.PlayerRemoving:Connect(onPlayerRemoving)