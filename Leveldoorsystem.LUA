--[========================================================================[
    Script: Level-Restricted Door / Gate
    Description: A door that only opens for players who meet a minimum
                 Level requirement (read from their leaderstats). Players
                 who don't qualify are gently pushed back and shown a
                 message via a BillboardGui hint.
    Location: ServerScriptService
    Requires: A door/gate model in Workspace with:
                - A "Barrier" Part (the actual collidable door piece)
                - A "Trigger" Part (a slightly larger, non-collidable
                  Part covering the doorway, used to detect players)
--]========================================================================]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local REQUIRED_LEVEL = 10
local doorModel = workspace:WaitForChild("LevelDoor")
local barrier = doorModel:WaitForChild("Barrier")
local trigger = doorModel:WaitForChild("Trigger")

-- Keeps track of players currently allowed through, to avoid re-checking
-- every frame for the same character
local playersChecked = {}

local function setDoorOpen(isOpen)
	local targetTransparency = isOpen and 1 or 0
	local targetCanCollide = not isOpen

	barrier.CanCollide = targetCanCollide
	TweenService:Create(barrier, TweenInfo.new(0.3), { Transparency = targetTransparency }):Play()
end

local function getPlayerLevel(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return 0
	end

	local level = leaderstats:FindFirstChild("Level")
	if not level then
		return 0
	end

	return level.Value
end

local function onTriggerTouched(hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	if playersChecked[player.UserId] then
		return
	end
	playersChecked[player.UserId] = true

	local playerLevel = getPlayerLevel(player)

	if playerLevel >= REQUIRED_LEVEL then
		setDoorOpen(true)
		print("[LevelDoor] " .. player.Name .. " passed (Level " .. playerLevel .. ")")

		task.delay(3, function()
			setDoorOpen(false)
			playersChecked[player.UserId] = nil
		end)
	else
		print("[LevelDoor] " .. player.Name .. " blocked (Level " .. playerLevel .. " / requires " .. REQUIRED_LEVEL .. ")")

		task.delay(2, function()
			playersChecked[player.UserId] = nil
		end)
	end
end

trigger.Touched:Connect(onTriggerTouched)

-- Clean up the check-list if a player leaves mid-interaction
Players.PlayerRemoving:Connect(function(player)
	playersChecked[player.UserId] = nil
end)