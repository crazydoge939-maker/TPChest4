local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

local HeightMin = 90
local HeightMax = 160

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

-- Таблица для хранения активных Highlight
local activeHighlights = {}

local function clearHighlights()
	for _, hl in ipairs(activeHighlights) do
		if hl and hl.Parent then hl:Destroy() end
	end
	activeHighlights = {}
end

local function updatePlayerCoordinates()
	local pos = humanoidRootPart.Position
	coordsLabel.Text = string.format("Координаты [X=%.1f, Y=%.1f, Z=%.1f]", pos.X, pos.Y, pos.Z)
end

local function getObjectsByNames(names)
	local objects = {}
	-- Путь для сундуков
	local npcDropsFolder = workspace:FindFirstChild("NPCDrops")
	if npcDropsFolder then
		local itemsFolder = npcDropsFolder:FindFirstChild("Items")
		if itemsFolder then
			for _, model in pairs(itemsFolder:GetChildren()) do
				if model:IsA("Model") and table.find(names, model.Name) then
					for _, child in pairs(model:GetChildren()) do
						if child:IsA("BasePart") then
							table.insert(objects, child)
						end
					end
				end
			end
		end
	end
	-- Путь для предметов
	local itemsFolder = workspace:FindFirstChild("Items")
	if itemsFolder then
		for _, model in pairs(itemsFolder:GetChildren()) do
			if model:IsA("Model") and table.find(names, model.Name) then
				for _, child in pairs(model:GetChildren()) do
					if child:IsA("BasePart") then
						table.insert(objects, child)
					end
				end
			end
		end
	end
	return objects
end

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

local function setupClickToTeleport(part)
	if part then
		local clickDetector = part:FindFirstChildOfClass("ClickDetector")
		if not clickDetector then
			clickDetector = Instance.new("ClickDetector")
			clickDetector.Parent = part
		end
		clickDetector.MouseClick:Connect(function()
			if tpModeActive then
				local y = part.Position.Y
				if y >= HeightMin and y <= HeightMax then
					humanoidRootPart.CFrame = CFrame.new(part.Position.X, y + 3, part.Position.Z)
				end
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

						-- Обработчик клика для телепорта
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
				local y = chest.Position.Y
				if y >= HeightMin and y <= HeightMax then
					table.insert(accessibleChests, chest)
				end
			end
			if #accessibleChests > 0 then
				local selectedChest = accessibleChests[math.random(1, #accessibleChests)]
				local y = selectedChest.Position.Y
				if y >= HeightMin and y <= HeightMax then
					humanoidRootPart.CFrame = CFrame.new(selectedChest.Position.X, y + 3, selectedChest.Position.Z)
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

-- Обработчики кнопок
startChestButton.MouseButton1Click:Connect(startTeleportChestCycle)
stopChestButton.MouseButton1Click:Connect(stopTeleportChestCycle)

tpItemsButton.MouseButton1Click:Connect(function()
	tpModeActive = not tpModeActive
	if tpModeActive then
		tpItemsButton.Text = "Стоп [Предметам]"
	else
		tpItemsButton.Text = "Старт [Предметам]"
	end
end)

toggleHighlightButton.MouseButton1Click:Connect(function()
	isHighlightEnabled = not isHighlightEnabled
	if isHighlightEnabled then
		toggleHighlightButton.Text = "[OFF] Подсветку"
		addHighlightToObjects()
	else
		toggleHighlightButton.Text = "[ON] Подсветку"
		clearHighlights()
	end
end)

-- Обновление данных
spawn(function()
	while true do
		updateChestCount()
		updateItemCount()
		updatePlayerCoordinates()
		if isHighlightEnabled then
			addHighlightToObjects()
		else
			clearHighlights()
		end
		wait(0.1)
	end
end)
