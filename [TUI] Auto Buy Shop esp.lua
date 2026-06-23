local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local isEnabled = false
local running = false

-- Allowed ObjectText values
local ALLOWED_OBJECTS = {
	["Purchase Wood!"] = true,
	["Purchase Stone!"] = true,
    ["Purchase Rusty Metal!"] = true,
	["Purchase Metal!"] = true,
	["Purchase Line Paper!"] = true,
	["Purchase Leather!"] = true,
	["Purchase Rope!"] = true,
	["Purchase Meat!"] = true,
	["Purchase Orb!"] = true,
	["Purchase Cursed Orb!"] = true,
	["Purchase Holy Orb!"] = true,
	["Purchase Shattered Chain!"] = true,
	["Purchase Holy Chain!"] = true,
	["Purchase Dark Chest!"] = true,
	["Purchase Light Chest!"] = true,
	["Purchase Radioactive Cup!"] = true,
}

-- ===================== UI =====================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Auto Buy Shop"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.new(0.1, 0, 0.1, 0)
frame.Position = UDim2.new(0.5, 0, 0, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(80, 80, 120)
frameStroke.Thickness = 1.5
frameStroke.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0.3, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ Auto Teleport"
title.TextColor3 = Color3.fromRGB(220, 220, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(0.5, 0, 0.2, 0)
statusLabel.Position = UDim2.new(0.025, 0, 0.4, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: OFF"
statusLabel.TextColor3 = Color3.fromRGB(180, 80, 80)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, 0, 0.3, 0)
toggleButton.Position = UDim2.new(0, 0, 0.7, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
toggleButton.Text = "OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.BorderSizePixel = 0
toggleButton.AutoButtonColor = true
toggleButton.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleButton

-- ===================== TOGGLE LOGIC =====================

local function updateUI()
    if isEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        toggleButton.Text = "ON"
        statusLabel.Text = "Status: ON"
        statusLabel.TextColor3 = Color3.fromRGB(80, 200, 100)
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        toggleButton.Text = "OFF"
        statusLabel.Text = "Status: OFF"
        statusLabel.TextColor3 = Color3.fromRGB(180, 80, 80)
    end
end

-- ===================== TELEPORT & PROMPT LOGIC =====================

local function findProximityPrompt(model)
    local prompt = model:FindFirstChildOfClass("ProximityPrompt")
    if prompt then return prompt end
    for _, desc in model:GetDescendants() do
        if desc:IsA("ProximityPrompt") then
            return desc
        end
    end
    return nil
end

local function isPromptAllowed(prompt)
    if not prompt then return false end
    local objectText = prompt.ObjectText
    if objectText and ALLOWED_OBJECTS[objectText] then
        return true
    end
    return false
end

local function waitForPrompt(model, maxTime)
    local elapsed = 0
    while elapsed < maxTime do
        if not model or not model.Parent then return nil end
        local prompt = findProximityPrompt(model)
        if prompt and prompt.Enabled and isPromptAllowed(prompt) then
            return prompt
        end
        task.wait(0.3)
        elapsed += 0.3
    end
    return nil
end

local function teleportAndActivate(model)
    if not isEnabled then return end
    if not model:IsA("Model") or model.Name ~= "Model" then return end
    if not model or not model.Parent then return end

    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Teleport to model
    local modelPivot = model:GetPivot()
    local teleportPos = modelPivot.Position + Vector3.new(0, 3, 0)
    hrp.CFrame = CFrame.new(teleportPos)

    -- Wait for allowed ProximityPrompt (up to 6 seconds)
    local prompt = waitForPrompt(model, 6)
    if not prompt then return end
    if not model or not model.Parent then return end

    -- Wait for physics and prompt to be ready
    task.wait(0.5)

    -- Activate the prompt
    if prompt and prompt.Enabled and prompt.Parent and isEnabled then
        prompt.HoldDuration = 0
        task.wait(0.1)
        prompt:InputHoldBegin()
        task.wait(0.15)
        prompt:InputHoldEnd()
    end
end

-- ===================== MAIN LOOP =====================

local function mainLoop()
    while running do
        if isEnabled then
            -- Search for Model in entire Workspace
            for _, obj in Workspace:GetDescendants() do
                if obj:IsA("Model") and obj.Name == "Model" and obj.Parent then
                    -- Check if prompt has allowed ObjectText
                    local prompt = findProximityPrompt(obj)
                    if isPromptAllowed(prompt) then
                        teleportAndActivate(obj)
                        break -- Process one at a time, then loop again
                    end
                end
            end
        end
        task.wait(0.5)
    end
end

-- ===================== BUTTON HANDLER =====================

toggleButton.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    updateUI()

    if isEnabled then
        running = true
        task.spawn(mainLoop)
    else
        running = false
    end
end)

-- Initialize UI state
updateUI()
