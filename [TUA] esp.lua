local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

-- Списки названий моделей
local ChestModels = {"Chest"}
local ItemModels = {	
	"Rainbow Star",
	"Moon Fragment",
	"Water Sphereite",	
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

-- Кнопка переключения режима отображения названий
local toggleDisplayButton = Instance.new("TextButton")
toggleDisplayButton.Size = UDim2.new(0.8, 0, 0, 40)
toggleDisplayButton.Position = UDim2.new(0.1, 0, 0, 125)
toggleDisplayButton.BackgroundColor3 = Color3.fromRGB(0, 0, 170)
toggleDisplayButton.BorderSizePixel = 2
toggleDisplayButton.BorderColor3 = Color3.new(1, 1, 1)
toggleDisplayButton.Font = Enum.Font.SourceSansBold
toggleDisplayButton.TextSize = 14
toggleDisplayButton.TextScaled = true
toggleDisplayButton.Text = "[OFF] Названия"
toggleDisplayButton.TextColor3 = Color3.new(1, 1, 1)
toggleDisplayButton.Parent = panel

local isDisplayNames = false -- состояние отображения названий

-- Метки для счетчиков
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

-- Таблица для хранения созданных BillboardGui
local activeBillboards = {}

local function clearBillboards()
	for _, gui in ipairs(activeBillboards) do
		if gui and gui.Parent then
			gui:Destroy()
		end
	end
	activeBillboards = {}
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

local function addBillboardGuiToObjects()
	clearBillboards()

	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant:IsA("Model") then
			local name = descendant.Name
			if table.find(ChestModels, name) or table.find(ItemModels, name) then
				for _, part in pairs(descendant:GetChildren()) do
					if part:IsA("BasePart") then
						-- Создаем BillboardGui
						local billboardGui = Instance.new("BillboardGui")
						billboardGui.Size = UDim2.new(0, 100, 0, 40)
						billboardGui.Adornee = part
						billboardGui.AlwaysOnTop = true
						billboardGui.Parent = part

						-- Создаем текстовую метку
						local textLabel = Instance.new("TextLabel")
						textLabel.Size = UDim2.new(1, 0, 1, 0)
						textLabel.BackgroundTransparency = 1
						textLabel.Text = name
						if table.find(ChestModels, name) then
							textLabel.TextColor3 = Color3.fromRGB(255, 165, 0) -- оранжевый для сундуков
						else
							textLabel.TextColor3 = Color3.fromRGB(85, 255, 255) -- синий для предметов
						end
						textLabel.TextScaled = true
						textLabel.Font = Enum.Font.SourceSansBold
						textLabel.Parent = billboardGui

						table.insert(activeBillboards, billboardGui)
					end
				end
			end
		end
	end
end

local function updateDisplay()
	-- Обновляем счетчики
	updateChestCount()
	updateItemCount()

	-- Обновляем отображение названий
	if isDisplayNames then
		addBillboardGuiToObjects()
	else
		clearBillboards()
	end
end

-- Обновление данных раз в 1 секунду
spawn(function()
	while true do
		updateDisplay()
		wait(3)
	end
end)

-- Переключатель отображения названий
toggleDisplayButton.MouseButton1Click:Connect(function()
	isDisplayNames = not isDisplayNames
	if isDisplayNames then
		toggleDisplayButton.Text = "[ON] Названия"
		addBillboardGuiToObjects()
	else
		toggleDisplayButton.Text = "[OFF] Названия"
		clearBillboards()
	end
end)
