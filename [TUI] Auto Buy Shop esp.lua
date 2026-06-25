local SoundOpen = script.Parent.Parent.SoundOpen
local SoundClose = script.Parent.Parent.SoundClose

local Prox_Open = script.Parent

local Tweeninfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

Prox_Open.Triggered:Connect(function()
	-- Открываем дверь
	Prox_Open.Enabled = false
	SoundOpen:Play()
	wait(2)
	-- Закрываем дверь
	wait(0.5)
	SoundClose:Play()
	script.Parent.Parent.Parent:Destroy()
	wait(2.5)
	Prox_Open.Enabled = true
end)

-- Управление ресурсами и таймером
local ServerStorage = game:GetService("ServerStorage")
local ResourcesFolder = ServerStorage:WaitForChild("Resources Tool")

local resources = {
	{name = "Metal", chance = 15, minQty = 1, maxQty = 2},
	{name = "Wood", chance = 30, minQty = 1, maxQty = 3},
	{name = "Glass", chance = 45, minQty = 1, maxQty = 4},
	{name = "Microcircuit", chance = 5, minQty = 1, maxQty = 1},
	{name = "Gunpowder", chance = 5, minQty = 1, maxQty = 2},
}

local cooldownTimeSeconds = 65 -- Время между получением ресурсов
local remainingTime = cooldownTimeSeconds
local timerActive = false
local ProximityPrompt = script.Parent
local timerCoroutine = nil

local function onPromptTriggered(player)
	if timerActive then
		return -- Если таймер активен, не выдаём ресурс
	end

	-- Выбор ресурса по вероятности
	local rand = math.random(1, 100)
	local cumulativeChance = 0
	local selectedResource = nil

	for _, resource in ipairs(resources) do
		cumulativeChance = cumulativeChance + resource.chance
		if rand <= cumulativeChance then
			selectedResource = resource
			break
		end
	end

	if selectedResource then
		local resourceTool = ResourcesFolder:FindFirstChild(selectedResource.name)
		if resourceTool then
			local count = math.random(selectedResource.minQty, selectedResource.maxQty)
			for i = 1, count do
				local clone = resourceTool:Clone()
				clone.Parent = player.Backpack
			end
		else
			warn("Ресурс " .. selectedResource.name .. " не найден в Resources Folder")
		end
	end
end

-- Инициализация
ProximityPrompt.Triggered:Connect(onPromptTriggered)
