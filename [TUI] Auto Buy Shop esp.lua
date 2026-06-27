local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local masterEnabled = true
local categoryEnabled = { false, false, false }
local mainRunning = false

-- ===================== CATEGORIES =====================

local CATEGORIES = {
	{
		name = "Black Market",
		items = {
			"Purchase Wood!",
			"Purchase Stone!",
			"Purchase Rusty Metal!",
			"Purchase Metal!",
			"Purchase Line Paper!",
			"Purchase Leather!",
			"Purchase Rope!",
			"Purchase Meat!",
			"Purchase Coal!",
			"Purchase Orb!",
			"Purchase Cursed Orb!",
			"Purchase Holy Orb!",
			"Purchase Shattered Chain!",
			"Purchase Holy Chain!",
			"Purchase Ruler's Diary!",
			"Purchase Light Chest!",
			"Purchase Dark Chest!",
			"Purchase Radioactive Cup!",
			"Purchase Blood Cup!",
			"Purchase Kings Arm!",
			"Purchase Space Egg!",
			"Purchase Blood Tear!",
			"Purchase Saints Head!",
			"Purchase Saints Brain!",
			"Purchase Saints Torso!",
			"Purchase Saints Leg!",
			"Purchase Saints Arm!",
		},
	},
	{
		name = "Mysterious Seller",
		items = {
			"Acid Cup",
			"Charge",
			"Shattered Chain",
			"Ghoul's Tentacle",
			"Saints Brain",
			"Dark Chest",
			"Paper",
			"Warp Spiral",
			"Unknown Eye",
		},
	},
	{
		name = "DJ",
		items = {
			"Gold",
			"Holy Chain",
			"Beachball",
			"Kings Arm",
			"Light Chest",
		},
	},
}

-- Build flat list of all allowed objects
local ALLOWED_OBJECTS = {}
for _, category in CATEGORIES do
	for _, item in category.items do
		table.insert(ALLOWED_OBJECTS, item)
	end
end

-- Build category item sets for quick lookup
local categoryItemSet = {}
for catIdx, category in CATEGORIES do
	categoryItemSet[catIdx] = {}
	for _, item in category.items do
		categoryItemSet[catIdx][item] = true
	end
end

-- Track which items are allowed
local itemStates = {}
for _, name in ALLOWED_OBJECTS do
	itemStates[name] = false
end

-- Helper
local function getDisplayName(objectText)
	return objectText:gsub("Purchase ", ""):gsub("!", "")
end

-- Current category
local currentCategory = 1

-- ===================== UI =====================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Auto Buy Shop"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Small open button (shown when panel is hidden)
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenButton"
openBtn.Size = UDim2.new(0.2, 0, 0.05, 0)
openBtn.Position = UDim2.new(0.5, 0, 0.05, 0)
openBtn.AnchorPoint = Vector2.new(0.5, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
openBtn.Text = "Auto Buy  [ + ]"
openBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
openBtn.TextScaled = true
openBtn.Font = Enum.Font.GothamBold
openBtn.BorderSizePixel = 0
openBtn.Visible = false
openBtn.Parent = screenGui

local openBtnCorner = Instance.new("UICorner")
openBtnCorner.CornerRadius = UDim.new(0.03, 0)
openBtnCorner.Parent = openBtn

local openBtnStroke = Instance.new("UIStroke")
openBtnStroke.Color = Color3.fromRGB(80, 80, 120)
openBtnStroke.Thickness = 1.5
openBtnStroke.Parent = openBtn

-- Make openBtn draggable
local UserInputService = game:GetService("UserInputService")
local openDragInput
local openDragStart
local openStartPos
local openIsDragging = false

openBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		openDragStart = input.Position
		openStartPos = openBtn.Position
		openIsDragging = false
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				openDragStart = nil
			end
		end)
	end
end)

openBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		openDragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == openDragInput and openDragStart then
		local delta = input.Position - openDragStart
		if delta.Magnitude > 5 then
			openIsDragging = true
		end
		openBtn.Position = UDim2.new(
			openStartPos.X.Scale, openStartPos.X.Offset + delta.X,
			openStartPos.Y.Scale, openStartPos.Y.Offset + delta.Y
		)
	end
end)

-- Main panel
local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.new(0.2, 0, 0.42, 0)
frame.Position = UDim2.new(0.5, 0, 0.05, 0)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0.03, 0)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(80, 80, 120)
frameStroke.Thickness = 1.5
frameStroke.Parent = frame

-- Layout padding
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0.015, 0)
padding.PaddingBottom = UDim.new(0.01, 0)
padding.PaddingLeft = UDim.new(0.02, 0)
padding.PaddingRight = UDim.new(0.02, 0)
padding.Parent = frame

-- Title row with hide button
local titleRow = Instance.new("Frame")
titleRow.Name = "TitleRow"
titleRow.Size = UDim2.new(1, 0, 0.055, 0)
titleRow.BackgroundTransparency = 1
titleRow.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Position = UDim2.new(0.25, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Buy"
title.TextColor3 = Color3.fromRGB(220, 220, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = titleRow

local hideBtn = Instance.new("TextButton")
hideBtn.Name = "HideButton"
hideBtn.Size = UDim2.new(0.14, 0, 0.95, 0)
hideBtn.Position = UDim2.new(0.85, 0, 0, 0)
hideBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
hideBtn.Text = "X"
hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.TextScaled = true
hideBtn.Font = Enum.Font.GothamBold
hideBtn.BorderSizePixel = 0
hideBtn.Parent = titleRow

local hideBtnCorner = Instance.new("UICorner")
hideBtnCorner.CornerRadius = UDim.new(0.15, 0)
hideBtnCorner.Parent = hideBtn

-- Category tabs
local tabRow = Instance.new("Frame")
tabRow.Name = "TabRow"
tabRow.Size = UDim2.new(1, 0, 0.065, 0)
tabRow.Position = UDim2.new(0, 0, 0.06, 0)
tabRow.BackgroundTransparency = 1
tabRow.Parent = frame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0.008, 0)
tabLayout.Parent = tabRow

local tabButtons = {}
for i, category in CATEGORIES do
	local tabBtn = Instance.new("TextButton")
	tabBtn.Name = "Tab_" .. i
	tabBtn.Size = UDim2.new(0.32, 0, 1, 0)
	tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	tabBtn.Text = category.name
	tabBtn.TextColor3 = Color3.fromRGB(160, 160, 200)
	tabBtn.TextScaled = true
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.BorderSizePixel = 0
	tabBtn.LayoutOrder = i
	tabBtn.Parent = tabRow

	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0.1, 0)
	tabCorner.Parent = tabBtn

	tabButtons[i] = tabBtn
end

-- Separator
local separator = Instance.new("Frame")
separator.Name = "Separator"
separator.Size = UDim2.new(1, 0, 0.004, 0)
separator.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
separator.BorderSizePixel = 0
separator.Parent = frame

-- Category toggle row (separate ON/OFF per category)
local catToggleRow = Instance.new("Frame")
catToggleRow.Name = "CatToggleRow"
catToggleRow.Size = UDim2.new(1, 0, 0.065, 0)
catToggleRow.Position = UDim2.new(0, 0, 0.135, 0)
catToggleRow.BackgroundTransparency = 1
catToggleRow.Parent = frame

local catToggleLayout = Instance.new("UIListLayout")
catToggleLayout.FillDirection = Enum.FillDirection.Horizontal
catToggleLayout.SortOrder = Enum.SortOrder.LayoutOrder
catToggleLayout.Padding = UDim.new(0.008, 0)
catToggleLayout.Parent = catToggleRow

local catToggleButtons = {}
for i, category in CATEGORIES do
	local catBtn = Instance.new("TextButton")
	catBtn.Name = "CatToggle_" .. i
	catBtn.Size = UDim2.new(0.32, 0, 1, 0)
	catBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	catBtn.Text = "OFF"
	catBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	catBtn.TextScaled = true
	catBtn.Font = Enum.Font.GothamBold
	catBtn.BorderSizePixel = 0
	catBtn.LayoutOrder = i
	catBtn.Parent = catToggleRow

	local catBtnCorner = Instance.new("UICorner")
	catBtnCorner.CornerRadius = UDim.new(0.1, 0)
	catBtnCorner.Parent = catBtn

	catToggleButtons[i] = catBtn
end

-- Separator 2
local separator2 = Instance.new("Frame")
separator2.Name = "Separator2"
separator2.Size = UDim2.new(1, 0, 0.004, 0)
separator2.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
separator2.BorderSizePixel = 0
separator2.Parent = frame

-- ScrollingFrame for item toggles
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ItemList"
scrollFrame.Size = UDim2.new(1, 0, 0.775, 0)
scrollFrame.Position = UDim2.new(0, 0, 0.21, 0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = frame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0.02, 0)
scrollCorner.Parent = scrollFrame

local scrollPadding = Instance.new("UIPadding")
scrollPadding.PaddingTop = UDim.new(0.01, 0)
scrollPadding.PaddingBottom = UDim.new(0.01, 0)
scrollPadding.PaddingLeft = UDim.new(0.01, 0)
scrollPadding.PaddingRight = UDim.new(0.01, 0)
scrollPadding.Parent = scrollFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0.008, 0)
listLayout.Parent = scrollFrame

-- Create item toggle rows for all categories
local itemButtons = {}
local itemRows = {}

for catIdx, category in CATEGORIES do
	itemRows[catIdx] = {}
	for i, objectText in category.items do
		local row = Instance.new("Frame")
		row.Name = getDisplayName(objectText)
		row.Size = UDim2.new(1, 0, 0.08, 0)
		row.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
		row.BorderSizePixel = 0
		row.LayoutOrder = i
		row.Visible = (catIdx == currentCategory)
		row.Parent = scrollFrame

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0.02, 0)
		rowCorner.Parent = row

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
		nameLabel.Position = UDim2.new(0.02, 0, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = getDisplayName(objectText)
		nameLabel.TextColor3 = Color3.fromRGB(200, 200, 230)
		nameLabel.TextScaled = true
		nameLabel.Font = Enum.Font.Gotham
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = row

		local itemBtn = Instance.new("TextButton")
		itemBtn.Name = "ItemToggle"
		itemBtn.Size = UDim2.new(0.3, 0, 0.8, 0)
		itemBtn.Position = UDim2.new(0.67, 0, 0.1, 0)
		itemBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
		itemBtn.Text = "✓"
		itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		itemBtn.TextScaled = true
		itemBtn.Font = Enum.Font.GothamBold
		itemBtn.BorderSizePixel = 0
		itemBtn.AutoButtonColor = true
		itemBtn.Parent = row

		local itemBtnCorner = Instance.new("UICorner")
		itemBtnCorner.CornerRadius = UDim.new(0.15, 0)
		itemBtnCorner.Parent = itemBtn

		itemButtons[objectText] = itemBtn
		itemRows[catIdx][objectText] = row
	end
end

-- ===================== UI LOGIC =====================

local function updateCatToggleUI(catIdx)
	local btn = catToggleButtons[catIdx]
	if not btn then return end
	if categoryEnabled[catIdx] then
		btn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
		btn.Text = "ON"
	else
		btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
		btn.Text = "OFF"
	end
end

local function updateItemButton(objectText)
	local btn = itemButtons[objectText]
	if not btn then return end
	if itemStates[objectText] then
		btn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
		btn.Text = "✓"
	else
		btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
		btn.Text = "X"
	end
end

local function updateTabButtons()
	for i, tabBtn in tabButtons do
		if i == currentCategory then
			tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
			tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
			tabBtn.TextColor3 = Color3.fromRGB(160, 160, 200)
		end
	end
end

local function switchCategory(catIdx)
	currentCategory = catIdx
	for catI, rows in itemRows do
		for objectText, row in rows do
			row.Visible = (catI == currentCategory)
		end
	end
	updateTabButtons()
end

-- Connect tab buttons
for i, tabBtn in tabButtons do
	tabBtn.MouseButton1Click:Connect(function()
		switchCategory(i)
	end)
end

-- Connect item toggle buttons
for objectText, btn in itemButtons do
	btn.MouseButton1Click:Connect(function()
		itemStates[objectText] = not itemStates[objectText]
		updateItemButton(objectText)
	end)
end

-- Hide/show panel
local panelVisible = true

local function togglePanel()
	panelVisible = not panelVisible
	frame.Visible = panelVisible
	openBtn.Visible = not panelVisible
end

hideBtn.MouseButton1Click:Connect(togglePanel)
openBtn.MouseButton1Click:Connect(function()
	if not openIsDragging then
		togglePanel()
	end
end)

-- ===================== TELEPORT & PROMPT LOGIC =====================

local function findProximityPromptInModel(model)
	local prompt = model:FindFirstChildOfClass("ProximityPrompt")
	if prompt then return prompt end
	-- Only search 1 level deep (avoids expensive GetDescendants)
	for _, child in model:GetChildren() do
		local pp = child:FindFirstChildOfClass("ProximityPrompt")
		if pp then return pp end
	end
	return nil
end

-- Cache NPC folder references and track presence
local npcsGuilds = Workspace:FindFirstChild("npcs_guilds")
local mysteriousSellerFolder = npcsGuilds and npcsGuilds:FindFirstChild("Mysterious Seller") or nil
local djFolder = npcsGuilds and npcsGuilds:FindFirstChild("DJ") or nil
local mysteriousSellerPresent = mysteriousSellerFolder ~= nil
local djPresent = djFolder ~= nil

-- Event-based cache for Black Market models (no periodic scanning)
local blackMarketModels = {}

local function removeIfBlackMarketModel(obj)
	if obj:IsA("Model") and obj.Name == "Model" then
		for i, m in blackMarketModels do
			if m == obj then
				table.remove(blackMarketModels, i)
				break
			end
		end
	end
end

local function addIfBlackMarketModel(obj)
	if obj:IsA("Model") and obj.Name == "Model" then
		table.insert(blackMarketModels, obj)
		obj.AncestryChanged:Connect(function()
			if not obj.Parent then
				removeIfBlackMarketModel(obj)
			end
		end)
	end
end

-- Initial scan (GetChildren only — models are direct children of Workspace)
for _, obj in Workspace:GetChildren() do
	addIfBlackMarketModel(obj)
end

-- Keep cache in sync via events (no more periodic rescans)
Workspace.ChildAdded:Connect(addIfBlackMarketModel)

-- NPC presence tracking via AncestryChanged
local function setupNpcFolderEvents(folder)
	local function onNpcChildAdded(child)
		if child.Name == "Mysterious Seller" then
			mysteriousSellerFolder = child
			mysteriousSellerPresent = true
			child.AncestryChanged:Connect(function()
				if not child.Parent or not child:IsDescendantOf(folder) then
					if mysteriousSellerFolder == child then
						mysteriousSellerPresent = false
						mysteriousSellerFolder = nil
					end
				end
			end)
		elseif child.Name == "DJ" then
			djFolder = child
			djPresent = true
			child.AncestryChanged:Connect(function()
				if not child.Parent or not child:IsDescendantOf(folder) then
					if djFolder == child then
						djPresent = false
						djFolder = nil
					end
				end
			end)
		end
	end

	folder.ChildAdded:Connect(onNpcChildAdded)
	for _, child in folder:GetChildren() do
		onNpcChildAdded(child)
	end
end

if npcsGuilds then
	setupNpcFolderEvents(npcsGuilds)
else
	-- Watch for npcs_guilds folder to appear
	Workspace.ChildAdded:Connect(function(child)
		if child.Name == "npcs_guilds" and not npcsGuilds then
			npcsGuilds = child
			mysteriousSellerFolder = child:FindFirstChild("Mysterious Seller")
			mysteriousSellerPresent = mysteriousSellerFolder ~= nil
			djFolder = child:FindFirstChild("DJ")
			djPresent = djFolder ~= nil
			setupNpcFolderEvents(child)
		end
	end)
end

local function isPromptAllowed(prompt)
	if not prompt then return false end
	local objectText = prompt.ObjectText
	if objectText and itemStates[objectText] then
		return true
	end
	return false
end

-- Substring matching for NPC categories (ObjectText like "Sell Charge111111!" or "DJ Troll Offers Holy Chain!")
local function findMatchingItem(objectText, catIdx)
	if not objectText then return nil end
	for itemName in categoryItemSet[catIdx] do
		if string.find(objectText, itemName, 1, true) then
			return itemName
		end
	end
	return nil
end

local function isCharacterAlive()
	local character = player.Character
	if not character then return false end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp or not hrp.Parent then return false end
	return true
end

local function teleportAndActivate(model, prefoundPrompt)
	if not masterEnabled then return end
	if not model:IsA("Model") then return end
	if not model or not model.Parent then return end
	if not isCharacterAlive() then return end

	local character = player.Character
	local hrp = character:FindFirstChild("HumanoidRootPart")

	-- Teleport to model
	local modelPivot = model:GetPivot()
	local teleportPos = modelPivot.Position + Vector3.new(0, 3, 0)
	hrp.CFrame = CFrame.new(teleportPos)

	-- Wait for a valid ProximityPrompt (up to 4 seconds)
	local prompt = nil
	local elapsed = 0
	while elapsed < 4 do
		if not model or not model.Parent then return end
		if not isCharacterAlive() then return end
		if prefoundPrompt and prefoundPrompt.Parent and prefoundPrompt.Enabled then
			prompt = prefoundPrompt
			break
		elseif not prefoundPrompt then
			prompt = findProximityPromptInModel(model)
			if prompt and prompt.Enabled then break end
			prompt = nil
		end
		task.wait(0.5)
		elapsed += 0.5
	end

	if not prompt then return end
	if not isCharacterAlive() then return end

	-- Wait for physics and prompt to be ready
	task.wait(0.3)

	if not isCharacterAlive() then return end

	-- Activate the prompt
	if prompt and prompt.Enabled and prompt.Parent and masterEnabled then
		prompt.HoldDuration = 0
		task.wait(0.1)
		if not isCharacterAlive() then return end
		prompt:InputHoldBegin()
		task.wait(0.15)
		if not isCharacterAlive() then return end
		prompt:InputHoldEnd()
	end
end

-- ===================== MAIN LOOP WITH PRIORITY =====================
-- Priority: 1) Черный Рынок  2) Mysterious Seller  3) DJ
-- If a higher-priority category has an item to buy, go there first

local function mainLoop()
	while mainRunning do
		if masterEnabled and isCharacterAlive() then
			local ok, err = pcall(function()
				local acted = false

				-- Priority 1: Черный Рынок (uses cached models)
				if categoryEnabled[1] and not acted then
					for _, obj in blackMarketModels do
						if obj.Parent then
							local prompt = findProximityPromptInModel(obj)
							if isPromptAllowed(prompt) then
								teleportAndActivate(obj, nil)
								acted = true
								break
							end
						end
					end
				end

				-- Priority 2: Mysterious Seller (scan NPC model descendants when present)
				if categoryEnabled[2] and not acted and mysteriousSellerPresent and mysteriousSellerFolder and mysteriousSellerFolder.Parent then
					for _, desc in mysteriousSellerFolder:GetDescendants() do
						if desc:IsA("ProximityPrompt") and desc.Parent and desc.Enabled then
							local matchedItem = findMatchingItem(desc.ObjectText, 2)
							if matchedItem and itemStates[matchedItem] then
								teleportAndActivate(mysteriousSellerFolder, desc)
								acted = true
								break
							end
						end
					end
				end

				-- Priority 3: DJ (scan NPC model descendants when present)
				if categoryEnabled[3] and not acted and djPresent and djFolder and djFolder.Parent then
					for _, desc in djFolder:GetDescendants() do
						if desc:IsA("ProximityPrompt") and desc.Parent and desc.Enabled then
							local matchedItem = findMatchingItem(desc.ObjectText, 3)
							if matchedItem and itemStates[matchedItem] then
								teleportAndActivate(djFolder, desc)
								acted = true
								break
							end
						end
					end
				end
			end)
			if not ok then
				warn("[AutoBuy] Error in main loop: " .. tostring(err))
			end
		end
		task.wait(1.5)
	end
end

-- Connect category toggle buttons
for i, catBtn in catToggleButtons do
	catBtn.MouseButton1Click:Connect(function()
		categoryEnabled[i] = not categoryEnabled[i]
		updateCatToggleUI(i)
		-- Start main loop if any category is ON
		local anyOn = false
		for c = 1, #CATEGORIES do
			if categoryEnabled[c] then anyOn = true break end
		end
		if anyOn and not mainRunning then
			mainRunning = true
			task.spawn(mainLoop)
		elseif not anyOn then
			mainRunning = false
		end
	end)
end

-- ===================== INITIALIZE =====================

updateTabButtons()
for i = 1, #CATEGORIES do
	updateCatToggleUI(i)
end
for objectText, _ in itemButtons do
	updateItemButton(objectText)
end
