-- WATCH UI v_search_fix
-- LocalScript -> StarterPlayerScripts / PlayerGui

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- wait for character
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

-- ==========================
-- DRAG & DROP HELPER
-- ==========================
local function makeDraggable(frame)
    local dragging = false
    local dragStart
    local startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ROOT UI
local screen = Instance.new("ScreenGui")
screen.Name = "WatchUI_search_v1"
screen.ResetOnSpawn = false
screen.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- MAIN left small panel
local main = Instance.new("Frame", screen)
main.Name = "MainPanel"
main.Size = UDim2.new(0, 300, 0, 50)
main.Position = UDim2.new(0, 20, 0, 180)
main.BackgroundColor3 = Color3.fromRGB(35,35,35)
Instance.new("UICorner", main)

makeDraggable(main) -- Main panel verschiebbar

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Watch Menu"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left

local arrow = Instance.new("TextButton", main)
arrow.Name = "ToggleBtn"
arrow.Size = UDim2.new(0, 28, 0, 28)
arrow.Position = UDim2.new(1, -34, 0, 11)
arrow.BackgroundColor3 = Color3.fromRGB(70,70,70)
arrow.TextColor3 = Color3.fromRGB(255,255,255)
arrow.Text = "▼"
arrow.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", arrow)

local container = Instance.new("Frame", main)
container.Name = "Container"
container.Size = UDim2.new(1, 0, 0, 220)
container.Position = UDim2.new(0, 0, 1, 0)
container.BackgroundTransparency = 1
container.Visible = false

local function createLabel(text, y)
    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(1, -20, 0, 24)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextScaled = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

local usernameLabel = createLabel("You: " .. LocalPlayer.Name, 0)
local timeLabel = createLabel("Time: " .. os.date("%H:%M:%S"), 30)
local playerCountLabel = createLabel("Players: 0", 60)

local function createButton(text, y)
    local b = Instance.new("TextButton", container)
    b.Size = UDim2.new(1, -20, 0, 30)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Text = text
    b.Font = Enum.Font.SourceSans
    b.TextScaled = true
    Instance.new("UICorner", b)
    return b
end

local watchBtn = createButton("WATCH MODE", 100)
local copyNearestBtn = createButton("COPY NEAREST PLAYER", 135)

-- Toggle container
local collapsed = true
arrow.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    container.Visible = not collapsed
    arrow.Text = collapsed and "▼" or "▲"
    main.Size = collapsed and UDim2.new(0,300,0,50) or UDim2.new(0,300,0,270)
end)

-- RIGHT panel (hidden until watch active)
local rightPanel = Instance.new("Frame", screen)
rightPanel.Name = "RightPanel"
rightPanel.Size = UDim2.new(0, 260, 0, 380)
rightPanel.Position = UDim2.new(1, -280, 0, 360)
rightPanel.BackgroundColor3 = Color3.fromRGB(28,28,28)
rightPanel.Visible = false
Instance.new("UICorner", rightPanel)

makeDraggable(rightPanel) -- Right panel verschiebbar

local rpTitle = Instance.new("TextLabel", rightPanel)
rpTitle.Size = UDim2.new(1, -20, 0, 28)
rpTitle.Position = UDim2.new(0, 10, 0, 8)
rpTitle.BackgroundTransparency = 1
rpTitle.Text = "Players"
rpTitle.TextColor3 = Color3.fromRGB(255,255,255)
rpTitle.Font = Enum.Font.SourceSansBold
rpTitle.TextScaled = true
rpTitle.TextXAlignment = Enum.TextXAlignment.Left

-- SEARCH BOX on top of list
local searchBox = Instance.new("TextBox", rightPanel)
searchBox.Size = UDim2.new(1, -20, 0, 28)
searchBox.Position = UDim2.new(0, 10, 0, 40)
searchBox.Text = ""
searchBox.PlaceholderText = "Search username or displayname..."
searchBox.Font = Enum.Font.SourceSans
searchBox.TextScaled = true
searchBox.ClearTextOnFocus = false
Instance.new("UICorner", searchBox)

-- Scrollable list
local scroll = Instance.new("ScrollingFrame", rightPanel)
scroll.Name = "PlayerScroll"
scroll.Size = UDim2.new(1, -20, 1, -92)
scroll.Position = UDim2.new(0, 10, 0, 76)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 8
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local uiList = Instance.new("UIListLayout", scroll)
uiList.Padding = UDim.new(0,6)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
local padding = Instance.new("UIPadding", scroll)
padding.PaddingTop = UDim.new(0,4)

-- state vars
local watching = false
local watchGui
local currentIndex = 1
local plist = {}
local cameraLoader
local cameraConn
local infoBillboard
local playerButtons = {} -- [UserId] = {btn = button, player = player}

-- UTIL: rebuild plist (contains all players in Players:GetPlayers order)
local function rebuildPlist()
    plist = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(plist, p)
    end
end

-- UTIL: create/update a button for a given player
local function makePlayerButton(p)
    local uid = p.UserId
    local existing = playerButtons[uid]
    if existing and existing.btn and existing.btn.Parent then
        existing.player = p
        existing.btn.Text = p.Name .. " (" .. (p.DisplayName or "") .. ")"
        return existing.btn
    end

    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -10, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSans
    btn.TextScaled = true
    btn.AutoButtonColor = true
    btn.Text = p.Name .. " (" .. (p.DisplayName or "") .. ")"
    btn.Name = "Player_"..uid
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        -- if not in watch mode, start it
        if not watching then
            rebuildPlist()
            for i, pl in ipairs(plist) do
                if pl == p then
                    currentIndex = i
                    break
                end
            end
        else
            rebuildPlist()
            for i, pl in ipairs(plist) do
                if pl == p then
                    currentIndex = i
                    return
                end
            end
        end
    end)

    playerButtons[uid] = {btn = btn, player = p}
    return btn
end

-- refresh right panel list (create all player buttons, then filter)
local function refreshRightList(filter)
    filter = (filter or ""):lower()
    for _, p in ipairs(Players:GetPlayers()) do
        makePlayerButton(p)
    end
    for uid, entry in pairs(playerButtons) do
        local found = false
        for _, p in ipairs(Players:GetPlayers()) do
            if p.UserId == uid then found = true; break end
        end
        if not found then
            if entry.btn and entry.btn.Parent then entry.btn:Destroy() end
            playerButtons[uid] = nil
        end
    end

    for uid, entry in pairs(playerButtons) do
        local txt = (entry.player.Name .. " " .. (entry.player.DisplayName or "")):lower()
        if txt:find(filter, 1, true) then
            entry.btn.Visible = true
        else
            entry.btn.Visible = false
        end
    end
end

uiList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    local h = uiList.AbsoluteContentSize.Y
    scroll.CanvasSize = UDim2.new(0,0,0, math.max(h + 8, 0))
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    refreshRightList(searchBox.Text)
end)

local function findNearestExcludingSelf()
    local nearest, nearestDist = nil, math.huge
    local second, secondDist = nil, math.huge
    if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then return nil end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
            if d < nearestDist then
                second, secondDist = nearest, nearestDist
                nearest, nearestDist = p, d
            elseif d < secondDist then
                second, secondDist = p, d
            end
        end
    end
    if nearest == LocalPlayer then
        return second
    end
    if nearest and nearest ~= LocalPlayer then
        return nearest
    end
    return nil
end

copyNearestBtn.MouseButton1Click:Connect(function()
    local n = findNearestExcludingSelf()
    if n then
        pcall(function() setclipboard(n.Name) end)
    end
end)

local function createOrUpdateBillboard(target)
    if not target then return end
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        if infoBillboard then
            infoBillboard:Destroy()
            infoBillboard = nil
        end
        return
    end
    local hrp = target.Character.HumanoidRootPart
    if infoBillboard and infoBillboard.Parent ~= hrp then
        infoBillboard:Destroy()
        infoBillboard = nil
    end
    if not infoBillboard then
        infoBillboard = Instance.new("BillboardGui")
        infoBillboard.Name = "WatchInfo"
        infoBillboard.Size = UDim2.new(0,220,0,70)
        infoBillboard.StudsOffset = Vector3.new(0,2.3,0)
        infoBillboard.AlwaysOnTop = true
        infoBillboard.Parent = hrp

        local frame = Instance.new("Frame", infoBillboard)
        frame.Size = UDim2.new(1,0,1,0)
        frame.BackgroundTransparency = 0.45
        frame.BackgroundColor3 = Color3.fromRGB(5,5,5)
        Instance.new("UICorner", frame)

        local nameLbl = Instance.new("TextLabel", frame)
        nameLbl.Name = "NameLbl"
        nameLbl.Size = UDim2.new(1,-8,0,20)
        nameLbl.Position = UDim2.new(0,4,0,4)
        nameLbl.BackgroundTransparency = 1
        nameLbl.TextColor3 = Color3.fromRGB(255,255,255)
        nameLbl.Font = Enum.Font.SourceSansBold
        nameLbl.TextScaled = true
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left

        local hpLbl = Instance.new("TextLabel", frame)
        hpLbl.Name = "HpLbl"
        hpLbl.Size = UDim2.new(1,-8,0,18)
        hpLbl.Position = UDim2.new(0,4,0,26)
        hpLbl.BackgroundTransparency = 1
        hpLbl.TextColor3 = Color3.fromRGB(255,100,100)
        hpLbl.Font = Enum.Font.SourceSans
        hpLbl.TextScaled = true
        hpLbl.TextXAlignment = Enum.TextXAlignment.Left

        local distLbl = Instance.new("TextLabel", frame)
        distLbl.Name = "DistLbl"
        distLbl.Size = UDim2.new(1,-8,0,18)
        distLbl.Position = UDim2.new(0,4,0,46)
        distLbl.BackgroundTransparency = 1
        distLbl.TextColor3 = Color3.fromRGB(200,200,200)
        distLbl.Font = Enum.Font.SourceSans
        distLbl.TextScaled = true
        distLbl.TextXAlignment = Enum.TextXAlignment.Left
    end
end

local function stopWatch()
    watching = false
    rightPanel.Visible = false
    if cameraConn then cameraConn:Disconnect(); cameraConn = nil end
    if cameraLoader then pcall(function() cameraLoader:Destroy() end); cameraLoader = nil end
    if infoBillboard then pcall(function() infoBillboard:Destroy() end); infoBillboard = nil end
    if watchGui then pcall(function() watchGui:Destroy() end); watchGui = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end

local function startWatch(initialIndex)
    if watching then return end
    watching = true
    rightPanel.Visible = true
    refreshRightList(searchBox.Text)

    rebuildPlist()
    if #plist == 0 then
        watching = false
        rightPanel.Visible = false
        return
    end

    currentIndex = math.clamp(initialIndex or 1, 1, #plist)

    watchGui = Instance.new("Frame", screen)
    watchGui.Size = UDim2.new(0, 380, 0, 160)
    watchGui.Position = UDim2.new(0.5, -190, 0.72, -75)
    watchGui.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Instance.new("UICorner", watchGui)
    makeDraggable(watchGui) -- Watch GUI verschiebbar

    local nameLabel = Instance.new("TextLabel", watchGui)
    nameLabel.Size = UDim2.new(1, -120, 0, 28)
    nameLabel.Position = UDim2.new(0, 12, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextScaled = true
    nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = plist[currentIndex] and plist[currentIndex].Name or "?"

    local smallInfo = Instance.new("TextLabel", watchGui)
    smallInfo.Size = UDim2.new(1, -120, 0, 20)
    smallInfo.Position = UDim2.new(0, 12, 0, 40)
    smallInfo.BackgroundTransparency = 1
    smallInfo.Font = Enum.Font.SourceSans
    smallInfo.TextScaled = true
    smallInfo.TextColor3 = Color3.fromRGB(200,200,200)
    smallInfo.TextXAlignment = Enum.TextXAlignment.Left

    local copyBtn = Instance.new("TextButton", watchGui)
    copyBtn.Size = UDim2.new(0, 100, 0, 32)
    copyBtn.Position = UDim2.new(1, -110, 0, 8)
    copyBtn.Text = "Copy username"
    copyBtn.Font = Enum.Font.SourceSans
    copyBtn.TextScaled = true
    copyBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    Instance.new("UICorner", copyBtn)
    copyBtn.MouseButton1Click:Connect(function()
        local t = plist[currentIndex]
        if t and t ~= LocalPlayer then
            pcall(function() setclipboard(t.Name) end)
        end
    end)

    local leftBtn = Instance.new("TextButton", watchGui)
    leftBtn.Size = U
