local ChestModels = {
	"Chest_p", "Dark Chest_p", "Light Chest_p",
}
local ItemModels = {
	"Rope_p", "Metal_p", "Wood_p", "Stone_p", "Meat_p", "Orb_p", "Cursed Orb_p", "Holy Orb_p",
}
local SpecialItems = {
	"Heart Chest_p", "Rose_p", "Skin Chest_p",
}

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local HeightMin = 113
local HeightMax = 210

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

-- Перетаскивание панели
local dragging, dragInput, dragStart, startPos
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

-- Кнопка для телепорта к особым вещам
local tpSpecialButton = Instance.new("TextButton")
tpSpecialButton.Size = UDim2.new(0.8, 0, 0, 40)
tpSpecialButton.Position = UDim2.new(0.1, 0, 0, 180)
tpSpecialButton.BackgroundColor3 = Color3.fromRGB(170, 170, 0)
tpSpecialButton.BorderSizePixel = 2
tpSpecialButton.BorderColor3 = Color3.new(1, 1, 1)
tpSpecialButton.Font = Enum.Font.SourceSansBold
tpSpecialButton.TextSize = 14
tpSpecialButton.TextScaled = true
tpSpecialButton.Text = "ТП к Особым"
tpSpecialButton.TextColor3 = Color3.new(0, 0, 0)
tpSpecialButton.Parent = panel

-- Кнопка переключения подсветки
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
local linesToItems = {}
local linesToSpecial = {} -- для особых вещей

-- Функции для линий
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

local function clearLines(linesTable)
	for _, data in ipairs(linesTable) do
		if data then
			if data.beam then data.beam:Destroy() end
			if data.attTarget then data.attTarget:Destroy() end
			if data.attPlayer then data.attPlayer:Destroy() end
		end
	end
	table.clear(linesTable)
end

local function updateLines(targets, linesTable, color)
	clearLines(linesTable)
	for _, target in ipairs(targets) do
		local attPlayer = createAttachment(humanoidRootPart)
		local attTarget = createAttachment(target)
		local beam = createBeam(attPlayer, attTarget, color)
		if not isHighlightEnabled then
			beam.Transparency = NumberSequence.new(1)
		else
			beam.Transparency = NumberSequence.new(0)
		end
		table.insert(linesTable, {beam=beam, attTarget=attTarget, attPlayer=attPlayer})
	end
end

-- Получение объектов по названиям
local function getAllObjects(names)
	local objs = {}
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and table.find(names, model.Name) then
			for _, child in pairs(model:GetChildren()) do
				if child:IsA("BasePart") then
					table.insert(objs, child)
				end
			end
		end
	end
	return objs
end

local function updateCounts()
	local chests = getAllObjects(ChestModels)
	local items = getAllObjects(ItemModels)
	chestCountLabel.Text = "Сундуков ["..#chests.."]"
	itemCountLabel.Text = "Предметов ["..#items.."]"
end

local activeHighlights = {}
local function clearHighlights()
	for _, hl in ipairs(activeHighlights) do
		if hl and hl.Parent then hl:Destroy() end
	end
	activeHighlights = {}
end
local function addHighlights(names)
	clearHighlights()
	local objs = getAllObjects(names)
	for _, obj in ipairs(objs) do
		local hl = Instance.new("Highlight")
		hl.Adornee = obj
		hl.FillColor = Color3.new(1, 0.6667, 0) -- желтый
		hl.OutlineColor = Color3.new(1, 0.6667, 0)
		hl.FillTransparency = 0.2
		hl.OutlineTransparency = 0
		hl.Parent = obj
		table.insert(activeHighlights, hl)
	end
end

local teleportingSpecial = false
local function teleportToSpecial()
	if teleportingSpecial then return end
	teleportingSpecial = true
	local specials = getAllObjects(SpecialItems)
	if #specials > 0 then
		local target = specials[math.random(1, #specials)]
		local y = target.Position.Y
		if y >= HeightMin and y <= HeightMax then
			humanoidRootPart.CFrame = CFrame.new(target.Position.X, y + 3, target.Position.Z)
		end
	end
	teleportingSpecial = false
end

local function startTeleportSpecialCycle()
	if teleportingSpecial then return end
	teleportingSpecial = true
	startChestButton.Visible = false
	stopChestButton.Visible = true
	coroutine.wrap(function()
		while teleportingSpecial do
			teleportToSpecial()
			wait(0.1)
		end
	end)()
end

local function stopTeleportSpecial()
	teleportingSpecial = false
	startChestButton.Visible = true
	stopChestButton.Visible = false
end

-- Обработчики кнопок
toggleHighlightButton.MouseButton1Click = nil
toggleHighlightButton.Activated:Connect(function()
	isHighlightEnabled = not isHighlightEnabled
	if isHighlightEnabled then
		toggleHighlightButton.Text = "[OFF] Подсветку"
		setLinesVisibility(true)
		setLinesTransparency(linesToChests, 0)
		setLinesTransparency(linesToItems, 0)
		addHighlights(ChestModels)
		addHighlights(ItemModels)
	else
		toggleHighlightButton.Text = "[ON] Подсветку"
		setLinesVisibility(false)
		setLinesTransparency(linesToChests, 1)
		setLinesTransparency(linesToItems, 1)
		clearHighlights()
	end
end)

startChestButton.Activated = nil
startChestButton.MouseButton1Click = nil
startChestButton.Activated:Connect(function()
	startTeleportChestCycle()
end)

stopChestButton.Activated = nil
stopChestButton.MouseButton1Click = nil
stopChestButton.Activated:Connect(function()
	stopTeleportChestCycle()
end)

tpSpecialButton.Activated = nil
tpSpecialButton.MouseButton1Click = nil
tpSpecialButton.Activated:Connect(function()
	teleportToSpecial()
end)

-- Циклы обновления
spawn(function()
	while true do
		updateCounts()
		if isHighlightEnabled then
			addHighlights(ChestModels)
			addHighlights(ItemModels)
		else
			clearHighlights()
		end
		wait(0.1)
	end
end)

local lastUpdate = 0
runService.RenderStepped:Connect(function()
	local now = tick()
	if now - lastUpdate >= 0.2 then
		updateLines(getAllObjects(ChestModels), linesToChests, Color3.new(1, 0.6667, 0))
		updateLines(getAllObjects(ItemModels), linesToItems, Color3.new(1, 0.6667, 0))
		lastUpdate = now
	end
end)
