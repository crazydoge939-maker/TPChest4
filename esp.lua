local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local runService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportChestGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Создаем кнопку для запуска
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 200, 0, 50)
startButton.Position = UDim2.new(0.5, -100, 0.9, -25)
startButton.Text = "Начать телепорт к сункам"
startButton.Parent = screenGui

-- Создаем кнопку для остановки
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0, 200, 0, 50)
stopButton.Position = UDim2.new(0.5, -100, 0.8, -25)
stopButton.Text = "Остановить"
stopButton.Parent = screenGui
stopButton.Visible = false

-- Создаем текст для отображения количества сундуков
local chestCountLabel = Instance.new("TextLabel")
chestCountLabel.Size = UDim2.new(0, 250, 0, 50)
chestCountLabel.Position = UDim2.new(0.5, -125, 0.1, 0)
chestCountLabel.Text = "Всего сундуков: 0"
chestCountLabel.BackgroundColor3 = Color3.new(0, 0, 0)
chestCountLabel.TextColor3 = Color3.new(1, 1, 1)
chestCountLabel.Parent = screenGui

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
    chestCountLabel.Text = "Всего сундуков: " .. count
end

-- Обновляем счетчик сундуков каждые 5 секунд
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

local function teleportToRandomAccessibleChest()
    local chests = getAllChests()
    local accessibleChests = findAccessibleChest(chests)
    if #accessibleChests == 0 then return end

    local randomChest = accessibleChests[math.random(1, #accessibleChests)]
    for _, part in pairs(randomChest:GetChildren()) do
        if part:IsA("BasePart") then
            local y = part.Position.Y
            if y >= 114 and y <= 180 then
                humanoidRootPart.CFrame = CFrame.new(part.Position.X, y + 3, part.Position.Z)
                break
            end
        end
    end
end

local function activateNearbyProximityPrompts()
    local radius = 15
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") then
            local prompt = model:FindFirstChildOfClass("ProximityPrompt")
            if prompt and prompt.Enabled then
                local modelPos = model:GetModelCFrame() and model:GetModelCFrame().Position or nil
                if not modelPos then continue end
                local distance = (humanoidRootPart.Position - modelPos).Magnitude
                if distance <= radius then
                    -- Активируем Prompt
                    prompt:InputBegan({UserInputType = Enum.UserInputType.MouseButton1}, true)
                end
            end
        end
    end
end

local function startTeleportCycle()
    if teleporting then return end
    teleporting = true
    startButton.Visible = false
    stopButton.Visible = true

    -- Сделать игрока закрепленным
    if character and character:FindFirstChildOfClass("Humanoid") then
        character:FindFirstChildOfClass("Humanoid").PlatformStand = true
    end

    local function cycle()
        while teleporting do
            -- Активируем Prompt
            activateNearbyProximityPrompts()
            -- Телепортируемся, если лимит по высоте позволяет
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
    end

    coroutine.wrap(cycle)()
end

local function stopTeleportCycle()
    teleporting = false
    startButton.Visible = true
    stopButton.Visible = false

    -- Разблокировать игрока
    if character and character:FindFirstChildOfClass("Humanoid") then
        character:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end
end

startButton.MouseButton1Click:Connect(startTeleportCycle)
stopButton.MouseButton1Click:Connect(stopTeleportCycle)

-- Подсветка сундуков
local function addHighlightToChests()
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model.Name == "chests" then
            for _, part in pairs(model:GetChildren()) do
                if part:IsA("BasePart") then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = part
                    highlight.FillColor = Color3.new(1, 1, 0) -- Желтый цвет
                    highlight.OutlineColor = Color3.new(1, 1, 0)
                    highlight.FillTransparency = 0.2
                    highlight.OutlineTransparency = 0
                    highlight.Parent = part
                end
            end
        end
    end
end

-- Вызов функции для добавления подсветки
addHighlightToChests()
