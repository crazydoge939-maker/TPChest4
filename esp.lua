
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local workspace = game.Workspace

local HeightMin = 113
local HeightMax = 210

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportChestPanel"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Создаем основную панель
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 200, 0, 220)
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
title.Text = "AUTO FARM"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextScaled = true
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = panel

-- Кнопки [Сундуки]
local startChestButton = Instance.new("TextButton")
startChestButton.Size = UDim2.new(0.8, 0, 0, 40)
startChestButton.Position = UDim2.new(0, 20, 0, 130)
startChestButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
startChestButton.BorderSizePixel = 2
startChestButton.BorderColor3 = Color3.new(1, 1, 1)
startChestButton.Font = Enum.Font.SourceSansBold
startChestButton.TextSize = 16
startChestButton.TextScaled = true
startChestButton.Text = "Старт [Сундуки]"
startChestButton.TextColor3 = Color3.new(1, 1, 1)
startChestButton.Parent = panel

local stopChestButton = Instance.new("TextButton")
stopChestButton.Size = UDim2.new(0.8, 0, 0, 40)
stopChestButton.Position = UDim2.new(0, 20, 0, 130)
stopChestButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
stopChestButton.BorderSizePixel = 2
stopChestButton.BorderColor3 = Color3.new(1, 1, 1)
stopChestButton.Font = Enum.Font.SourceSansBold
stopChestButton.TextSize = 16
stopChestButton.TextScaled = true
stopChestButton.Text = "Стоп [Сундуки]"
stopChestButton.TextColor3 = Color3.new(1, 1, 1)
stopChestButton.Parent = panel
stopChestButton.Visible = false

-- Кнопки [Предметы]
--local startItemButton = Instance.new("TextButton")
--startItemButton.Size = UDim2.new(0.8, 0, 0, 40)
--startItemButton.Position = UDim2.new(0, 20, 0, 180)
--startItemButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
--startItemButton.BorderSizePixel = 2
--startItemButton.BorderColor3 = Color3.new(1, 1, 1)
--startItemButton.Font = Enum.Font.SourceSansBold
--startItemButton.TextSize = 16
--startItemButton.TextScaled = true
--startItemButton.Text = "Старт [Предметы]"
--startItemButton.TextColor3 = Color3.new(1, 1, 1)
--startItemButton.Parent = panel

--local stopItemButton = Instance.new("TextButton")
--stopItemButton.Size = UDim2.new(0.8, 0, 0, 40)
--stopItemButton.Position = UDim2.new(0, 20, 0, 180)
--stopItemButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
--stopItemButton.BorderSizePixel = 2
--stopItemButton.BorderColor3 = Color3.new(1, 1, 1)
--stopItemButton.Font = Enum.Font.SourceSansBold
--stopItemButton.TextSize = 16
--stopItemButton.TextScaled = true
--stopItemButton.Text = "Стоп [Предметы]"
--stopItemButton.TextColor3 = Color3.new(1, 1, 1)
--stopItemButton.Parent = panel
--stopItemButton.Visible = false

local chestCountLabel = Instance.new("TextLabel")
chestCountLabel.Size = UDim2.new(0, 80, 0, 80)
chestCountLabel.Position = UDim2.new(0, 10, 0, 40)
chestCountLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
chestCountLabel.BorderSizePixel = 0
chestCountLabel.Text = "Всего сундуков [0]"
chestCountLabel.Font = Enum.Font.SourceSans
chestCountLabel.TextSize = 16
chestCountLabel.TextScaled = true
chestCountLabel.TextColor3 = Color3.new(1, 1, 1)
chestCountLabel.Parent = panel

local itemCountLabel = Instance.new("TextLabel")
itemCountLabel.Size = UDim2.new(0, 80, 0, 80)
itemCountLabel.Position = UDim2.new(0, 110, 0, 40)
itemCountLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
itemCountLabel.BorderSizePixel = 0
itemCountLabel.Text = "Всего предметов [0]"
itemCountLabel.Font = Enum.Font.SourceSans
itemCountLabel.TextSize = 16
itemCountLabel.TextScaled = true
itemCountLabel.TextColor3 = Color3.new(1, 1, 1)
itemCountLabel.Parent = panel

local coordsLabel = Instance.new("TextLabel")
coordsLabel.Size = UDim2.new(1, -20, 0, 30)
coordsLabel.Position = UDim2.new(0, 10, 0, 180)
coordsLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
coordsLabel.BorderSizePixel = 0
coordsLabel.Text = "Координаты [X=0, Y=0, Z=0]"
coordsLabel.Font = Enum.Font.SourceSans
coordsLabel.TextSize = 14
coordsLabel.TextScaled = true
coordsLabel.TextColor3 = Color3.new(1, 1, 1)
coordsLabel.Parent = panel


-- Создание Линии
-- Таблицы для линий
local linesToChests = {}
local linesToOther = {}

local function createAttachment(parent)
	local att = Instance.new("Attachment")
	att.Parent = parent
	return att
end

local function createBeam(attachment0, attachment1, color)
	local beam = Instance.new("Beam")
	beam.Attachment0 = attachment0
	beam.Attachment1 = attachment1
	beam.Color = ColorSequence.new(color)
	beam.Width0 = 0.2
	beam.Width1 = 0.2
	beam.Parent = attachment0.Parent -- или в workspace
	beam.FaceCamera = true
	return beam
end

local linesToChests = {}
local linesToOther = {}

local function updateLines(targets, linesTable, color)
	-- Создаем или обновляем линии
	for i, target in ipairs(targets) do
		if not linesTable[i] then
			local attachmentPlayer = createAttachment(humanoidRootPart)
			local attachmentTarget = createAttachment(target)
			local beam = createBeam(attachmentPlayer, attachmentTarget, color)
			linesTable[i] = {
				beam = beam,
				attachmentPlayer = attachmentPlayer,
				attachmentTarget = attachmentTarget
			}
		end
		-- Обновляем позиции
		local lineData = linesTable[i]
		lineData.attachmentPlayer.WorldPosition = humanoidRootPart.Position
		lineData.attachmentTarget.WorldPosition = target.Position
		lineData.beam.Enabled = true
	end

	-- Удаляем лишние линии
	while #linesTable > #targets do
		local lineData = table.remove(linesTable)
		lineData.beam:Destroy()
		lineData.attachmentTarget:Destroy()
		lineData.attachmentPlayer:Destroy()
	end
end


-- Обновление координат
runService.RenderStepped:Connect(function()
	local pos = humanoidRootPart.Position
	coordsLabel.Text = string.format("Координаты                                                                                        [X=%.1f, Y=%.1f, Z=%.1f]", pos.X, pos.Y, pos.Z)
end)

-- Общие функции для поиска объектов
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
	local totalChestCount = #chests
	chestCountLabel.Text = "Сундуков [" .. tostring(totalChestCount) .. "]"
end

local function updateItemCount()
	local items = getAllObjectsByNames({"other"})
	local totalItemCount = #items
	itemCountLabel.Text = "Предметов [" .. tostring(totalItemCount) .. "]"
end

local activeHighlights = {}

local function clearHighlights()
	for _, highlight in ipairs(activeHighlights) do
		if highlight and highlight.Parent then
			highlight:Destroy()
		end
	end
	activeHighlights = {}
end

local function addHighlightToObjects(names)
	clearHighlights()
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and table.find(names, model.Name) then
			for _, part in pairs(model:GetChildren()) do
				if part:IsA("BasePart") then
					local highlight = Instance.new("Highlight")
					highlight.Adornee = part
					if model.Name == "other" then
						highlight.FillColor = Color3.new(0.5, 0, 0.5) -- фиолетовый
						highlight.OutlineColor = Color3.new(1, 0, 1)
					else
						highlight.FillColor = Color3.new(0, 0.490196, 0) -- зеленый
						highlight.OutlineColor = Color3.new(0, 1, 0)
					end
					highlight.FillTransparency = 0.2
					highlight.OutlineTransparency = 0
					highlight.Parent = part
					table.insert(activeHighlights, highlight)
				end
			end
		end
	end
end

local teleportingChest = false
local teleportingItem = false

local function startTeleportChestCycle()
	if teleportingChest then return end
	teleportingChest = true
	startChestButton.Visible = false
	stopChestButton.Visible = true

	coroutine.wrap(function()
		while teleportingChest do
			local chests = getAllObjectsByNames({"chests"})
			local accessibleChests = {}

			-- Проверка сундуков
			for _, chest in pairs(chests) do
				local accessible = false
				for _, part in pairs(chest:GetChildren()) do
					if part:IsA("BasePart") then
						local y = part.Position.Y
						if y >= HeightMin and y <= HeightMax then
							accessible = true
							break
						end
					end
				end
				if accessible then table.insert(accessibleChests, chest) end
			end

			-- Телепортируемся к случайному сундуку
			if #accessibleChests > 0 then
				local selectedChest = accessibleChests[math.random(1, #accessibleChests)]
				for _, part in pairs(selectedChest:GetChildren()) do
					if part:IsA("BasePart") then
						local y = part.Position.Y
						if y >= HeightMin and y <= HeightMax then
							humanoidRootPart.CFrame = CFrame.new(part.Position.X, y + 3, part.Position.Z)
							break
						end
					end
				end
			end
			wait(0.1)
		end
	end)()
end

--local function startTeleportItemCycle()
--	if teleportingItem then return end
--	teleportingItem = true
--	startItemButton.Visible = false
--	stopItemButton.Visible = true

--	coroutine.wrap(function()
--		while teleportingItem do
--			local items = getAllObjectsByNames({"other"})
--			local accessibleItems = {}

--			-- Проверка сундуков
--			for _, item in pairs(items) do
--				local accessible = false
--				for _, part in pairs(item:GetChildren()) do
--					if part:IsA("Part") then
--						local y = part.Position.Y
--						if y >= HeightMin and y <= HeightMax then
--							accessible = true
--							break
--						end
--					end
--				end
--				if accessible then table.insert(accessibleItems, item) end
--			end

--			-- Телепортируемся к случайному предмету
--			if #accessibleItems > 0 then
--				local selectedItem = accessibleItems[math.random(1, #accessibleItems)]
--				for _, part in pairs(selectedItem:GetChildren()) do
--					if part:IsA("Part") then
--						local y = part.Position.Y
--						if y >= HeightMin and y <= HeightMax then
--							humanoidRootPart.CFrame = CFrame.new(part.Position.X, y + 3, part.Position.Z)
--							break
--						end
--					end
--				end
--			end
--			wait(0.1)
--		end
--	end)()
--end

local function stopTeleportChestCycle()
	teleportingChest = false
	startChestButton.Visible = true
	stopChestButton.Visible = false
end

--local function stopTeleportItemCycle()
--	teleportingItem = false
--	startItemButton.Visible = true
--	stopItemButton.Visible = false
--end

startChestButton.MouseButton1Click:Connect(startTeleportChestCycle)
stopChestButton.MouseButton1Click:Connect(stopTeleportChestCycle)

--startItemButton.MouseButton1Click:Connect(startTeleportItemCycle)
--stopItemButton.MouseButton1Click:Connect(stopTeleportItemCycle)

-- Обновляем и подсвечиваем каждые 5 секунд
spawn(function()
	while true do
		updateChestCount()
		updateItemCount()
		addHighlightToObjects({"chests", "other"})
		wait(0.1)
	end
end)

-- Изначальная подсветка
addHighlightToObjects({"chests", "other"})

-- Обновление линий каждый фрейм
runService.RenderStepped:Connect(function()
	local chests = getAllObjectsByNames({"chests"})
	local items = getAllObjectsByNames({"other"})

	updateLines(chests, linesToChests, Color3.new(0.333333, 1, 0)) -- фиолетовый для сундуков
	updateLines(items, linesToOther, Color3.new(0.333333, 0, 1)) -- желтый (или любой другой цвет) для предметов
end)
