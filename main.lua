-- [[ FarelDestroyer - Fly Script ]] --
-- Developer: Farel Destroyer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local mt = getrawmetatable(game)
setreadonly(mt, false)

local old = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    if getnamecallmethod() == "Kick" then
        return
    end
    return old(self, ...)
end)

local Window = WindUI:CreateWindow({
    Title = "FarelDestroyer - Fly Script",
    Author = "t.me/nyxdestroy",
    Theme = "Dark",
    Size = UDim2.fromOffset(660, 430),
    Folder = "farel_fly_script_mobile_pro",
    SideBarWidth = 190,
    ScrollBarEnabled = true
})

Window:SetBackgroundImage("rbxassetid://76527064525832")
Window:SetBackgroundImageTransparency(0.85)

WindUI:Notify({
    Title = "Farel Fly Script Loaded",
    Content = "Mobile support, smooth fly, auto teleport list",
    Icon = "check",
    Duration = 5
})

task.spawn(function()
    while task.wait(0.03) do
        local hue = (tick() % 5) / 5
        Window:EditWindow({
            TitleColor = Color3.fromHSV(hue, 1, 1)
        })
    end
end)

-- =============================================
-- SEMUA TAB (dibuat duluan, non-blocking)
-- =============================================
local HomeTab    = Window:Tab({ Title = "Home",          Icon = "home"    })
local FlyTab     = Window:Tab({ Title = "Fly Menu",      Icon = "rocket"  })
local TeleportTab = Window:Tab({ Title = "Teleport Menu", Icon = "map-pin" })

-- =============================================
-- HOME TAB - Section label
-- =============================================
HomeTab:Section({ Title = "Script Information" })

-- =============================================
-- IMAGE CAROUSEL
-- Pakai pendekatan dari code Google:
-- Standalone ScreenGui + ImageLabel + TweenPosition
-- Di-overlay di atas WindUI window dengan posisi relatif
-- =============================================
task.spawn(function()
    task.wait(0.5) -- beri waktu WindUI render window dulu

    local playerGui = player:WaitForChild("PlayerGui")

    -- Cari ScreenGui WindUI untuk ambil posisi & size window
    local windGui = nil
    for i = 1, 50 do
        for _, v in ipairs(playerGui:GetChildren()) do
            if v:IsA("ScreenGui") and v ~= playerGui:FindFirstChild("TikTokSlide_Custom") then
                windGui = v
                break
            end
        end
        if windGui then break end
        task.wait(0.1)
    end

    -- Buat ScreenGui overlay untuk carousel
    local sg = Instance.new("ScreenGui")
    sg.Name = "TikTokSlide_Custom"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 9999
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    sg.Parent = playerGui

    local images = {
        "rbxassetid://107142226685820",
        "rbxassetid://80586200988399",
        "rbxassetid://106259507228247"
    }

    local currentIndex = 1
    local isTweening = false

    -- Main container carousel
    -- Posisi: di bawah section "Script Information" di dalam area content WindUI
    -- WindUI window: center screen, 660x430, sidebar 190
    -- Content area mulai X: 50% - 330 + 190 = kira2 50%-140
    -- Section "Script Information" tingginya ~40px dari atas content
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "CarouselMain"
    mainFrame.Size = UDim2.new(0, 450, 0, 155)
    -- Posisi: tengah window WindUI, offset ke area content (setelah sidebar 190px)
    mainFrame.Position = UDim2.new(0.5, -115, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    mainFrame.ClipsDescendants = true
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 10
    mainFrame.Parent = sg

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    -- ImageLabel utama (hanya 1, ganti image saat slide)
    local imgLabel = Instance.new("ImageLabel")
    imgLabel.Size = UDim2.new(1, 0, 1, 0)
    imgLabel.Position = UDim2.new(0, 0, 0, 0)
    imgLabel.Image = images[currentIndex]
    imgLabel.BackgroundTransparency = 1
    imgLabel.ScaleType = Enum.ScaleType.Crop
    imgLabel.ZIndex = 11
    imgLabel.Parent = mainFrame

    local imgCorner = Instance.new("UICorner")
    imgCorner.CornerRadius = UDim.new(0, 12)
    imgCorner.Parent = imgLabel

    -- Dots indicator
    local dotHolder = Instance.new("Frame")
    dotHolder.Size = UDim2.new(1, 0, 0, 18)
    dotHolder.Position = UDim2.new(0, 0, 1, 4)
    dotHolder.BackgroundTransparency = 1
    dotHolder.ZIndex = 12
    dotHolder.Parent = mainFrame

    local dotList = Instance.new("UIListLayout")
    dotList.FillDirection = Enum.FillDirection.Horizontal
    dotList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    dotList.VerticalAlignment = Enum.VerticalAlignment.Center
    dotList.Padding = UDim.new(0, 6)
    dotList.Parent = dotHolder

    local dots = {}
    for i = 1, #images do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, i == 1 and 20 or 6, 0, 6)
        dot.BackgroundColor3 = i == 1
            and Color3.fromRGB(255, 255, 255)
            or Color3.fromRGB(80, 80, 95)
        dot.BorderSizePixel = 0
        dot.ZIndex = 13
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        dot.Parent = dotHolder
        table.insert(dots, dot)
    end

    local function updateDots(idx)
        for i, dot in ipairs(dots) do
            local on = i == idx
            TweenService:Create(dot,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad),
                {
                    Size = UDim2.new(0, on and 20 or 6, 0, 6),
                    BackgroundColor3 = on
                        and Color3.fromRGB(255, 255, 255)
                        or Color3.fromRGB(80, 80, 95)
                }
            ):Play()
        end
    end

    local function goNext()
        if isTweening then return end
        isTweening = true

        local nextIndex = (currentIndex % #images) + 1

        -- Slide keluar ke kiri
        imgLabel:TweenPosition(
            UDim2.new(-1.05, 0, 0, 0),
            Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.35, true,
            function()
                currentIndex = nextIndex
                imgLabel.Image = images[currentIndex]
                imgLabel.Position = UDim2.new(1.05, 0, 0, 0)
                updateDots(currentIndex)

                -- Slide masuk dari kanan
                imgLabel:TweenPosition(
                    UDim2.new(0, 0, 0, 0),
                    Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.35, true,
                    function()
                        isTweening = false
                    end
                )
            end
        )
    end

    -- Auto slide tiap 3 detik
    task.spawn(function()
        while sg and sg.Parent do
            task.wait(3)
            goNext()
        end
    end)

    -- Track apakah Home tab sedang aktif
    -- Sembunyikan carousel kalau bukan di Home
    -- WindUI pakai tab switching, kita detect via HomeTab callbacks
    local isHomeActive = true

    -- Karena WindUI ga ada OnTabChanged public, kita monitor via
    -- apakah ada elemen Home yang visible di GUI tree
    task.spawn(function()
        while sg and sg.Parent do
            task.wait(0.2)
            -- Cek apakah window masih ada
            if not windGui or not windGui.Parent then
                sg.Enabled = false
            end
        end
    end)
end)

-- =============================================
-- Sisa HOME TAB content
-- =============================================
local executor = identifyexecutor and identifyexecutor()
    or getexecutorname and getexecutorname()
    or "Unknown"

local gameName = "Unknown"
pcall(function()
    gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

HomeTab:Section({ Title = "Developer Card" })
HomeTab:Paragraph({
    Title = "Farel Destroyer",
    Content =
        "Creator : Farel\n" ..
        "Script : Fly Script\n" ..
        "Version : 1.0 Beta\n" ..
        "Executor : " .. executor
})

local function safeClipboardCopy(label, url)
    if setclipboard then
        setclipboard(url)
        WindUI:Notify({ Title = label, Content = "Link copied to clipboard", Duration = 3 })
    else
        WindUI:Notify({ Title = label, Content = url, Duration = 5 })
    end
end

HomeTab:Section({ Title = "Contact Developer" })
HomeTab:Button({
    Title = "Telegram",
    Callback = function() safeClipboardCopy("Telegram", "https://t.me/nyxdestroy") end
})
HomeTab:Button({
    Title = "WhatsApp",
    Callback = function() safeClipboardCopy("WhatsApp", "https://wa.me/6282172505548") end
})

HomeTab:Section({ Title = "Script Status" })
HomeTab:Paragraph({
    Title = "Script Status",
    Content =
        "Status : Running\n" ..
        "Version : 1.0 Beta\n" ..
        "Executor : " .. executor .. "\n" ..
        "Player : " .. player.Name .. "\n" ..
        "Game : " .. gameName
})

-- =============================================
-- FLY TAB
-- =============================================
FlyTab:Section({ Title = "Fly Controller" })

local flyEnabled = false
local flySpeed = 0
local flyMax = 300
local flyConnection = nil
local bodyGyro = nil
local bodyVelocity = nil
local currentToggle = nil

local function updateFlyToggleText()
    if currentToggle and currentToggle.SetTitle then
        currentToggle:SetTitle("FLY (" .. (flyEnabled and "Active" or "Nonactive") .. ")")
    end
end

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getRoot()
    return getCharacter():WaitForChild("HumanoidRootPart")
end

local function getHumanoid()
    return getCharacter():WaitForChild("Humanoid")
end

local function cleanupFly()
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    pcall(function()
        local hum = getHumanoid()
        hum.PlatformStand = false
        hum.AutoRotate = true
    end)
end

local function ensureFlyObjects()
    local root = getRoot()
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVelocity then bodyVelocity:Destroy() end

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "FarelFlyGyro"
    bodyGyro.P = 90000
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    bodyGyro.Parent = root

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "FarelFlyVelocity"
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root
end

local function setFlyState(state)
    flyEnabled = state
    updateFlyToggleText()

    if not flyEnabled then
        cleanupFly()
        WindUI:Notify({ Title = "Fly Disabled", Content = "Fly dimatikan", Icon = "x" })
        return
    end

    local hum = getHumanoid()
    ensureFlyObjects()
    hum.PlatformStand = false
    hum.AutoRotate = false

    if flyConnection then flyConnection:Disconnect() end

    local smoothVelocity = Vector3.zero

    flyConnection = RunService.RenderStepped:Connect(function(dt)
        if not flyEnabled then return end
        local char = player.Character
        if not char or not char.Parent then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or not bodyGyro or not bodyVelocity then return end

        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        humanoid.AutoRotate = false

        local moveDir = humanoid.MoveDirection
        local targetVelocity = (moveDir.Magnitude > 0 and flySpeed > 0)
            and moveDir.Unit * flySpeed
            or Vector3.zero

        local alpha = math.clamp((dt or 0.016) * 8, 0, 1)
        smoothVelocity = smoothVelocity:Lerp(targetVelocity, alpha)
        bodyVelocity.Velocity = smoothVelocity
    end)

    WindUI:Notify({ Title = "Fly Enabled", Content = "Fly aktif dengan smooth physics", Icon = "check" })
end

player.CharacterAdded:Connect(function()
    task.wait(1)
    if flyEnabled then setFlyState(true) else cleanupFly() end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        setFlyState(not flyEnabled)
        if currentToggle and currentToggle.SetValue then
            pcall(function() currentToggle:SetValue(flyEnabled) end)
        end
    end
end)

FlyTab:Paragraph({
    Title = "Fly Speed",
    Desc = "> 0\nMax 300\nMobile support aktif"
})

FlyTab:Slider({
    Title = "Fly Speed",
    Step = 1,
    Value = { Min = 0, Max = flyMax, Default = 0 },
    Callback = function(v) flySpeed = v end
})

currentToggle = FlyTab:Toggle({
    Title = "FLY (Nonactive)",
    Value = false,
    Callback = function(v) setFlyState(v) end
})

FlyTab:Paragraph({
    Title = "Keybind",
    Desc = "Tekan F untuk toggle fly di PC. Mobile pakai toggle UI."
})

-- =============================================
-- TELEPORT TAB
-- =============================================
TeleportTab:Section({ Title = "Player Teleport" })

local selectedPlayer = nil
local dropdown = nil

local function getPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then table.insert(names, plr.Name) end
    end
    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

local function applyDropdownOptions()
    if not dropdown then return end
    local names = getPlayerNames()
    if dropdown.SetOptions then dropdown:SetOptions(names)
    elseif dropdown.SetValues then dropdown:SetValues(names)
    elseif dropdown.Refresh then dropdown:Refresh(names)
    end
end

dropdown = TeleportTab:Dropdown({
    Title = "Teleport To",
    Values = getPlayerNames(),
    Callback = function(v) selectedPlayer = v end
})

TeleportTab:Button({
    Title = "TELEPORT",
    Desc = "Teleport ke player terpilih",
    Callback = function()
        if not selectedPlayer or selectedPlayer == "" then
            WindUI:Notify({ Title = "Error", Content = "Pilih player dulu!", Icon = "alert-circle" })
            return
        end
        local target = Players:FindFirstChild(selectedPlayer)
        local myChar = player.Character
        if not target or not target.Character or not myChar then
            WindUI:Notify({ Title = "Error", Content = "Target tidak tersedia", Icon = "alert-circle" })
            return
        end
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if targetRoot and myRoot then
            myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
            WindUI:Notify({ Title = "Teleported", Content = "Berhasil teleport ke " .. selectedPlayer, Icon = "check" })
        else
            WindUI:Notify({ Title = "Error", Content = "HumanoidRootPart tidak ditemukan", Icon = "alert-circle" })
        end
    end
})

TeleportTab:Paragraph({
    Title = "Auto Update",
    Desc = "Daftar player update otomatis saat player masuk / keluar"
})

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    applyDropdownOptions()
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if selectedPlayer == leavingPlayer.Name then selectedPlayer = nil end
    task.wait(0.1)
    applyDropdownOptions()
end)

task.delay(1, applyDropdownOptions)