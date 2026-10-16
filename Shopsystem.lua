--[========================================================================[
    Script: Shop / Interactive Store System
    Description: Shop where a player interacts with a ProximityPrompt,
                 pays with their Coins leaderstat, and receives the item.
    Location: ServerScriptService
    Requires: A model in Workspace with a ProximityPrompt inside
              (e.g. a "ShopStand" model with a "ProximityPrompt" child).
--]========================================================================]

local ServerStorage = game:GetService("ServerStorage")

-- Available shop items
local SHOP_ITEMS = {
	["Basic Sword"] = { price = 50, toolName = "BasicSword" },
	["Combat Helmet"] = { price = 120, toolName = "CombatHelmet" },
}

-- ProximityPrompt reference (adjust the path to match your map)
local shopStand = workspace:WaitForChild("ShopStand")
local prompt = shopStand:WaitForChild("ProximityPrompt")

-- Item sold by this specific stand
local ITEM_NAME = "Basic Sword"
prompt.ActionText = "Buy " .. ITEM_NAME
prompt.ObjectText = SHOP_ITEMS[ITEM_NAME].price .. " Coins"

local function onPromptTriggered(player)
	local item = SHOP_ITEMS[ITEM_NAME]
	if not item then
		warn("[Shop] Item not configured: " .. ITEM_NAME)
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end

	local coins = leaderstats:FindFirstChild("Coins")
	if not coins then
		return
	end

	-- Check if the player already owns the tool to avoid duplicates
	local backpack = player:FindFirstChild("Backpack")
	local character = player.Character
	local alreadyOwns = (backpack and backpack:FindFirstChild(item.toolName))
		or (character and character:FindFirstChild(item.toolName))

	if alreadyOwns then
		print("[Shop] " .. player.Name .. " already owns this item.")
		return
	end

	-- Check for sufficient funds
	if coins.Value < item.price then
		print("[Shop] " .. player.Name .. " does not have enough coins.")
		return
	end

	-- Charge and deliver the item
	coins.Value -= item.price

	local toolTemplate = ServerStorage:FindFirstChild(item.toolName)
	if toolTemplate then
		local newTool = toolTemplate:Clone()
		newTool.Parent = backpack
		print("[Shop] " .. player.Name .. " bought " .. ITEM_NAME)
	else
		warn("[Shop] Tool '" .. item.toolName .. "' not found in ServerStorage. Refunding.")
		coins.Value += item.price
	end
end

prompt.Triggered:Connect(onPromptTriggered)