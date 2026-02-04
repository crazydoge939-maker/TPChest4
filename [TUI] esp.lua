-- StarterPlayerScripts/TeleportScript.lua

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterPlayer = game:GetService("StarterPlayer")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Создаем основное GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = ScreenGui

-- Делает панель перетаскиваемой
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		updateInput(input)
	end
end)

-- Заголовок
local title = Instance.new("TextLabel")
title.Text = "Телепортатор"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- Кнопки
local buttonSize = UDim2.new(1, -20, 0, 40)
local padding = 10

local tpChestsEnabled = true
local tpOtherEnabled = true
local cooldownTime = 2 -- по умолчанию 2 секунды
local lastTpTime = 0

local function createButton(text, yPos)
	local btn = Instance.new("TextButton")
	btn.Size = buttonSize
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 16
	btn.Text = text
	btn.Parent = frame
	return btn
end

local btnChests = createButton("TP Сундуки", 40)
local btnOther = createButton("TP Предметы", 90)

-- Поле для установки кд
local cooldownLabel = Instance.new("TextLabel")
cooldownLabel.Size = UDim2.new(1, -20, 0, 20)
cooldownLabel.Position = UDim2.new(0, 10, 0, 140)
cooldownLabel.BackgroundColor3 = Color3.fromRGB(50,50,50)
cooldownLabel.TextColor3 = Color3.new(1, 1, 1)
cooldownLabel.Font = Enum.Font.SourceSans
cooldownLabel.TextSize = 14
cooldownLabel.Text = "КД (сек):"
cooldownLabel.Parent = frame

local cooldownBox = Instance.new("TextBox")
cooldownBox.Size = UDim2.new(0, 50, 0, 20)
cooldownBox.Position = UDim2.new(0, 100, 0, 140)
cooldownBox.BackgroundColor3 = Color3.fromRGB(70,70,70)
cooldownBox.TextColor3 = Color3.new(1, 1, 1)
cooldownBox.Font = Enum.Font.SourceSans
cooldownBox.TextSize = 14
cooldownBox.Text = tostring(cooldownTime)
cooldownBox.Parent = frame

cooldownBox.FocusLost:Connect(function()
	local val = tonumber(cooldownBox.Text)
	if val and val >= 0 then
		cooldownTime = val
	end
end)

-- Поле для подсветки
local highlightEnabled = {chests = true, other = true}

local function toggleHighlight(type)
	highlightEnabled[type] = not highlightEnabled[type]
end

local btnHighlightChests = createButton("Подсветка сундуков: ON", 170)
local btnHighlightOther = createButton("Подсветка предметов: ON", 220)

btnHighlightChests.MouseButton1Click:Connect(function()
	highlightEnabled.chests = not highlightEnabled.chests
	if highlightEnabled.chests then
		btnHighlightChests.Text = "Подсветка сундуков: ON"
	else
		btnHighlightChests.Text = "Подсветка сундуков: OFF"
	end
end)

btnHighlightOther.MouseButton1Click:Connect(function()
	highlightEnabled.other = not highlightEnabled.other
	if highlightEnabled.other then
		btnHighlightOther.Text = "Подсветка предметов: ON"
	else
		btnHighlightOther.Text = "Подсветка предметов: OFF"
	end
end)

-- Кнопки телепортации
local function teleportToModel(modelName)
	if tick() - lastTpTime < cooldownTime then return end
	local models = workspace:GetDescendants()
	local targets = {}
	for _, obj in ipairs(models) do
		if obj:IsA("Model") and obj.Name:lower() == modelName then
			table.insert(targets, obj)
		end
	end
	if #targets == 0 then return end
	local targetModel = targets[math.random(1, #targets)]
	local hrp = targetModel:FindFirstChild("HumanoidRootPart") or targetModel:FindFirstChildWhichIsA("BasePart")
	if hrp then
		local pos = hrp.Position
		-- Ограничение по высоте
		local y = math.clamp(pos.Y, 110, 220)
		humanoidRootPart.CFrame = CFrame.new(pos.X, y + 2, pos.Z)
		lastTpTime = tick()
	end
end

btnChests.MouseButton1Click:Connect(function()
	if not tpChestsEnabled then return end
	teleportToModel("chests")
end)

btnOther.MouseButton1Click:Connect(function()
	if not tpOtherEnabled then return end
	teleportToModel("other")
end)

-- Переключатели для включения/выключения телепортов
local function createToggleButton(text, yPos, initialState, callback)
	local btn = createButton(text, yPos)
	local state = initialState
	btn.MouseButton1Click:Connect(function()
		state = not state
		callback(state)
		if state then
			btn.Text = text:gsub(": OFF", ": ON")
		else
			btn.Text = text:gsub(": ON", ": OFF")
		end
	end)
	if initialState then
		btn.Text = text:gsub(": OFF", ": ON")
	else
		btn.Text = text:gsub(": ON", ": OFF")
	end
end

-- Создаем переключатели
local function createSwitches()
	local chestsSwitch = createButton("Телепортировать к сундукам: ON", 300)
	local otherSwitch = createButton("Телепортировать к предметам: ON", 340)

	local chestsState = true
	local otherState = true

	chestsSwitch.MouseButton1Click:Connect(function()
		chestsState = not chestsState
		tpChestsEnabled = chestsState
		chestsSwitch.Text = "Телепортировать к сундукам: " .. (chestsState and "ON" or "OFF")
	end)

	otherSwitch.MouseButton1Click:Connect(function()
		otherState = not otherState
		tpOtherEnabled = otherState
		otherSwitch.Text = "Телепортировать к предметам: " .. (otherState and "ON" or "OFF")
	end)

end

createSwitches()

-- Отображение координат и количества моделей
local coordsLabel = Instance.new("TextLabel")
coordsLabel.Size = UDim2.new(1, -20, 0, 40)
coordsLabel.Position = UDim2.new(0, 10, 0, 380)
coordsLabel.BackgroundColor3 = Color3.fromRGB(50,50,50)
coordsLabel.TextColor3 = Color3.new(1, 1, 1)
coordsLabel.Font = Enum.Font.SourceSans
coordsLabel.TextSize = 14
coordsLabel.Text = "Координаты: "
coordsLabel.Parent = frame

local chestsCountLabel = Instance.new("TextLabel")
chestsCountLabel.Size = UDim2.new(1, -20, 0, 20)
chestsCountLabel.Position = UDim2.new(0, 10, 0, 330)
chestsCountLabel.BackgroundColor3 = Color3.fromRGB(50,50,50)
chestsCountLabel.TextColor3 = Color3.new(1, 1, 1)
chestsCountLabel.Font = Enum.Font.SourceSans
chestsCountLabel.TextSize = 14
chestsCountLabel.Text = "Сундуки: 0"
chestsCountLabel.Parent = frame

local othersCountLabel = Instance.new("TextLabel")
othersCountLabel.Size = UDim2.new(1, -20, 0, 20)
othersCountLabel.Position = UDim2.new(0, 10, 0, 350)
othersCountLabel.BackgroundColor3 = Color3.fromRGB(50,50,50)
othersCountLabel.TextColor3 = Color3.new(1, 1, 1)
othersCountLabel.Font = Enum.Font.SourceSans
othersCountLabel.TextSize = 14
othersCountLabel.Text = "Предметы: 0"
othersCountLabel.Parent = frame

-- Обновление координат и количества
RunService.RenderStepped:Connect(function()
	local pos = humanoidRootPart.Position
	coordsLabel.Text = string.format("Координаты: X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z)

	local models = workspace:GetDescendants()
	local chestsCount = 0
	local othersCount = 0
	for _, obj in ipairs(models) do
		if obj:IsA("Model") then
			if obj.Name:lower() == "chests" then
				chestsCount = chestsCount + 1
			elseif obj.Name:lower() == "other" then
				othersCount = othersCount + 1
			end
		end
	end
	chestsCountLabel.Text = "Сундуки: " .. chestsCount
	othersCountLabel.Text = "Предметы: " .. othersCount
end)

-- Подсветка моделей
local function highlightModel(model, color)
	local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
	if hrp then
		local highlight = hrp:FindFirstChildOfClass("Highlight")
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Adornee = hrp
			highlight.Parent = hrp
			highlight.FillColor = color
			highlight.OutlineColor = color
			highlight.Enabled = true
		else
			highlight.FillColor = color
			highlight.OutlineColor = color
			highlight.Enabled = true
		end
	end
end

local function removeHighlight(model)
	local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
	if hrp then
		local highlight = hrp:FindFirstChildOfClass("Highlight")
		if highlight then
			highlight.Enabled = false
		end
	end
end

local highlightedModels = {}

RunService.RenderStepped:Connect(function()
	-- Обновляем подсветку для сундуков
	local models = workspace:GetDescendants()
	for _, model in ipairs(models) do
		if model:IsA("Model") then
			if model.Name:lower() == "chests" and highlightEnabled.chests then
				highlightModel(model, Color3.fromRGB(0, 255, 0))
			elseif model.Name:lower() == "other" and highlightEnabled.other then
				highlightModel(model, Color3.fromRGB(0, 0, 255))
			else
				removeHighlight(model)
			end
		end
	end
end)

-- Важно: Можно дополнительно улучшить подсветку, чтобы она не накладывалась
-- и чтобы подсветка оставалась, даже если модели исчезают и появляются заново.

-- В конце, скрипт готов к запуску.
