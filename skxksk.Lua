-- XAR Main Script - Professional Roblox Script
-- Created by: جمال
-- Version: 2.0.0

local XAR = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- إعدادات السكربت
local Settings = {
    UI = {
        ThemeColor = Color3.fromRGB(30, 144, 255),
        BackgroundColor = Color3.fromRGB(25, 25, 25),
        TextColor = Color3.fromRGB(255, 255, 255),
        Transparency = 0.1,
        CornerRadius = UDim.new(0, 12)
    },
    Animations = {
        FadeTime = 0.3,
        ScaleTime = 0.2,
        SlideTime = 0.25
    },
    Camera = {
        FollowSpeed = 50,
        TweenTime = 1
    }
}

-- متغيرات عامة
local selectedPlayer = nil
local isMonitoring = false
local isSittingOnHead = false
local currentMusic = nil
local currentDance = nil
local cameraConnection = nil

-- إنشاء الواجهة الرئيسية
local function CreateMainUI()
    -- ScreenGui الرئيسي
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "XAR_UI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- الإطار الرئيسي (الظهور التدريجي)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
    mainFrame.BackgroundColor3 = Settings.UI.BackgroundColor
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- زوايا دائرية
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = Settings.UI.CornerRadius
    UICorner.Parent = mainFrame
    
    -- تأثير الزجاج (Glassmorphism)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
    })
    gradient.Transparency = NumberSequence.new(0.95)
    gradient.Parent = mainFrame
    
    -- شريط العنوان
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Settings.UI.ThemeColor
    titleBar.BackgroundTransparency = 0.2
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "XAR"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0.5, -15)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    -- Tabs (الأقسام)
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 50)
    tabContainer.Position = UDim2.new(0, 0, 0, 50)
    tabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    tabContainer.BackgroundTransparency = 0.2
    tabContainer.Parent = mainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 10)
    tabLayout.Parent = tabContainer
    
    local tabs = {"الاتصال", "الرقصات", "الأغاني", "المعلومات"}
    local tabButtons = {}
    
    for i, tabName in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabName .. "Tab"
        tabBtn.Size = UDim2.new(0, 70, 0, 35)
        tabBtn.BackgroundColor3 = Settings.UI.ThemeColor
        tabBtn.BackgroundTransparency = 0.3
        tabBtn.Text = tabName
        tabBtn.TextColor3 = Color3.new(1, 1, 1)
        tabBtn.TextSize = 14
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.Parent = tabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabBtn
        
        tabButtons[tabName] = tabBtn
    end
    
    -- Content Area (منطقة المحتوى)
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -20, 1, -120)
    contentArea.Position = UDim2.new(0, 10, 0, 110)
    contentArea.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    contentArea.BackgroundTransparency = 0.3
    contentArea.ClipsDescendants = true
    contentArea.Parent = mainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentArea
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.Parent = contentArea
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = "ContentScroller"
    scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.ScrollBarImageColor3 = Settings.UI.ThemeColor
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollingFrame.Parent = contentArea
    
    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Padding = UDim.new(0, 10)
    scrollLayout.Parent = scrollingFrame
    
    -- تأثير الظهور التدريجي
    mainFrame.BackgroundTransparency = 1
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    
    local fadeIn = TweenService:Create(mainFrame, TweenInfo.new(Settings.Animations.FadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.2,
        Size = UDim2.new(0, 350, 0, 500)
    })
    fadeIn:Play()
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        local fadeOut = TweenService:Create(mainFrame, TweenInfo.new(Settings.Animations.FadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0)
        })
        fadeOut:Play()
        task.wait(Settings.Animations.FadeTime)
        screenGui:Destroy()
    end)
    
    return {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        ContentScroller = scrollingFrame,
        TabButtons = tabButtons
    }
end

-- قسم الاتصال باللاعبين
local function CreateConnectionTab(contentScroller)
    local container = Instance.new("Frame")
    container.Name = "ConnectionTab"
    container.Size = UDim2.new(1, 0, 0, 400)
    container.BackgroundTransparency = 1
    container.Parent = contentScroller
    
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -20, 0, 45)
    searchBox.Position = UDim2.new(0, 10, 0, 10)
    searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    searchBox.PlaceholderText = "أدخل اسم اللاعب..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.TextColor3 = Color3.new(1, 1, 1)
    searchBox.TextSize = 16
    searchBox.Font = Enum.Font.Gotham
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = container
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 8)
    searchCorner.Parent = searchBox
    
    local connectBtn = Instance.new("TextButton")
    connectBtn.Name = "ConnectBtn"
    connectBtn.Size = UDim2.new(0, 200, 0, 45)
    connectBtn.Position = UDim2.new(0.5, -100, 0, 65)
    connectBtn.BackgroundColor3 = Settings.UI.ThemeColor
    connectBtn.Text = "اتصال باللاعب"
    connectBtn.TextColor3 = Color3.new(1, 1, 1)
    connectBtn.TextSize = 16
    connectBtn.Font = Enum.Font.GothamBold
    connectBtn.Parent = container
    
    local connectCorner = Instance.new("UICorner")
    connectCorner.CornerRadius = UDim.new(0, 8)
    connectCorner.Parent = connectBtn
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 0, 120)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "لم يتم الاتصال بأي لاعب"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = container
    
    local playerInfo = Instance.new("Frame")
    playerInfo.Name = "PlayerInfo"
    playerInfo.Size = UDim2.new(1, -20, 0, 100)
    playerInfo.Position = UDim2.new(0, 10, 0, 160)
    playerInfo.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    playerInfo.BackgroundTransparency = 0.2
    playerInfo.Visible = false
    playerInfo.Parent = container
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = playerInfo
    
    local playerAvatar = Instance.new("ImageLabel")
    playerAvatar.Name = "PlayerAvatar"
    playerAvatar.Size = UDim2.new(0, 60, 0, 60)
    playerAvatar.Position = UDim2.new(0, 20, 0.5, -30)
    playerAvatar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    playerAvatar.BackgroundTransparency = 0.3
    playerAvatar.Image = ""
    playerAvatar.Parent = playerInfo
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = playerAvatar
    
    local playerNameLabel = Instance.new("TextLabel")
    playerNameLabel.Name = "PlayerNameLabel"
    playerNameLabel.Size = UDim2.new(0, 200, 0, 30)
    playerNameLabel.Position = UDim2.new(0, 100, 0, 10)
    playerNameLabel.BackgroundTransparency = 1
    playerNameLabel.Text = "..."
    playerNameLabel.TextColor3 = Color3.new(1, 1, 1)
    playerNameLabel.TextSize = 18
    playerNameLabel.Font = Enum.Font.GothamBold
    playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerNameLabel.Parent = playerInfo
    
    -- أزرار التحكم باللاعب
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -120, 0, 30)
    buttonContainer.Position = UDim2.new(0, 100, 0, 45)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = playerInfo
    
    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    btnLayout.Padding = UDim.new(0, 5)
    btnLayout.Parent = buttonContainer
    
    -- زر نسخ الملابس
    local copyClothesBtn = Instance.new("TextButton")
    copyClothesBtn.Size = UDim2.new(0, 90, 0, 30)
    copyClothesBtn.BackgroundColor3 = Settings.UI.ThemeColor
    copyClothesBtn.Text = "نسخ الملابس"
    copyClothesBtn.TextColor3 = Color3.new(1, 1, 1)
    copyClothesBtn.TextSize = 12
    copyClothesBtn.Font = Enum.Font.Gotham
    copyClothesBtn.Parent = buttonContainer
    
    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 6)
    copyCorner.Parent = copyClothesBtn
    
    -- زر المراقبة
    local monitorBtn = Instance.new("TextButton")
    monitorBtn.Size = UDim2.new(0, 40, 0, 30)
    monitorBtn.BackgroundColor3 = Settings.UI.ThemeColor
    monitorBtn.Text = "👀"
    monitorBtn.TextColor3 = Color3.new(1, 1, 1)
    monitorBtn.TextSize = 16
    monitorBtn.Font = Enum.Font.Gotham
    monitorBtn.Parent = buttonContainer
    
    local monitorCorner = Instance.new("UICorner")
    monitorCorner.CornerRadius = UDim.new(0, 6)
    monitorCorner.Parent = monitorBtn
    
    -- زر الجلوس على الرأس
    local sitBtn = Instance.new("TextButton")
    sitBtn.Size = UDim2.new(0, 90, 0, 30)
    sitBtn.BackgroundColor3 = Settings.UI.ThemeColor
    sitBtn.Text = "الجلوس على الرأس"
    sitBtn.TextColor3 = Color3.new(1, 1, 1)
    sitBtn.TextSize = 11
    sitBtn.Font = Enum.Font.Gotham
    sitBtn.Parent = buttonContainer
    
    local sitCorner = Instance.new("UICorner")
    sitCorner.CornerRadius = UDim.new(0, 6)
    sitCorner.Parent = sitBtn
    
    -- زر الانتقال
    local teleportBtn = Instance.new("TextButton")
    teleportBtn.Size = UDim2.new(0, 70, 0, 30)
    teleportBtn.BackgroundColor3 = Settings.UI.ThemeColor
    teleportBtn.Text = "انتقال"
    teleportBtn.TextColor3 = Color3.new(1, 1, 1)
    teleportBtn.TextSize = 12
    teleportBtn.Font = Enum.Font.Gotham
    teleportBtn.Parent = buttonContainer
    
    local teleportCorner = Instance.new("UICorner")
    teleportCorner.CornerRadius = UDim.new(0, 6)
    teleportCorner.Parent = teleportBtn
    
    -- وظائف الأزرار
    connectBtn.MouseButton1Click:Connect(function()
        local targetName = searchBox.Text
        local targetPlayer = Players:FindFirstChild(targetName)
        
        if targetPlayer and targetPlayer.Character then
            selectedPlayer = targetPlayer
            statusLabel.Text = "✅ متصل باللاعب: " .. targetPlayer.Name
            playerInfo.Visible = true
            playerNameLabel.Text = targetPlayer.Name
            
            -- محاولة جلب الصورة الرمزية
            pcall(function()
                local userId = targetPlayer.UserId
                playerAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
            end)
        else
            statusLabel.Text = "❌ اللاعب غير موجود!"
        end
    end)
    
    -- نسخ الملابس
    copyClothesBtn.MouseButton1Click:Connect(function()
        if selectedPlayer and selectedPlayer.Character then
            local targetChar = selectedPlayer.Character
            local playerChar = player.Character
            
            if playerChar then
                -- نسخ القميص
                local targetShirt = targetChar:FindFirstChildOfClass("Shirt")
                local targetPants = targetChar:FindFirstChildOfClass("Pants")
                
                if targetShirt then
                    local newShirt = Instance.new("Shirt")
                    newShirt.ShirtTemplate = targetShirt.ShirtTemplate
                    newShirt.Parent = playerChar
                end
                
                if targetPants then
                    local newPants = Instance.new("Pants")
                    newPants.PantsTemplate = targetPants.PantsTemplate
                    newPants.Parent = playerChar
                end
                
                -- نسخ الإكسسوارات
                for _, accessory in ipairs(targetChar:GetChildren()) do
                    if accessory:IsA("Accessory") then
                        local newAccessory = accessory:Clone()
                        newAccessory.Parent = playerChar
                    end
                end
                
                statusLabel.Text = "✅ تم نسخ الملابس بنجاح!"
            end
        end
    end)
    
    -- المراقبة
    monitorBtn.MouseButton1Click:Connect(function()
        if selectedPlayer and selectedPlayer.Character then
            isMonitoring = not isMonitoring
            
            if isMonitoring then
                monitorBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                monitorBtn.Text = "👀 ✓"
                
                -- بدء المراقبة
                local camera = workspace.CurrentCamera
                local targetChar = selectedPlayer.Character
                local head = targetChar:FindFirstChild("Head")
                
                if head then
                    if cameraConnection then
                        cameraConnection:Disconnect()
                    end
                    
                    cameraConnection = RunService.RenderStepped:Connect(function()
                        if isMonitoring and selectedPlayer and selectedPlayer.Character then
                            local targetHead = selectedPlayer.Character:FindFirstChild("Head")
                            if targetHead then
                                camera.CFrame = CFrame.new(targetHead.Position + Vector3.new(0, 5, 10), targetHead.Position)
                            end
                        end
                    end)
                end
            else
                monitorBtn.BackgroundColor3 = Settings.UI.ThemeColor
                monitorBtn.Text = "👀"
                
                if cameraConnection then
                    cameraConnection:Disconnect()
                    cameraConnection = nil
                end
                
                -- إعادة الكاميرا
                workspace.CurrentCamera.CameraSubject = player.Character
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            end
        end
    end)
    
    -- الجلوس على الرأس
    sitBtn.MouseButton1Click:Connect(function()
        if selectedPlayer and selectedPlayer.Character and player.Character then
            isSittingOnHead = not isSittingOnHead
            
            if isSittingOnHead then
                sitBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                sitBtn.Text = "✓ الجلوس على الرأس"
                
                local targetHead = selectedPlayer.Character:FindFirstChild("Head")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                if targetHead and humanoid then
                    humanoid.Sit = true
                    
                    local connection
                    connection = RunService.Heartbeat:Connect(function()
                        if isSittingOnHead and selectedPlayer and selectedPlayer.Character then
                            local currentHead = selectedPlayer.Character:FindFirstChild("Head")
                            if currentHead and player.Character then
                                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                                if rootPart then
                                    rootPart.CFrame = CFrame.new(currentHead.Position + Vector3.new(0, 2, 0))
                                end
                            end
                        else
                            connection:Disconnect()
                        end
                    end)
                end
            else
                sitBtn.BackgroundColor3 = Settings.UI.ThemeColor
                sitBtn.Text = "الجلوس على الرأس"
                
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Sit = false
                end
            end
        end
    end)
    
    -- الانتقال
    teleportBtn.MouseButton1Click:Connect(function()
        if selectedPlayer and selectedPlayer.Character and player.Character then
            local targetChar = selectedPlayer.Character
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if rootPart and targetChar then
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    rootPart.CFrame = targetRoot.CFrame + Vector3.new(0, 5, 0)
                    statusLabel.Text = "✅ تم الانتقال!"
                end
            end
        end
    end)
    
    return container
end

-- قسم الرقصات
local function CreateDanceTab(contentScroller)
    local container = Instance.new("Frame")
    container.Name = "DanceTab"
    container.Size = UDim2.new(1, 0, 0, 300)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = contentScroller
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "🎵 الرقصات المتاحة"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = container
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 100, 0, 100)
    gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    gridLayout.Parent = container
    
    -- قائمة الرقصات (Animation IDs من Roblox)
    local danceAnimations = {
        {Name = "رقصة 1", ID = "rbxassetid://507770564"}, -- Dance 1
        {Name = "رقصة 2", ID = "rbxassetid://507770998"}, -- Dance 2
        {Name = "رقصة 3", ID = "rbxassetid://507771372"}, -- Dance 3
        {Name = "رقصة 4", ID = "rbxassetid://507771940"}, -- Dance 4
        {Name = "رقصة 5", ID = "rbxassetid://507772245"}, -- Dance 5
        {Name = "رقصة 6", ID = "rbxassetid://507772686"}, -- Dance 6
        {Name = "رقصة 7", ID = "rbxassetid://507773028"}, -- Dance 7
        {Name = "رقصة 8", ID = "rbxassetid://507773421"}, -- Dance 8
        {Name = "رقصة 9", ID = "rbxassetid://507773797"}, -- Dance 9
        {Name = "رقصة 10", ID = "rbxassetid://507774187"} -- Dance 10
    }
    
    for _, dance in ipairs(danceAnimations) do
        local danceBtn = Instance.new("TextButton")
        danceBtn.Size = UDim2.new(1, 0, 1, 0)
        danceBtn.BackgroundColor3 = Settings.UI.ThemeColor
        danceBtn.BackgroundTransparency = 0.2
        danceBtn.Text = dance.Name
        danceBtn.TextColor3 = Color3.new(1, 1, 1)
        danceBtn.TextSize = 14
        danceBtn.Font = Enum.Font.Gotham
        danceBtn.Parent = container
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = danceBtn
        
        danceBtn.MouseButton1Click:Connect(function()
            if player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    -- إيقاف الرقصة الحالية إذا وجدت
                    if currentDance then
                        currentDance:Stop()
                    end
                    
                    -- تشغيل الرقصة الجديدة
                    local animTrack = humanoid:LoadAnimation(dance.ID)
                    animTrack:Play()
                    currentDance = animTrack
                end
            end
        end)
    end
    
    -- زر إيقاف الرقص
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(1, -20, 0, 45)
    stopBtn.Position = UDim2.new(0, 10, 0, 250)
    stopBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    stopBtn.Text = "⏹️ إيقاف الرقص"
    stopBtn.TextColor3 = Color3.new(1, 1, 1)
    stopBtn.TextSize = 16
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.Parent = container
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 8)
    stopCorner.Parent = stopBtn
    
    stopBtn.MouseButton1Click:Connect(function()
        if currentDance then
            currentDance:Stop()
            currentDance = nil
        end
    end)
    
    return container
end

-- قسم الأغاني
local function CreateMusicTab(contentScroller)
    local container = Instance.new("Frame")
    container.Name = "MusicTab"
    container.Size = UDim2.new(1, 0, 0, 350)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = contentScroller
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "🎵 الأغاني"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = container
    
    local musicList = {
        {Name = "أغنية 1", ID = 9120789931, URL = "https://youtu.be/XUC15OqNFDw"},
        {Name = "أغنية 2", ID = 9120790123, URL = "https://youtu.be/t5XY86UaG5Y"},
        {Name = "أغنية 3", ID = 9120790345, URL = "https://youtu.be/aZjkwW9kVHQ"},
        {Name = "أغنية 4", ID = 9120790567, URL = "https://youtu.be/DMlyN-F85jg"},
        {Name = "أغنية 5", ID = 9120790789, URL = "https://youtu.be/8UNwYMVo0FA"}
    }
    
    for i, music in ipairs(musicList) do
        local musicBtn = Instance.new("TextButton")
        musicBtn.Size = UDim2.new(1, -20, 0, 45)
        musicBtn.Position = UDim2.new(0, 10, 0, 40 + (i-1) * 55)
        musicBtn.BackgroundColor3 = Settings.UI.ThemeColor
        musicBtn.BackgroundTransparency = 0.2
        musicBtn.Text = "🎵 " .. music.Name
        musicBtn.TextColor3 = Color3.new(1, 1, 1)
        musicBtn.TextSize = 16
        musicBtn.Font = Enum.Font.Gotham
        musicBtn.Parent = container
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = musicBtn
        
        musicBtn.MouseButton1Click:Connect(function()
            -- إيقاف الأغنية الحالية
            if currentMusic then
                currentMusic:Stop()
                currentMusic:Destroy()
            end
            
            -- إنشاء وتشغيل أغنية جديدة
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://" .. music.ID
            sound.Volume = 0.5
            sound.Looped = true
            sound.RollOffMode = Enum.RollOffMode.Linear
            sound.MaxDistance = 100
            sound.EmitterSize = 20
            sound.Parent = player.Character or workspace
            
            if player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    sound.Parent = head
                end
            end
            
            sound:Play()
            currentMusic = sound
        end)
    end
    
    -- زر إيقاف الأغاني
    local stopMusicBtn = Instance.new("TextButton")
    stopMusicBtn.Size = UDim2.new(1, -20, 0, 45)
    stopMusicBtn.Position = UDim2.new(0, 10, 0, 295)
    stopMusicBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    stopMusicBtn.Text = "⏹️ إيقاف الأغاني"
    stopMusicBtn.TextColor3 = Color3.new(1, 1, 1)
    stopMusicBtn.TextSize = 16
    stopMusicBtn.Font = Enum.Font.GothamBold
    stopMusicBtn.Parent = container
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 8)
    stopCorner.Parent = stopMusicBtn
    
    stopMusicBtn.MouseButton1Click:Connect(function()
        if currentMusic then
            currentMusic:Stop()
            currentMusic:Destroy()
            currentMusic = nil
        end
    end)
    
    return container
end

-- قسم المعلومات
local function CreateInfoTab(contentScroller)
    local container = Instance.new("Frame")
    container.Name = "InfoTab"
    container.Size = UDim2.new(1, 0, 0, 200)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = contentScroller
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 30)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "ℹ️ معلومات السكربت"
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.TextSize = 18
    infoLabel.Font = Enum.Font.GothamBold
    infoLabel.Parent = container
    
    local creatorFrame = Instance.new("Frame")
    creatorFrame.Size = UDim2.new(1, -20, 0, 80)
    creatorFrame.Position = UDim2.new(0, 10, 0, 40)
    creatorFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    creatorFrame.BackgroundTransparency = 0.2
    creatorFrame.Parent = container
    
    local creatorCorner = Instance.new("UICorner")
    creatorCorner.CornerRadius = UDim.new(0, 8)
    creatorCorner.Parent = creatorFrame
    
    local creatorText = Instance.new("TextLabel")
    creatorText.Size = UDim2.new(1, -20, 0, 30)
    creatorText.Position = UDim2.new(0, 10, 0, 10)
    creatorText.BackgroundTransparency = 1
    creatorText.Text = "صانع السكربت: جمال"
    creatorText.TextColor3 = Color3.new(1, 1, 1)
    creatorText.TextSize = 20
    creatorText.Font = Enum.Font.GothamBold
    creatorText.TextXAlignment = Enum.TextXAlignment.Left
    creatorText.Parent = creatorFrame
    
    local bestText = Instance.new("TextLabel")
    bestText.Size = UDim2.new(1, -20, 0, 30)
    bestText.Position = UDim2.new(0, 10, 0, 45)
    bestText.BackgroundTransparency = 1
    bestText.Text = "✨ أفضل سكربت في العالم ✨"
    bestText.TextColor3 = Color3.fromRGB(255, 215, 0)
    bestText.TextSize = 16
    bestText.Font = Enum.Font.Gotham
    bestText.TextXAlignment = Enum.TextXAlignment.Left
    bestText.Parent = creatorFrame
    
    local telegramBtn = Instance.new("TextButton")
    telegramBtn.Size = UDim2.new(1, -20, 0, 45)
    telegramBtn.Position = UDim2.new(0, 10, 0, 130)
    telegramBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 204)
    telegramBtn.Text = "📱 قناتنا على التليجرام"
    telegramBtn.TextColor3 = Color3.new(1, 1, 1)
    telegramBtn.TextSize = 16
    telegramBtn.Font = Enum.Font.GothamBold
    telegramBtn.Parent = container
    
    local telegramCorner = Instance.new("UICorner")
    telegramCorner.CornerRadius = UDim.new(0, 8)
    telegramCorner.Parent = telegramBtn
    
    telegramBtn.MouseButton1Click:Connect(function()
        setclipboard("https://t.me/hzhsksosm")
        
        -- إظهار رسالة تأكيد
        local notification = Instance.new("TextLabel")
        notification.Size = UDim2.new(0, 200, 0, 40)
        notification.Position = UDim2.new(0.5, -100, 0.5, -20)
        notification.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        notification.Text = "✅ تم نسخ الرابط!"
        notification.TextColor3 = Color3.new(1, 1, 1)
        notification.TextSize = 16
        notification.Font = Enum.Font.GothamBold
        notification.Parent = container
        
        local notifCorner = Instance.new("UICorner")
        notifCorner.CornerRadius = UDim.new(0, 8)
        notifCorner.Parent = notification
        
        task.wait(2)
        notification:Destroy()
    end)
    
    return container
end

-- تشغيل السكربت
local function Initialize()
    -- إنشاء الواجهة
    local ui = CreateMainUI()
    
    -- إنشاء الأقسام
    local connectionTab = CreateConnectionTab(ui.ContentScroller)
    local danceTab = CreateDanceTab(ui.ContentScroller)
    local musicTab = CreateMusicTab(ui.ContentScroller)
    local infoTab = CreateInfoTab(ui.ContentScroller)
    
    -- تبديل الأقسام
    ui.TabButtons["الاتصال"].MouseButton1Click:Connect(function()
        connectionTab.Visible = true
        danceTab.Visible = false
        musicTab.Visible = false
        infoTab.Visible = false
    end)
    
    ui.TabButtons["الرقصات"].MouseButton1Click:Connect(function()
        connectionTab.Visible = false
        danceTab.Visible = true
        musicTab.Visible = false
        infoTab.Visible = false
    end)
    
    ui.TabButtons["الأغاني"].MouseButton1Click:Connect(function()
        connectionTab.Visible = false
        danceTab.Visible = false
        musicTab.Visible = true
        infoTab.Visible = false
    end)
    
    ui.TabButtons["المعلومات"].MouseButton1Click:Connect(function()
        connectionTab.Visible = false
        danceTab.Visible = false
        musicTab.Visible = false
        infoTab.Visible = true
    end)
    
    -- إظهار قسم الاتصال افتراضياً
    connectionTab.Visible = true
    
    -- اختصار لوحة المفاتيح (X) لفتح/إغلاق السكربت
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.X then
            if ui.MainFrame.Visible then
                local fadeOut = TweenService:Create(ui.MainFrame, TweenInfo.new(Settings.Animations.FadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 0)
                })
                fadeOut:Play()
                task.wait(Settings.Animations.FadeTime)
                ui.MainFrame.Visible = false
            else
                ui.MainFrame.Visible = true
                local fadeIn = TweenService:Create(ui.MainFrame, TweenInfo.new(Settings.Animations.FadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0.2,
                    Size = UDim2.new(0, 350, 0, 500)
                })
                fadeIn:Play()
            end
        end
    end)
end

-- بدء التشغيل
task.spawn(Initialize)

return XAR
