local player = game.Players.LocalPlayer
local character = nil
local humanoidRootPart = nil
local humanoid = nil

local function onCharacterAdded(newCharacter)
	character = newCharacter
	humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
	humanoid = newCharacter:WaitForChild("Humanoid")
end

if player.Character then
	onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

local runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local MinHeight = 110
local MaxHeight = 210

local CHEST_NAMES = {"chests", "Dark Chest_p", "Light Chest_p"}
local ITEM_NAMES = {"other", "Toll-096 Loot Bag", "Trollge King Loot Bag", "Saints Head_p", "Saints Torso_p", "Saints Leg_p", "Saints Arm_p", "Saints Finger_p", "Saints Eyes_p", "Space Heat_p", "Space Egg_p"}

-- Создаем UI (оставлю без изменений, так как это не нагружает сильно)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportChestPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0.13, 0, 0.375, 0)
panel.Position = UDim2.new(0.45, 0, 0.25, 0)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panel.BorderSizePixel = 4
panel.BorderColor3 = Color3.fromRGB(255, 255, 255)
panel.Parent = screenGui

-- Перетаскивание (оставлю как есть)

local dragging = false
local dragInput, dragStart, startPos

panel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = panel.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

panel.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
		dragInput = input
	end
end)

runService.Heartbeat:Connect(function()
	if dragging and dragInput then
		local delta = dragInput.Position - dragStart
		panel.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.12, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.BorderSizePixel = 0
title.Text = "AUTO FARM"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextScaled = true
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = panel

local startChestButton = Instance.new("TextButton")
startChestButton.Size = UDim2.new(0.4, 0, 0.2, 0)
startChestButton.Position = UDim2.new(0.05, 0, 0.425, 0)
startChestButton.BackgroundColor3 = Color3.fromRGB(38, 13, 0)
startChestButton.BorderSizePixel = 2
startChestButton.BorderColor3 = Color3.new(0.666667, 0.333333, 0)
startChestButton.Font = Enum.Font.Michroma
startChestButton.TextSize = 16
startChestButton.TextScaled = true
startChestButton.Text = "Сундуки [OFF]"
startChestButton.TextColor3 = Color3.new(0.666667, 0.333333, 0)
startChestButton.Parent = panel

local startItemButton = Instance.new("TextButton")
startItemButton.Size = UDim2.new(0.4, 0, 0.2, 0)
startItemButton.Position = UDim2.new(0.54, 0, 0.425, 0)
startItemButton.BackgroundColor3 = Color3.fromRGB(0, 49, 74)
startItemButton.BorderSizePixel = 2
startItemButton.BorderColor3 = Color3.new(0, 0.666667, 1)
startItemButton.Font = Enum.Font.Michroma
startItemButton.TextSize = 16
startItemButton.TextScaled = true
startItemButton.Text = "Предметы [OFF]"
startItemButton.TextColor3 = Color3.new(0, 0.666667, 1)
startItemButton.Parent = panel

local chestCountLabel = Instance.new("TextLabel")
chestCountLabel.Size = UDim2.new(0.4, 0, 0.275, 0)
chestCountLabel.Position = UDim2.new(0.05, 0, 0.13, 0)
chestCountLabel.BackgroundColor3 = Color3.fromRGB(139, 46, 0)
chestCountLabel.BorderSizePixel = 0
chestCountLabel.Text = "Сундуков [0]"
chestCountLabel.Font = Enum.Font.Michroma
chestCountLabel.TextSize = 16
chestCountLabel.TextScaled = true
chestCountLabel.TextColor3 = Color3.new(1, 0.333333, 0)
chestCountLabel.Parent = panel

local itemCountLabel = Instance.new("TextLabel")
itemCountLabel.Size = UDim2.new(0.4, 0, 0.275, 0)
itemCountLabel.Position = UDim2.new(0.545, 0, 0.13, 0)
itemCountLabel.BackgroundColor3 = Color3.fromRGB(0, 36, 54)
itemCountLabel.BorderSizePixel = 2
itemCountLabel.BorderColor3 = Color3.new(0, 0.333333, 1)
itemCountLabel.Text = "Предметов [0]"
itemCountLabel.Font = Enum.Font.Michroma
itemCountLabel.TextSize = 16
itemCountLabel.TextScaled = true
itemCountLabel.TextColor3 = Color3.new(0, 0.333333, 1)
itemCountLabel.Parent = panel

local coordsLabel = Instance.new("TextLabel")
coordsLabel.Size = UDim2.new(0.9, 0, 0.1, 0)
coordsLabel.Position = UDim2.new(0.05, 0, 0.9, 0)
coordsLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
coordsLabel.BorderSizePixel = 0
coordsLabel.Text = "[X=0, Y=0, Z=0]"
coordsLabel.Font = Enum.Font.Michroma
coordsLabel.TextSize = 12
coordsLabel.TextScaled = true
coordsLabel.TextColor3 = Color3.new(1, 1, 1)
coordsLabel.Parent = panel
coordsLabel.BorderSizePixel = 2
coordsLabel.BorderColor3 = Color3.fromRGB(255, 255, 255)

-- Кеширование объектов
local chestsCache = {}
local itemsCache = {}
local lastCacheUpdate = 0

local function getAllObjectsByNames(names)
	local objects = {}
	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant:IsA("Model") and table.find(names, descendant.Name) then
			for _, child in pairs(descendant:GetChildren()) do
				if child:IsA("BasePart") then
					table.insert(objects, child)
				end
			end
		elseif (descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation")) and table.find(names, descendant.Name) then
			table.insert(objects, descendant)
		end
	end
	return objects
end

local function updateObjectCaches()
	chestsCache = getAllObjectsByNames(CHEST_NAMES)
	itemsCache = getAllObjectsByNames(ITEM_NAMES)
end

-- Обновлять кеш раз в 1 секунду
runService.Heartbeat:Connect(function(step)
	lastCacheUpdate = lastCacheUpdate + step
	if lastCacheUpdate >= 1 then
		updateObjectCaches()
		lastCacheUpdate = 0
	end
end)

-- Обновление координат
local lastCoordsUpdate = 0
local coordsUpdateInterval = 0.2
runService.Heartbeat:Connect(function(step)
	lastCoordsUpdate = lastCoordsUpdate + step
	if lastCoordsUpdate >= coordsUpdateInterval then
		if humanoidRootPart and humanoidRootPart.Parent then
			local pos = humanoidRootPart.Position
			coordsLabel.Text = string.format("[X=%.1f, Y=%.1f, Z=%.1f]", pos.X, pos.Y, pos.Z)
		end
		lastCoordsUpdate = 0
	end
end)

-- Обновление счетчиков
local lastCountsUpdate = 0
local countsUpdateInterval = 0.5
local function updateCounts()
	chestCountLabel.Text = "Сундуков [" .. #chestsCache .. "]"
	itemCountLabel.Text = "Предметов [" .. #itemsCache .. "]"
end

runService.Heartbeat:Connect(function(step)
	lastCountsUpdate = lastCountsUpdate + step
	if lastCountsUpdate >= countsUpdateInterval then
		updateCounts()
		lastCountsUpdate = 0
	end
end)

-- Кулдаун
local cooldownSeconds = 1
local cooldownBox = Instance.new("TextBox")
cooldownBox.Size = UDim2.new(0.25, 0, 0.1, 0)
cooldownBox.Position = UDim2.new(0.06, 0, 0.65, 0)
cooldownBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
cooldownBox.BorderSizePixel = 1
cooldownBox.Text = tostring(cooldownSeconds)
cooldownBox.PlaceholderText = "КД ТП"
cooldownBox.Font = Enum.Font.Michroma
cooldownBox.TextSize = 14
cooldownBox.TextColor3 = Color3.new(1,1,1)
cooldownBox.BorderSizePixel = 2
cooldownBox.BorderColor3 = Color3.fromRGB(255, 255, 255)
cooldownBox.Parent = panel

cooldownBox.FocusLost:Connect(function()
	local val = tonumber(cooldownBox.Text)
	if val then
		cooldownSeconds = val
	end
end)

local teleporting = false
local lastTeleportTime = 0

-- Функция телепорта
local function teleportToPart(part)
	if not part then return end
	if not humanoidRootPart or not humanoidRootPart.Parent then return end
	humanoidRootPart.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
	humanoidRootPart.CanCollide = false
	task.wait(0.1)
	humanoidRootPart.CanCollide = true
end

-- Активация промптов
local promptDebounce = {} -- чтобы не активировать один промпт несколько раз

local function activatePrompt(prompt)
	if not prompt or not prompt.Enabled then return end
	if not prompt.Parent or not prompt.Parent:IsA("BasePart") then return end
	if promptDebounce[prompt] then return end
	promptDebounce[prompt] = true
	prompt:InputHoldBegin()
	task.wait(0.2)
	prompt:InputHoldEnd()
	task.wait(0.1)
	promptDebounce[prompt] = nil
end

local function activateAllNearbyPrompts(modelNames)
	local hrp = humanoidRootPart
	if not hrp or not hrp.Parent then return 0 end
	local count = 0
	for _, modelName in ipairs(modelNames) do
		for _, descendant in pairs(workspace:GetDescendants()) do
			local targets = {}
			if descendant:IsA("Model") and descendant.Name == modelName then
				targets = descendant:GetDescendants()
			elseif (descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation")) and descendant.Name == modelName then
				targets = {descendant}
			end
			for _, obj in ipairs(targets) do
				if obj:IsA("ProximityPrompt") and obj.Enabled and obj.Parent and obj.Parent:IsA("BasePart") then
					local dist = (hrp.Position - obj.Parent.Position).Magnitude
					if dist <= 20 and not promptDebounce[obj] then
						coroutine.wrap(activatePrompt)(obj)
						count = count + 1
					end
				end
			end
		end
	end
	return count
end

-- Управление телепортом
local teleportingChests = false
local teleportingItems = false
local skipObjects = {} -- [part] = true
local failedAttempts = {} -- [part] = count
local MAX_FAILED_ATTEMPTS = 3
local NEARBY_RADIUS = 25

local function getAccessibleObjects(names)
	local objects = {}
	for _, obj in ipairs(chestsCache) do
		if not skipObjects[obj] then
			local y = obj.Position.Y
			if y >= MinHeight and y <= MaxHeight then
				table.insert(objects, obj)
			end
		end
	end
	for _, obj in ipairs(itemsCache) do
		if not skipObjects[obj] then
			local y = obj.Position.Y
			if y >= MinHeight and y <= MaxHeight then
				table.insert(objects, obj)
			end
		end
	end
	return objects
end

local function getClosestObject(objects)
	if #objects == 0 then return nil end
	local minDist = math.huge
	local closest = nil
	local hrpPos = humanoidRootPart and humanoidRootPart.Position
	if not hrpPos then return nil end
	for _, obj in ipairs(objects) do
		local dist = (obj.Position - hrpPos).Magnitude
		if dist < minDist then
			minDist = dist
			closest = obj
		end
	end
	return closest
end

local function teleportToNearest(objects)
	local target = getClosestObject(objects)
	if target then
		teleportToPart(target)
		-- Проверка
		task.wait(0.5)
		if target.Parent then
			failedAttempts[target] = (failedAttempts[target] or 0) + 1
			if failedAttempts[target] >= MAX_FAILED_ATTEMPTS then
				skipObjects[target] = true
			end
		else
			failedAttempts[target] = nil
			skipObjects[target] = nil
		end
	end
end

local combinedCycleRunning = false

local function ensureCombinedCycle()
	if combinedCycleRunning then return end
	combinedCycleRunning = true

	coroutine.wrap(function()
		while true do
			if not (teleportingChests or teleportingItems) then
				-- остановить цикл
				break
			end

			-- Проверка таймаута по кулдауну
			local now = tick()
			if now - lastTeleportTime < cooldownSeconds then
				wait(cooldownSeconds - (now - lastTeleportTime))
			end

			if not humanoidRootPart or not humanoidRootPart.Parent then
				wait(cooldownSeconds)
				continue
			end

			local bothEnabled = teleportingChests and teleportingItems

			if bothEnabled then
				local chests = getAllObjectsByNames(CHEST_NAMES)
				if #chests > 0 then
					teleportToNearest(chests)
					lastTeleportTime = tick()
				else
					local items = getAllObjectsByNames(ITEM_NAMES)
					if #items > 0 then
						teleportToNearest(items)
						lastTeleportTime = tick()
					end
				end
			elseif teleportingChests then
				local chests = getAllObjectsByNames(CHEST_NAMES)
				if #chests > 0 then
					teleportToNearest(chests)
					lastTeleportTime = tick()
				end
			elseif teleportingItems then
				local items = getAllObjectsByNames(ITEM_NAMES)
				if #items > 0 then
					teleportToNearest(items)
					lastTeleportTime = tick()
				end
			end

			wait(cooldownSeconds)
		end
		-- Сброс
		skipObjects = {}
		failedAttempts = {}
		combinedCycleRunning = false
	end)()
end

-- Обработчики кнопок
local function createButtonWithOutline(text, size, position, color, parent)
	local btn = Instance.new("TextButton")
	btn.Text = text
	btn.Size = size
	btn.Position = position
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextStrokeColor3 = Color3.new(0, 0, 0)
	btn.TextStrokeTransparency = 0
	btn.Font = Enum.Font.Michroma
	btn.BorderSizePixel = 2
	btn.BorderColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.Parent = parent
	return btn
end

local promptAutoActivate = false

local togglePromptBtn = createButtonWithOutline("Авто сбор [OFF]", UDim2.new(0.6, 0, 0.1, 0), UDim2.new(0.345, 0, 0.65, 0), Color3.fromRGB(24, 0, 36), panel)

togglePromptBtn.MouseButton1Click:Connect(function()
	promptAutoActivate = not promptAutoActivate
	togglePromptBtn.Text = "Авто сбор " .. (promptAutoActivate and "[ON]" or "[OFF]")
	togglePromptBtn.BackgroundColor3 = promptAutoActivate and Color3.fromRGB(85, 0, 255) or Color3.fromRGB(24, 0, 36)
end)

-- Ноклип режим
local noclipEnabled = false
local storedObjects = {}

runService.Heartbeat:Connect(function()
	-- Ноклип
	if noclipEnabled then
		if humanoidRootPart and humanoidRootPart.Parent then
			humanoidRootPart.CanCollide = false
			local hrpPos = humanoidRootPart.Position
			for _, part in pairs(workspace:GetDescendants()) do
				if part:IsA("BasePart") then
					local distance = (part.Position - hrpPos).Magnitude
					if distance <= 80 then
						if not storedObjects[part] then
							storedObjects[part] = part.CanCollide
						end
						part.CanCollide = false
					end
				end
			end
		end
	else
		for obj, state in pairs(storedObjects) do
			if obj and obj.Parent then
				obj.CanCollide = state
			end
		end
		storedObjects = {}
		if humanoidRootPart and humanoidRootPart.Parent then
			humanoidRootPart.CanCollide = true
		end
	end
end)

local function createNoclipButton()
	local btn = createButtonWithOutline("NoClip [OFF]", UDim2.new(0.6, 0, 0.1, 0), UDim2.new(0.345, 0, 0.77, 0), Color3.fromRGB(0, 0, 0), panel)
	btn.MouseButton1Click:Connect(function()
		noclipEnabled = not noclipEnabled
		btn.Text = "NoClip " .. (noclipEnabled and "[ON]" or "[OFF]")
		btn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
	end)
end

createNoclipButton()

-- Управление кнопками режима телепорта
local function stopTeleportChests()
	teleportingChests = false
	startChestButton.Text = "Сундуки [OFF]"
	startChestButton.BackgroundColor3 = Color3.fromRGB(38, 13, 0)
end

local function stopTeleportItems()
	teleportingItems = false
	startItemButton.Text = "Предметы [OFF]"
	startItemButton.BackgroundColor3 = Color3.fromRGB(0, 49, 74)
end

startChestButton.MouseButton1Click:Connect(function()
	if teleportingChests then
		stopTeleportChests()
	else
		teleportingChests = true
		startChestButton.Text = "Сундуки [ON]"
		startChestButton.BackgroundColor3 = Color3.fromRGB(136, 45, 0)
		ensureCombinedCycle()
	end
end)

startItemButton.MouseButton1Click:Connect(function()
	if teleportingItems then
		stopTeleportItems()
	else
		teleportingItems = true
		startItemButton.Text = "Предметы [ON]"
		startItemButton.BackgroundColor3 = Color3.fromRGB(0, 85, 255)
		ensureCombinedCycle()
	end
end)

-- Автоматический сбор промптов
spawn(function()
	while true do
		if promptAutoActivate then
			activateAllNearbyPrompts(CHEST_NAMES)
			activateAllNearbyPrompts(ITEM_NAMES)
		end
		task.wait(0.3)
	end
end)

-- Основной цикл для телепорта
local lastCycleTime = 0
runService.Heartbeat:Connect(function(step)
	lastCycleTime = lastCycleTime + step
	if lastCycleTime >= 0.2 then -- интервал вызова цикла
		if (teleportingChests or teleportingItems) and tick() - lastTeleportTime >= cooldownSeconds then
			if humanoidRootPart and humanoidRootPart.Parent then
				if teleportingChests then
					local chests = getAllObjectsByNames(CHEST_NAMES)
					if #chests > 0 then
						teleportToNearest(chests)
						lastTeleportTime = tick()
					end
				end
				if teleportingItems then
					local items = getAllObjectsByNames(ITEM_NAMES)
					if #items > 0 then
						teleportToNearest(items)
						lastTeleportTime = tick()
					end
				end
			end
		end
		lastCycleTime = 0
	end
end)
