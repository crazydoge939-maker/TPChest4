-- Place this script inside StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera

-- Настройки
local telepadHeightMin = 210
local telepadHeightMax = 113
local defaultCooldown = 1 -- секунды
local teleportCooldown = defaultCooldown
local lastTeleportTime = 0

-- Основные переменные
local gui -- основное окно
local toggleChests = true
local toggleOther = true

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 250)
Frame.Position = UDim2.new(0.5, -150, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Text = "Телепорт"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = Frame

-- Кнопки
local buttonChests = Instance.new("TextButton")
buttonChests.Text = "TP Сундуки"
buttonChests.Size = UDim2.new(0.5, -5, 0, 40)
buttonChests.Position = UDim2.new(0, 5, 0, 50)
buttonChests.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
buttonChests.TextColor3 = Color3.new(1,1,1)
buttonChests.Parent = Frame

local buttonOther = Instance.new("TextButton")
buttonOther.Text = "TP Предметы"
buttonOther.Size = UDim2.new(0.5, -5, 0, 40)
buttonOther.Position = UDim2.new(0.5, 0, 0, 50)
buttonOther.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
buttonOther.TextColor3 = Color3.new(1,1,1)
buttonOther.Parent = Frame

-- Кулдаун
local cooldownLabel = Instance.new("TextLabel")
cooldownLabel.Text = "Кулдаун (сек):"
cooldownLabel.Size = UDim2.new(0.5, -5, 0, 20)
cooldownLabel.Position = UDim2.new(0,5,0,100)
cooldownLabel.BackgroundTransparency = 1
cooldownLabel.TextColor3 = Color3.new(1,1,1)
cooldownLabel.Font = Enum.Font.SourceSans
cooldownLabel.TextSize = 14
cooldownLabel.Parent = Frame

local cooldownTextBox = Instance.new("TextBox")
cooldownTextBox.Text = tostring(teleportCooldown)
cooldownTextBox.Size = UDim2.new(0.5, -5, 0, 20)
cooldownTextBox.Position = UDim2.new(0.5, 0, 0, 100)
cooldownTextBox.BackgroundColor3 = Color3.fromRGB(70,70,70)
cooldownTextBox.TextColor3 = Color3.new(1,1,1)
cooldownTextBox.Font = Enum.Font.SourceSans
cooldownTextBox.TextSize = 14
cooldownTextBox.Parent = Frame

-- Координаты игрока
local coordsLabel = Instance.new("TextLabel")
coordsLabel.Text = "Координаты: "
coordsLabel.Size = UDim2.new(1, -10, 0, 20)
coordsLabel.Position = UDim2.new(0, 5, 0, 130)
coordsLabel.BackgroundTransparency = 1
coordsLabel.TextColor3 = Color3.new(1,1,1)
coordsLabel.Font = Enum.Font.SourceSans
coordsLabel.TextSize = 14
coordsLabel.Parent = Frame

-- Счетчик
local countLabel = Instance.new("TextLabel")
countLabel.Text = "Модели: 0"
countLabel.Size = UDim2.new(1, -10, 0, 20)
countLabel.Position = UDim2.new(0, 5, 0, 155)
countLabel.BackgroundTransparency = 1
countLabel.TextColor3 = Color3.new(1,1,1)
countLabel.Font = Enum.Font.SourceSans
countLabel.TextSize = 14
countLabel.Parent = Frame

-- Включение/выключение
local toggleChestsBtn = buttonChests
local toggleOtherBtn = buttonOther

local function toggleModel(typeName)
	if typeName == "chests" then
		toggleChests = not toggleChests
		toggleChestsBtn.BackgroundColor3 = toggleChests and Color3.fromRGB(70, 130, 180) or Color3.fromRGB(150, 50, 50)
	elseif typeName == "other" then
		toggleOther = not toggleOther
		toggleOtherBtn.BackgroundColor3 = toggleOther and Color3.fromRGB(70, 130, 180) or Color3.fromRGB(150, 50, 50)
	end
end

buttonChests.MouseButton1Click:Connect(function()
	toggleModel("chests")
end)

buttonOther.MouseButton1Click:Connect(function()
	toggleModel("other")
end)

-- Обработчик изменения кулдауна
cooldownTextBox.FocusLost:Connect(function()
	local num = tonumber(cooldownTextBox.Text)
	if num and num >= 0 then
		teleportCooldown = num
	else
		cooldownTextBox.Text = tostring(teleportCooldown)
	end
end)

-- Перемещение панели
local dragging = false
local dragInput, dragStart, startPos

Frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position
	end
end)

Frame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

Frame.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
		local delta = input.Position - dragStart
		Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Функция поиска моделей
local function findModels()
	local models = {}
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and (obj.Name == "chests" or obj.Name == "other") then
			table.insert(models, obj)
		end
	end
	return models
end

-- Создание BillboardGui над моделью
local function createBillboard(model)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.Adornee = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not billboard.Adornee then return end
	billboard.AlwaysOnTop = true
	billboard.Parent = model

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1,1,1)
	textLabel.TextScaled = true
	textLabel.Text = model.Name
	textLabel.Parent = billboard
end

-- Обновляем счетчик и координаты
local function updateInfo()
	local models = findModels()
	countLabel.Text = "Модели: " .. tostring(#models)
	local pos = character.HumanoidRootPart.Position
	coordsLabel.Text = string.format("Координаты: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
end

-- Постоянный телепорт
RunService.Heartbeat:Connect(function()
	updateInfo()
	local now = tick()
	if now - lastTeleportTime >= teleportCooldown then
		local models = findModels()
		local candidates = {}
		for _, model in pairs(models) do
			if (model.Name == "chests" and toggleChests) or (model.Name == "other" and toggleOther) then
				table.insert(candidates, model)
			end
		end
		if #candidates > 0 then
			local targetModel = candidates[math.random(1, #candidates)]
			local targetPart = targetModel.PrimaryPart or targetModel:FindFirstChildWhichIsA("BasePart")
			if targetPart then
				local pos = targetPart.Position
				-- Ограничение по высоте
				if pos.Y < telepadHeightMin then pos = Vector3.new(pos.X, telepadHeightMin, pos.Z) end
				if pos.Y > telepadHeightMax then pos = Vector3.new(pos.X, telepadHeightMax, pos.Z) end
				character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
				lastTeleportTime = now
			end
		end
	end
end)

-- Создаем BillboardGui над моделями
for _, model in pairs(findModels()) do
	createBillboard(model)
end

-- Обновление каждые 1 секунду
while true do
	wait(1)
	updateInfo()
end
