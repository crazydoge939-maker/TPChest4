local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera

local MaxHeight = 220
local MinHeight = 110

-- Переменные для телепортации
local teleportChests = false
local teleportOthers = false
local lastTpTime = 0

-- Переменная для автопрогика
local enabledPrompt = true

-- Создаем GUI для управления
local gui = Instance.new("ScreenGui")
gui.Name = "TeleportAndPromptControl"
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 200)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = gui

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
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local function createTextLabelWithOutline(text, size, position, parent)
	local label = Instance.new("TextLabel")
	label.Text = text
	label.Size = size
	label.Position = position
	label.BackgroundColor3 = Color3.new(0, 0, 0)
	label.TextColor3 = Color3.new(1,1,1)
	label.TextStrokeColor3 = Color3.new(0,0,0)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.Michroma
	label.TextScaled = true
	label.Parent = parent
	return label
end

local function createButtonWithOutline(text, size, position, color, parent)
	local button = Instance.new("TextButton")
	button.Text = text
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.new(1,1,1)
	button.TextStrokeColor3 = Color3.new(0,0,0)
	button.TextStrokeTransparency = 0
	button.Font = Enum.Font.Michroma
	button.TextScaled = true
	button.Parent = parent
	return button
end

local title = createTextLabelWithOutline("AUTO TP", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), mainFrame)

-- Телепорт кнопки
local toggleChests = createButtonWithOutline("TP Сундуки", UDim2.new(0, 100, 0, 30), UDim2.new(0, 5, 0, 100), Color3.fromRGB(88, 29, 0), mainFrame)
local toggleOther = createButtonWithOutline("TP Предметы", UDim2.new(0, 100, 0, 30), UDim2.new(0, 115, 0, 100), Color3.fromRGB(0, 0, 127), mainFrame)

local cooldownBox = Instance.new("TextBox")
cooldownBox.Text = "1"
cooldownBox.PlaceholderText = "КД ТП"
cooldownBox.Size = UDim2.new(0, 50, 0, 30)
cooldownBox.Position = UDim2.new(0, 5, 0, 140)
cooldownBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
cooldownBox.TextColor3 = Color3.new(0,0,0)
cooldownBox.Font = Enum.Font.Michroma
cooldownBox.TextScaled = true
cooldownBox.Parent = mainFrame

local coordsLabel = createTextLabelWithOutline("Корды", UDim2.new(1, -10, 0, 20), UDim2.new(0, 5, 0, 180), mainFrame)

local chestsCountLabel = createTextLabelWithOutline("Сундуков [", UDim2.new(0, 100, 0, 50), UDim2.new(0, 5, 0, 40), mainFrame)
local othersCountLabel = createTextLabelWithOutline("Предметов [", UDim2.new(0, 100, 0, 50), UDim2.new(0, 115, 0, 40), mainFrame)

-- Кнопка для включения/выключения автоподтверждения Prompts
local togglePromptBtn = createButtonWithOutline("Авто сбор [Вкл]", UDim2.new(0, 120, 0, 30), UDim2.new(0, 65, 0, 140), Color3.fromRGB(24, 0, 36), mainFrame)

local promptAutoActivate = false -- состояние автоподтверждения Prompts

togglePromptBtn.MouseButton1Click:Connect(function()
	promptAutoActivate = not promptAutoActivate
	togglePromptBtn.Text = "Авто сбор " .. (promptAutoActivate and "[Вкл]" or "[Выкл]")
	togglePromptBtn.BackgroundColor3 = promptAutoActivate and Color3.fromRGB(85, 0, 255) or Color3.fromRGB(24, 0, 36)
end)

local function getCooldown()
	local cd = tonumber(cooldownBox.Text)
	if cd == nil or cd < 0 then
		return 2
	end
	return cd
end

toggleChests.MouseButton1Click:Connect(function()
	teleportChests = not teleportChests
	toggleChests.BackgroundColor3 = teleportChests and Color3.fromRGB(255, 85, 0) or Color3.fromRGB(125, 0, 0)
end)

toggleOther.MouseButton1Click:Connect(function()
	teleportOthers = not teleportOthers
	toggleOther.BackgroundColor3 = teleportOthers and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(0, 0, 127)
end)

local function disableCollision(part)
	if part and part:IsA("BasePart") then
		part.CanCollide = false
	end
end

local function findClosestObject(position, radius)
	local closestPart = nil
	local closestDistance = math.huge
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Part") and obj.CanCollide then
			local height = obj.Position.Y
			if height >= MinHeight and height <= MaxHeight then -- фильтр по высоте
				local distance = (obj.Position - position).magnitude
				if distance <= radius then
					if distance < closestDistance then
						closestDistance = distance
						closestPart = obj
					end
				end
			end
		end
	end
	return closestPart
end

local function createBillboard(model)
	if model:FindFirstChildOfClass("BillboardGui") then
		return
	end

	local attachPart = nil
	for _, part in ipairs(model:GetChildren()) do
		if part:IsA("BasePart") then
			attachPart = part
			break
		end
	end

	if not attachPart then
		warn("Не найдена BasePart в модели: " .. model.Name)
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.Adornee = attachPart
	billboard.AlwaysOnTop = true
	billboard.Name = "Billboard_" .. model:GetFullName()
	billboard.Parent = model

	local textLabel = Instance.new("TextLabel")
	textLabel.Text = model.Name
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextScaled = true

	if string.lower(model.Name) == "chests" then
		textLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
	elseif string.lower(model.Name) == "other" then
		textLabel.TextColor3 = Color3.fromRGB(0, 0, 255)
	else
		textLabel.TextColor3 = Color3.new(1, 1, 1)
	end

	textLabel.Parent = billboard
end

local modelsCache = {
	chests = {},
	other = {}
}

local function findModels(name)
	local models = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and (string.lower(obj.Name) == string.lower(name)) then
			local part = obj:FindFirstChildWhichIsA("BasePart")
			if part then
				local height = part.Position.Y
				if height >= MinHeight and height <= MaxHeight then
					table.insert(models, obj)
				end
			end
		end
	end
	-- Обновляем кэш
	modelsCache[name] = models

	return models
end

local function updateCounts()
	local chestsModels = findModels("chests")
	local otherModels = findModels("other")
	chestsCountLabel.Text = "Сундуков [" .. #chestsModels .. "]"
	othersCountLabel.Text = "Предметов [" .. #otherModels .. "]"
end

local function updateCoords()
	local pos = character:FindFirstChild("HumanoidRootPart").Position
	coordsLabel.Text = string.format("Корды [X=%.1f] [Y=%.1f] [Z=%.1f]", pos.X, pos.Y, pos.Z)
end

local function activatePrompt(prompt)
	if prompt and prompt.Enabled then
		prompt:InputHoldBegin()
		wait(0.2)
		prompt:InputHoldEnd()
	end
end

-- Основной цикл
RunService.Heartbeat:Connect(function()
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
						local targetY = targetPart.Position.Y
						if targetY >= MinHeight and targetY <= MaxHeight then
							local newY = targetY
							if newY < MinHeight then newY = MinHeight end
							if newY > MaxHeight then newY = MaxHeight end
							hrp.CFrame = CFrame.new(targetPart.Position.X, newY, targetPart.Position.Z)
							lastTpTime = now

							disableCollision(hrp)

							local radius = 105
							local closestPart = findClosestObject(hrp.Position, radius)
							if closestPart then
								disableCollision(closestPart)
							end
						end
					end
				end
			end
		end
	end

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

updateCounts()
updateCoords()

coroutine.wrap(function()
	while true do
		wait(1)
		updateCounts()
		updateCoords()
	end
end)()
