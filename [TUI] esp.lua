local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera

local gui = Instance.new("ScreenGui")
gui.Name = "TeleportGUI"
gui.Parent = player:WaitForChild("PlayerGui")

-- Основная панель
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = gui

-- Возможность перемещать панель
local dragging = false
local dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

mainFrame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
		local delta = dragInput.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Заголовок
local title = Instance.new("TextLabel")
title.Text = "Телепорт"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = mainFrame

-- Кнопки включения/выключения
local toggleChests = Instance.new("TextButton")
toggleChests.Text = "TP Сундуки"
toggleChests.Size = UDim2.new(0.5, -5, 0, 30)
toggleChests.Position = UDim2.new(0, 5, 0, 35)
toggleChests.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
toggleChests.TextColor3 = Color3.new(1, 1, 1)
toggleChests.Parent = mainFrame

local toggleOther = Instance.new("TextButton")
toggleOther.Text = "TP Предметы"
toggleOther.Size = UDim2.new(0.5, -5, 0, 30)
toggleOther.Position = UDim2.new(0.5, 0, 0, 35)
toggleOther.BackgroundColor3 = Color3.fromRGB(0, 0, 150)
toggleOther.TextColor3 = Color3.new(1, 1, 1)
toggleOther.Parent = mainFrame

-- Кулдаун настройка
local cooldownLabel = Instance.new("TextLabel")
cooldownLabel.Text = "КД (сек):"
cooldownLabel.Size = UDim2.new(0, 80, 0, 20)
cooldownLabel.Position = UDim2.new(0, 5, 0, 70)
cooldownLabel.BackgroundTransparency = 1
cooldownLabel.TextColor3 = Color3.new(1, 1, 1)
cooldownLabel.Font = Enum.Font.SourceSans
cooldownLabel.TextSize = 14
cooldownLabel.Parent = mainFrame

local cooldownBox = Instance.new("TextBox")
cooldownBox.Text = "2" -- по умолчанию 2 сек
cooldownBox.Size = UDim2.new(0, 50, 0, 20)
cooldownBox.Position = UDim2.new(0, 85, 0, 70)
cooldownBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
cooldownBox.TextColor3 = Color3.new(0, 0, 0)
cooldownBox.Font = Enum.Font.SourceSans
cooldownBox.TextSize = 14
cooldownBox.Parent = mainFrame

-- Координаты игрока
local coordsLabel = Instance.new("TextLabel")
coordsLabel.Text = "Координаты: "
coordsLabel.Size = UDim2.new(1, -10, 0, 20)
coordsLabel.Position = UDim2.new(0, 5, 0, 100)
coordsLabel.BackgroundTransparency = 1
coordsLabel.TextColor3 = Color3.new(1, 1, 1)
coordsLabel.Font = Enum.Font.SourceSans
coordsLabel.TextSize = 14
coordsLabel.Parent = mainFrame

-- Количество моделей
local chestsCountLabel = Instance.new("TextLabel")
chestsCountLabel.Text = "Честов: 0"
chestsCountLabel.Size = UDim2.new(0.5, -5, 0, 20)
chestsCountLabel.Position = UDim2.new(0, 5, 0, 130)
chestsCountLabel.BackgroundTransparency = 1
chestsCountLabel.TextColor3 = Color3.new(1, 1, 1)
chestsCountLabel.Font = Enum.Font.SourceSans
chestsCountLabel.TextSize = 14
chestsCountLabel.Parent = mainFrame

local othersCountLabel = Instance.new("TextLabel")
othersCountLabel.Text = "Предметов: 0"
othersCountLabel.Size = UDim2.new(0.5, -5, 0, 20)
othersCountLabel.Position = UDim2.new(0.5, 0, 0, 130)
othersCountLabel.BackgroundTransparency = 1
othersCountLabel.TextColor3 = Color3.new(1, 1, 1)
othersCountLabel.Font = Enum.Font.SourceSans
othersCountLabel.TextSize = 14
othersCountLabel.Parent = mainFrame

-- Объявляем переменные для включения/выключения телепортации
local teleportChests = false
local teleportOthers = false

-- Кулдаун
local lastTpTime = 0

local function getCooldown()
	local cd = tonumber(cooldownBox.Text)
	if cd == nil or cd < 0 then
		return 2 -- по умолчанию
	end
	return cd
end

-- Обработчики кнопок
toggleChests.MouseButton1Click:Connect(function()
	teleportChests = not teleportChests
	toggleChests.BackgroundColor3 = teleportChests and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 150, 0)
end)

toggleOther.MouseButton1Click:Connect(function()
	teleportOthers = not teleportOthers
	toggleOther.BackgroundColor3 = teleportOthers and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 0, 150)
end)

-- Функция поиска моделей
local function findModels(name)
	local models = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and (string.lower(obj.Name) == string.lower(name)) then
			table.insert(models, obj)
		end
	end
	return models
end

-- Создаем BillboardGui над моделью
local function createBillboard(model)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.Adornee = model:FindFirstChildWhichIsA("BasePart") -- прикрепляем к первому базовому объекту
	billboard.AlwaysOnTop = true

	local textLabel = Instance.new("TextLabel")
	textLabel.Text = model.Name
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextScaled = true
	textLabel.Parent = billboard

	billboard.Parent = model
end

-- Обновление счетчика моделей
local function updateCounts()
	local chestsModels = findModels("chests")
	local otherModels = findModels("other")
	chestsCountLabel.Text = "Честов: " .. #chestsModels
	othersCountLabel.Text = "Предметов: " .. #otherModels
end

-- Обновление координат
local function updateCoords()
	local pos = character:FindFirstChild("HumanoidRootPart").Position
	coordsLabel.Text = string.format("Координаты: X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z)
end

-- Основной цикл
RunService.Heartbeat:Connect(function()
	-- Обновляем координаты
	updateCoords()

	local now = tick()
	local cooldown = getCooldown()

	if teleportChests or teleportOthers then
		if now - lastTpTime >= cooldown then
			local modelsToTp = {}
			if teleportChests then
				local chestsModels = findModels("chests")
				for _, m in ipairs(chestsModels) do
					table.insert(modelsToTp, m)
				end
			end
			if teleportOthers then
				local otherModels = findModels("other")
				for _, m in ipairs(otherModels) do
					table.insert(modelsToTp, m)
				end
			end

			if #modelsToTp > 0 then
				local targetModel = modelsToTp[math.random(1, #modelsToTp)]
				local hrp = character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local targetPart = targetModel:FindFirstChildWhichIsA("BasePart")
					if targetPart then
						local newY = targetPart.Position.Y
						if newY < 113 then newY = 113 end
						if newY > 210 then newY = 210 end
						hrp.CFrame = CFrame.new(targetPart.Position.X, newY, targetPart.Position.Z)
						lastTpTime = now
					end
				end
			end
		end
	end
end)

-- Обновляем счетчики при запуске
updateCounts()

-- Обновляем счетчики каждую секунду
while true do
	wait(1)
	updateCounts()
end

-- Обновляем координаты каждую секунду
while true do
	wait(1)
	updateCoords()
end
