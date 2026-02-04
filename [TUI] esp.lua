-- Вставьте этот скрипт в StarterPlayerScripts

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Настройки
local teleporterEnabled = true
local cooldownTime = 5 -- по умолчанию 5 секунд
local lastTeleportTime = 0
local minY = 110
local maxY = 220

-- GUI Создание
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Основная панель
local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 300, 0, 200)
Panel.Position = UDim2.new(0.5, -150, 0.5, -100)
Panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Panel.BorderSizePixel = 0
Panel.Parent = ScreenGui

-- Возможность перемещать панель
local dragging = false
local dragInput, dragStart, startPos

Panel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Panel.Position
    end
end)

Panel.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

Panel.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input.Position
        local delta = dragInput - dragStart
        Panel.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
    end
end)

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Text = "TP Panel"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.new(1,1,1)
Title.Parent = Panel

-- Кнопка для включения/выключения
local toggleButton = Instance.new("TextButton")
toggleButton.Text = "Включить/Выключить"
toggleButton.Size = UDim2.new(1, -20, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 40)
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Parent = Panel

-- Кнопка для TP сундуков
local tpChestsButton = Instance.new("TextButton")
tpChestsButton.Text = "TP Сундуки"
tpChestsButton.Size = UDim2.new(1, -20, 0, 30)
tpChestsButton.Position = UDim2.new(0, 10, 0, 80)
tpChestsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
tpChestsButton.TextColor3 = Color3.new(1,1,1)
tpChestsButton.Parent = Panel

-- Кнопка для TP предметов
local tpOtherButton = Instance.new("TextButton")
tpOtherButton.Text = "TP Предметы"
tpOtherButton.Size = UDim2.new(1, -20, 0, 30)
tpOtherButton.Position = UDim2.new(0, 10, 0, 120)
tpOtherButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
tpOtherButton.TextColor3 = Color3.new(1,1,1)
tpOtherButton.Parent = Panel

-- Время кулдауна
local cooldownLabel = Instance.new("TextLabel")
cooldownLabel.Text = "КД (сек):"
cooldownLabel.Size = UDim2.new(0, 60, 0, 20)
cooldownLabel.Position = UDim2.new(0, 10, 0, 160)
cooldownLabel.BackgroundTransparency = 1
cooldownLabel.TextColor3 = Color3.new(1,1,1)
cooldownLabel.Parent = Panel

local cooldownBox = Instance.new("TextBox")
cooldownBox.Text = tostring(cooldownTime)
cooldownBox.Size = UDim2.new(0, 50, 0, 20)
cooldownBox.Position = UDim2.new(0, 70, 0, 160)
cooldownBox.BackgroundColor3 = Color3.fromRGB(70,70,70)
cooldownBox.TextColor3 = Color3.new(1,1,1)
cooldownBox.Parent = Panel

-- Координаты игрока
local coordsLabel = Instance.new("TextLabel")
coordsLabel.Text = "Координаты: "
coordsLabel.Size = UDim2.new(1, -20, 0, 20)
coordsLabel.Position = UDim2.new(0, 10, 0, 190)
coordsLabel.BackgroundTransparency = 1
coordsLabel.TextColor3 = Color3.new(1,1,1)
coordsLabel.Parent = Panel

-- Счётчики
local chestsCountLabel = Instance.new("TextLabel")
chestsCountLabel.Text = "Честы: 0"
chestsCountLabel.Size = UDim2.new(0.5, -15, 0, 20)
chestsCountLabel.Position = UDim2.new(0, 10, 0, 220)
chestsCountLabel.BackgroundTransparency = 1
chestsCountLabel.TextColor3 = Color3.new(1,1,1)
chestsCountLabel.Parent = Panel

local othersCountLabel = Instance.new("TextLabel")
othersCountLabel.Text = "Предметы: 0"
othersCountLabel.Size = UDim2.new(0.5, -15, 0, 20)
othersCountLabel.Position = UDim2.new(0.5, 5, 0, 220)
othersCountLabel.BackgroundTransparency = 1
othersCountLabel.TextColor3 = Color3.new(1,1,1)
othersCountLabel.Parent = Panel

-- Переменные
local tpActive = true

toggleButton.MouseButton1Click:Connect(function()
    tpActive = not tpActive
    if tpActive then
        toggleButton.Text = "Выключить"
        toggleButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    else
        toggleButton.Text = "Включить"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
    end
end)

-- Обновление кулдауна
cooldownBox.FocusLost:Connect(function()
    local val = tonumber(cooldownBox.Text)
    if val and val >= 0 then
        cooldownTime = val
    else
        cooldownBox.Text = tostring(cooldownTime)
    end
end)

-- Основная логика
local function getModelsByName(name)
    local models = {}
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and (string.lower(model.Name) == "chests" or string.lower(model.Name) == "other") then
            table.insert(models, model)
        end
    end
    return models
end

local function updateCounts()
    local chestsCount = 0
    local othersCount = 0
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") then
            local nameLower = string.lower(model.Name)
            if nameLower == "chests" then
                chestsCount = chestsCount + 1
            elseif nameLower == "other" then
                othersCount = othersCount + 1
            end
        end
    end
    chestsCountLabel.Text = "Честы: " .. chestsCount
    othersCountLabel.Text = "Предметы: " .. othersCount
end

local function createBillboard(model)
    -- Удаляем предыдущий BillboardGui, если есть
    local existing = model:FindFirstChildOfClass("BillboardGui")
    if existing then existing:Destroy() end

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(2, 0, 1, 0)
    billboard.Adornee = model:FindFirstChildWhichIsA("BasePart")
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = model

    local textLabel = Instance.new("TextLabel")
    textLabel.Text = model.Name
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1,1,1)
    textLabel.TextStrokeColor3 = Color3.new(0,0,0)
    textLabel.TextStrokeTransparency = 0
    textLabel.Parent = billboard
end

local function updateBillboards()
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and (string.lower(model.Name) == "chests" or string.lower(model.Name) == "other") then
            createBillboard(model)
        end
    end
end

local function teleportPlayer(targetPosition)
    local y = targetPosition.Y
    if y < minY then y = minY end
    if y > maxY then y = maxY end
    humanoidRootPart.CFrame = CFrame.new(targetPosition.X, y, targetPosition.Z)
end

local function getRandomModel()
    local models = getModelsByName()
    if #models == 0 then return nil end
    return models[math.random(1, #models)]
end

local function getPlayerPosition()
    local pos = humanoidRootPart.Position
    coordsLabel.Text = string.format("Координаты: %.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
end

-- Основной цикл
RunService.Heartbeat:Connect(function()
    getPlayerPosition()
    updateCounts()
    updateBillboards()
    if tpActive and tick() - lastTeleportTime > cooldownTime then
        local model = getRandomModel()
        if model and model:FindFirstChildWhichIsA("BasePart") then
            local targetPos = model:GetPrimaryPartCFrame().p
            teleportPlayer(targetPos)
            lastTeleportTime = tick()
        end
    end
end)

-- Обработка кнопок
tpChestsButton.MouseButton1Click:Connect(function()
    -- Можно дополнительно реализовать выбор модели, если нужно
    -- В данном случае телепорт к случайной модели с именем "chests"
    local chestsModels = {}
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and string.lower(model.Name) == "chests" then
            table.insert(chestsModels, model)
        end
    end
    if #chestsModels > 0 then
        local model = chestsModels[math.random(1, #chestsModels)]
        if model and model:FindFirstChildWhichIsA("BasePart") then
            local targetPos = model:GetPrimaryPartCFrame().p
            teleportPlayer(targetPos)
        end
    end
end)

tpOtherButton.MouseButton1Click:Connect(function()
    local otherModels = {}
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and string.lower(model.Name) == "other" then
            table.insert(otherModels, model)
        end
    end
    if #otherModels > 0 then
        local model = otherModels[math.random(1, #otherModels)]
        if model and model:FindFirstChildWhichIsA("BasePart") then
            local targetPos = model:GetPrimaryPartCFrame().p
            teleportPlayer(targetPos)
        end
    end
end)

-- Обновление через каждую секунду
while true do
    wait(1)
    updateCounts()
    updateBillboards()
end
