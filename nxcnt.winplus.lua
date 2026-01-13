
-- LocalScript | StarterPlayerScripts 

-- =====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer

-- =====================
-- Preloader blackscreen
local function showPreloader()
	local preGui = Instance.new("ScreenGui")
	preGui.Name = "rj3yBlackscreen"
	preGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	preGui.Parent = LP:WaitForChild("PlayerGui")

	local black = Instance.new("Frame", preGui)
	black.Size = UDim2.fromScale(1, 1)
	black.Position = UDim2.fromScale(0, 0)
	black.BackgroundColor3 = Color3.new(0, 0, 0)
	black.BorderSizePixel = 0
	black.ZIndex = 9998

	local mainLabel = Instance.new("TextLabel", black)
	mainLabel.Size = UDim2.fromScale(0.9, 0.18)
	mainLabel.Position = UDim2.fromScale(0.05, 0.4)
	mainLabel.BackgroundTransparency = 1
	mainLabel.Text = "loading nxcnt.win+"
	mainLabel.Font = Enum.Font.GothamBold
	mainLabel.TextColor3 = Color3.new(1, 1, 1)
	mainLabel.TextScaled = true
	mainLabel.TextWrapped = true
	mainLabel.TextYAlignment = Enum.TextYAlignment.Center
	mainLabel.TextTransparency = 0
	mainLabel.ZIndex = 9999

	local subLabel = Instance.new("TextLabel", black)
	subLabel.Size = UDim2.fromScale(0.9, 0.08)
	subLabel.Position = UDim2.fromScale(0.05, 0.62)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = "made by nxcnt.win"
	subLabel.Font = Enum.Font.Gotham
	subLabel.TextColor3 = Color3.new(1, 1, 1)
	subLabel.TextScaled = true
	subLabel.TextWrapped = true
	subLabel.TextYAlignment = Enum.TextYAlignment.Center
	subLabel.TextTransparency = 0
	subLabel.ZIndex = 9999

	-- display for a short time then fade out
	spawn(function()
		wait(2.5)
		local t1 = TweenService:Create(black, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
		local t2 = TweenService:Create(mainLabel, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 1})
		local t3 = TweenService:Create(subLabel, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 1})
		t1:Play(); t2:Play(); t3:Play()
		t1.Completed:Wait()
		preGui:Destroy()
	end)
end

-- show the preloader immediately
pcall(showPreloader)

-- =====================
-- SETTINGS
-- =====================
local Settings = {
	Highlight = true,
	Names = true,
	Distance = true,
	Lines = false,
	Rainbow = true,
	LockOn = false,
	LockTarget = "Head",
	LockVisibleOnly = false,
	Crosshair = false
	,SilentMode = "Off" -- options: "Off", "Legit", "Rage"
	,Fly = false
	,Chams = false
	,WalkSpeed = 16
	,JumpPower = 50
	,FlySpeed = 50
}

local VERSION = "v1.0.0+"

local Performance = {
	MaxDistance = 700,
	TextUpdateRate = 0.3,
	LineUpdateRate = 0.05,
	SkipOffscreen = true
}

-- Keep performance values in sync with settings
Performance.MaxDistance = Settings.LockRange or Performance.MaxDistance
Performance.TextUpdateRate = Settings.TextUpdateRate or Performance.TextUpdateRate
Performance.LineUpdateRate = Settings.LineUpdateRate or Performance.LineUpdateRate

-- Fly controls
local FlySpeed = 50
local Flying = false
local flyVelocity = Vector3.new(0,0,0)
-- Mobile fly touch state + UI container
local flyTouchState = {F=false,B=false,L=false,R=false,U=false,D=false}
local flyControlsContainer = nil
-- Slider state
local draggingSlider = nil

-- =====================
-- STORAGE
-- =====================
local ESP = {}
local hue = 0
local lastTextUpdate = 0
local lastLineUpdate = 0
local SilentCooldown = 0.2
local lastSilent = 0

-- Crosshair drawing objects
local crossHor = Drawing.new("Line")
crossHor.Thickness = 3
crossHor.Transparency = 1
crossHor.Visible = false

local crossVer = Drawing.new("Line")
crossVer.Thickness = 3
crossVer.Transparency = 1
crossVer.Visible = false

local crossText = Drawing.new("Text")
crossText.Size = 20
crossText.Color = Color3.new(1,1,1)
crossText.Center = true
crossText.Outline = true
crossText.OutlineColor = Color3.new(0,0,0)
crossText.Text = "nxcnt.win+"
crossText.Visible = false

-- spinning crosshair state
local crossAngle = 0
local crossSpinSpeed = math.pi -- radians per second

-- =====================
-- GUI (DRAGGABLE MENU)
-- =====================
local gui = Instance.new("ScreenGui")
gui.Name = "nxcnt.win+"
gui.ResetOnSpawn = false
-- Keep this GUI above most other GUIs (preloader uses 10000)
gui.DisplayOrder = 9999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP:WaitForChild("PlayerGui")

local isTouch = UserInputService.TouchEnabled
local frame = Instance.new("ScrollingFrame", gui)
if isTouch then
	frame.Size = UDim2.fromScale(0.85, 0.6)
	frame.Position = UDim2.fromScale(0.07, 0.18)
else
	frame.Size = UDim2.fromScale(0.23, 0.6)
	frame.Position = UDim2.fromScale(0.05, 0.18)
end
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.ClipsDescendants = true
frame.ScrollBarThickness = 6
frame.CanvasSize = UDim2.new(0,0,0,0)

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

-- content container will hold the toggles and selectors and auto-size the canvas
local content = Instance.new("Frame", frame)
content.Name = "Content"
content.BackgroundTransparency = 1
content.Size = UDim2.new(1, 0, 0, 0)
content.Position = UDim2.new(0, 0, 0, 0)

local listLayout = Instance.new("UIListLayout", content)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	frame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
	content.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y)
end)

local title = Instance.new("TextLabel", frame)
local titleHeight = isTouch and 0.12 or 0.16
title.Size = UDim2.fromScale(1, titleHeight)
title.BackgroundTransparency = 1
title.Text = "nxcnt.win+ " .. VERSION
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)

-- Custom drag handler (works on both mouse and touch)
do
	local dragging = false
	local dragStart = Vector2.new(0,0)
	local startPos = UDim2.new()

	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local delta = input.Position - dragStart
		local absStartX = startPos.X.Scale * Camera.ViewportSize.X + startPos.X.Offset
		local absStartY = startPos.Y.Scale * Camera.ViewportSize.Y + startPos.Y.Offset
		local newX = absStartX + delta.X
		local newY = absStartY + delta.Y
		newX = math.clamp(newX, 0, Camera.ViewportSize.X - frame.AbsoluteSize.X)
		newY = math.clamp(newY, 0, Camera.ViewportSize.Y - frame.AbsoluteSize.Y)
		frame.Position = UDim2.new(0, newX, 0, newY)
	end)
end

-- Close / Open buttons
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.fromScale(0.12, titleHeight)
closeBtn.Position = UDim2.fromScale(0.86, 0)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = isTouch and UDim2.fromScale(0.18,0.08) or UDim2.fromScale(0.09,0.05)
openBtn.Position = isTouch and UDim2.fromScale(0.02,0.9) or UDim2.fromScale(0.02,0.9)
openBtn.Text = "nxcnt.win+"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextScaled = true
openBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
openBtn.Visible = false
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0,8)

closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	openBtn.Visible = true
end)
openBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
	openBtn.Visible = false
end)

-- Make the open button draggable (useful on touch)
do
	local dragging = false
	local dragStart = Vector2.new(0,0)
	local startPos = UDim2.new()

	openBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = openBtn.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local delta = input.Position - dragStart
		local absStartX = startPos.X.Scale * Camera.ViewportSize.X + startPos.X.Offset
		local absStartY = startPos.Y.Scale * Camera.ViewportSize.Y + startPos.Y.Offset
		local newX = absStartX + delta.X
		local newY = absStartY + delta.Y
		newX = math.clamp(newX, 0, Camera.ViewportSize.X - openBtn.AbsoluteSize.X)
		newY = math.clamp(newY, 0, Camera.ViewportSize.Y - openBtn.AbsoluteSize.Y)
		openBtn.Position = UDim2.new(0, newX, 0, newY)
	end)
end

-- =====================
-- TOGGLE CREATOR
-- =====================
local Buttons = {}

local function setSubmenuVisible(name, visible)
	local info = Buttons[name]
	if not info then return end
	local btn = info.btn
	btn.Visible = visible
end

local function toggleChanged(name, value)
	if name == "LockOn" then
		setSubmenuVisible("LockVisibleOnly", value)
	end

	if name == "Fly" then
		if value and isTouch then
			createFlyTouchControls()
		else
			removeFlyTouchControls()
		end
	end

	if name == "Lines" and value == false then
		for _, data in pairs(ESP) do
			if data.Line then
				data.Line.Visible = false
			end
		end
	end
end


local function createToggle(name, order)
	local btn = Instance.new("TextButton", content)
	local btnHeight = isTouch and 0.12 or 0.11
	local gap = isTouch and 0.03 or 0.12
	local xOffset = (name == "LockVisibleOnly") and 0.12 or 0.05
	local width = (name == "LockVisibleOnly") and 0.83 or 0.9
	btn.Size = UDim2.fromScale(width, btnHeight)
	btn.LayoutOrder = order
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.TextColor3 = Color3.new(1,1,1)

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

	local function refresh()
		btn.Text = name .. ": " .. (Settings[name] and "ON" or "OFF")
		btn.BackgroundColor3 = Settings[name] and Color3.fromRGB(60,160,60)
			or Color3.fromRGB(160,60,60)
	end

	btn.MouseButton1Click:Connect(function()
		Settings[name] = not Settings[name]
		refresh()
		if toggleChanged then toggleChanged(name, Settings[name]) end
	end)

	Buttons[name] = { btn = btn, order = order, xOffset = xOffset, width = width }

	refresh()
end

createToggle("Highlight", 0)
createToggle("Names", 1)
createToggle("Distance", 2)
createToggle("Lines", 3)
createToggle("Rainbow", 4)
createToggle("LockOn", 5)
createToggle("LockVisibleOnly", 6)
createToggle("Crosshair", 8)
createSelector("SilentMode", 9, {"Off", "Legit", "Rage"})
createToggle("Fly", 10)
createToggle("Chams", 11)
createSlider("WalkSpeed", 12, 10, 100, 1)
createSlider("JumpPower", 13, 10, 200, 1)
createSlider("FlySpeed", 14, 10, 200, 1)
createSlider("LockRange", 15, 50, 2000, 10)
createSlider("TextUpdateRate", 16, 0.05, 1.0, 0.05)
createSlider("LineUpdateRate", 17, 0.01, 0.2, 0.01)
createSlider("SilentCooldownSetting", 18, 0.05, 1.0, 0.05)
createSlider("SilentLegitBlend", 19, 0.0, 1.0, 0.01)
createSlider("HighlightTransparency", 20, 0.0, 1.0, 0.01)
-- Create on-screen controls for mobile fly movement
function createFlyTouchControls()
	if flyControlsContainer or not isTouch then return end
	flyControlsContainer = Instance.new("Folder", gui)
	flyControlsContainer.Name = "FlyControls"

	local size = 0.16
	local pad = 0.02

	-- D-pad (left-bottom)
	local dpad = Instance.new("Frame", flyControlsContainer)
	dpad.Size = UDim2.fromScale(size, size)
	dpad.Position = UDim2.fromScale(pad, 0.78)
	dpad.BackgroundTransparency = 1

	local function makeBtn(name, pos)
		local b = Instance.new("TextButton", dpad)
		b.Name = name
		b.Size = UDim2.fromScale(0.32, 0.32)
		b.Position = UDim2.fromScale(pos.X, pos.Y)
		b.Text = ""
		b.AutoButtonColor = false
		b.BackgroundColor3 = Color3.fromRGB(40,40,40)
		b.TextColor3 = Color3.new(1,1,1)
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
		-- touch handlers
		b.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				if name == "F" then flyTouchState.F = true end
				if name == "B" then flyTouchState.B = true end
				if name == "L" then flyTouchState.L = true end
				if name == "R" then flyTouchState.R = true end
			end
		end)
		b.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				if name == "F" then flyTouchState.F = false end
				if name == "B" then flyTouchState.B = false end
				if name == "L" then flyTouchState.L = false end
				if name == "R" then flyTouchState.R = false end
			end
		end)
		return b
	end

	-- layout: up center, left, right, down center (we'll place F,B,L,R)
	makeBtn("F", Vector2.new(0.34, 0))
	makeBtn("B", Vector2.new(0.34, 0.68))
	makeBtn("L", Vector2.new(0, 0.34))
	makeBtn("R", Vector2.new(0.68, 0.34))

	-- Vertical controls (right-bottom)
	local vert = Instance.new("Frame", flyControlsContainer)
	vert.Size = UDim2.fromScale(0.10, 0.28)
	vert.Position = UDim2.fromScale(0.85, 0.68)
	vert.BackgroundTransparency = 1

	local function makeVBtn(name, y)
		local b = Instance.new("TextButton", vert)
		b.Name = name
		b.Size = UDim2.fromScale(1, 0.48)
		b.Position = UDim2.fromScale(0, y)
		b.Text = name == "U" and "+" or "-"
		b.Font = Enum.Font.SourceSansBold
		b.TextScaled = true
		b.AutoButtonColor = false
		b.BackgroundColor3 = Color3.fromRGB(40,40,40)
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
		b.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				flyTouchState[name] = true
			end
		end)
		b.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				flyTouchState[name] = false
			end
		end)
		return b
	end

	makeVBtn("U", 0)
	makeVBtn("D", 0.52)
end

function removeFlyTouchControls()
	if not flyControlsContainer then return end
	flyControlsContainer:Destroy()
	flyControlsContainer = nil
	flyTouchState = {F=false,B=false,L=false,R=false,U=false,D=false}
end
-- Slider creator: horizontal slider with label and value
local function createSlider(name, order, minVal, maxVal, step)
	local container = Instance.new("Frame", content)
	container.Size = UDim2.fromScale(0.9, 0.12)
	container.LayoutOrder = order
	container.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", container)
	label.Size = UDim2.fromScale(0.5, 1)
	label.Position = UDim2.fromScale(0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = Color3.new(1,1,1)

	local valLabel = Instance.new("TextLabel", container)
	valLabel.Size = UDim2.fromScale(0.5, 1)
	valLabel.Position = UDim2.fromScale(0.5, 0)
	valLabel.BackgroundTransparency = 1
	valLabel.Font = Enum.Font.Gotham
	valLabel.TextScaled = true
	valLabel.TextColor3 = Color3.new(1,1,1)
	valLabel.TextXAlignment = Enum.TextXAlignment.Right

	local bar = Instance.new("Frame", container)
	bar.Size = UDim2.fromScale(1, 0.28)
	bar.Position = UDim2.fromScale(0, 0.62)
	bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)

	local fill = Instance.new("Frame", bar)
	fill.Size = UDim2.fromScale(0, 1)
	fill.Position = UDim2.fromScale(0,0)
	fill.BackgroundColor3 = Color3.fromRGB(140,140,140)
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0,6)

	local function setValue(v)
		v = math.clamp(v, minVal, maxVal)
		if step and step > 0 then
			v = math.floor((v / step) + 0.5) * step
		end
		Settings[name] = v
		local ratio = (v - minVal) / (maxVal - minVal)
		fill.Size = UDim2.fromScale(ratio, 1)
		if step and step < 1 then
			valLabel.Text = string.format("%.2f", v)
		else
			valLabel.Text = tostring(math.floor(v))
		end

		-- apply immediate effects
		if name == "WalkSpeed" and LP.Character and LP.Character:FindFirstChild("Humanoid") then
			LP.Character.Humanoid.WalkSpeed = v
		elseif name == "JumpPower" and LP.Character and LP.Character:FindFirstChild("Humanoid") then
			LP.Character.Humanoid.JumpPower = v
		elseif name == "FlySpeed" then
			FlySpeed = v
		elseif name == "LockRange" then
			Performance.MaxDistance = v
		elseif name == "TextUpdateRate" then
			Performance.TextUpdateRate = v
		elseif name == "LineUpdateRate" then
			Performance.LineUpdateRate = v
		elseif name == "SilentCooldownSetting" then
			SilentCooldown = v
		elseif name == "SilentLegitBlend" then
			Settings.SilentLegitBlend = v
		elseif name == "HighlightTransparency" then
			Settings.HighlightTransparency = v
		end
	end

	-- initialize
	setValue(Settings[name] or minVal)

	-- dragging behavior
	local dragging = false
	local function updateFromInput(pos)
		local abs = bar.AbsolutePosition
		local w = bar.AbsoluteSize.X
		local x = math.clamp(pos.X - abs.X, 0, w)
		local ratio = x / w
		local value = minVal + ratio * (maxVal - minVal)
		setValue(value)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			draggingSlider = bar
			updateFromInput(input.Position)
		end
	end)
	bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			draggingSlider = nil
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			updateFromInput(input.Position)
		end
	end)

	Buttons[name] = { btn = container, order = order }
end
-- Selector creator: cycles through options for a setting (responsive)
local function createSelector(name, order, options)
	local btn = Instance.new("TextButton", content)
	local btnHeight = isTouch and 0.12 or 0.11
	local gap = isTouch and 0.03 or 0.12
	btn.Size = UDim2.fromScale(0.9, btnHeight)
	btn.LayoutOrder = order
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.TextColor3 = Color3.new(1,1,1)

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

	local idx = 1
	for i, v in ipairs(options) do
		if Settings[name] == v then idx = i; break end
	end

	local function refresh()
		btn.Text = name .. ": " .. tostring(Settings[name])
		btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
	end

	btn.MouseButton1Click:Connect(function()
		idx = idx % #options + 1
		Settings[name] = options[idx]
		refresh()
	end)

	refresh()
end

createSelector("LockTarget", 7, {"Head", "Torso", "HumanoidRootPart", "Legs"})

-- initialize submenu visibility
-- initialize submenu visibility (instant)
if Buttons["LockVisibleOnly"] then
	setSubmenuVisible("LockVisibleOnly", Settings.LockOn)
end

-- =====================
-- ESP CREATION
-- =====================
local function createESP(player, char)
	if ESP[char] then return end

	local data = {}

	local h = Instance.new("Highlight")
	h.FillTransparency = Settings.HighlightTransparency or 0.6
	h.OutlineTransparency = 0
	h.Adornee = char
	h.Parent = workspace
	data.Highlight = h
	data.Player = player

	local head = char:FindFirstChild("Head")
	if head then
		local bill = Instance.new("BillboardGui", head)
		bill.Size = UDim2.fromScale(6,1.4)
		bill.StudsOffset = Vector3.new(0,3,0)
		bill.AlwaysOnTop = true

		local label = Instance.new("TextLabel", bill)
		label.Size = UDim2.fromScale(1,1)
		label.BackgroundTransparency = 1
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.TextStrokeTransparency = 0
		label.TextColor3 = Color3.new(1,1,1)

		data.Billboard = bill
		data.Label = label
	end

	local line = Drawing.new("Line")
	line.Thickness = 1.5
	line.Transparency = 1
	line.Visible = false
	data.Line = line

	ESP[char] = data
end

local function removeESP(char)
	if not ESP[char] then return end
	for _, v in pairs(ESP[char]) do
		if typeof(v) == "Instance" then v:Destroy() end
		if typeof(v) == "userdata" then v:Remove() end
	end
	ESP[char] = nil
end

local function handlePlayer(p)
	if p == LP then return end

	if p.Character then
		createESP(p, p.Character)
	end

	p.CharacterAdded:Connect(function(c)
		createESP(p, c)
	end)

	p.CharacterRemoving:Connect(removeESP)
end

for _, p in ipairs(Players:GetPlayers()) do
	handlePlayer(p)
end
Players.PlayerAdded:Connect(handlePlayer)

local function getTargetPosition(char, target)
	if not char then return nil end
	if target == "Head" then
		local part = char:FindFirstChild("Head")
		if part then return part.Position end
	elseif target == "Torso" then
		local part = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso")
		if part then return part.Position end
	elseif target == "HumanoidRootPart" then
		local part = char:FindFirstChild("HumanoidRootPart")
		if part then return part.Position end
	elseif target == "Legs" then
		local legNames = {"LeftFoot","RightFoot","LeftLeg","RightLeg","LeftLowerLeg","RightLowerLeg"}
		local sum = Vector3.new(0,0,0)
		local count = 0
		for _, name in ipairs(legNames) do
			local p = char:FindFirstChild(name)
			if p then sum = sum + p.Position; count = count + 1 end
		end
		if count > 0 then return sum / count end
	end
	return nil
end

local function isTargetVisible(pos, char)
	local origin = Camera.CFrame.Position
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {LP.Character}
	params.IgnoreWater = true

	-- Try multiple nearby target offsets to be more robust against small occluders
	local offsets = {
		Vector3.new(0,0,0),
		Vector3.new(0,0.15,0),
		Vector3.new(0.15,0,0),
		Vector3.new(-0.15,0,0),
		Vector3.new(0,0.15,0.15),
	}

	for _, off in ipairs(offsets) do
		local target = pos + off
		local dir = target - origin
		local result = workspace:Raycast(origin, dir, params)
		if result and result.Instance and result.Instance:IsDescendantOf(char) then
			return true
		end
	end

	return false
end

local function findNearestTarget()
	if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return nil end
	local myPos = LP.Character.HumanoidRootPart.Position
	local nearestPos = nil
	local nearestDist = math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character then
			local pos = getTargetPosition(p.Character, Settings.LockTarget)
			if pos then
				local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
				if Settings.LockVisibleOnly then
					if not onScreen then
						continue
					end
					if not isTargetVisible(pos, p.Character) then
						continue
					end
				end
				local dist = (myPos - pos).Magnitude
				if dist < nearestDist then
					nearestDist = dist
					nearestPos = pos
				end
			end
		end
	end
	return nearestPos, nearestDist
end

RunService.RenderStepped:Connect(function(dt)
	hue = (hue + dt * 0.25) % 1
	local rainbow = Color3.fromHSV(hue, 1, 1)

	if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
	local myPos = LP.Character.HumanoidRootPart.Position
	local now = tick()

	-- Crosshair handling (spinning)
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	local chLen = isTouch and 18 or 10
	local chColor = Settings.Rainbow and rainbow or Color3.new(1,1,1)
	if Settings.Crosshair then
		crossHor.Visible = true
		crossVer.Visible = true
		crossText.Visible = true
		crossAngle = (crossAngle + dt * crossSpinSpeed) % (2 * math.pi)
		local a1 = crossAngle
		local a2 = crossAngle + math.pi/2
		local v1 = Vector2.new(math.cos(a1), math.sin(a1))
		local v2 = Vector2.new(math.cos(a2), math.sin(a2))
		crossHor.From = center + v1 * chLen
		crossHor.To = center - v1 * chLen
		crossVer.From = center + v2 * chLen
		crossVer.To = center - v2 * chLen
		crossHor.Color = chColor
		crossVer.Color = chColor
		crossText.Position = Vector2.new(center.X, center.Y + (isTouch and 26 or 14))
		crossText.Color = chColor
	else
		crossHor.Visible = false
		crossVer.Visible = false
		crossText.Visible = false
	end

	-- Lock camera to nearest selected target when enabled
	if Settings.LockOn and Settings.SilentMode == "Off" then
		local targetPos, hdDist = findNearestTarget()
		if targetPos and hdDist and hdDist <= Performance.MaxDistance then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
		end
	end

	-- Fly handling (simple)
	if Settings.Fly and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = LP.Character.HumanoidRootPart
		local move = Vector3.new(0,0,0)
		if isTouch then
			if flyTouchState.F then move = move + (Camera.CFrame.LookVector) end
			if flyTouchState.B then move = move - (Camera.CFrame.LookVector) end
			if flyTouchState.L then move = move - (Camera.CFrame.RightVector) end
			if flyTouchState.R then move = move + (Camera.CFrame.RightVector) end
			if flyTouchState.U then move = move + Vector3.new(0,1,0) end
			if flyTouchState.D then move = move - Vector3.new(0,1,0) end
		else
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + (Camera.CFrame.LookVector) end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - (Camera.CFrame.LookVector) end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - (Camera.CFrame.RightVector) end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + (Camera.CFrame.RightVector) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
		end
		if move.Magnitude > 0 then
			move = move.Unit * FlySpeed * dt
			hrp.CFrame = hrp.CFrame + move
		end
	end

	for char, data in pairs(ESP) do
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local dist = (myPos - hrp.Position).Magnitude

		if dist > Performance.MaxDistance then
			data.Highlight.Enabled = false
			if data.Billboard then data.Billboard.Enabled = false end
			data.Line.Visible = false
			continue
		end

		-- team-based billboard color for names
		if data.Billboard and data.Label then
			if Settings.Chams and data.Player and data.Player.Team and LP.Team and data.Player.Team == LP.Team then
				data.Label.TextColor3 = data.Player.Team.TeamColor.Color
			else
				data.Label.TextColor3 = Color3.new(1,1,1)
			end
		end

		local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
		if Performance.SkipOffscreen and not onScreen then
			data.Line.Visible = false
			continue
		end

		-- determine color (chams/team aware or rainbow/static)
		local color
		if Settings.Chams and data.Player then
			local pteam = data.Player.Team
			if pteam and LP.Team and pteam == LP.Team then
				color = (pteam.TeamColor and pteam.TeamColor.Color) or Color3.fromRGB(60,160,60)
			else
				color = Color3.fromRGB(200,50,50)
			end
		else
			color = Settings.Rainbow and rainbow or Color3.new(1,0,0)
		end

		data.Highlight.Enabled = Settings.Highlight or Settings.Chams
		data.Highlight.FillColor = color
		data.Highlight.OutlineColor = color
		data.Highlight.FillTransparency = Settings.HighlightTransparency or 0.6

		if data.Label and now - lastTextUpdate >= Performance.TextUpdateRate then
			data.Billboard.Enabled = Settings.Names or Settings.Distance

			if Settings.Names and Settings.Distance then
				data.Label.Text = char.Name .. " | " .. math.floor(dist) .. " studs"
			elseif Settings.Names then
				data.Label.Text = char.Name
			elseif Settings.Distance then
				data.Label.Text = math.floor(dist) .. " studs"
			end
		end

		-- Ensure lines stay off when the setting is disabled
		if not Settings.Lines then
			data.Line.Visible = false
		else
			if onScreen and now - lastLineUpdate >= Performance.LineUpdateRate then
				data.Line.Visible = true
				data.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
				data.Line.To = Vector2.new(screenPos.X, screenPos.Y)
				data.Line.Color = color
			else
				data.Line.Visible = false
			end
		end
	end

	if now - lastTextUpdate >= Performance.TextUpdateRate then
		lastTextUpdate = now
	end
	if now - lastLineUpdate >= Performance.LineUpdateRate then
		lastLineUpdate = now
	end
end)

-- ensure humanoid properties stay in sync if sliders changed or character respawn
local function applyHumanoidSettings(hum)
	if hum then
		if Settings.WalkSpeed then hum.WalkSpeed = Settings.WalkSpeed end
		if Settings.JumpPower then hum.JumpPower = Settings.JumpPower end
	end
end

if LP.Character and LP.Character:FindFirstChild("Humanoid") then
	applyHumanoidSettings(LP.Character.Humanoid)
end
LP.CharacterAdded:Connect(function(c)
	c:WaitForChild("Humanoid"):WaitForChild("RootPart")
	applyHumanoidSettings(c:FindFirstChild("Humanoid"))
	-- restore FlySpeed from settings
	FlySpeed = Settings.FlySpeed or FlySpeed
end)

	-- Silent-aim: brief, on-click camera snap towards nearest target (client-side only)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if Settings.SilentMode == "Off" then return end

		local now = tick()
		if now - lastSilent < SilentCooldown then return end
		lastSilent = now

		local targetPos, dist = findNearestTarget()
		if not targetPos or not dist then return end
		if dist > Performance.MaxDistance then return end

		local prev = Camera and Camera.CFrame
		if not prev then return end

		if Settings.SilentMode == "Rage" then
			-- full instant snap (rage)
			Camera.CFrame = CFrame.new(prev.Position, targetPos)
			spawn(function()
				wait(0.06)
				if Camera and prev then Camera.CFrame = prev end
			end)
		elseif Settings.SilentMode == "Legit" then
			-- aim assist: tween camera rotation slightly towards target
			local dirNow = (prev.LookVector)
			local desired = (targetPos - prev.Position).Unit
			local blend = Settings.SilentLegitBlend or 0.35 -- how strong the assist is (0-1)
			local mixed = (dirNow:Lerp(desired, blend)).Unit
			Camera.CFrame = CFrame.new(prev.Position, prev.Position + mixed)
			spawn(function()
				wait(0.12)
				if Camera and prev then Camera.CFrame = prev end
			end)
		end
	end)
