
local player = game.Players.LocalPlayer
local character = nil
local humanoidRootPart = nil
local humanoid = nil

local function onCharacterAdded(newCharacter)
	character = newCharacter
	humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
	humanoid = newCharacter:WaitForChild("Humanoid")
end

-- Инициализация текущего персонажа
if player.Character then
	onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

local runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local MinHeight = -110
local MaxHeight = 210

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportChestPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Основная панель
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0.13, 0, 0.375, 0)
panel.Position = UDim2.new(0.45, 0, 0.25, 0)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panel.BorderSizePixel = 4
panel.BorderColor3 = Color3.fromRGB(255, 255, 255)
panel.Parent = screenGui

-- Перетаскивание панели
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

runService.RenderStepped:Connect(function()
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

-- Заголовок
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

-- Кнопки [Старт / Стоп] Chest
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



-- Кнопки [Старт / Стоп] Item
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



-- Метки
local chestCountLabel = Instance.new("TextLabel")
chestCountLabel.Size = UDim2.new(0.4, 0, 0.275, 0)
chestCountLabel.Position = UDim2.new(0.05, 0, 0.13, 0)
chestCountLabel.BackgroundColor3 = Color3.fromRGB(139, 46, 0)
chestCountLabel.BorderSizePixel = 0
chestCountLabel.BorderColor3 = Color3.new(1, 0.333333, 0)
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

-- Получение всех объектов по именам
local function getAllObjectsByNames(names)
	local objects = {}
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and table.find(names, model.Name) then
			for _, child in pairs(model:GetChildren()) do
				if child:IsA("BasePart") then
					table.insert(objects, child)
				end
			end
		end
	end
	return objects
end

local function updateChestCount()
	local chests = getAllObjectsByNames({"chests", "Dark Chest_p", "Light Chest_p"})
	chestCountLabel.Text = "Сундуков [" .. #chests .. "]"
end

local function updateItemCount()
	local items = getAllObjectsByNames({"other", "Toll-096 Loot Bag", "Trollge King Loot Bag", "Saints Head_p", "Saints Torso_p", "Saints Leg_p", "Saints Arm_p", "Saints Finger_p", "Saints Eyes_p", "Space Heat_p", "Space Egg_p"})
	itemCountLabel.Text = "Предметов [" .. #items .. "]"
end

-- Обновление координат
runService.RenderStepped:Connect(function()
	if humanoidRootPart and humanoidRootPart.Parent then
		local pos = humanoidRootPart.Position
		coordsLabel.Text = string.format("[X=%.1f, Y=%.1f, Z=%.1f]", pos.X, pos.Y, pos.Z)
	end
end)

-- Основной цикл для обновления счетчиков
spawn(function()
	while true do
		updateChestCount()
		updateItemCount()
		wait(0.2)
	end
end)

-- Кулдаун и управление
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

local function teleportToPart(part)
	if not part then return end
	if not humanoidRootPart or not humanoidRootPart.Parent then return end
	humanoidRootPart.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
	humanoidRootPart.CanCollide = false
	wait(0.1)
	humanoidRootPart.CanCollide = true
end

local promptDebounce = {} -- трекинг уже активируемых промптов

local function activatePrompt(prompt)
	if not prompt or not prompt.Enabled then return end
	if not prompt.Parent or not prompt.Parent:IsA("BasePart") then return end
	-- Не активируем промпт, если он уже в процессе
	if promptDebounce[prompt] then return end
	promptDebounce[prompt] = true
	prompt:InputHoldBegin()
	task.wait(0.2)
	prompt:InputHoldEnd()
	task.wait(0.1)
	promptDebounce[prompt] = nil
end

-- Активация всех промптов поблизости одновременно
local function activateAllNearbyPrompts(modelNames)
	local hrp = humanoidRootPart
	if not hrp or not hrp.Parent then return 0 end

	local promptsToActivate = {}
	for _, modelName in ipairs(modelNames) do
		for _, model in ipairs(workspace:GetDescendants()) do
			if model:IsA("Model") and model.Name == modelName then
				for _, descendant in ipairs(model:GetDescendants()) do
					if descendant:IsA("ProximityPrompt") and descendant.Enabled then
						if descendant.Parent and descendant.Parent:IsA("BasePart") then
							descendant.HoldDuration = 0
							descendant.MaxActivationDistance = 20
							local distance = (hrp.Position - descendant.Parent.Position).Magnitude
							if distance <= descendant.MaxActivationDistance and not promptDebounce[descendant] then
								table.insert(promptsToActivate, descendant)
							end
						end
					end
				end
			end
		end
	end

	-- Активируем все промпты одновременно через отдельные корутины
	for _, prompt in ipairs(promptsToActivate) do
		coroutine.wrap(activatePrompt)(prompt)
	end

	return #promptsToActivate
end

local teleportingChests = false
local teleportingItems = false

local skipObjects = {} -- [part] = true — объекты, пропускаемые после 3 неудачных попыток
local failedAttempts = {} -- [part] = count — счётчик неудачных телепортов
local MAX_FAILED_ATTEMPTS = 3
local NEARBY_RADIUS = 25 -- радиус для одновременного сбора близких объектов

-- Вспомогательная функция: получить доступные объекты по именам (исключая пропущенные из-за лимита)
local function getAccessibleObjects(names)
	local objects = getAllObjectsByNames(names)
	local accessible = {}
	for _, obj in pairs(objects) do
		if obj.Parent and not skipObjects[obj] then
			local y = obj.Position.Y
			if y >= MinHeight and y <= MaxHeight then
				table.insert(accessible, obj)
			end
		end
	end
	return accessible
end

-- Вспомогательная функция: телепорт к ближайшему объекту из списка
local function teleportToNearest(accessibleList)
	if #accessibleList == 0 then return nil end
	if not humanoidRootPart or not humanoidRootPart.Parent then return nil end
	table.sort(accessibleList, function(a, b)
		local distA = (a.Position - humanoidRootPart.Position).Magnitude
		local distB = (b.Position - humanoidRootPart.Position).Magnitude
		return distA < distB
	end)
	local selected = accessibleList[1]
	teleportToPart(selected)

	-- Проверяем, собрался ли целевой объект
	task.wait(0.5)
	if selected.Parent then
		failedAttempts[selected] = (failedAttempts[selected] or 0) + 1
		if failedAttempts[selected] >= MAX_FAILED_ATTEMPTS then
			skipObjects[selected] = true
		end
	else
		-- Объект собран — очищаем счётчики
		failedAttempts[selected] = nil
		skipObjects[selected] = nil
	end
	return selected
end

-- Объединённый цикл телепортации с приоритетом
local combinedCycleRunning = false

local function ensureCombinedCycle()
	if combinedCycleRunning then return end
	combinedCycleRunning = true

	coroutine.wrap(function()
		while combinedCycleRunning do
			-- Если оба режима выключены — останавливаем цикл
			if not teleportingChests and not teleportingItems then
				combinedCycleRunning = false
				skipObjects = {}
				failedAttempts = {}
				return
			end

			-- Если персонаж мёртв или не загружен — пропускаем итерацию
			if not humanoidRootPart or not humanoidRootPart.Parent then
				wait(cooldownSeconds)
				continue
			end

			local bothEnabled = teleportingChests and teleportingItems

			if bothEnabled then
				-- Приоритет: сначала сундуки, потом предметы
				-- Объекты с лимитом попыток (skipObjects) не считаются доступными
				local chests = getAccessibleObjects({"chests"})
				if #chests > 0 then
					teleportToNearest(chests)
				else
					-- Сундуков нет (или все пропущены) — переключаемся на предметы
					local items = getAccessibleObjects({"other"})
					if #items > 0 then
						teleportToNearest(items)
					end
				end
			elseif teleportingChests then
				local chests = getAccessibleObjects({"chests"})
				if #chests > 0 then
					teleportToNearest(chests)
				end
			elseif teleportingItems then
				local items = getAccessibleObjects({"other"})
				if #items > 0 then
					teleportToNearest(items)
				end
			end

			wait(cooldownSeconds)
		end
		skipObjects = {}
		failedAttempts = {}
	end)()
end

local function createButtonWithOutline(text, size, position, color, parent)
	local button = Instance.new("TextButton")
	button.Text = text
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextStrokeColor3 = Color3.new(0,0,0)
	button.TextStrokeTransparency = 0
	button.Font = Enum.Font.Michroma
	button.BorderSizePixel = 2
	button.BorderColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Parent = parent
	return button
end

local promptAutoActivate = false -- состояние автоподтверждения Prompts

local togglePromptBtn = createButtonWithOutline("Авто сбор [OFF]", UDim2.new(0.6, 0, 0.1, 0), UDim2.new(0.345, 0, 0.65, 0), Color3.fromRGB(24, 0, 36), panel)

togglePromptBtn.MouseButton1Click:Connect(function()
	promptAutoActivate = not promptAutoActivate
	togglePromptBtn.Text = "Авто сбор " .. (promptAutoActivate and "[ON]" or "[OFF]")
	togglePromptBtn.BackgroundColor3 = promptAutoActivate and Color3.fromRGB(85, 0, 255) or Color3.fromRGB(24, 0, 36)
end)

-- Переменные для нокаипа
local noclipEnabled = false
local noclipButton
local storedObjects = {} -- таблица для хранения объектов и их исходных CanCollide

-- Отдельный цикл для авто-сбора промптов
spawn(function()
	while true do
		if promptAutoActivate then
			activateAllNearbyPrompts({"chests", "other"})
		end
		task.wait(0.3)
	end
end)

-- Ноклип режим (в Heartbeat)
runService.Heartbeat:Connect(function()
	if noclipEnabled then
		if humanoidRootPart and humanoidRootPart.Parent then
			humanoidRootPart.CanCollide = false
			local hrpPos = humanoidRootPart.Position
			for _, part in pairs(workspace:GetDescendants()) do
				if part:IsA("BasePart") then
					local distance = (part.Position - hrpPos).magnitude
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
		for obj, originalState in pairs(storedObjects) do
			if obj and obj.Parent then
				obj.CanCollide = originalState
			end
		end
		storedObjects = {}
		if humanoidRootPart and humanoidRootPart.Parent then
			humanoidRootPart.CanCollide = true
		end
	end
end)


-- Создаем кнопку для нокаипа
local function createNoclipButton()
	noclipButton = createButtonWithOutline(
		"NoClip [OFF]",
		UDim2.new(0.6, 0, 0.1, 0),
		UDim2.new(0.345, 0, 0.77, 0),
		Color3.fromRGB(0, 0, 0),
		panel
	)

	noclipButton.MouseButton1Click:Connect(function()
		noclipEnabled = not noclipEnabled
		if noclipEnabled then
			noclipButton.Text = "NoClip [ON]"
			noclipButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		else
			noclipButton.Text = "NoClip [OFF]"
			noclipButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			-- при отключении восстанавливаем CanCollide
			for obj, originalState in pairs(storedObjects) do
				if obj and obj.Parent then
					obj.CanCollide = originalState
				end
			end
			-- очищаем таблицу после восстановления
			storedObjects = {}
		end
	end)
end

createNoclipButton()

local function stopTeleportCycleChests()
	teleportingChests = false
	startChestButton.Text = "Сундуки [OFF]"
	startChestButton.BackgroundColor3 = Color3.fromRGB(38, 13, 0)
	startChestButton.BorderColor3 = Color3.new(0.666667, 0.333333, 0)
	startChestButton.TextColor3 = Color3.new(0.666667, 0.333333, 0)
	-- Если оба режима выключены, цикл остановится сам на следующей итерации
end

local function stopTeleportCycleItems()
	teleportingItems = false
	startItemButton.Text = "Предметы [OFF]"
	startItemButton.BackgroundColor3 = Color3.fromRGB(0, 49, 74)
	startItemButton.BorderColor3 = Color3.new(0, 0.666667, 1)
	startItemButton.TextColor3 = Color3.new(0, 0.666667, 1)
	-- Если оба режима выключены, цикл остановится сам на следующей итерации
end

startChestButton.MouseButton1Click:Connect(function()
	if teleportingChests then
		stopTeleportCycleChests()
	else
		teleportingChests = true
		startChestButton.Text = "Сундуки [ON]"
		startChestButton.BackgroundColor3 = Color3.fromRGB(136, 45, 0)
		startChestButton.BorderColor3 = Color3.new(1, 0.333333, 0)
		startChestButton.TextColor3 = Color3.new(1, 0.333333, 0)
		ensureCombinedCycle()
	end
end)

startItemButton.MouseButton1Click:Connect(function()
	if teleportingItems then
		stopTeleportCycleItems()
	else
		teleportingItems = true
		startItemButton.Text = "Предметы [ON]"
		startItemButton.BackgroundColor3 = Color3.fromRGB(0, 85, 255)
		startItemButton.BorderColor3 = Color3.new(0, 1, 1)
		startItemButton.TextColor3 = Color3.new(0, 1, 1)
		ensureCombinedCycle()
	end
end)

-- ТП для другого объекта
local function teleportPlayerToObject(target)
	if not target then return end
	if not humanoidRootPart or not humanoidRootPart.Parent then return end
	humanoidRootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
	humanoidRootPart.CanCollide = false
	wait(0.1)
	humanoidRootPart.CanCollide = true
end
