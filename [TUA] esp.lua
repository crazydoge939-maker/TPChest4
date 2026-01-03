local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

local HeightMin = 113
local HeightMax = 210

-- Списки названий моделей
local ChestModels = {"Chest"}
local ItemModels = {	
	"Rainbow  Star",
	"Moon Fragment",
	"Meat",
	"Rotting Meat",
	"Heart",
	"Eye",
	"Mysterious Shadow",

	"Four-Leaf Clover",
	"Tomato",
	"Cocoa Bean",
	"Onion",

	"Metal Ore",
	"Gold Ore",
	"Diamond Ore",
}

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportChestPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Создаем основную панель
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 200, 0, 265)
panel.Position = UDim2.new(0.5, -100, 0.5, -150)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panel.BorderSizePixel = 4
panel.BorderColor3 = Color3.fromRGB(255, 255, 255)
panel.Parent = screenGui

-- Сделать панель перетаскиваемой
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

-- Кнопки [Сундуки]
local startChestButton = Instance.new("TextButton")
startChestButton.Size = UDim2.new(0.45, 0, 0, 40)
startChestButton.Position = UDim2.new(0.035, 0, 0, 130)
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
stopChestButton.Size = UDim2.new(0.45, 0, 0, 40)
stopChestButton.Position = UDim2.new(0.035, 0, 0, 130)
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

-- Кнопки [Предметам]
local tpItemsButton = Instance.new("TextButton")
tpItemsButton.Size = UDim2.new(0.45, 0, 0, 40)
tpItemsButton.Position = UDim2.new(0.515, 0, 0, 130)
tpItemsButton.BackgroundColor3 = Color3.fromRGB(0, 170, 170)
tpItemsButton.BorderSizePixel = 2
tpItemsButton.BorderColor3 = Color3.new(1, 1, 1)
tpItemsButton.Font = Enum.Font.SourceSansBold
tpItemsButton.TextSize = 14
tpItemsButton.TextScaled = true
tpItemsButton.Text = "Старт [Предметам]"
tpItemsButton.TextColor3 = Color3.new(1,1,1)
tpItemsButton.Parent = panel

local tpModeActive = false -- режим телепортации к предметам

-- Кнопка переключения режима подсветки линий/подсветки
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

local isHighlightEnabled = true -- состояние подсветки

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

-- Храним линии
local linesToChests = {}
local linesToItems = {}

-- Функции для получения объектов по спискам названий
local function getObjectsByNames(names)
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

-- Создаем Attachment и Beam
local function createAttachment(parent)
	local att = Instance.new("Attachment")
	att.Parent = parent
	return att
end

local function createBeam(att0, att1, color)
	local beam = Instance.new("Beam")
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.Color = ColorSequence.new(color)
	beam.Width0 = 0.2
	beam.Width1 = 0.2
	beam.FaceCamera = true
	beam.Parent = att0.Parent
	return beam
end

-- Удаление всех линий
local function clearAllLines(linesTable)
	for _, lineData in ipairs(linesTable) do
		if lineData then
			if lineData.beam then lineData.beam:Destroy() end
			if lineData.attachmentTarget then lineData.attachmentTarget:Destroy() end
			if lineData.attachmentPlayer then lineData.attachmentPlayer:Destroy() end
		end
	end
	table.clear(linesTable)
end

-- Обновление линий
local function updateLines(targets, linesTable, color)
	clearAllLines(linesTable)
	for _, target in ipairs(targets) do
		local attPlayer = createAttachment(humanoidRootPart)
		local attTarget = createAttachment(target)
		local beam = createBeam(attPlayer, attTarget, color)
		if not isHighlightEnabled then
			beam.Transparency = NumberSequence.new(1)
		else
			beam.Transparency = NumberSequence.new(0)
		end
		table.insert(linesTable, {
			beam = beam,
			attachmentTarget = attTarget,
			attachmentPlayer = attPlayer
		})
	end
end

-- Обновление координат
runService.RenderStepped:Connect(function()
	local pos = humanoidRootPart.Position
	coordsLabel.Text = string.format("Координаты                                                                                      [X=%.1f, Y=%.1f, Z=%.1f]", pos.X, pos.Y, pos.Z)
end)

-- Получение всех объектов по спискам моделей
local function getAllObjectsByModels(modelNames)
	return getObjectsByNames(modelNames)
end

local function updateChestCount()
	local chests = getAllObjectsByModels(ChestModels)
	chestCountLabel.Text = "Сундуков [" .. #chests .. "]"
end

local function updateItemCount()
	local items = getAllObjectsByModels(ItemModels)
	itemCountLabel.Text = "Предметов [" .. #items .. "]"
end

local activeHighlights = {}

local function clearHighlights()
	for _, hl in ipairs(activeHighlights) do
		if hl and hl.Parent then hl:Destroy() end
	end
	activeHighlights = {}
end

-- Функция телепортации к объекту
local function teleportToObject(objectPart)
	local y = objectPart.Position.Y
	if y >= HeightMin and y <= HeightMax then
		humanoidRootPart.CFrame = CFrame.new(objectPart.Position.X, y + 3, objectPart.Position.Z)
	end
end

-- Обработка клика по объекту
local function setupClickToTeleport(part)
	if part then
		local clickDetector = part:FindFirstChildOfClass("ClickDetector")
		if not clickDetector then
			clickDetector = Instance.new("ClickDetector")
			clickDetector.Parent = part
		end
		clickDetector.MouseClick:Connect(function()
			if tpModeActive then
				teleportToObject(part)
			end
		end)
	end
end

local function addHighlightToObjects()
	clearHighlights()
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") then
			local name = model.Name
			if table.find(ChestModels, name) or table.find(ItemModels, name) then
				for _, part in pairs(model:GetChildren()) do
					if part:IsA("BasePart") then
						local highlight = Instance.new("Highlight")
						highlight.Adornee = part
						if table.find(ChestModels, name) then
							highlight.FillColor = Color3.new(1, 0.6667, 0)
							highlight.OutlineColor = Color3.new(1, 0.3333, 0)
						elseif table.find(ItemModels, name) then
							highlight.FillColor = Color3.new(0, 0, 1)
							highlight.OutlineColor = Color3.new(0, 1, 1)
						end
						highlight.FillTransparency = 0.2
						highlight.OutlineTransparency = 0
						highlight.Parent = part
						table.insert(activeHighlights, highlight)

						-- Добавляем к объекту обработчик клика для телепорта
						setupClickToTeleport(part)
					end
				end
			end
		end
	end
end

local teleportingChest = false

local function startTeleportChestCycle()
	if teleportingChest then return end
	teleportingChest = true
	startChestButton.Visible = false
	stopChestButton.Visible = true

	coroutine.wrap(function()
		while teleportingChest do
			local chests = getAllObjectsByModels(ChestModels)
			local accessibleChests = {}
			for _, chest in pairs(chests) do
				local accessible = false
				for _, part in pairs(chest:GetChildren()) do
					if part:IsA("BasePart") then
						local y = part.Position.Y
						if y >= HeightMin and y <= HeightMax then
							accessible = true
							break
						end
					end
				end
				if accessible then table.insert(accessibleChests, chest) end
			end
			if #accessibleChests > 0 then
				local selectedChest = accessibleChests[math.random(1, #accessibleChests)]
				for _, part in pairs(selectedChest:GetChildren()) do
					if part:IsA("BasePart") then
						local y = part.Position.Y
						if y >= HeightMin and y <= HeightMax then
							humanoidRootPart.CFrame = CFrame.new(part.Position.X, y + 3, part.Position.Z)
							break
						end
					end
				end
			end
			wait(0.1)
		end
	end)()
end

local function stopTeleportChestCycle()
	teleportingChest = false
	startChestButton.Visible = true
	stopChestButton.Visible = false
end

local function setLinesVisibility(enabled)
	for _, lineData in ipairs(linesToChests) do
		if lineData and lineData.beam then
			lineData.beam.Enabled = enabled
		end
	end
	for _, lineData in ipairs(linesToItems) do
		if lineData and lineData.beam then
			lineData.beam.Enabled = enabled
		end
	end
end

local function setLinesTransparency(linesTable, transparencyValue)
	for _, lineData in ipairs(linesTable) do
		if lineData and lineData.beam then
			lineData.beam.Transparency = NumberSequence.new(transparencyValue)
		end
	end
end

-- Обработка переключателя подсветки
toggleHighlightButton.MouseButton1Click:Connect(function()
	isHighlightEnabled = not isHighlightEnabled
	if isHighlightEnabled then
		toggleHighlightButton.Text = "[OFF] Подсветку"
		setLinesVisibility(true)
		setLinesTransparency(linesToChests, 0)
		setLinesTransparency(linesToItems, 0)
		addHighlightToObjects()
	else
		toggleHighlightButton.Text = "[ON] Подсветку"
		setLinesVisibility(false)
		setLinesTransparency(linesToChests, 1)
		setLinesTransparency(linesToItems, 1)
		clearHighlights()
	end
end)

-- Новая кнопка для режима ТП к предметам
tpItemsButton.MouseButton1Click:Connect(function()
	tpModeActive = not tpModeActive
	if tpModeActive then
		tpItemsButton.Text = "Стоп [Предметам]"
	else
		tpItemsButton.Text = "Старт [Предметам]"
	end
end)

startChestButton.MouseButton1Click:Connect(startTeleportChestCycle)
stopChestButton.MouseButton1Click:Connect(stopTeleportChestCycle)

-- Обновление и подсветка
spawn(function()
	while true do
		updateChestCount()
		updateItemCount()
		if isHighlightEnabled then
			addHighlightToObjects()
		else
			clearHighlights()
		end
		wait(0.1)
	end
end)

-- Обновление линий
local lastUpdateTime = 0
runService.RenderStepped:Connect(function()
	local now = tick()
	if now - lastUpdateTime >= 0.2 then
		local chests = getObjectsByNames(ChestModels)
		local items = getObjectsByNames(ItemModels)
		updateLines(chests, linesToChests, Color3.new(1, 0.3333, 0))
		updateLines(items, linesToItems, Color3.new(0, 1, 1))
		lastUpdateTime = now
	end
end)
