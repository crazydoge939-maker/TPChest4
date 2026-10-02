-- Trick or Treat Door Teleport (LocalScript, StarterPlayerScripts)
-- Авто-телепорт к случайной двери из Model TrickorTreatDoors по интервалу.
-- При телепорте к двери её ProximityPrompt активируется автоматически (удержание 0).

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local CONFIG = {
	MapName = "map",
	EventName = "HALLOWEEN",
	ModelName = "TrickorTreatDoors",
	DoorName = "Door",
	DefaultInterval = 5,
	MinInterval = 0,
	StandoffDistance = 3, -- расстояние от двери при телепорте
}

local enabled = false
local interval = CONFIG.DefaultInterval

-- ================== ПОИСК ДВЕРЕЙ ==================

local function getDoorsModel()
	local map = workspace:FindFirstChild(CONFIG.MapName)
	if not map then
		return nil
	end
	local event = map:FindFirstChild(CONFIG.EventName)
	if not event then
		return nil
	end
	local model = event:FindFirstChild(CONFIG.ModelName)
	if model and model:IsA("Model") then
		return model
	end
	return nil
end

-- Ищет ProximityPrompt внутри Door -> Attachment
local function getDoorPrompt(door)
	local attachment = door:FindFirstChildOfClass("Attachment")
	if not attachment then
		return nil
	end
	return attachment:FindFirstChildOfClass("ProximityPrompt")
end

-- Возвращает двери, у которых ProximityPrompt существует и включен
local function getValidDoors()
	local model = getDoorsModel()
	if not model then
		return {}
	end
	local doors = {}
	for _, child in model:GetChildren() do
		if child:IsA("BasePart") and child.Name == CONFIG.DoorName then
			local prompt = getDoorPrompt(child)
			if prompt and prompt.Enabled then
				table.insert(doors, child)
			end
		end
	end
	return doors
end

-- ================== НУЛЕВОЕ УДЕРЖАНИЕ ДЛЯ ВСЕХ ПРОМПТОВ ==================

-- Ставит HoldDuration = 0 у промпта двери
local function applyZeroHold(door)
	if not (door:IsA("BasePart") and door.Name == CONFIG.DoorName) then
		return
	end
	local prompt = getDoorPrompt(door)
	if prompt then
		prompt.HoldDuration = 0
	end
end

-- Применяет нулевое удержание ко всем текущим дверям и следит за новыми
local function setupZeroHold()
	local model = getDoorsModel()
	if not model then
		return false
	end
	for _, door in model:GetChildren() do
		applyZeroHold(door)
	end
	model.ChildAdded:Connect(applyZeroHold)
	-- Если ProximityPrompt добавляется в уже существующую дверь позже
	model.DescendantAdded:Connect(function(desc)
		if desc:IsA("ProximityPrompt") then
			desc.HoldDuration = 0
		end
	end)
	return true
end

-- При появлении скрипта сразу ставим удержание 0 у всех промптов
-- (если модель ещё не загружена — ждём её появления)
task.spawn(function()
	while not setupZeroHold() do
		task.wait(0.5)
	end
end)

-- ================== ТЕЛЕПОРТ ==================

local function getCharacterRoot()
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart")
end

-- Активирует ProximityPrompt двери с нулевым удержанием.
-- Блокирующая: ждёт срабатывания с повторами, чтобы телепорт к следующей двери
-- не начинался, пока промпт текущей двери не активирован (или не истекли попытки).
local function triggerPrompt(door)
	local prompt = getDoorPrompt(door)
	if not prompt then
		return false
	end

	local originalLineOfSight = prompt.RequiresLineOfSight

	local triggered = false
	local conn = prompt.Triggered:Connect(function()
		triggered = true
	end)

	prompt.RequiresLineOfSight = false -- промпт виден с любой стороны двери

	-- Промпт можно активировать только когда он отображён на экране.
	-- Сразу после телепорта ProximityPromptService ещё не обнаружил игрока,
	-- а камера не успела обновиться — поэтому пробуем много раз с задержкой.
	for _ = 1, 20 do
		if triggered then
			break
		end
		if not prompt.Parent or not prompt.Enabled then
			break -- промпт удалён или выключен игрой (например, кулдаун двери)
		end

		-- Если игрока унесло от двери (другой телепорт, падение и т.п.) — прекращаем
		local currentRoot = getCharacterRoot()
		if not currentRoot then
			break
		end
		if (currentRoot.Position - door.Position).Magnitude > prompt.MaxActivationDistance + 5 then
			break
		end

		prompt.HoldDuration = 0 -- удержание 0 — срабатывает мгновенно
		prompt.RequiresLineOfSight = false

		prompt:InputHoldBegin()
		task.wait(0.15)
		prompt:InputHoldEnd()

		if not triggered then
			task.wait(0.25)
		end
	end

	conn:Disconnect()

	-- Возвращаем исходное значение после срабатывания
	if prompt and prompt.Parent then
		prompt.RequiresLineOfSight = originalLineOfSight
	end

	return triggered
end

local function teleportToRandomDoor()
	local doors = getValidDoors()
	if #doors == 0 then
		return false
	end

	local door = doors[math.random(1, #doors)]
	local root = getCharacterRoot()
	if not root then
		return false
	end

	-- Встаём перед дверью (со стороны -Z) и разворачиваемся к ней
	local offset = CFrame.new(0, 0, -(door.Size.Z / 2 + CONFIG.StandoffDistance))
	local targetPos = (door.CFrame * offset).Position
	root.CFrame = CFrame.lookAt(targetPos, door.Position)

	-- Даём движку время применить телепорт, а камере — обновиться,
	-- затем активируем промпт (блокирующе, до срабатывания)
	task.wait(0.25)
	triggerPrompt(door)
	return true
end

-- ================== АВТО-ТЕЛЕПОРТ (по интервалу) ==================

task.spawn(function()
	local lastTp = 0
	while true do
		if enabled then
			if os.clock() - lastTp >= interval then
				if teleportToRandomDoor() then
					lastTp = os.clock()
				end
			end
		end
		task.wait(0.2)
	end
end)

-- ================== GUI (на Scale) ==================

local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TrickOrTreatTpGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromScale(0.18, 0.22) -- масштаб от размера экрана
main.Position = UDim2.new(0.01, 0, 0.5, 0)
main.AnchorPoint = Vector2.new(0, 0.5)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui

-- ================== ПЕРЕТАСКИВАНИЕ ПАНЕЛИ ==================
-- Свойство Draggable больше не работает, поэтому делаем перетаскивание вручную

local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragStart = nil
local startPos = nil

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

main.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging
		and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.fromScale(0.92, 0.15)
title.Position = UDim2.fromScale(0.04, 0.04)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 170, 60)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Text = "Trick or Treat TP"
title.Parent = main

-- Кнопка Вкл/Выкл
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.fromScale(0.92, 0.18)
toggleButton.Position = UDim2.new(0.04, 0, 0.24, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextScaled = true
toggleButton.Text = "Тп: ВЫКЛ"
toggleButton.Parent = main
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- Поле интервала
local intervalLabel = Instance.new("TextLabel")
intervalLabel.Name = "IntervalLabel"
intervalLabel.Size = UDim2.fromScale(0.55, 0.16)
intervalLabel.Position = UDim2.new(0.04, 0, 0.48, 0)
intervalLabel.BackgroundTransparency = 1
intervalLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
intervalLabel.Font = Enum.Font.Gotham
intervalLabel.TextScaled = true
intervalLabel.TextXAlignment = Enum.TextXAlignment.Left
intervalLabel.Text = "Интервал (сек):"
intervalLabel.Parent = main

local intervalBox = Instance.new("TextBox")
intervalBox.Name = "IntervalBox"
intervalBox.Size = UDim2.fromScale(0.3, 0.16)
intervalBox.Position = UDim2.new(0.66, 0, 0.48, 0)
intervalBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
intervalBox.TextColor3 = Color3.new(1, 1, 1)
intervalBox.Font = Enum.Font.Gotham
intervalBox.TextScaled = true
intervalBox.Text = tostring(CONFIG.DefaultInterval)
intervalBox.ClearTextOnFocus = false
intervalBox.Parent = main
local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 8)
boxCorner.Parent = intervalBox

-- Статус
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.fromScale(0.92, 0.12)
statusLabel.Position = UDim2.new(0.04, 0, 0.7, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = ""
statusLabel.Parent = main

-- ================== КАМЕРА СВЕРХУ ВНИЗ ==================

local RunService = game:GetService("RunService")

local cameraHeight = 40 -- высота камеры над игроком
local cameraConn = nil

-- Каждый кадр держим камеру над игроком и смотрим вниз
local function startTopDownCamera()
	if cameraConn then
		return -- уже включена
	end
	cameraConn = RunService.RenderStepped:Connect(function()
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		local root = getCharacterRoot()
		if not root then
			return
		end
		-- Камера пересоздаётся при респавне — переключаем в Scriptable заново
		if camera.CameraType ~= Enum.CameraType.Scriptable then
			camera.CameraType = Enum.CameraType.Scriptable
		end
		local pos = root.Position
		camera.CFrame = CFrame.lookAt(
			Vector3.new(pos.X, pos.Y + cameraHeight, pos.Z),
			pos
		)
	end)
end

-- Возвращаем камеру в обычный режим (вид от персонажа)
local function stopTopDownCamera()
	if cameraConn then
		cameraConn:Disconnect()
		cameraConn = nil
	end
	local camera = workspace.CurrentCamera
	if camera then
		camera.CameraType = Enum.CameraType.Custom
	end
end

-- ================== ЛОГИКА GUI ==================

local function updateGui()
	if enabled then
		toggleButton.BackgroundColor3 = Color3.fromRGB(70, 160, 80)
		toggleButton.Text = "Тп: ВКЛ"
	else
		toggleButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
		toggleButton.Text = "Тп: ВЫКЛ"
	end

	local doorCount = #getValidDoors()
	if doorCount == 0 then
		statusLabel.Text = "Двери не найдены!"
		statusLabel.TextColor3 = Color3.fromRGB(230, 90, 90)
	else
		statusLabel.Text = "Дверей доступно: " .. doorCount
		statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	end
end

toggleButton.MouseButton1Click:Connect(function()
	enabled = not enabled
	if enabled then
		startTopDownCamera()
	else
		stopTopDownCamera()
	end
	updateGui()
end)

-- ================== ВНЕШНЕЕ УПРАВЛЕНИЕ (для AutoKill) ==================
_G.getTrickOrTreatEnabled = function()
	return enabled
end

_G.setTrickOrTreatEnabled = function(state)
	if enabled ~= state then
		enabled = state
		if enabled then
			startTopDownCamera()
		else
			stopTopDownCamera()
		end
		updateGui()
	end
end

intervalBox.FocusLost:Connect(function()
	local value = tonumber(intervalBox.Text)
	if value and value >= CONFIG.MinInterval then
		interval = value
	else
		interval = CONFIG.DefaultInterval
		intervalBox.Text = tostring(interval)
	end
end)

-- Обновляем счётчик дверей периодически
local doorsModel = getDoorsModel()
if doorsModel then
	doorsModel.ChildAdded:Connect(updateGui)
	doorsModel.ChildRemoved:Connect(updateGui)
end

task.spawn(function()
	while true do
		updateGui()
		task.wait(2)
	end
end)

updateGui()
