--[[
	Teleport Toggle Script
	GUI с кнопкой-переключателем и полем ввода времени.
	При включении телепортирует игрока на заданные координаты через указанный интервал.
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ============================================
-- НАСТРОЙКИ КООРДИНАТ ТЕЛЕПОРТАЦИИ
-- Измените эти значения на нужные вам координаты
-- ============================================
local TELEPORT_POSITION = Vector3.new(0, 50, 0)

-- ============================================
-- Создание GUI
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportToggleGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 180)
mainFrame.Position = UDim2.new(0, 20, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- Скругление углов
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Телепорт"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

-- Сделаем заголовок «ручкой» для перетаскивания (визуальный курсор)
titleLabel.Active = true

-- ============================================
-- Логика перетаскивания панели (ПК + телефон)
-- ============================================
local UserInputService = game:GetService("UserInputService")

local dragging = false
local dragStart = nil
local frameStart = nil

local function updateDrag(input)
	if dragging and dragStart and frameStart then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			frameStart.X.Scale,
			frameStart.X.Offset + delta.X,
			frameStart.Y.Scale,
			frameStart.Y.Offset + delta.Y
		)
	end
end

titleLabel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		frameStart = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleLabel.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		updateDrag(input)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		updateDrag(input)
	end
end)

-- Подпись для поля ввода времени
local delayLabel = Instance.new("TextLabel")
delayLabel.Name = "DelayLabel"
delayLabel.Size = UDim2.new(1, -20, 0, 20)
delayLabel.Position = UDim2.new(0, 10, 0, 45)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Интервал (сек):"
delayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
delayLabel.Font = Enum.Font.Gotham
delayLabel.TextSize = 14
delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.Parent = mainFrame

-- Поле ввода времени
local delayInput = Instance.new("TextBox")
delayInput.Name = "DelayInput"
delayInput.Size = UDim2.new(1, -20, 0, 35)
delayInput.Position = UDim2.new(0, 10, 0, 68)
delayInput.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
delayInput.Text = "5"
delayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
delayInput.Font = Enum.Font.Gotham
delayInput.TextSize = 16
delayInput.PlaceholderText = "Введите секунды"
delayInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
delayInput.ClearTextOnFocus = false
delayInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = delayInput

-- Кнопка-переключатель
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, -20, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 115)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
toggleButton.Text = "ВЫКЛ"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 16
toggleButton.AutoButtonColor = true
toggleButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleButton

-- Статус-бар (показывает обратный отсчёт)
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 160)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = mainFrame

-- ============================================
-- Логика телепортации
-- ============================================

local isTeleporting = false
local teleportThread = nil

local function getDelaySeconds()
	local text = delayInput.Text
	local value = tonumber(text)
	if value and value > 0 then
		return value
	end
	return 5 -- значение по умолчанию
end

local function teleportPlayer()
	local character = player.Character
	if character then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(TELEPORT_POSITION)
		end
	end
end

local function startTeleportLoop()
	local delay = getDelaySeconds()
	teleportThread = task.spawn(function()
		while isTeleporting do
			teleportPlayer()
			-- Обратный отсчёт
			for i = math.floor(delay), 1, -1 do
				if not isTeleporting then break end
				statusLabel.Text = "Следующий телепорт через: " .. i .. " сек"
				task.wait(1)
			end
			-- Обновляем задержку на случай, если игрок изменил значение
			delay = getDelaySeconds()
		end
		statusLabel.Text = ""
	end)
end

toggleButton.MouseButton1Click:Connect(function()
	isTeleporting = not isTeleporting

	if isTeleporting then
		toggleButton.Text = "ВКЛ"
		toggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
		startTeleportLoop()
	else
		toggleButton.Text = "ВЫКЛ"
		toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
		statusLabel.Text = ""
		if teleportThread then
			task.cancel(teleportThread)
			teleportThread = nil
			end
		end
	end)

-- Обработка нажатия Enter в поле ввода
delayInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local value = tonumber(delayInput.Text)
		if not value or value <= 0 then
			delayInput.Text = "5"
		end
	end
end)
