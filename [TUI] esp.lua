local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local MinHeight = 110
local MaxHeight = 220

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportChestPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Основная панель
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 200, 0, 280)
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

-- Кнопки [Старт / Стоп] Chest
local startChestButton = Instance.new("TextButton")
startChestButton.Size = UDim2.new(0, 80, 0, 60)
startChestButton.Position = UDim2.new(0, 10, 0, 130)
startChestButton.BackgroundColor3 = Color3.fromRGB(38, 13, 0)
startChestButton.BorderSizePixel = 2
startChestButton.BorderColor3 = Color3.new(0.666667, 0.333333, 0)
startChestButton.Font = Enum.Font.Michroma
startChestButton.TextSize = 16
startChestButton.TextScaled = true
startChestButton.Text = "Сундуки [OFF]"
startChestButton.TextColor3 = Color3.new(0.666667, 0.333333, 0)
startChestButton.Parent = panel

local stopChestButton = Instance.new("TextButton")
stopChestButton.Size = UDim2.new(0, 80, 0, 60)
stopChestButton.Position = UDim2.new(0, 10, 0, 130)
stopChestButton.BackgroundColor3 = Color3.fromRGB(136, 45, 0)
stopChestButton.BorderSizePixel = 2
stopChestButton.BorderColor3 = Color3.new(1, 0.333333, 0)
stopChestButton.Font = Enum.Font.Michroma
stopChestButton.TextSize = 16
stopChestButton.TextScaled = true
stopChestButton.Text = "Сундуки [ON]"
stopChestButton.TextColor3 = Color3.new(1, 0.333333, 0)
stopChestButton.Parent = panel
stopChestButton.Visible = false

-- Кнопки [Старт / Стоп] Item
local startItemButton = Instance.new("TextButton")
startItemButton.Size = UDim2.new(0, 80, 0, 60)
startItemButton.Position = UDim2.new(0, 110, 0, 130)
startItemButton.BackgroundColor3 = Color3.fromRGB(0, 49, 74)
startItemButton.BorderSizePixel = 2
startItemButton.BorderColor3 = Color3.new(0, 0.666667, 1)
startItemButton.Font = Enum.Font.Michroma
startItemButton.TextSize = 16
startItemButton.TextScaled = true
startItemButton.Text = "Предметы [OFF]"
startItemButton.TextColor3 = Color3.new(0, 0.666667, 1)
startItemButton.Parent = panel

local stopItemButton = Instance.new("TextButton")
stopItemButton.Size = UDim2.new(0, 80, 0, 60)
stopItemButton.Position = UDim2.new(0, 110, 0, 130)
stopItemButton.BackgroundColor3 = Color3.fromRGB(0, 85, 255)
stopItemButton.BorderSizePixel = 2
stopItemButton.BorderColor3 = Color3.new(0, 1, 1)
stopItemButton.Font = Enum.Font.Michroma
stopItemButton.TextSize = 16
stopItemButton.TextScaled = true
stopItemButton.Text = "Предметы [ON]"
stopItemButton.TextColor3 = Color3.new(0, 1, 1)
stopItemButton.Parent = panel
stopItemButton.Visible = false

-- Метки
local chestCountLabel = Instance.new("TextLabel")
chestCountLabel.Size = UDim2.new(0, 80, 0, 80)
chestCountLabel.Position = UDim2.new(0, 10, 0, 40)
chestCountLabel.BackgroundColor3 = Color3.fromRGB(139, 46, 0)
chestCountLabel.BorderSizePixel = 0
chestCountLabel.BorderColor3 = Color3.new(1, 0.333333, 0)
chestCountLabel.Text = "Сундуков [0]"
chestCountLabel.Font = Enum.Font.Michroma
chestCountLabel.TextSize = 16
chestCountLabel.TextScaled = true
chestCountLabel.TextColor3 = Color3.new(1, 0.333333, 0)
chestCountLabel.Parent = panel

local itemCountLabel = Instance.new("TextLabel")
itemCountLabel.Size = UDim2.new(0, 80, 0, 80)
itemCountLabel.Position = UDim2.new(0, 110, 0, 40)
itemCountLabel.BackgroundColor3 = Color3.fromRGB(0, 36, 54)
itemCountLabel.BorderSizePixel = 2
itemCountLabel.BorderColor3 = Color3.new(0, 0.333333, 1)
itemCountLabel.Text = "Предметов [0]"
itemCountLabel.Font = Enum.Font.Michroma
itemCountLabel.TextSize = 16
itemCountLabel.TextScaled = true
itemCountLabel.TextColor3 = Color3.new(0, 0.333333, 1)
itemCountLabel.Parent = panel

local coordsLabel = Instance.new("TextLabel")
coordsLabel.Size = UDim2.new(1, -20, 0, 30)
coordsLabel.Position = UDim2.new(0, 10, 0, 240)
coordsLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
coordsLabel.BorderSizePixel = 0
coordsLabel.Text = "[X=0, Y=0, Z=0]"
coordsLabel.Font = Enum.Font.Michroma
coordsLabel.TextSize = 12
coordsLabel.TextScaled = true
coordsLabel.TextColor3 = Color3.new(1, 1, 1)
coordsLabel.Parent = panel

-- Получение всех объектов по именам
local function getAllObjectsByNames(names)
	local objects = {}
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and table.find(names, model.Name) then
			for _, child in pairs(model:GetChildren()) do
				if child:IsA("BasePart") then
					table.insert(objects, child)
				end
			end
		end
	end
	return objects
end

local function updateChestCount()
	local chests = getAllObjectsByNames({"chests"})
	chestCountLabel.Text = "Сундуков [" .. #chests .. "]"
end

local function updateItemCount()
	local items = getAllObjectsByNames({"other"})
	itemCountLabel.Text = "Предметов [" .. #items .. "]"
end

-- Обновление координат
runService.RenderStepped:Connect(function()
	local pos = humanoidRootPart.Position
	coordsLabel.Text = string.format("[X=%.1f, Y=%.1f, Z=%.1f]", pos.X, pos.Y, pos.Z)
end)

-- Основной цикл для обновления счетчиков (объединен в один)
spawn(function()
	while true do
		updateChestCount()
		updateItemCount()
		wait(0.2)
	end
end)

-- Кулдаун и управление
local cooldownSeconds = 1
local cooldownBox = Instance.new("TextBox")
cooldownBox.Size = UDim2.new(0, 50, 0, 30)
cooldownBox.Position = UDim2.new(0, 10, 0, 200)
cooldownBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
cooldownBox.BorderSizePixel = 1
cooldownBox.Text = tostring(cooldownSeconds)
cooldownBox.PlaceholderText = "КД ТП"
cooldownBox.Font = Enum.Font.SourceSans
cooldownBox.TextSize = 14
cooldownBox.TextColor3 = Color3.new(1,1,1)
cooldownBox.Parent = panel

cooldownBox.FocusLost:Connect(function()
	local val = tonumber(cooldownBox.Text)
	if val then
		cooldownSeconds = val
	end
end)

local teleporting = false

local function teleportToPart(part)
	if not part then return end
	humanoidRootPart.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
	humanoidRootPart.CanCollide = false
	wait(0.1)
	humanoidRootPart.CanCollide = true
end

local function startTeleportCycleChests()
	if teleporting then return end
	teleporting = true
	startChestButton.Visible = false
	stopChestButton.Visible = true
	coroutine.wrap(function()
		while teleporting do
			local chests = getAllObjectsByNames({"chests"})
			local accessibleChests = {}
			for _, chest in pairs(chests) do
				local y = chest.Position.Y
				if y >= MinHeight and y <= MaxHeight then
					table.insert(accessibleChests, chest)
				end
			end
			if #accessibleChests > 0 then
				local selected = accessibleChests[math.random(1, #accessibleChests)]
				teleportToPart(selected)
			end
			wait(cooldownSeconds)
		end
	end)()
end

local function startTeleportCycleItems()
	if teleporting then return end
	teleporting = true
	startItemButton.Visible = false
	stopItemButton.Visible = true
	coroutine.wrap(function()
		while teleporting do
			local items = getAllObjectsByNames({"other"})
			local accessibleItems = {}
			for _, item in pairs(items) do
				local y = item.Position.Y
				if y >= MinHeight and y <= MaxHeight then
					table.insert(accessibleItems, item)
				end
			end
			if #accessibleItems > 0 then
				local selected = accessibleItems[math.random(1, #accessibleItems)]
				teleportToPart(selected)
			end
			wait(cooldownSeconds)
		end
	end)()
end

local function createButtonWithOutline(text, size, position, color, parent)
	local button = Instance.new("TextButton")
	button.Text = text
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextStrokeColor3 = Color3.new(0,0,0)
	button.TextStrokeTransparency = 0
	button.Font = Enum.Font.Michroma
	button.TextScaled = true
	button.Parent = parent
	return button
end

local promptAutoActivate = false -- состояние автоподтверждения Prompts

local togglePromptBtn = createButtonWithOutline("Авто сбор [OFF]", UDim2.new(0, 120, 0, 30), UDim2.new(0, 70, 0, 200), Color3.fromRGB(24, 0, 36), panel)

togglePromptBtn.MouseButton1Click:Connect(function()
	promptAutoActivate = not promptAutoActivate
	togglePromptBtn.Text = "Авто сбор " .. (promptAutoActivate and "[ON]" or "[OFF]")
	togglePromptBtn.BackgroundColor3 = promptAutoActivate and Color3.fromRGB(85, 0, 255) or Color3.fromRGB(24, 0, 36)
end)

local function activatePrompt(prompt)
	if prompt and prompt.Enabled then
		prompt:InputHoldBegin()
		wait(0.2)
		prompt:InputHoldEnd()
	end
end

-- Основной цикл
runService.Heartbeat:Connect(function()
	if promptAutoActivate then
		local playerChar = game.Players.LocalPlayer.Character
		if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
			for _, modelName in ipairs({"chests", "other"}) do
				for _, model in ipairs(workspace:GetChildren()) do
					if model:IsA("Model") and model.Name == modelName then
						for _, descendant in ipairs(model:GetDescendants()) do
							if descendant:IsA("ProximityPrompt") and descendant.Enabled then
								if descendant.Parent and descendant.Parent:IsA("BasePart") then
									descendant.HoldDuration = 0
									descendant.MaxActivationDistance = 20
									local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
									if hrp then
										local distance = (hrp.Position - descendant.Parent.Position).magnitude
										if distance <= descendant.MaxActivationDistance then
											activatePrompt(descendant)
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end)

local function stopTeleportCycle()
	teleporting = false
	startChestButton.Visible = true
	stopChestButton.Visible = false
	startItemButton.Visible = true
	stopItemButton.Visible = false
end

startChestButton.MouseButton1Click:Connect(startTeleportCycleChests)
stopChestButton.MouseButton1Click:Connect(stopTeleportCycle)
startItemButton.MouseButton1Click:Connect(startTeleportCycleItems)
stopItemButton.MouseButton1Click:Connect(stopTeleportCycle)

-- ТП для другого объекта
local function teleportPlayerToObject(target)
	if not target then return end
	humanoidRootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
	humanoidRootPart.CanCollide = false
	wait(0.1)
	humanoidRootPart.CanCollide = true
end
