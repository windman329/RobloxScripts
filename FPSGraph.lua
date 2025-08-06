local gui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
gui.Name = "Graph"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
gui.ScreenInsets = Enum.ScreenInsets.None

local RunService = game:GetService("RunService")

-- Настройки графика
local config = {
	sampleRate = 0.2,            -- интервал обновления (сек)
	maxSamples = 50,             -- количество точек на графике
	minY = 0,                    -- минимальное значение по Y
	maxY = 500,                  -- максимальное значение по Y
	graphColor = Color3.fromRGB(0, 255, 0),     -- цвет линии графика
	pointColor = Color3.fromRGB(100, 255, 100), -- цвет точек
	lineThickness = 1,           -- толщина линий графика
	pointSize = 2,               -- размер точек
	avgLineColor = Color3.fromRGB(0, 0, 255),   -- цвет линии среднего (синяя)
	avgLineThickness = 1,        -- толщина линии среднего
	minLineColor = Color3.fromRGB(255, 0, 0),   -- цвет линии минимального (красная)
	minLineThickness = 1,        -- толщина линии минимального
	maxLineColor = Color3.fromRGB(255, 255, 255), -- цвет линии максимального (белая)
	maxLineThickness = 1         -- толщина линии максимального
}

local graphFrame = Instance.new("Frame", gui)
graphFrame.Name = "GraphFrame"
graphFrame.BackgroundColor3 = Color3.new(0, 0, 0)
graphFrame.AnchorPoint = Vector2.new(1, 0)
graphFrame.Position = UDim2.new(1, -5, 0, 5)
graphFrame.Size = UDim2.new(0.25, 0, 0.25, 0)
local values = {}
local drawFolder = Instance.new("Folder", graphFrame)
drawFolder.Name = "GraphDrawings"

local closeB = Instance.new("TextButton", graphFrame)
closeB.Name = "closeB"
closeB.BackgroundColor3 = Color3.new(255, 0, 0)
closeB.AnchorPoint = Vector2.new(1, 0)
closeB.Position = UDim2.new(0, -5, 0, 0)
closeB.Size = UDim2.new(0, 20, 0, 20)
closeB.Text = "X"
closeB.TextColor3 = Color3.new(255, 255, 255)

local avgL = Instance.new("TextLabel", graphFrame)
avgL.Name = "avg"
avgL.BackgroundTransparency = 1
avgL.Position = UDim2.new(0, 70, 0, 0)
avgL.Size = UDim2.new(0, 60, 0, 10)
avgL.FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
avgL.MaxVisibleGraphemes = 8
avgL.TextColor3 = config.avgLineColor
avgL.TextSize = 14
avgL.TextXAlignment = Enum.TextXAlignment.Left
avgL.TextYAlignment = Enum.TextYAlignment.Top

local maxL = Instance.new("TextLabel", graphFrame)
maxL.Name = "max"
maxL.BackgroundTransparency = 1
maxL.Position = UDim2.new(0, 135, 0, 0)
maxL.Size = UDim2.new(0, 60, 0, 10)
maxL.FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
maxL.MaxVisibleGraphemes = 8
maxL.TextColor3 = config.maxLineColor
maxL.TextSize = 14
maxL.TextXAlignment = Enum.TextXAlignment.Left
maxL.TextYAlignment = Enum.TextYAlignment.Top

local minL = Instance.new("TextLabel", graphFrame)
minL.Name = "min"
minL.BackgroundTransparency = 1
minL.Position = UDim2.new(0, 200, 0, 0)
minL.Size = UDim2.new(0, 60, 0, 10)
minL.FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
minL.MaxVisibleGraphemes = 8
minL.TextColor3 = config.minLineColor
minL.TextSize = 14
minL.TextXAlignment = Enum.TextXAlignment.Left
minL.TextYAlignment = Enum.TextYAlignment.Top

local valL = Instance.new("TextLabel", graphFrame)
valL.Name = "val"
valL.BackgroundTransparency = 1
valL.Position = UDim2.new(0, 5, 0, 0)
valL.Size = UDim2.new(0, 60, 0, 10)
valL.FontFace = Font.new("16658246179", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
valL.MaxVisibleGraphemes = 8
valL.TextColor3 = config.graphColor
valL.TextSize = 14
valL.TextXAlignment = Enum.TextXAlignment.Left
valL.TextYAlignment = Enum.TextYAlignment.Top

local lastTime = tick()
local val = Instance.new("NumberValue", graphFrame)
local avg = 0
local minVal = 0
local maxVal = 0

-- Обновление FPS каждый кадр
RunService.RenderStepped:Connect(function()
	local now = tick()
	local dt = now - lastTime
	lastTime = now
	val.Value = 1 / dt
end)

local function drawGraph()
	drawFolder:ClearAllChildren()

	local width = graphFrame.AbsoluteSize.X
	local height = graphFrame.AbsoluteSize.Y
	local stepX = width / config.maxSamples

	-- Нарисовать линии и точки для значений
	for i = 2, #values do
		local v1, v2 = values[i - 1], values[i]
		local x1 = (i - 2) * stepX
		local y1 = height - ((v1 - config.minY) / (config.maxY - config.minY)) * height
		local x2 = (i - 1) * stepX
		local y2 = height - ((v2 - config.minY) / (config.maxY - config.minY)) * height

		local dx = x2 - x1
		local dy = y2 - y1
		local distance = math.sqrt(dx*dx + dy*dy)

		-- Линия графика
		local line = Instance.new("Frame")
		line.BackgroundColor3 = config.graphColor
		line.BorderSizePixel = 0
		line.AnchorPoint = Vector2.new(0.5, 0.5)
		line.Size = UDim2.new(0, distance, 0, config.lineThickness)
		line.Position = UDim2.new(0, x1 + dx/2, 0, y1 + dy/2)
		line.Rotation = math.deg(math.atan2(dy, dx))
		line.Parent = drawFolder

		-- Точка
		local dot = Instance.new("Frame")
		dot.BackgroundColor3 = config.pointColor
		dot.BorderSizePixel = 0
		dot.Size = UDim2.new(0, config.pointSize, 0, config.pointSize)
		dot.Position = UDim2.new(0, x2 - config.pointSize / 2, 0, y2 - config.pointSize / 2)
		dot.Parent = drawFolder
	end

	-- Рассчитать среднее значение
	local sum = 0
	for _, v in ipairs(values) do
		sum = sum + v
	end
	avg = #values > 0 and sum / #values or 0

	-- Найти минимум и максимум
	minVal = math.huge
	maxVal = -math.huge
	for _, v in ipairs(values) do
		if v < minVal then minVal = v end
		if v > maxVal then maxVal = v end
	end

	-- Вычислить Y для средней линии
	local avgY = height - ((avg - config.minY) / (config.maxY - config.minY)) * height
	-- Вычислить Y для минимальной линии
	local minY = height - ((minVal - config.minY) / (config.maxY - config.minY)) * height
	-- Вычислить Y для максимальной линии
	local maxY = height - ((maxVal - config.minY) / (config.maxY - config.minY)) * height

	-- Линия среднего значения (синяя)
	local avgLine = Instance.new("Frame")
	avgLine.BackgroundColor3 = config.avgLineColor
	avgLine.BorderSizePixel = 0
	avgLine.AnchorPoint = Vector2.new(0, 0.5)
	avgLine.Size = UDim2.new(1, 0, 0, config.avgLineThickness)
	avgLine.Position = UDim2.new(0, 0, 0, avgY)
	avgLine.Parent = drawFolder

	-- Линия минимального значения (красная)
	local minLine = Instance.new("Frame")
	minLine.BackgroundColor3 = config.minLineColor
	minLine.BorderSizePixel = 0
	minLine.AnchorPoint = Vector2.new(0, 0.5)
	minLine.Size = UDim2.new(1, 0, 0, config.minLineThickness)
	minLine.Position = UDim2.new(0, 0, 0, minY)
	minLine.Parent = drawFolder

	-- Линия максимального значения (белая)
	local maxLine = Instance.new("Frame")
	maxLine.BackgroundColor3 = config.maxLineColor
	maxLine.BorderSizePixel = 0
	maxLine.AnchorPoint = Vector2.new(0, 0.5)
	maxLine.Size = UDim2.new(1, 0, 0, config.maxLineThickness)
	maxLine.Position = UDim2.new(0, 0, 0, maxY)
	maxLine.Parent = drawFolder
end

closeB.MouseButton1Click:Connect(function()
	print("closing...")
	gui:Destroy()
	print("closed!")
	script:Destroy()
end)

while true do
	local value = math.clamp(val.Value, config.minY, config.maxY)
	valL.Text = string.format("%.6f", value)
	avgL.Text = string.format("%.6f", avg)
	minL.Text = string.format("%.6f", minVal)
	maxL.Text = string.format("%.6f", maxVal)
	table.insert(values, value)
	if #values > config.maxSamples then
		table.remove(values, 1)
	end

	drawGraph()
	task.wait(config.sampleRate)
end
