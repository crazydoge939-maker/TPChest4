local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

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
}

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportChestPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Создаем основную панель
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 200, 0, 175)
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

-- Кнопка переключения режима подсветки линий/подсветки
local toggleHighlightButton = Instance.new("TextButton")
toggleHighlightButton.Size = UDim2.new(0.8, 0, 0, 40)
toggleHighlightButton.Position = UDim2.new(0.1, 0, 0, 125)
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

-- Таблица для хранения активных Highlight
local activeHighlights = {}

local function clearHighlights()
	for _, hl in ipairs(activeHighlights) do
		if hl and hl.Parent then hl:Destroy() end
	end
	activeHighlights = {}
end

local function getObjectsByNames(names)
	local objects = {}
	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant:IsA("Model") and table.find(names, descendant.Name) then
			for _, child in pairs(descendant:GetChildren()) do
				if child:IsA("BasePart") then
					table.insert(objects, child)
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
					end
				end
			end
		end
	end
end

local function updateCountsAndHighlights()
	-- Обновляем счетчики
	updateChestCount()
	updateItemCount()
	-- Обновляем подсветку
	if isHighlightEnabled then
		addHighlightToObjects()
	else
		clearHighlights()
	end
end

-- Обновление данных раз в 1 секунду для снижения лагов
spawn(function()
	while true do
		updateCountsAndHighlights()
		wait(1)
	end
end)
