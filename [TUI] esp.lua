-- Вставьте этот скрипт в StarterPlayerScripts

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local workspace = game.Workspace

local toggleChests = false -- Включено или выключено телепорт к сундукам
local toggleOthers = false -- Включено или выключено телепорт к предметам
local cooldownTime = 1 -- по умолчанию 1 секунда
local lastTPTime = 0

local MaxHeight = 210
local MinHeight = 113

-- Создаем основную GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Создаем основную панель
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 330, 0, 190)
MainPanel.Position = UDim2.new(0, 100, 0, 100)
MainPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainPanel.BorderSizePixel = 0
MainPanel.Parent = ScreenGui

-- Создаем перетаскиваемую часть для основной панели
local dragging = false
local dragInput, dragStart, startPos

MainPanel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainPanel.Position
	end
end)

MainPanel.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

MainPanel.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

RunService.RenderStepped:Connect(function()
	if dragging and dragInput then
		local delta = dragInput.Position - dragStart
		MainPanel.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
	end
end)

-- Создаем кнопку для "TP Сундуки"
local function createButton(text, position)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 90, 0, 50)
	btn.Position = position
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.BorderSizePixel = 0
	btn.Parent = MainPanel
	return btn
end

local btnChests = createButton("TP Сундуки [OFF]", UDim2.new(0, 10, 0, 70))
local btnOthers = createButton("TP Предметы [OFF]", UDim2.new(0, 110, 0, 70))

local cooldownBox = Instance.new("TextBox")
cooldownBox.Size = UDim2.new(0, 60, 0, 50)
cooldownBox.Position = UDim2.new(0, 265, 0, 10)
cooldownBox.Text = tostring(cooldownTime)
cooldownBox.PlaceholderText = "КД ТП"
cooldownBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
cooldownBox.TextColor3 = Color3.fromRGB(255,255,255)
cooldownBox.Font = Enum.Font.GothamBold
cooldownBox.TextSize = 16
cooldownBox.Parent = MainPanel

local coordsLabel = Instance.new("TextLabel")
coordsLabel.Size = UDim2.new(0, 250, 0, 50)
coordsLabel.Position = UDim2.new(0, 10, 0, 130)
coordsLabel.Text = "Coords: "
coordsLabel.BackgroundColor3 = Color3.fromRGB(30,30,30)
coordsLabel.TextColor3 = Color3.fromRGB(255,255,255)
coordsLabel.Font = Enum.Font.GothamBold
coordsLabel.TextSize = 14
coordsLabel.Parent = MainPanel

local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(0, 250, 0, 50)
countLabel.Position = UDim2.new(0, 10, 0, 10)
countLabel.Text = "Сундуки [0] | Предметы [0]"
countLabel.BackgroundColor3 = Color3.fromRGB(30,30,30)
countLabel.TextColor3 = Color3.fromRGB(255,255,255)
countLabel.Font = Enum.Font.GothamBold
countLabel.TextSize = 14
countLabel.Parent = MainPanel

-- Создаем мини-панель для включения/выключения телепорта
local MiniPanelSize = 4 -- 6x6
local MiniPanel = Instance.new("Frame")
MiniPanel.Size = UDim2.new(0, 6*40, 0, 6*40) -- 240x240
MiniPanel.Position = UDim2.new(0, 450, 0, 100)
MiniPanel.BackgroundColor3 = Color3.fromRGB(60,60,60)
MiniPanel.BorderSizePixel = 2
MiniPanel.Parent = ScreenGui

-- Создаем кнопку для открытия/закрытия мини-панели
local toggleMiniPanelBtn = createButton("[ON]/[OFF] мини-панель", UDim2.new(0,230,0,70))
local miniPanelVisible = true

toggleMiniPanelBtn.MouseButton1Click:Connect(function()
	miniPanelVisible = not miniPanelVisible
	MiniPanel.Visible = miniPanelVisible
end)

-- Сделаем мини-панель перетаскиваемой
local miniDragging = false
local miniDragInput, miniDragStart, miniStartPos

MiniPanel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		miniDragging = true
		miniDragStart = input.Position
		miniStartPos = MiniPanel.Position
	end
end)

MiniPanel.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		miniDragging = false
	end
end)

MiniPanel.InputChanged:Connect(function(input)
	if miniDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		miniDragInput = input
	end
end)

RunService.RenderStepped:Connect(function()
	if miniDragging and miniDragInput then
		local delta = miniDragInput.Position - miniDragStart
		MiniPanel.Position = miniStartPos + UDim2.new(0, delta.X, 0, delta.Y)
	end
end)

-- Создаем кнопки внутри мини-панели
local allowedModels = {
	"Chest_p",
	"Dark Chest_p",
	"Light Chest_p",
	"Skin Chest_p",
	"Heart Chest_p",
	"Wood_p",
	"Stone_p",
	"Metal_p",
	"Rusty Metal_p",
	"Meat_p",
	"Rope_p",
	"Line Paper_p",
	"Leather_p",
	"Meat_p",
	"Holy Chain",
	"Shattered Chain",
	"Orb_p",
	"Holy Orb_p",
	"Cursed Orb_p",
}

local function createMiniButton(name, row, col)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 40)
	btn.Position = UDim2.new(0, col * 40, 0, row * 40)
	btn.Text = name
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(255,0,0) -- по умолчанию запрещено
	btn.TextColor3 = Color3.fromRGB(0, 0, 0)
	btn.BorderSizePixel = 1
	btn.Parent = MiniPanel
	return btn
end

local miniButtons = {}
for i, name in ipairs(allowedModels) do
	local row = math.floor((i-1)/6)
	local col = (i-1) % 6
	local btn = createMiniButton(name, row, col)
	miniButtons[name] = btn
end

-- Создаем таблицы для статусов разрешения
local modelStatus = {}
for _, name in ipairs(allowedModels) do
	modelStatus[name] = false -- по умолчанию выключены
end

-- Обработка нажатий кнопок мини-панели
for name, btn in pairs(miniButtons) do
	btn.MouseButton1Click:Connect(function()
		modelStatus[name] = not modelStatus[name]
		if modelStatus[name] then
			btn.BackgroundColor3 = Color3.fromRGB(0,255,0) -- зеленый, разрешено
		else
			btn.BackgroundColor3 = Color3.fromRGB(255,0,0) -- красный, запрещено
		end
	end)
end

-- Функция для обновления текста BillboardGui с контуром
local function createBillboard(model, name, color, allowed)
	-- Удаляем существующие BillboardGui
	for _, child in pairs(model:GetChildren()) do
		if child:IsA("BillboardGui") then
			child:Destroy()
		end
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 150, 0, 50)
	billboard.Adornee = model:FindFirstChildWhichIsA("BasePart")
	billboard.AlwaysOnTop = true
	billboard.Parent = model
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = name
	textLabel.TextColor3 = color -- цвет текста остается неизменным
	textLabel.TextStrokeColor3 = allowed and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0) -- цвет контура зависит от статуса
	textLabel.TextStrokeTransparency = 0 -- делаем контур видимым
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 20
	textLabel.Parent = billboard
end

-- Обновляем модели и ставим статус
local chestsModels = {}
local othersModels = {}

local function refreshModels()
	chestsModels = {}
	othersModels = {}
	-- Очистка старых BillboardGui
	for _, model in pairs(workspace:GetChildren()) do
		if model:IsA("Model") then
			for _, child in pairs(model:GetChildren()) do
				if child:IsA("BillboardGui") then
					child:Destroy()
				end
			end
		end
	end
	for _, model in pairs(workspace:GetChildren()) do
		if model:IsA("Model") then
			if model.Name:lower() == "chests" then
				for _, m in pairs(model:GetChildren()) do
					if m:IsA("Model") then
						table.insert(chestsModels, m)
						local name = m.Name
						local allowed = false
						for _, n in ipairs(allowedModels) do
							if n == name then
								allowed = modelStatus[n]
								break
							end
						end
						createBillboard(m, name, Color3.fromRGB(255, 165, 0), allowed)
					end
				end
			elseif model.Name:lower() == "others" then
				for _, m in pairs(model:GetChildren()) do
					if m:IsA("Model") then
						table.insert(othersModels, m)
						local name = m.Name
						local allowed = false
						for _, n in ipairs(allowedModels) do
							if n == name then
								allowed = modelStatus[n]
								break
							end
						end
						createBillboard(m, name, Color3.fromRGB(0, 191, 255), allowed)
					end
				end
			end
		end
	end
end

local function updateCount()
	countLabel.Text = "Сундуки [" .. tostring(#chestsModels) .. "]" .. " | Предметы [" .. tostring(#othersModels) .. "]"
end

refreshModels()

-- Обработка основных переключателей
btnChests.MouseButton1Click:Connect(function()
	if toggleChests then
		toggleChests = false
	else
		toggleChests = true
		toggleOthers = false
	end
	btnChests.Text = toggleChests and "TP Сундуки [ON]" or "TP Сундуки [OFF]"
	btnOthers.Text = toggleOthers and "TP Предметы [ON]" or "TP Предметы [OFF]"
end)

btnOthers.MouseButton1Click:Connect(function()
	if toggleOthers then
		toggleOthers = false
	else
		toggleOthers = true
		toggleChests = false
	end
	btnChests.Text = toggleChests and "TP Сундуки [ON]" or "TP Сундуки [OFF]"
	btnOthers.Text = toggleOthers and "TP Предметы [ON]" or "TP Предметы"
end)

-- Кулдаун
cooldownBox.FocusLost:Connect(function()
	local val = tonumber(cooldownBox.Text)
	if val and val >= 0 then
		cooldownTime = val
	else
		cooldownBox.Text = tostring(cooldownTime)
	end
end)

local playerCharacter = player.Character or player.CharacterAdded:Wait()
local hrp = playerCharacter:WaitForChild("HumanoidRootPart")
local lastTPTime = 0

RunService.RenderStepped:Connect(function()
	-- Обновляем координаты
	local pos = hrp.Position
	coordsLabel.Text = string.format("Coords: %.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)

	-- Телепорт, если модели разрешены и находятся в пределах высоты
	if (toggleChests or toggleOthers) then
		local now = tick()
		if now - lastTPTime >= cooldownTime then
			local targetModels = {}
			if toggleChests then
				targetModels = chestsModels
			elseif toggleOthers then
				targetModels = othersModels
			end
			if #targetModels > 0 then
				local targetModel = targetModels[math.random(1, #targetModels)]
				local part = targetModel:FindFirstChildWhichIsA("BasePart")
				if part then
					local name = targetModel.Name
					local allowed = false
					for _, n in ipairs(allowedModels) do
						if n == name then
							allowed = modelStatus[n]
							break
						end
					end
					if allowed then
						local targetPos = part.Position
						-- Проверка высоты модели
						if targetPos.Y >= MinHeight and targetPos.Y <= MaxHeight then
							hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y, targetPos.Z)
							lastTPTime = now
						end
					end
				end
			end
		end
	end
end)

-- Обновляем модели и счетчик периодически
while true do
	wait(1)
	refreshModels()
	updateCount()
end
