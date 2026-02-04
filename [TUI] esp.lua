local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local HeightMin = 113
local HeightMax = 210

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportChestPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Основная панель
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 200, 0, 265)
panel.Position = UDim2.new(0.5, -100, 0.5, -150)
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
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.BorderSizePixel = 0
title.Text = "AUTO FARM"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextScaled = true
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = panel

-- Кнопки [Старт / Стоп]
local startChestButton = Instance.new("TextButton")
startChestButton.Size = UDim2.new(0.8, 0, 0, 40)
startChestButton.Position = UDim2.new(0.1, 0, 0, 130)
startChestButton.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
startChestButton.BorderSizePixel = 2
startChestButton.BorderColor3 = Color3.new(1, 1, 1)
startChestButton.Font = Enum.Font.SourceSansBold
startChestButton.TextSize = 16
startChestButton.TextScaled = true
startChestButton.Text = "Старт [Сундуки]"
startChestButton.TextColor3 = Color3.new(1, 1, 1)
startChestButton.Parent = panel

local stopChestButton = Instance.new("TextButton")
stopChestButton.Size = UDim2.new(0.8, 0, 0, 40)
stopChestButton.Position = UDim2.new(0.1, 0, 0, 130)
stopChestButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
stopChestButton.BorderSizePixel = 2
stopChestButton.BorderColor3 = Color3.new(1, 1, 1)
stopChestButton.Font = Enum.Font.SourceSansBold
stopChestButton.TextSize = 16
stopChestButton.TextScaled = true
stopChestButton.Text = "Стоп [Сундуки]"
stopChestButton.TextColor3 = Color3.new(1, 1, 1)
stopChestButton.Parent = panel
stopChestButton.Visible = false

-- Кнопка подсветки линий/подсветки
local toggleHighlightButton = Instance.new("TextButton")
toggleHighlightButton.Size = UDim2.new(0.8, 0, 0, 40)
toggleHighlightButton.Position = UDim2.new(0.1, 0, 0, 225)
toggleHighlightButton.BackgroundColor3 = Color3.fromRGB(0, 0, 170)
toggleHighlightButton.BorderSizePixel = 2
toggleHighlightButton.BorderColor3 = Color3.new(1, 1, 1)
toggleHighlightButton.Font = Enum.Font.SourceSansBold
toggleHighlightButton.TextSize = 14
toggleHighlightButton.TextScaled = true
toggleHighlightButton.Text = "[OFF] Подсветку"
toggleHighlightButton.TextColor3 = Color3.new(1, 1, 1)
toggleHighlightButton.Parent = panel

local isHighlightEnabled = true

-- Метки
local chestCountLabel = Instance.new("TextLabel")
chestCountLabel.Size = UDim2.new(0, 80, 0, 80)
chestCountLabel.Position = UDim2.new(0, 10, 0, 40)
chestCountLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
chestCountLabel.BorderSizePixel = 0
chestCountLabel.Text = "Сундуков [0]"
chestCountLabel.Font = Enum.Font.SourceSans
chestCountLabel.TextSize = 16
chestCountLabel.TextScaled = true
chestCountLabel.TextColor3 = Color3.new(1, 1, 1)
chestCountLabel.Parent = panel

local itemCountLabel = Instance.new("TextLabel")
itemCountLabel.Size = UDim2.new(0, 80, 0, 80)
itemCountLabel.Position = UDim2.new(0, 110, 0, 40)
itemCountLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
itemCountLabel.BorderSizePixel = 0
itemCountLabel.Text = "Предметов [0]"
itemCountLabel.Font = Enum.Font.SourceSans
itemCountLabel.TextSize = 16
itemCountLabel.TextScaled = true
itemCountLabel.TextColor3 = Color3.new(1, 1, 1)
itemCountLabel.Parent = panel

local coordsLabel = Instance.new("TextLabel")
coordsLabel.Size = UDim2.new(1, -20, 0, 30)
coordsLabel.Position = UDim2.new(0, 10, 0, 180)
coordsLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
coordsLabel.BorderSizePixel = 0
coordsLabel.Text = "Координаты [X=0, Y=0, Z=0]"
coordsLabel.Font = Enum.Font.SourceSans
coordsLabel.TextSize = 14
coordsLabel.TextScaled = true
coordsLabel.TextColor3 = Color3.new(1, 1, 1)
coordsLabel.Parent = panel

-- Таблицы линий
local linesToChests = {}
local linesToOther = {}

-- Создание BillboardGui над моделями
local function createBillboardGui(parent, text)
	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = parent
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Parent = billboard
	billboard.Parent = parent
	return billboard
end

local highlightInstances = {}

local function clearHighlights()
	for _, hl in ipairs(highlightInstances) do
		if hl and hl.Parent then hl:Destroy() end
	end
	highlightInstances = {}
end

local function addBillboardToObjects(names)
	clearHighlights()
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and table.find(names, model.Name) then
			for _, part in pairs(model:GetChildren()) do
				if part:IsA("BasePart") then
					local billboard = createBillboardGui(part, model.Name)
					table.insert(highlightInstances, billboard)
				end
			end
		end
	end
end

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
	local chests = getAllObjectsByNames({"chests"})
	chestCountLabel.Text = "Сундуков [" .. #chests .. "]"
end

local function updateItemCount()
	local items = getAllObjectsByNames({"other"})
	itemCountLabel.Text = "Предметов [" .. #items .. "]"
end

local function getClosestObject(objects)
	local minDist = math.huge
	local closest = nil
	for _, obj in ipairs(objects) do
		local dist = (humanoidRootPart.Position - obj.Position).Magnitude
		if dist < minDist then
			minDist = dist
			closest = obj
		end
	end
	return closest
end

local autoActivateProximityPrompt = true

local function setProximityPromptDelay(prompts, delay)
	for _, prompt in pairs(prompts) do
		if prompt:IsA("ProximityPrompt") then
			prompt.HoldDuration = delay
		end
	end
end

local function getAllProximityPrompts()
	local prompts = {}
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			table.insert(prompts, obj)
		end
	end
	return prompts
end

local function setupProximityPrompts()
	local prompts = getAllProximityPrompts()
	setProximityPromptDelay(prompts, 0)
end

setupProximityPrompts()

-- Автоматическая активация ProximityPrompt
local function autoActivatePrompt()
	if autoActivateProximityPrompt then
		local prompts = getAllProximityPrompts()
		local closestObj = getClosestObject(prompts)
		if closestObj then
			closestObj:InputHoldBegin()
		end
	end
end

-- Обработка кнопки включения/выключения автоактивации
local autoActivateButton = Instance.new("TextButton")
autoActivateButton.Size = UDim2.new(0.8, 0, 0, 40)
autoActivateButton.Position = UDim2.new(0.1, 0, 0, 270)
autoActivateButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
autoActivateButton.BorderSizePixel = 2
autoActivateButton.BorderColor3 = Color3.new(1,1,1)
autoActivateButton.Font = Enum.Font.SourceSansBold
autoActivateButton.TextSize = 14
autoActivateButton.TextScaled = true
autoActivateButton.Text = "Авто активация: ВКЛ"
autoActivateButton.TextColor3 = Color3.new(1,1,1)
autoActivateButton.Parent = panel

local autoActivateEnabled = true

autoActivateButton.MouseButton1Click:Connect(function()
	autoActivateEnabled = not autoActivateEnabled
	if autoActivateEnabled then
		autoActivateButton.Text = "Авто активация: ВКЛ"
	else
		autoActivateButton.Text = "Авто активация: ВЫКЛ"
	end
end)

-- Обновление координат
runService.RenderStepped:Connect(function()
	local pos = humanoidRootPart.Position
	coordsLabel.Text = string.format("Координаты [X=%.1f, Y=%.1f, Z=%.1f]", pos.X, pos.Y, pos.Z)
end)

-- Основной цикл для линий и подсветки
spawn(function()
	while true do
		updateChestCount()
		updateItemCount()
		if isHighlightEnabled then
			addBillboardToObjects({"chests", "other"})
		else
			clearHighlights()
		end
		wait(0.1)
	end
end)

-- Обновление линий (заменяем на BillboardGui)
local function updateBillboards(names)
	-- Очистка старых
	clearHighlights()
	-- Создаем новые BillboardGui
	addBillboardToObjects(names)
end

-- Основной цикл для обновления
spawn(function()
	while true do
		updateChestCount()
		updateItemCount()
		if isHighlightEnabled then
			addBillboardToObjects({"chests", "other"})
		else
			clearHighlights()
		end
		wait(0.2)
	end
end)

-- Кулдаун (КД) и текстбокс для установки времени
local cooldownSeconds = 5 -- начальное значение
local cooldownBox = Instance.new("TextBox")
cooldownBox.Size = UDim2.new(0, 50, 0, 30)
cooldownBox.Position = UDim2.new(0.5, -25, 0, 230)
cooldownBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
cooldownBox.BorderSizePixel = 2
cooldownBox.Text = tostring(cooldownSeconds)
cooldownBox.Font = Enum.Font.SourceSans
cooldownBox.TextSize = 14
cooldownBox.TextColor3 = Color3.new(1,1,1)
cooldownBox.Parent = panel

-- Обработчик изменения
cooldownBox.FocusLost:Connect(function()
	local val = tonumber(cooldownBox.Text)
	if val then
		cooldownSeconds = val
	end
end)

local teleporting = false

local function teleportToPart(part)
	if not part then return end
	humanoidRootPart.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
	-- Ноулип
	humanoidRootPart.CanCollide = false
	wait(0.1)
	humanoidRootPart.CanCollide = true
end

local function startTeleportCycle()
	if teleporting then return end
	teleporting = true
	startChestButton.Visible = false
	stopChestButton.Visible = true
	coroutine.wrap(function()
		while teleporting do
			local chests = getAllObjectsByNames({"chests"})
			local accessibleChests = {}
			for _, chest in pairs(chests) do
				local y = chest.Position.Y
				if y >= HeightMin and y <= HeightMax then
					table.insert(accessibleChests, chest)
				end
			end
			if #accessibleChests > 0 then
				local selected = accessibleChests[math.random(1, #accessibleChests)]
				teleportToPart(selected)
			end
			wait(cooldownSeconds)
		end
	end)()
end

local function stopTeleportCycle()
	teleporting = false
	startChestButton.Visible = true
	stopChestButton.Visible = false
end

startChestButton.MouseButton1Click:Connect(startTeleportCycle)
stopChestButton.MouseButton1Click:Connect(stopTeleportCycle)

-- Обработка подсветки
toggleHighlightButton.MouseButton1Click:Connect(function()
	isHighlightEnabled = not isHighlightEnabled
	if isHighlightEnabled then
		toggleHighlightButton.Text = "[OFF] Подсветку"
		addBillboardToObjects({"chests", "other"})
	else
		toggleHighlightButton.Text = "[ON] Подсветку"
		clearHighlights()
	end
end)

-- ТП для других моделей (пример)
local function teleportPlayerToObject(target)
	if not target then return end
	humanoidRootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
	humanoidRootPart.CanCollide = false
	wait(0.1)
	humanoidRootPart.CanCollide = true
end

-- Возможность ТП для другого объекта
-- Например, при нажатии на кнопку или команда, вызывайте:
-- teleportPlayerToObject(someObject)

-- Отключение коллизии ближайшего объекта
runService.Heartbeat:Connect(function()
	local allParts = {}
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("BasePart") then
			table.insert(allParts, model)
		end
	end
	local closestPart = getClosestObject(allParts)
	if closestPart then
		closestPart.CanCollide = false
	end
end)
