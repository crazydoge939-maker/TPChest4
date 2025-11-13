local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local runService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local MinHeight = 114
local MaxHeight = 180

local teleporting = false -- чтобы стартовать/остановить цикл

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportChestGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Создаем кнопку для запуска
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 200, 0, 50)
startButton.Position = UDim2.new(0.5, -100, 0.9, -25)
startButton.Text = "Начать телепорт к сундукам"
startButton.Parent = screenGui

-- Создаем кнопку для остановки
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0, 200, 0, 50)
stopButton.Position = UDim2.new(0.5, -100, 0.8, -25)
stopButton.Text = "Остановить"
stopButton.Parent = screenGui
stopButton.Visible = false

local function getAllChests()
	local chests = {}
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model.Name == "chests" then
			table.insert(chests, model)
		end
	end
	return chests
end

local function findAccessibleChest(chests)
	local accessibleChests = {}
	for _, chest in pairs(chests) do
		local accessible = false
		for _, part in pairs(chest:GetChildren()) do
			if part:IsA("BasePart") then
				local y = part.Position.Y
				if y >= MinHeight and y <= MaxHeight then
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
			if y > MaxHeight or y < MinHeight then
				-- Не телепортируемся на сундук вне лимита
				return
			end
			humanoidRootPart.CFrame = CFrame.new(part.Position.X, y + 3, part.Position.Z)
			break
		end
	end
end

local function startTeleportCycle()
	if teleporting then return end
	teleporting = true
	startButton.Visible = false
	stopButton.Visible = true

	local function cycle()
		while teleporting do
			-- Телепортируемся, если лимит по высоте позволяет
			local chests = getAllChests()
			local accessibleChests = findAccessibleChest(chests)
			if #accessibleChests > 0 then
				local selectedChest = accessibleChests[math.random(1, #accessibleChests)]
				local validPartFound = false
				for _, part in pairs(selectedChest:GetChildren()) do
					if part:IsA("BasePart") then
						local y = part.Position.Y
						if y >= MinHeight and y <= MaxHeight then
							humanoidRootPart.CFrame = CFrame.new(part.Position.X, y + 3, part.Position.Z)
							validPartFound = true
							break
						end
					end
				end
			end
			wait(0.5)
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
