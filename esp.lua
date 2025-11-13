
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local workspace = game.Workspace

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportChestPanel"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Создаем основную панель
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 300, 0, 200)
panel.Position = UDim2.new(0.5, -150, 0.5, -100)
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

-- Добавляем заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.BorderSizePixel = 0
title.Text = "Телепорт к сундокам"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = panel

-- Создаем кнопку для запуска
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0.8, 0, 0, 40)
startButton.Position = UDim2.new(0.1, 0, 0.5, 0)
startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
startButton.BorderSizePixel = 2
startButton.BorderColor3 = Color3.new(1, 1, 1)
startButton.Font = Enum.Font.SourceSansBold
startButton.TextSize = 16
startButton.Text = "Начать телепорт"
startButton.TextColor3 = Color3.new(1, 1, 1)
startButton.Parent = panel

-- Создаем кнопку для остановки
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0.8, 0, 0, 40)
stopButton.Position = UDim2.new(0.1, 0, 0.5, 0)
stopButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
stopButton.BorderSizePixel = 2
stopButton.BorderColor3 = Color3.new(1, 1, 1)
stopButton.Font = Enum.Font.SourceSansBold
stopButton.TextSize = 16
stopButton.Text = "Остановить"
stopButton.TextColor3 = Color3.new(1, 1, 1)
stopButton.Parent = panel
stopButton.Visible = false

-- Создаем метку для количества сундуков
local chestCountLabel = Instance.new("TextLabel")
chestCountLabel.Size = UDim2.new(1, -20, 0, 30)
chestCountLabel.Position = UDim2.new(0, 10, 0, 50)
chestCountLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
chestCountLabel.BorderSizePixel = 0
chestCountLabel.Text = "Всего сундуков: 0"
chestCountLabel.Font = Enum.Font.SourceSans
chestCountLabel.TextSize = 16
chestCountLabel.TextColor3 = Color3.new(1, 1, 1)
chestCountLabel.Parent = panel

-- Создаем метку для координат игрока
local coordsLabel = Instance.new("TextLabel")
coordsLabel.Size = UDim2.new(1, -20, 0, 30)
coordsLabel.Position = UDim2.new(0, 10, 0, 160)
coordsLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
coordsLabel.BorderSizePixel = 0
coordsLabel.Text = "Координаты: X=0, Y=0, Z=0"
coordsLabel.Font = Enum.Font.SourceSans
coordsLabel.TextSize = 14
coordsLabel.TextColor3 = Color3.new(1, 1, 1)
coordsLabel.Parent = panel

-- Обновление координат
runService.RenderStepped:Connect(function()
	local pos = humanoidRootPart.Position
	coordsLabel.Text = string.format("Координаты: X=%.1f, Y=%.1f, Z=%.1f", pos.X, pos.Y, pos.Z)
end)

-- Функции поиска сундуков
local function getAllChests()
	local chests = {}
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model.Name == "chests" then
			for _, child in pairs(model:GetChildren()) do
				if child:IsA("BasePart") then
					table.insert(chests, child)
				end
			end
		end
	end
	return chests
end

local function updateChestCount()
	local chests = getAllChests()
	local count = #chests
	chestCountLabel.Text = "Всего сундуков: " .. tostring(count)
end

local function findAccessibleChest(chests)
	local accessibleChests = {}
	for _, chest in pairs(chests) do
		local accessible = false
		for _, part in pairs(chest:GetChildren()) do
			if part:IsA("BasePart") then
				local y = part.Position.Y
				if y >= 114 and y <= 180 then
					accessible = true
					break
				end
			end
		end
		if accessible then
			table.insert(accessibleChests, chest)
		end
	end
	return accessibleChests
end

local teleporting = false
local function startTeleportCycle()
	if teleporting then return end
	teleporting = true
	startButton.Visible = false
	stopButton.Visible = true

	local function cycle()
		while teleporting do
			local chests = getAllChests()
			local accessibleChests = findAccessibleChest(chests)
			if #accessibleChests > 0 then
				local selectedChest = accessibleChests[math.random(1, #accessibleChests)]
				for _, part in pairs(selectedChest:GetChildren()) do
					if part:IsA("BasePart") then
						local y = part.Position.Y
						if y >= 114 and y <= 180 then
							humanoidRootPart.CFrame = CFrame.new(part.Position.X, y + 3, part.Position.Z)
							break
						end
					end
				end
			end
			wait(0.25)
		end
	end
	coroutine.wrap(cycle)()
end

local function stopTeleportCycle()
	teleporting = false
	startButton.Visible = true
	stopButton.Visible = false
end

startButton.MouseButton1Click:Connect(startTeleportCycle)
stopButton.MouseButton1Click:Connect(stopTeleportCycle)

-- Добавляем подсветку сундуков
local activeHighlights = {}

local function clearHighlights()
	for _, highlight in ipairs(activeHighlights) do
		if highlight and highlight.Parent then
			highlight:Destroy()
		end
	end
	activeHighlights = {}
end

local function addHighlightToChests()
	-- Сначала очищаем старые подсветки
	clearHighlights()
	-- Затем добавляем новые подсветки для всех сундуков
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model.Name == "chests" then
			for _, part in pairs(model:GetChildren()) do
				if part:IsA("BasePart") then
					local highlight = Instance.new("Highlight")
					highlight.Adornee = part
					highlight.FillColor = Color3.new(1, 1, 0)
					highlight.FillTransparency = 0.2
					highlight.OutlineColor = Color3.new(1, 1, 0)
					highlight.OutlineTransparency = 0
					highlight.Parent = part
					table.insert(activeHighlights, highlight)
				end
			end
		end
	end
end

-- Обновляем счетчик каждые 5 секунд
spawn(function()
	while true do
		updateChestCount()
		addHighlightToChests()
		wait(0.25)
	end
end)

addHighlightToChests()
