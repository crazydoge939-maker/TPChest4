local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Навигация
local navigationHistory = {}
local currentObject = nil
local currentHighlights = {}
local currentFolderConnections = {}
local highlightedObject = nil -- для переключения подсветки
local clickSelectEnabled = false -- выбор объектов кликом в 3D мире
local cameraModeEnabled = false -- режим камеры: при выборе объекта камера летит к нему
local lastSelectedObject = nil -- последний выбранный объект (для ТП)

-- Состояние орбитальной камеры
local cameraTargetPos = Vector3.new(0, 0, 0)
local cameraYaw = 0
local cameraPitch = 0
local cameraDistance = 30
local rightMouseDragging = false
local cameraTweening = false

-- Forward-declaration
local updateCameraCFrame

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FolderExplorerGUI"
screenGui.Parent = playerGui

-- Левая панель
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 130, 0, 200)
panel.Position = UDim2.new(0.01, 0, 0.05, 0)
panel.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
panel.BorderSizePixel = 0
panel.BackgroundTransparency = 0.05
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(90, 90, 110)
panelStroke.Thickness = 1.5
panelStroke.Parent = panel

-- Шапка панели
local panelHeader = Instance.new("Frame")
panelHeader.Size = UDim2.new(1, 0, 0, 28)
panelHeader.Position = UDim2.new(0, 0, 0, 0)
panelHeader.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
panelHeader.BorderSizePixel = 0
panelHeader.Parent = panel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = panelHeader

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -84, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Объекты"
title.TextColor3 = Color3.fromRGB(235, 235, 245)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panelHeader

-- Кнопка переключения видимости 2-й панели (Контент)
local toggleContentBtn = Instance.new("TextButton")
toggleContentBtn.Name = "ToggleContent"
toggleContentBtn.Size = UDim2.new(0, 18, 0, 20)
toggleContentBtn.Position = UDim2.new(1, -40, 0.5, -10)
toggleContentBtn.Text = "📋"
toggleContentBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 60)
toggleContentBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleContentBtn.TextScaled = true
toggleContentBtn.Font = Enum.Font.SourceSansBold
toggleContentBtn.Parent = panelHeader

local toggleContentCorner = Instance.new("UICorner")
toggleContentCorner.CornerRadius = UDim.new(0, 6)
toggleContentCorner.Parent = toggleContentBtn

-- Кнопка переключения видимости 3-й панели (Свойства)
local togglePropsBtn = Instance.new("TextButton")
togglePropsBtn.Name = "ToggleProps"
togglePropsBtn.Size = UDim2.new(0, 18, 0, 20)
togglePropsBtn.Position = UDim2.new(1, -20, 0.5, -10)
togglePropsBtn.Text = "⚙"
togglePropsBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 60)
togglePropsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
togglePropsBtn.TextScaled = true
togglePropsBtn.Font = Enum.Font.SourceSansBold
togglePropsBtn.Parent = panelHeader

local togglePropsCorner = Instance.new("UICorner")
togglePropsCorner.CornerRadius = UDim.new(0, 6)
togglePropsCorner.Parent = togglePropsBtn

-- Кнопка переключения выбора по клику
local clickToggleButton = Instance.new("TextButton")
clickToggleButton.Name = "ClickSelectToggle"
clickToggleButton.Size = UDim2.new(0, 18, 0, 20)
clickToggleButton.Position = UDim2.new(1, -80, 0.5, -10)
clickToggleButton.Text = "🖱"
clickToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
clickToggleButton.TextColor3 = Color3.fromRGB(180, 180, 190)
clickToggleButton.TextScaled = true
clickToggleButton.Font = Enum.Font.SourceSansBold
clickToggleButton.Parent = panelHeader

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = clickToggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(120, 120, 135)
toggleStroke.Thickness = 1
toggleStroke.Parent = clickToggleButton

local function updateToggleVisual()
	if clickSelectEnabled then
		clickToggleButton.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
		clickToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		toggleStroke.Color = Color3.fromRGB(90, 220, 130)
	else
		clickToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
		clickToggleButton.TextColor3 = Color3.fromRGB(180, 180, 190)
		toggleStroke.Color = Color3.fromRGB(120, 120, 135)
	end
end

updateToggleVisual()

-- Кнопка переключения режима камеры
local cameraToggleButton = Instance.new("TextButton")
cameraToggleButton.Name = "CameraModeToggle"
cameraToggleButton.Size = UDim2.new(0, 18, 0, 20)
cameraToggleButton.Position = UDim2.new(1, -60, 0.5, -10)
cameraToggleButton.Text = "📷"
cameraToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
cameraToggleButton.TextColor3 = Color3.fromRGB(180, 180, 190)
cameraToggleButton.TextScaled = true
cameraToggleButton.Font = Enum.Font.SourceSansBold
cameraToggleButton.Parent = panelHeader

local camToggleCorner = Instance.new("UICorner")
camToggleCorner.CornerRadius = UDim.new(0, 6)
camToggleCorner.Parent = cameraToggleButton

local camToggleStroke = Instance.new("UIStroke")
camToggleStroke.Color = Color3.fromRGB(120, 120, 135)
camToggleStroke.Thickness = 1
camToggleStroke.Parent = cameraToggleButton

local function updateCameraToggleVisual()
	if cameraModeEnabled then
		cameraToggleButton.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
		cameraToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		camToggleStroke.Color = Color3.fromRGB(80, 160, 255)
	else
		cameraToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
		cameraToggleButton.TextColor3 = Color3.fromRGB(180, 180, 190)
		camToggleStroke.Color = Color3.fromRGB(120, 120, 135)
	end
end

updateCameraToggleVisual()

cameraToggleButton.MouseButton1Click:Connect(function()
	cameraModeEnabled = not cameraModeEnabled
	updateCameraToggleVisual()
	local camera = Workspace.CurrentCamera
	if cameraModeEnabled then
		-- Включить Scriptable, чтобы стандартная камера не перехватывала ввод
		if camera then
			camera.CameraType = Enum.CameraType.Scriptable
		end
	else
		rightMouseDragging = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		if camera then
			camera.CameraType = Enum.CameraType.Custom
		end
	end
end)

-- Сенсорное управление камерой для мобильных устройств
local activeTouches = {} -- input -> position
local touchDragging = false
local lastTouch1Pos = nil
local lastPinchDistance = nil

-- Подсчёт активных касаний
local function getActiveTouchCount()
	local count = 0
	for _ in pairs(activeTouches) do
		count += 1
	end
	return count
end

-- Получить массив позиций всех активных касаний
local function getActiveTouchPositions()
	local positions = {}
	for _, pos in pairs(activeTouches) do
		table.insert(positions, pos)
	end
	return positions
end

-- Вращение камеры правой кнопкой мыши или касанием
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if cameraModeEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
		rightMouseDragging = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	elseif cameraModeEnabled and input.UserInputType == Enum.UserInputType.Touch then
		activeTouches[input] = input.Position
		local count = getActiveTouchCount()
		if count == 1 then
			touchDragging = true
			lastTouch1Pos = input.Position
			lastPinchDistance = nil
		elseif count == 2 then
			touchDragging = false
			local positions = getActiveTouchPositions()
			lastPinchDistance = (positions[1] - positions[2]).Magnitude
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		rightMouseDragging = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	elseif input.UserInputType == Enum.UserInputType.Touch then
		activeTouches[input] = nil
		local count = getActiveTouchCount()
		if count == 0 then
			touchDragging = false
			lastTouch1Pos = nil
			lastPinchDistance = nil
		elseif count == 1 then
			touchDragging = true
			local positions = getActiveTouchPositions()
			lastTouch1Pos = positions[1]
			lastPinchDistance = nil
		end
	end
end)

-- Вращение (движение мыши с ПКМ / касание) и зум (колёсико / пинч)
UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if not cameraModeEnabled then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement and rightMouseDragging then
		local delta = input.Delta
		cameraYaw = cameraYaw - delta.X * 0.005
		cameraPitch = math.clamp(cameraPitch - delta.Y * 0.005, math.rad(-85), math.rad(85))
		updateCameraCFrame()
	elseif input.UserInputType == Enum.UserInputType.MouseWheel then
		cameraDistance = math.clamp(cameraDistance - input.Position.Z * 5, 5, 200)
		updateCameraCFrame()
	elseif input.UserInputType == Enum.UserInputType.Touch then
		activeTouches[input] = input.Position
		local count = getActiveTouchCount()
		if count == 1 and touchDragging and lastTouch1Pos then
			local delta = input.Position - lastTouch1Pos
			cameraYaw = cameraYaw - delta.X * 0.008
			cameraPitch = math.clamp(cameraPitch - delta.Y * 0.008, math.rad(-85), math.rad(85))
			lastTouch1Pos = input.Position
			updateCameraCFrame()
		elseif count == 2 and lastPinchDistance then
			local positions = getActiveTouchPositions()
			local currentDist = (positions[1] - positions[2]).Magnitude
			local pinchDelta = currentDist - lastPinchDistance
			cameraDistance = math.clamp(cameraDistance - pinchDelta * 0.5, 5, 200)
			lastPinchDistance = currentDist
			updateCameraCFrame()
		end
	end
end)

-- Проверка, является ли объект физическим (имеет позицию в мире)
local function isPhysicalObject(obj)
	return obj:IsA("BasePart") or obj:IsA("Model")
end

-- Функции камеры и телепорта
local TweenService = game:GetService("TweenService")

local function getObjectPosition(obj)
	if obj:IsA("BasePart") then
		return obj.Position
	elseif obj:IsA("Model") then
		if obj.PrimaryPart then
			return obj.PrimaryPart.Position
		else
			local cf = obj:GetBoundingBox()
			return cf.Position
		end
	else
		return obj:GetPivot().Position
	end
end

function updateCameraCFrame()
	local camera = Workspace.CurrentCamera
	if not camera then return end
	local rot = CFrame.fromOrientation(cameraPitch, cameraYaw, 0)
	local cameraCFrame = CFrame.new(cameraTargetPos) * rot * CFrame.new(0, 0, cameraDistance)
	camera.CFrame = CFrame.lookAt(cameraCFrame.Position, cameraTargetPos)
end

local function focusCameraOnObject(obj)
	if not cameraModeEnabled then return end
	if not isPhysicalObject(obj) then return end -- Защита: не физические объекты
	local camera = Workspace.CurrentCamera
	if not camera then return end
	cameraTargetPos = getObjectPosition(obj)
	-- Вычислить начальные углы и дистанцию из текущей позиции камеры
	local offset = camera.CFrame.Position - cameraTargetPos
	cameraDistance = math.clamp(offset.Magnitude, 5, 200)
	if offset.Magnitude > 0.1 then
		cameraYaw = math.atan2(-offset.X, -offset.Z)
		cameraPitch = math.asin(math.clamp(offset.Y / offset.Magnitude, -1, 1))
	else
		cameraYaw = 0
		cameraPitch = 0
	end
	camera.CameraType = Enum.CameraType.Scriptable
	-- Плавный переход к новой позиции
	local targetCFrame
	local function computeTargetCFrame()
		local rot = CFrame.fromOrientation(cameraPitch, cameraYaw, 0)
		local cf = CFrame.new(cameraTargetPos) * rot * CFrame.new(0, 0, cameraDistance)
		return CFrame.lookAt(cf.Position, cameraTargetPos)
	end
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(camera, tweenInfo, {CFrame = computeTargetCFrame()})
	tween:Play()
	cameraTweening = true
	tween.Completed:Connect(function()
		cameraTweening = false
	end)
end

local currentPropsTarget = nil
local currentPropsLiveLabels = nil -- массив {label=TextLabel, getter=function} для живого обновления

-- Отслеживание перемещения выбранного объекта + живые свойства
RunService.RenderStepped:Connect(function()
	-- Обновление живых свойств в 3-й панели
	if currentPropsLiveLabels and currentPropsTarget and currentPropsTarget.Parent then
		for _, entry in ipairs(currentPropsLiveLabels) do
			entry.label.Text = entry.getter()
		end
	end

	if not cameraModeEnabled then return end
	if cameraTweening then return end
	if not lastSelectedObject then return end
	if not lastSelectedObject.Parent then return end
	if not isPhysicalObject(lastSelectedObject) then return end
	local newPos = getObjectPosition(lastSelectedObject)
	if (newPos - cameraTargetPos).Magnitude > 0.01 then
		cameraTargetPos = newPos
		updateCameraCFrame()
	end
end)

local function teleportToObject()
	if not lastSelectedObject then return end
	if not isPhysicalObject(lastSelectedObject) then return end -- Защита: не физические объекты
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local targetPos = getObjectPosition(lastSelectedObject)
	hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
	if cameraModeEnabled then
		cameraModeEnabled = false
		rightMouseDragging = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		updateCameraToggleVisual()
		local camera = Workspace.CurrentCamera
		if camera then
			camera.CameraType = Enum.CameraType.Custom
		end
	end
end

local panelScroll = Instance.new("ScrollingFrame")
panelScroll.Name = "PanelScroll"
panelScroll.Size = UDim2.new(1, -8, 1, -36)
panelScroll.Position = UDim2.new(0, 4, 0, 32)
panelScroll.BackgroundTransparency = 1
panelScroll.BorderSizePixel = 0
panelScroll.ScrollBarThickness = 3
panelScroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
panelScroll.ScrollingDirection = Enum.ScrollingDirection.Y
panelScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
panelScroll.Parent = panel

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = panelScroll
uiListLayout.SortOrder = Enum.SortOrder.Name
uiListLayout.Padding = UDim.new(0, 3)

-- Правая панель
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(0, 180, 0, 200)
contentFrame.Position = UDim2.new(0.01, 140, 0.05, 0)
contentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = screenGui

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = contentFrame

local contentStroke = Instance.new("UIStroke")
contentStroke.Color = Color3.fromRGB(90, 90, 110)
contentStroke.Thickness = 1.5
contentStroke.Parent = contentFrame

-- Верхняя панель: кнопка назад + хлебные крошки
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 28)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
topBar.BorderSizePixel = 0
topBar.Parent = contentFrame

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 8)
topBarCorner.Parent = topBar

local backButton = Instance.new("TextButton")
backButton.Size = UDim2.new(0, 28, 1, -8)
backButton.Position = UDim2.new(0, 4, 0.5, -10)
backButton.Text = "←"
backButton.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
backButton.TextScaled = true
backButton.Font = Enum.Font.SourceSansBold
backButton.Parent = topBar

local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 6)
backCorner.Parent = backButton

local breadcrumbLabel = Instance.new("TextLabel")
breadcrumbLabel.Size = UDim2.new(1, -36, 1, 0)
breadcrumbLabel.Position = UDim2.new(0, 36, 0, 0)
breadcrumbLabel.BackgroundTransparency = 1
breadcrumbLabel.Text = "Workspace"
breadcrumbLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
breadcrumbLabel.TextScaled = true
breadcrumbLabel.TextXAlignment = Enum.TextXAlignment.Left
breadcrumbLabel.Font = Enum.Font.SourceSans
breadcrumbLabel.Parent = topBar

-- Метка пути объекта
local pathLabel = Instance.new("TextLabel")
pathLabel.Size = UDim2.new(1, -8, 0, 22)
pathLabel.Position = UDim2.new(0, 4, 0, 32)
pathLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
pathLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
pathLabel.Text = "Выбор по клику: ВЫКЛ (🖱)"
pathLabel.TextScaled = true
pathLabel.Font = Enum.Font.SourceSans
pathLabel.TextXAlignment = Enum.TextXAlignment.Left
local pathPad = Instance.new("UIPadding")
pathPad.PaddingLeft = UDim.new(0, 6)
pathPad.Parent = pathLabel
local pathCorner = Instance.new("UICorner")
pathCorner.CornerRadius = UDim.new(0, 6)
pathCorner.Parent = pathLabel
pathLabel.Parent = contentFrame

-- Кнопка телепорта
local tpButton = Instance.new("TextButton")
tpButton.Name = "TeleportButton"
tpButton.Size = UDim2.new(1, -8, 0, 24)
tpButton.Position = UDim2.new(0, 4, 0, 56)
tpButton.Text = "ТП к объекту"
tpButton.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpButton.TextScaled = true
tpButton.Font = Enum.Font.SourceSansBold
tpButton.Parent = contentFrame

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 6)
tpCorner.Parent = tpButton

local tpStroke = Instance.new("UIStroke")
tpStroke.Color = Color3.fromRGB(140, 100, 180)
tpStroke.Thickness = 1
tpStroke.Parent = tpButton

tpButton.MouseButton1Click:Connect(function()
	if not lastSelectedObject or not isPhysicalObject(lastSelectedObject) then
		tpButton.Text = "⚠ Объект не физический!"
		task.wait(1.5)
		tpButton.Text = "ТП к объекту"
		return
	end
	teleportToObject()
end)

-- Переключение выбора по клику
clickToggleButton.MouseButton1Click:Connect(function()
	clickSelectEnabled = not clickSelectEnabled
	updateToggleVisual()
	if clickSelectEnabled then
		pathLabel.Text = "Выбор по клику: ВКЛ — кликните объект"
	else
		pathLabel.Text = "Выбор по клику: ВЫКЛ (🖱)"
	end
end)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -8, 1, -86)
scrollFrame.Position = UDim2.new(0, 4, 0, 84)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.Parent = contentFrame
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local contentLayout = Instance.new("UIListLayout")
contentLayout.Parent = scrollFrame
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, 3)

-- 3-я панель: Свойства объекта (как в Properties)
local propsFrame = Instance.new("Frame")
propsFrame.Size = UDim2.new(0, 180, 0, 200)
propsFrame.Position = UDim2.new(0.01, 330, 0.05, 0)
propsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
propsFrame.BorderSizePixel = 0
propsFrame.Parent = screenGui

local propsCorner = Instance.new("UICorner")
propsCorner.CornerRadius = UDim.new(0, 8)
propsCorner.Parent = propsFrame

local propsStroke = Instance.new("UIStroke")
propsStroke.Color = Color3.fromRGB(90, 90, 110)
propsStroke.Thickness = 1.5
propsStroke.Parent = propsFrame

local propsHeader = Instance.new("Frame")
propsHeader.Size = UDim2.new(1, 0, 0, 28)
propsHeader.Position = UDim2.new(0, 0, 0, 0)
propsHeader.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
propsHeader.BorderSizePixel = 0
propsHeader.Parent = propsFrame

local propsHeaderCorner = Instance.new("UICorner")
propsHeaderCorner.CornerRadius = UDim.new(0, 8)
propsHeaderCorner.Parent = propsHeader

local propsTitle = Instance.new("TextLabel")
propsTitle.Size = UDim2.new(1, -12, 1, 0)
propsTitle.Position = UDim2.new(0, 8, 0, 0)
propsTitle.BackgroundTransparency = 1
propsTitle.Text = "Свойства"
propsTitle.TextColor3 = Color3.fromRGB(235, 235, 245)
propsTitle.TextScaled = true
propsTitle.Font = Enum.Font.SourceSansBold
propsTitle.TextXAlignment = Enum.TextXAlignment.Left
propsTitle.Parent = propsHeader

local propsScroll = Instance.new("ScrollingFrame")
propsScroll.Size = UDim2.new(1, -8, 1, -36)
propsScroll.Position = UDim2.new(0, 4, 0, 32)
propsScroll.BackgroundTransparency = 1
propsScroll.BorderSizePixel = 0
propsScroll.Parent = propsFrame
propsScroll.ScrollBarThickness = 3
propsScroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
propsScroll.ScrollingDirection = Enum.ScrollingDirection.Y
propsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local propsLayout = Instance.new("UIListLayout")
propsLayout.Parent = propsScroll
propsLayout.SortOrder = Enum.SortOrder.LayoutOrder
propsLayout.Padding = UDim.new(0, 2)



-- Переключение видимости 2-й и 3-й панели с первой панели
local contentVisible = true
local propsVisible = true

local function updateToggleVisuals()
	if contentVisible then
		toggleContentBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 60)
		toggleContentBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		toggleContentBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
		toggleContentBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
	end
	if propsVisible then
		togglePropsBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 60)
		togglePropsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		togglePropsBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
		togglePropsBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
	end
end

updateToggleVisuals()

toggleContentBtn.MouseButton1Click:Connect(function()
	contentVisible = not contentVisible
	contentFrame.Visible = contentVisible
	updateToggleVisuals()
end)

togglePropsBtn.MouseButton1Click:Connect(function()
	propsVisible = not propsVisible
	propsFrame.Visible = propsVisible
	updateToggleVisuals()
end)

local function addPropRow(propName, propValue, order, liveGetter)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 22)
	row.BackgroundTransparency = 1
	row.LayoutOrder = order or 0
	row.Parent = propsScroll

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.45, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.SourceSans
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = propName
	nameLabel.Parent = row
	local nPad = Instance.new("UIPadding")
	nPad.PaddingLeft = UDim.new(0, 6)
	nPad.Parent = nameLabel

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.55, -4, 1, 0)
	valueLabel.Position = UDim2.new(0.45, 2, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	valueLabel.TextScaled = true
	valueLabel.Font = Enum.Font.SourceSans
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.Text = propValue
	valueLabel.Parent = row

	if liveGetter then
		table.insert(currentPropsLiveLabels, {label = valueLabel, getter = liveGetter})
	end

	return valueLabel
end

local function showProperties(obj)
	currentPropsTarget = obj
	currentPropsLiveLabels = {}

	for _, c in pairs(propsScroll:GetChildren()) do
		if c:IsA("Frame") or c:IsA("TextLabel") then
			c:Destroy()
		end
	end

	-- Предупреждение для не-физических объектов
	local physical = isPhysicalObject(obj)
	if not physical then
		local warnRow = Instance.new("TextLabel")
		warnRow.Size = UDim2.new(1, 0, 0, 28)
		warnRow.Text = "⚠ Не физический объект\nТП и камера отключены"
		warnRow.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
		warnRow.TextColor3 = Color3.fromRGB(255, 200, 100)
		warnRow.TextScaled = true
		warnRow.Font = Enum.Font.SourceSansBold
		warnRow.LayoutOrder = 0
		local wPad = Instance.new("UIPadding")
		wPad.PaddingLeft = UDim.new(0, 4)
		wPad.Parent = warnRow
		local wCorner = Instance.new("UICorner")
		wCorner.CornerRadius = UDim.new(0, 4)
		wCorner.Parent = warnRow
		warnRow.Parent = propsScroll
	end

	local order = 1

	-- Базовые свойства (живые)
	addPropRow("Name", obj.Name, order, function() return obj.Name end); order += 1
	addPropRow("ClassName", obj.ClassName, order, function() return obj.ClassName end); order += 1

	if physical then
		local pos = getObjectPosition(obj)
		addPropRow("Position", string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z), order, function()
			local p = getObjectPosition(obj)
			return string.format("%.2f, %.2f, %.2f", p.X, p.Y, p.Z)
		end); order += 1
	else
		addPropRow("Position", "(не физический)", order); order += 1
	end

	if obj:IsA("BasePart") then
		local sz = obj.Size
		addPropRow("Size", string.format("%.2f, %.2f, %.2f", sz.X, sz.Y, sz.Z), order, function()
			local s = obj.Size
			return string.format("%.2f, %.2f, %.2f", s.X, s.Y, s.Z)
		end); order += 1
		addPropRow("Color", string.format("%d, %d, %d", math.floor(obj.Color.R * 255), math.floor(obj.Color.G * 255), math.floor(obj.Color.B * 255)), order, function()
			return string.format("%d, %d, %d", math.floor(obj.Color.R * 255), math.floor(obj.Color.G * 255), math.floor(obj.Color.B * 255))
		end); order += 1
		addPropRow("Material", tostring(obj.Material), order, function() return tostring(obj.Material) end); order += 1
		addPropRow("Transparency", string.format("%.2f", obj.Transparency), order, function() return string.format("%.2f", obj.Transparency) end); order += 1
		addPropRow("Reflectance", string.format("%.2f", obj.Reflectance), order, function() return string.format("%.2f", obj.Reflectance) end); order += 1
		addPropRow("Anchored", tostring(obj.Anchored), order, function() return tostring(obj.Anchored) end); order += 1
		addPropRow("CanCollide", tostring(obj.CanCollide), order, function() return tostring(obj.CanCollide) end); order += 1
		addPropRow("CanTouch", tostring(obj.CanTouch), order, function() return tostring(obj.CanTouch) end); order += 1
		addPropRow("CanQuery", tostring(obj.CanQuery), order, function() return tostring(obj.CanQuery) end); order += 1
		addPropRow("CastShadow", tostring(obj.CastShadow), order, function() return tostring(obj.CastShadow) end); order += 1
		addPropRow("Mass", string.format("%.3f", obj.Mass), order, function() return string.format("%.3f", obj.Mass) end); order += 1
		addPropRow("Rotation", string.format("%.1f, %.1f, %.1f", 0, 0, 0), order, function()
			local rot = obj.CFrame - obj.CFrame.Position
			local rx, ry, rz = rot:ToOrientation()
			return string.format("%.1f, %.1f, %.1f", math.deg(rx), math.deg(ry), math.deg(rz))
		end); order += 1
		if obj:IsA("MeshPart") then
			if obj.MeshId and obj.MeshId ~= "" then
				local shortId = string.match(obj.MeshId, "%d+")
				addPropRow("MeshId", shortId or obj.MeshId, order, function()
					local sid = string.match(obj.MeshId or "", "%d+")
					return sid or obj.MeshId or ""
				end); order += 1
			end
			if obj.TextureID and obj.TextureID ~= "" then
				local shortTex = string.match(obj.TextureID, "%d+")
				addPropRow("TextureID", shortTex or obj.TextureID, order, function()
					local sid = string.match(obj.TextureID or "", "%d+")
					return sid or obj.TextureID or ""
				end); order += 1
			end
		end
	elseif obj:IsA("Model") then
		addPropRow("PrimaryPart", obj.PrimaryPart and obj.PrimaryPart.Name or "(нет)", order, function()
			return obj.PrimaryPart and obj.PrimaryPart.Name or "(нет)"
		end); order += 1
		local cf, size = obj:GetBoundingBox()
		addPropRow("Bounds Size", string.format("%.2f, %.2f, %.2f", size.X, size.Y, size.Z), order, function()
			local _, s = obj:GetBoundingBox()
			return string.format("%.2f, %.2f, %.2f", s.X, s.Y, s.Z)
		end); order += 1
		addPropRow("Children", tostring(#obj:GetChildren()), order, function() return tostring(#obj:GetChildren()) end); order += 1
		addPropRow("Descendants", tostring(#obj:GetDescendants()), order, function() return tostring(#obj:GetDescendants()) end); order += 1
	elseif obj:IsA("ProximityPrompt") then
		addPropRow("ActionText", obj.ActionText, order, function() return obj.ActionText end); order += 1
		addPropRow("ObjectText", obj.ObjectText, order, function() return obj.ObjectText end); order += 1
		addPropRow("KeyboardKeyCode", tostring(obj.KeyboardKeyCode), order, function() return tostring(obj.KeyboardKeyCode) end); order += 1
		addPropRow("GamepadKeyCode", tostring(obj.GamepadKeyCode), order, function() return tostring(obj.GamepadKeyCode) end); order += 1
		addPropRow("HoldDuration", string.format("%.2f", obj.HoldDuration), order, function() return string.format("%.2f", obj.HoldDuration) end); order += 1
		addPropRow("MaxActivationDistance", tostring(obj.MaxActivationDistance), order, function() return tostring(obj.MaxActivationDistance) end); order += 1
		addPropRow("RequiresLineOfSight", tostring(obj.RequiresLineOfSight), order, function() return tostring(obj.RequiresLineOfSight) end); order += 1
		addPropRow("Enabled", tostring(obj.Enabled), order, function() return tostring(obj.Enabled) end); order += 1
		addPropRow("Style", tostring(obj.Style), order, function() return tostring(obj.Style) end); order += 1
		addPropRow("UIOffset", string.format("%d, %d", obj.UIOffset.X, obj.UIOffset.Y), order, function() return string.format("%d, %d", obj.UIOffset.X, obj.UIOffset.Y) end); order += 1
	elseif obj:IsA("ClickDetector") then
		addPropRow("MaxActivationDistance", tostring(obj.MaxActivationDistance), order, function() return tostring(obj.MaxActivationDistance) end); order += 1
		addPropRow("MaxCursorDistance", tostring(obj.MaxCursorDistance), order, function() return tostring(obj.MaxCursorDistance) end); order += 1
		addPropRow("CursorIcon", obj.CursorIcon or "", order, function() return obj.CursorIcon or "" end); order += 1
		addPropRow("AlwaysRenderCursor", tostring(obj.AlwaysRenderCursor), order, function() return tostring(obj.AlwaysRenderCursor) end); order += 1
		addPropRow("InteractionShortcut", tostring(obj.InteractionShortcut), order, function() return tostring(obj.InteractionShortcut) end); order += 1
	elseif obj:IsA("SurfaceGui") then
		addPropRow("CanvasSize", string.format("%d x %d", obj.CanvasSize.X, obj.CanvasSize.Y), order, function() return string.format("%d x %d", obj.CanvasSize.X, obj.CanvasSize.Y) end); order += 1
		addPropRow("Face", tostring(obj.Face), order, function() return tostring(obj.Face) end); order += 1
		addPropRow("AlwaysOnTop", tostring(obj.AlwaysOnTop), order, function() return tostring(obj.AlwaysOnTop) end); order += 1
		addPropRow("ZOffset", tostring(obj.ZOffset), order, function() return tostring(obj.ZOffset) end); order += 1
		addPropRow("ToolPunchThroughDistance", tostring(obj.ToolPunchThroughDistance), order, function() return tostring(obj.ToolPunchThroughDistance) end); order += 1
		addPropRow("Children", tostring(#obj:GetChildren()), order, function() return tostring(#obj:GetChildren()) end); order += 1
	elseif obj:IsA("BillboardGui") then
		addPropRow("Size", string.format("%d, %d", obj.Size.X.Offset, obj.Size.Y.Offset), order, function() return string.format("%d, %d", obj.Size.X.Offset, obj.Size.Y.Offset) end); order += 1
		addPropRow("AlwaysOnTop", tostring(obj.AlwaysOnTop), order, function() return tostring(obj.AlwaysOnTop) end); order += 1
		addPropRow("MaxDistance", tostring(obj.MaxDistance), order, function() return tostring(obj.MaxDistance) end); order += 1
		addPropRow("ExtentsOffset", string.format("%.1f, %.1f, %.1f", obj.ExtentsOffset.X, obj.ExtentsOffset.Y, obj.ExtentsOffset.Z), order, function() return string.format("%.1f, %.1f, %.1f", obj.ExtentsOffset.X, obj.ExtentsOffset.Y, obj.ExtentsOffset.Z) end); order += 1
		addPropRow("LightInfluence", string.format("%.2f", obj.LightInfluence), order, function() return string.format("%.2f", obj.LightInfluence) end); order += 1
		addPropRow("Children", tostring(#obj:GetChildren()), order, function() return tostring(#obj:GetChildren()) end); order += 1
	elseif obj:IsA("ScreenGui") then
		addPropRow("DisplayOrder", tostring(obj.DisplayOrder), order, function() return tostring(obj.DisplayOrder) end); order += 1
		addPropRow("IgnoreGuiInset", tostring(obj.IgnoreGuiInset), order, function() return tostring(obj.IgnoreGuiInset) end); order += 1
		addPropRow("ResetOnSpawn", tostring(obj.ResetOnSpawn), order, function() return tostring(obj.ResetOnSpawn) end); order += 1
		addPropRow("ScreenInsets", tostring(obj.ScreenInsets), order, function() return tostring(obj.ScreenInsets) end); order += 1
		addPropRow("AlwaysOnTop", tostring(obj.AlwaysOnTop), order, function() return tostring(obj.AlwaysOnTop) end); order += 1
		addPropRow("Children", tostring(#obj:GetChildren()), order, function() return tostring(#obj:GetChildren()) end); order += 1
	elseif obj:IsA("BaseScript") then
		addPropRow("Enabled", tostring(obj.Enabled), order, function() return tostring(obj.Enabled) end); order += 1
		addPropRow("RunContext", tostring(obj.RunContext), order, function() return tostring(obj.RunContext) end); order += 1
		addPropRow("LinkedSource", obj.LinkedSource and tostring(obj.LinkedSource) or "(нет)", order, function() return obj.LinkedSource and tostring(obj.LinkedSource) or "(нет)" end); order += 1
		addPropRow("Parent", obj.Parent and obj.Parent.Name or "(nil)", order, function() return obj.Parent and obj.Parent.Name or "(nil)" end); order += 1
		addPropRow("Children", tostring(#obj:GetChildren()), order, function() return tostring(#obj:GetChildren()) end); order += 1
		addPropRow("Descendants", tostring(#obj:GetDescendants()), order, function() return tostring(#obj:GetDescendants()) end); order += 1
	elseif obj:IsA("Humanoid") then
		addPropRow("Health", string.format("%.1f", obj.Health), order, function() return string.format("%.1f", obj.Health) end); order += 1
		addPropRow("MaxHealth", tostring(obj.MaxHealth), order, function() return tostring(obj.MaxHealth) end); order += 1
		addPropRow("WalkSpeed", tostring(obj.WalkSpeed), order, function() return tostring(obj.WalkSpeed) end); order += 1
		addPropRow("JumpPower", tostring(obj.JumpPower), order, function() return tostring(obj.JumpPower) end); order += 1
		addPropRow("MoveDirection", string.format("%.2f, %.2f, %.2f", obj.MoveDirection.X, obj.MoveDirection.Y, obj.MoveDirection.Z), order, function() return string.format("%.2f, %.2f, %.2f", obj.MoveDirection.X, obj.MoveDirection.Y, obj.MoveDirection.Z) end); order += 1
		addPropRow("FloorMaterial", tostring(obj.FloorMaterial), order, function() return tostring(obj.FloorMaterial) end); order += 1
		addPropRow("State", tostring(obj:GetState()), order, function() return tostring(obj:GetState()) end); order += 1
		addPropRow("RigType", tostring(obj.RigType), order, function() return tostring(obj.RigType) end); order += 1
	elseif obj:IsA("Folder") then
		addPropRow("Parent", obj.Parent and obj.Parent.Name or "(nil)", order, function() return obj.Parent and obj.Parent.Name or "(nil)" end); order += 1
		addPropRow("Children", tostring(#obj:GetChildren()), order, function() return tostring(#obj:GetChildren()) end); order += 1
		addPropRow("Descendants", tostring(#obj:GetDescendants()), order, function() return tostring(#obj:GetDescendants()) end); order += 1
	else
		-- Универсальные свойства для любых объектов
		addPropRow("Parent", obj.Parent and obj.Parent.Name or "(nil)", order, function() return obj.Parent and obj.Parent.Name or "(nil)" end); order += 1
		addPropRow("Children", tostring(#obj:GetChildren()), order, function() return tostring(#obj:GetChildren()) end); order += 1
		addPropRow("Descendants", tostring(#obj:GetDescendants()), order, function() return tostring(#obj:GetDescendants()) end); order += 1
	end
end

-- Перетаскивание панели (за шапку или тело панели)
local dragging = false
local dragOffset = Vector2.new()

local function beginDrag(input)
	dragging = true
	dragOffset = Vector2.new(input.Position.X - panel.AbsolutePosition.X, input.Position.Y - panel.AbsolutePosition.Y)
end

panelHeader.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		beginDrag(input)
	end
end)

panel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		beginDrag(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local screenSize = Workspace.CurrentCamera.ViewportSize
		local newPosX = (input.Position.X - dragOffset.X) / screenSize.X
		local newPosY = (input.Position.Y - dragOffset.Y) / screenSize.Y
		newPosX = math.clamp(newPosX, 0, 1 - panel.AbsoluteSize.X / screenSize.X)
		newPosY = math.clamp(newPosY, 0, 1 - panel.AbsoluteSize.Y / screenSize.Y)
		panel.Position = UDim2.new(newPosX, 0, newPosY, 0)
		contentFrame.Position = UDim2.new(newPosX, panel.AbsoluteSize.X + 10, newPosY, 0)
		propsFrame.Position = UDim2.new(newPosX, panel.AbsoluteSize.X + contentFrame.AbsoluteSize.X + 20, newPosY, 0)
	end
end)

-- Подсветка объектов
local function clearHighlights()
	for _, h in pairs(currentHighlights) do
		if h and h.Parent then
			h:Destroy()
		end
	end
	currentHighlights = {}
end

local function highlightObject(obj, searchParent)
	-- Повторное нажатие — выключить подсветку
	if highlightedObject == obj then
		clearHighlights()
		highlightedObject = nil
		return
	end
	clearHighlights()
	highlightedObject = obj
	local targetName = obj.Name
	local function addHighlight(part)
		if part:IsA("BasePart") then
			local hl = Instance.new("Highlight")
			hl.FillTransparency = 0.7
			hl.OutlineColor = Color3.fromRGB(255, 255, 0)
			hl.FillColor = Color3.fromRGB(255, 255, 0)
			hl.Adornee = part
			hl.Parent = part
			table.insert(currentHighlights, hl)
		end
	end
	-- Подсветить объект и его потомков
	local function highlightTree(instance)
		addHighlight(instance)
		for _, desc in pairs(instance:GetDescendants()) do
			addHighlight(desc)
		end
	end
	highlightTree(obj)
	-- Найти все объекты с таким же именем внутри searchParent
	local parent = searchParent or Workspace
	for _, desc in pairs(parent:GetDescendants()) do
		if desc ~= obj and desc.Name == targetName then
			highlightTree(desc)
		end
	end
end

local function clearContent(frame)
	for _, child in pairs(frame:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

local function getColorByType(obj)
	if obj:IsA("Part") then return Color3.fromRGB(150, 150, 150)
	elseif obj:IsA("MeshPart") then return Color3.fromRGB(80, 80, 80)
	elseif obj:IsA("UnionOperation") then return Color3.fromRGB(0, 255, 0)
	elseif obj:IsA("Model") then return Color3.fromRGB(255, 0, 255)
	elseif obj:IsA("Folder") then return Color3.fromRGB(255, 165, 0)
	elseif obj:IsA("Script") then return Color3.fromRGB(255, 255, 255)
	elseif obj:IsA("LocalScript") then return Color3.fromRGB(0, 255, 255)
	elseif obj:IsA("Humanoid") then return Color3.fromRGB(165, 55, 0)
	elseif obj:IsA("ProximityPrompt") then return Color3.fromRGB(0, 0, 89)
	else return Color3.fromRGB(0, 0, 0) end
end

local function getLabelTextByType(obj)
	if obj:IsA("Part") then return "[Part]"
	elseif obj:IsA("MeshPart") then return "[MeshPart]"
	elseif obj:IsA("UnionOperation") then return "[Union]"
	elseif obj:IsA("Model") then return "[Model]"
	elseif obj:IsA("Folder") then return "[Folder]"
	elseif obj:IsA("Script") then return "[Script]"
	elseif obj:IsA("LocalScript") then return "[LocalScipt]"
	elseif obj:IsA("Humanoid") then return "[Humanoid]"
	elseif obj:IsA("ProximityPrompt") then return "[ProximityPrompt]"
	else return "[Object]" end
end

-- Хлебные крошки
local function updateBreadcrumb()
	local parts = {"Workspace"}
	for _, entry in ipairs(navigationHistory) do
		table.insert(parts, entry.obj.Name)
	end
	if currentObject then
		table.insert(parts, currentObject.Name)
	end
	breadcrumbLabel.Text = table.concat(parts, " > ")
end

local showObjectContents

local function navigateInto(obj)
	if currentObject then
		table.insert(navigationHistory, {obj = currentObject})
	end
	currentObject = obj
	lastSelectedObject = obj
	showObjectContents(obj)
	highlightObject(obj, Workspace)
	focusCameraOnObject(obj)
	updateBreadcrumb()
end

local function navigateBack()
	if #navigationHistory > 0 then
		local prev = table.remove(navigationHistory)
		currentObject = prev.obj
		lastSelectedObject = prev.obj
		showObjectContents(prev.obj)
		highlightObject(prev.obj, Workspace)
		focusCameraOnObject(prev.obj)
		updateBreadcrumb()
	end
end

backButton.MouseButton1Click:Connect(navigateBack)

local function createObjectButton(obj, count)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 24)
	if count and count > 1 then
		btn.Text = obj.Name .. " ×" .. count
	else
		btn.Text = obj.Name
	end
	btn.BackgroundColor3 = getColorByType(obj)
	btn.TextColor3 = Color3.fromRGB(0, 0, 0)
	btn.TextScaled = true
	btn.Font = Enum.Font.SourceSans
	btn.Parent = panelScroll

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 5)
	btnCorner.Parent = btn

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0.01, 0)
	padding.PaddingRight = UDim.new(0.01, 0)
	padding.PaddingTop = UDim.new(0.003, 0)
	padding.PaddingBottom = UDim.new(0.003, 0)
	padding.Parent = btn

	btn.MouseButton1Click:Connect(function()
		navigationHistory = {}
		currentObject = obj
		lastSelectedObject = obj
		showObjectContents(obj)
		highlightObject(obj, Workspace)
		focusCameraOnObject(obj)
		updateBreadcrumb()
	end)
end

function showObjectContents(obj)
	for _, conn in pairs(currentFolderConnections) do
		if conn then conn:Disconnect() end
	end
	currentFolderConnections = {}

	clearContent(scrollFrame)
	showProperties(obj)

	-- Информация об объекте
	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, 0, 0, 22)
	infoLabel.Text = "Объект: " .. obj.Name .. " [" .. obj.ClassName .. "]"
	infoLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	infoLabel.TextScaled = true
	infoLabel.Font = Enum.Font.SourceSansBold
	infoLabel.LayoutOrder = 1
	infoLabel.Parent = scrollFrame

	-- Цвет объекта
	local colorFrame = Instance.new("Frame")
	colorFrame.Size = UDim2.new(1, -4, 0, 26)
	colorFrame.BackgroundColor3 = getColorByType(obj)
	colorFrame.BorderSizePixel = 1
	colorFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
	colorFrame.LayoutOrder = 2
	colorFrame.Parent = scrollFrame

	local labelColor = Instance.new("TextLabel")
	labelColor.Size = UDim2.new(1, 0, 1, 0)
	labelColor.BackgroundTransparency = 1
	labelColor.TextColor3 = Color3.fromRGB(255, 255, 255)
	labelColor.TextScaled = true
	labelColor.Font = Enum.Font.SourceSansBold
	labelColor.Text = "Цвет объекта"
	labelColor.Parent = colorFrame

	local colorIndicator = Instance.new("Frame")
	colorIndicator.Size = UDim2.new(0.2, 0, 1, 0)
	colorIndicator.Position = UDim2.new(0.8, -2, 0, 0)
	colorIndicator.BackgroundColor3 = getColorByType(obj)
	colorIndicator.BorderSizePixel = 1
	colorIndicator.BorderColor3 = Color3.fromRGB(255, 255, 255)
	colorIndicator.Parent = colorFrame

	-- Заголовок дочерних объектов
	local childrenHeader = Instance.new("TextLabel")
	childrenHeader.Size = UDim2.new(1, 0, 0, 22)
	childrenHeader.Text = "Дочерние объекты"
	childrenHeader.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	childrenHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
	childrenHeader.TextScaled = true
	childrenHeader.Font = Enum.Font.SourceSansBold
	childrenHeader.LayoutOrder = 3
	childrenHeader.Parent = scrollFrame

	-- Кликабельная запись дочернего объекта
	local function addChildEntry(child, count)
		local childBtn = Instance.new("TextButton")
		childBtn.Size = UDim2.new(1, 0, 0, 24)
		childBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
		childBtn.Text = ""
		childBtn.AutoButtonColor = true
		childBtn.LayoutOrder = 4
		childBtn.Parent = scrollFrame

		local childCorner = Instance.new("UICorner")
		childCorner.CornerRadius = UDim.new(0, 5)
		childCorner.Parent = childBtn

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.75, 0, 1, 0)
		label.Position = UDim2.new(0, 2, 0, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextScaled = true
		label.Font = Enum.Font.SourceSans
		if count and count > 1 then
			label.Text = child.Name .. " " .. getLabelTextByType(child) .. " ×" .. count
		else
			label.Text = child.Name .. " " .. getLabelTextByType(child)
		end
		label.Parent = childBtn

		local colorBox = Instance.new("Frame")
		colorBox.Size = UDim2.new(0.15, -4, 1, 0)
		colorBox.Position = UDim2.new(0.75, 2, 0, 0)
		colorBox.BackgroundColor3 = getColorByType(child)
		colorBox.BorderSizePixel = 1
		colorBox.BorderColor3 = Color3.fromRGB(255, 255, 255)
		colorBox.Parent = childBtn

		-- Стрелка → если есть дочерние объекты
		local hasChildren = #child:GetChildren() > 0
		if hasChildren then
			local arrowLabel = Instance.new("TextLabel")
			arrowLabel.Size = UDim2.new(0.1, 0, 1, 0)
			arrowLabel.Position = UDim2.new(0.9, 0, 0, 0)
			arrowLabel.BackgroundTransparency = 1
			arrowLabel.Text = "→"
			arrowLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
			arrowLabel.TextScaled = true
			arrowLabel.Font = Enum.Font.SourceSansBold
			arrowLabel.Parent = childBtn
		end

		childBtn.MouseButton1Click:Connect(function()
			lastSelectedObject = child
			if hasChildren then
				navigateInto(child)
			else
				highlightObject(child, obj)
				focusCameraOnObject(child)
				showProperties(child)
			end
		end)
	end

	-- Построение списка дочерних объектов
	local function buildChildrenList()
		for _, c in pairs(scrollFrame:GetChildren()) do
			if c:IsA("TextButton") then
				c:Destroy()
			end
		end

		local children = {}
		for _, c in pairs(obj:GetChildren()) do
			table.insert(children, c)
		end

		local nameCounts = {}
		local nameFirstChild = {}
		for _, c in pairs(children) do
			local n = c.Name
			nameCounts[n] = (nameCounts[n] or 0) + 1
			if not nameFirstChild[n] then
				nameFirstChild[n] = c
			end
		end

		local displayedNames = {}
		for _, c in pairs(children) do
			local n = c.Name
			if not displayedNames[n] then
				displayedNames[n] = true
				addChildEntry(nameFirstChild[n], nameCounts[n])
			end
		end
	end

	buildChildrenList()

	-- Подписка на изменения дочерних объектов
	local conn1 = obj.ChildAdded:Connect(function()
		buildChildrenList()
	end)
	local conn2 = obj.ChildRemoved:Connect(function()
		buildChildrenList()
	end)
	table.insert(currentFolderConnections, conn1)
	table.insert(currentFolderConnections, conn2)
end

local function scanWorkspace()

	-- Клик по объекту в 3D мире: подсветка + показ пути
	local character = player.Character or player.CharacterAdded:Wait()

	local function isCharacterPart(instance)
		local char = player.Character
		if not char then return false end
		local current = instance
		while current do
			if current == char then return true end
			current = current.Parent
		end
		return false
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if not clickSelectEnabled then return end

		local mousePos = UserInputService:GetMouseLocation()
		local camera = Workspace.CurrentCamera
		local unitRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

		local rayParams = RaycastParams.new()
		rayParams.IgnoreWater = true

		local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, rayParams)
		if result then
			local hitPart = result.Instance

			-- Игнорировать части персонажа игрока
			if isCharacterPart(hitPart) then return end

			-- Найти верхнеуровневый объект (Model/Folder) внутри Workspace
			local targetObj = hitPart
			local parent = hitPart.Parent
			while parent and parent ~= Workspace and parent ~= game do
				if parent:IsA("Model") or parent:IsA("Folder") then
					targetObj = parent
				end
				parent = parent.Parent
			end

			highlightObject(targetObj, Workspace)
			pathLabel.Text = targetObj:GetFullName()
			lastSelectedObject = targetObj
			focusCameraOnObject(targetObj)

			-- Обновить навигацию в панели
			navigationHistory = {}
			currentObject = targetObj
			showObjectContents(targetObj)
			updateBreadcrumb()
		end
	end)
	local function refreshObjectList()
		for _, child in pairs(panelScroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		local nameCounts = {}
		local nameFirstObj = {}
		for _, obj in pairs(Workspace:GetChildren()) do
			if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") or obj:IsA("Model") or obj:IsA("Folder") then
				local n = obj.Name
				nameCounts[n] = (nameCounts[n] or 0) + 1
				if not nameFirstObj[n] then
					nameFirstObj[n] = obj
				end
			end
		end

		local displayedNames = {}
		for _, obj in pairs(Workspace:GetChildren()) do
			if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") or obj:IsA("Model") or obj:IsA("Folder") then
				local n = obj.Name
				if not displayedNames[n] then
					displayedNames[n] = true
					createObjectButton(nameFirstObj[n], nameCounts[n])
				end
			end
		end
	end

	refreshObjectList()

	Workspace.ChildAdded:Connect(function()
		refreshObjectList()
	end)
	Workspace.ChildRemoved:Connect(function()
		refreshObjectList()
	end)
end

scanWorkspace()
