-- Вставьте этот скрипт в StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Настройки
local teleportEnabled = false
local teleportCooldown = 5 -- по умолчанию 5 секунд
local lastTeleportTime = 0

local minY = 110
local maxY = 220

-- Создаем GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "TeleportGUI"

-- Создаем панель
local panel = Instance.new("Frame", screenGui)
panel.Size = UDim2.new(0, 300, 0, 200)
panel.Position = UDim2.new(0, 50, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panel.BorderSizePixel = 2
panel.Active = true

-- Украшаем панель
local UICorner = Instance.new("UICorner", panel)
local UIStroke = Instance.new("UIStroke", panel)
UIStroke.Color = Color3.new(1, 1, 1)
UIStroke.Thickness = 2

-- Кнопка "TP Сундуки"
local btnChests = Instance.new("TextButton", panel)
btnChests.Size = UDim2.new(0, 130, 0, 30)
btnChests.Position = UDim2.new(0, 10, 0, 10)
btnChests.Text = "TP Сундуки"
btnChests.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnChests.BorderSizePixel = 0

-- Кнопка "TP Предметы"
local btnOther = Instance.new("TextButton", panel)
btnOther.Size = UDim2.new(0, 130, 0, 30)
btnOther.Position = UDim2.new(0, 160, 0, 10)
btnOther.Text = "TP Предметы"
btnOther.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnOther.BorderSizePixel = 0

-- Чекбокс для включения/выключения телепортации
local toggleButton = Instance.new("TextButton", panel)
toggleButton.Size = UDim2.new(0, 270, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 50)
toggleButton.Text = "Телепортация: ВЫКЛ"
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.BorderSizePixel = 0

-- Настраиваем кд через TextBox
local cooldownLabel = Instance.new("TextLabel", panel)
cooldownLabel.Size = UDim2.new(0, 150, 0, 20)
cooldownLabel.Position = UDim2.new(0, 10, 0, 90)
cooldownLabel.Text = "КД (сек):"
cooldownLabel.TextColor3 = Color3.new(1,1,1)
cooldownLabel.BackgroundTransparency = 1

local cooldownInput = Instance.new("TextBox", panel)
cooldownInput.Size = UDim2.new(0, 100, 0, 20)
cooldownInput.Position = UDim2.new(0, 160, 0, 90)
cooldownInput.Text = tostring(teleportCooldown)
cooldownInput.TextColor3 = Color3.new(1,1,1)
cooldownInput.BackgroundColor3 = Color3.fromRGB(50,50,50)
cooldownInput.BorderSizePixel = 0

-- Координаты игрока
local coordsLabel = Instance.new("TextLabel", panel)
coordsLabel.Size = UDim2.new(0, 270, 0, 40)
coordsLabel.Position = UDim2.new(0, 10, 0, 120)
coordsLabel.TextColor3 = Color3.new(1,1,1)
coordsLabel.BackgroundTransparency = 1
coordsLabel.Text = "Координаты: "

-- Счетчик моделей
local countLabel = Instance.new("TextLabel", panel)
countLabel.Size = UDim2.new(0, 270, 0, 20)
countLabel.Position = UDim2.new(0, 10, 0, 160)
countLabel.TextColor3 = Color3.new(1,1,1)
countLabel.BackgroundTransparency = 1
countLabel.Text = "Модели: 0"

-- Переменная для текущего включения/выключения
local tpStatus = false

toggleButton.MouseButton1Click:Connect(function()
	tpStatus = not tpStatus
	if tpStatus then
		toggleButton.Text = "Телепортация: ВКЛ"
	else
		toggleButton.Text = "Телепортация: ВЫКЛ"
	end
end)

-- Обработка кнопок для переключения моделей
local currentTarget = "chests" -- по умолчанию
btnChests.MouseButton1Click:Connect(function()
	currentTarget = "chests"
end)
btnOther.MouseButton1Click:Connect(function()
	currentTarget = "other"
end)

-- Обновление кд
cooldownInput.FocusLost:Connect(function()
	local val = tonumber(cooldownInput.Text)
	if val and val >= 0 then
		teleportCooldown = val
	else
		cooldownInput.Text = tostring(teleportCooldown)
	end
end)

-- Функция для получения всех моделей по названию
local function getModelsByName(name)
	local models = {}
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj.Name:lower() == name then
			table.insert(models, obj)
		end
	end
	return models
end

-- Создаем BillboardGui для моделей
local function createBillboard(model, displayText)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.Adornee = model:FindFirstChildWhichIsA("BasePart") -- прикрепляем к первому BasePart
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, 2, 0)

	local textLabel = Instance.new("TextLabel", billboard)
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = displayText
	textLabel.TextColor3 = Color3.new(1,1,1)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextScaled = true

	billboard.Parent = workspace
	return billboard
end

local billboards = {}

-- Постоянный телепорт
RunService.RenderStepped:Connect(function()
	-- Обновляем координаты
	local pos = humanoidRootPart.Position
	coordsLabel.Text = string.format("Координаты: %.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)

	-- Обновляем счетчик
	local models = getModelsByName(currentTarget)
	countLabel.Text = "Модели: " .. #models

	-- Обновляем метки
	for _, bb in pairs(billboards) do
		if bb and bb.Parent then
			bb:Destroy()
		end
	end
	billboards = {}

	for _, model in pairs(models) do
		local displayText = model.Name
		local billboard = createBillboard(model, displayText)
		table.insert(billboards, billboard)
	end

	-- Телепортируем
	if tpStatus then
		local currentTime = tick()
		if currentTime - lastTeleportTime >= teleportCooldown then
			local modelsList = getModelsByName(currentTarget)
			if #modelsList > 0 then
				local targetModel = modelsList[math.random(1, #modelsList)]
				local targetPart = targetModel:FindFirstChildWhichIsA("BasePart")
				if targetPart then
					local y = targetPart.Position.Y
					if y < minY then y = minY elseif y > maxY then y = maxY end
					humanoidRootPart.CFrame = CFrame.new(targetPart.Position.X, y, targetPart.Position.Z)
					lastTeleportTime = currentTime
				end
			end
		end
	end
end)

-- Обновление высоты при перемещении мыши или по другим причинам (по желанию)
-- Можно добавить дополнительные функции, если нужно.

-- Украшаем панель (уже сделано через UICorner и UIStroke)
