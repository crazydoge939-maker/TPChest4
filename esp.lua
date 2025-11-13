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

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.BorderSizePixel = 0
title.Text = "Телепорт к сундокам"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = panel

-- Кнопка для запуска
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

-- Кнопка для остановки
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

-- Метка для количества сундуков
local chestCountLabel = Instance.new("TextLabel")
chestCountLabel.Size = UDim2.new(1, -20, 0, 30)
chestCountLabel.Position = UDim2.new(0, 10, 0, 60)
chestCountLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
chestCountLabel.BorderSizePixel = 0
chestCountLabel.Text = "Всего сундуков: 0"
chestCountLabel.Font = Enum.Font.SourceSans
chestCountLabel.TextSize = 16
chestCountLabel.TextColor3 = Color3.new(1, 1, 1)
chestCountLabel.Parent = panel

-- Метка координат игрока
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

-- Баг с сундуками: поиск и подсветка
local function getAllChests()
	local chests = {}
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model.Name == "chests" then
			table.insert(chests, model)
		end
	end
	return chests
end

local function updateChestCount()
	local chests = getAllChests()
	local count = #chests
	chestCountLabel.Text = "Всего сундуков: " .. tostring(count)
end

-- Обновлять счет каждые 5 секунд
spawn(function()
	while true do
		updateChestCount()
		wait(5)
	end
end)

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

-- Капсула
local capsule = nil

local function createCapsule()
	if capsule then return end -- уже есть
	local character = game.Players.LocalPlayer.Character
	if not character then return end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local size = Vector3.new(10, 10, 10)
	local wallThickness = 0.2

	capsule = Instance.new("Model")
	capsule.Name = "TeleportCapsule"
	capsule.Parent = workspace

	local partsData = {
		-- фронт
		{Position = Vector3.new(0, 0, -size.Z/2), Size = Vector3.new(size.X, size.Y, wallThickness)},
		-- зад
		{Position = Vector3.new(0, 0, size.Z/2), Size = Vector3.new(size.X, size.Y, wallThickness)},
		-- лево
		{Position = Vector3.new(-size.X/2, 0, 0), Size = Vector3.new(wallThickness, size.Y, size.Z)},
		-- право
		{Position = Vector3.new(size.X/2, 0, 0), Size = Vector3.new(wallThickness, size.Y, size.Z)},
		-- снизу
		{Position = Vector3.new(0, -size.Y/2, 0), Size = Vector3.new(size.X, wallThickness, size.Z)},
		-- сверху
		{Position = Vector3.new(0, size.Y/2, 0), Size = Vector3.new(size.X, wallThickness, size.Z)},
	}

	for _, data in pairs(partsData) do
		local part = Instance.new("Part")
		part.Size = data.Size
		part.Position = humanoidRootPart.Position + data.Position
		part.Anchored = true
		part.Transparency = 0.3
		part.Color = Color3.new(0,0,0)
		part.CanCollide = true
		part.Name = "CapsuleWall"
		part.Parent = capsule
	end

	-- Внутренний прозрачный блок
	local innerPart = Instance.new("Part")
	innerPart.Size = Vector3.new(size.X - wallThickness*2, size.Y - wallThickness*2, size.Z - wallThickness*2)
	innerPart.Position = humanoidRootPart.Position
	innerPart.Anchored = true
	innerPart.Transparency = 1
	innerPart.CanCollide = false
	innerPart.Name = "Inner"
	innerPart.Parent = capsule

	-- Обновление позиции капсулы
	local function updateCapsulePosition()
		if capsule and humanoidRootPart then
			capsule:SetPrimaryPartCFrame(CFrame.new(humanoidRootPart.Position))
			for _, part in pairs(capsule:GetChildren()) do
				if part:IsA("BasePart") then
					if part.Name ~= "Inner" then
						part.CFrame = CFrame.new(humanoidRootPart.Position + (part.Position - humanoidRootPart.Position))
					else
						part.CFrame = CFrame.new(humanoidRootPart.Position)
					end
				end
			end
		end
	end

	local connection
	connection = runService.Heartbeat:Connect(function()
		if capsule and humanoidRootPart then
			updateCapsulePosition()
		end
	end)

	capsule.AncestryChanged:Connect(function()
		if not capsule or not capsule.Parent then
			if connection then connection:Disconnect() end
		end
	end)
end

local function removeCapsule()
	if capsule then
		capsule:Destroy()
		capsule = nil
	end
end

local function onTeleportActivate()
	createCapsule()
end

local function onTeleportDeactivate()
	removeCapsule()
end

-- Кнопки
startButton.MouseButton1Click:Connect(function()
	if teleporting then return end
	teleporting = true
	onTeleportActivate()

	startButton.Visible = false
	stopButton.Visible = true

	if character and character:FindFirstChildOfClass("Humanoid") then
		character:FindFirstChildOfClass("Humanoid").PlatformStand = true
	end

	-- Основной цикл телепорта
	spawn(function()
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
			wait(1)
		end
	end)
end)

stopButton.MouseButton1Click:Connect(function()
	teleporting = false
	onTeleportDeactivate()

	startButton.Visible = true
	stopButton.Visible = false

	if character and character:FindFirstChildOfClass("Humanoid") then
		character:FindFirstChildOfClass("Humanoid").PlatformStand = false
	end
end)

-- Дополнительная логика или функции для телепортации, подсветки сундуков и пр.
-- Важно: вызовы onTeleportActivate() и onTeleportDeactivate() управляют созданием и удалением капсулы
