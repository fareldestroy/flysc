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
    if getnamecallmethod() == "Kick" then return end
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
        Window:EditWindow({ TitleColor = Color3.fromHSV(hue, 1, 1) })
    end
end)

-- =============================================
-- SEMUA TAB
-- =============================================
local HomeTab     = Window:Tab({ Title = "Home",          Icon = "home"    })
local FlyTab      = Window:Tab({ Title = "Fly Menu",      Icon = "rocket"  })
local TeleportTab = Window:Tab({ Title = "Teleport Menu", Icon = "map-pin" })

-- =============================================
-- HOME TAB
-- =============================================
HomeTab:Section({ Title = "Script Information" })

-- Spacer agar konten di bawah carousel tidak overlap
HomeTab:Paragraph({ Title = " ", Content = "\n\n\n\n\n\n\n\n" })

-- =============================================
-- CAROUSEL: ScreenGui overlay yang track posisi window WindUI realtime
-- =============================================
task.spawn(function()
    local playerGui = player:WaitForChild("PlayerGui")

    -- Tunggu WindUI ScreenGui
    local windGui = nil
    for _ = 1, 100 do
        task.wait(0.05)
        for _, v in ipairs(playerGui:GetChildren()) do
            if v:IsA("ScreenGui") and v.Name ~= "CarouselOverlay" and #v:GetDescendants() > 10 then
                windGui = v
                break
            end
        end
        if windGui then break end
    end
    if not windGui then return end

    task.wait(0.3)

    -- Cari Frame utama window WindUI (Frame terbesar langsung child ScreenGui)
    local windFrame = nil
    for _, v in ipairs(windGui:GetChildren()) do
        if v:IsA("Frame") then
            windFrame = v
            break
        end
    end
    if not windFrame then return end

    -- Buat ScreenGui overlay carousel
    local sg = Instance.new("ScreenGui")
    sg.Name = "CarouselOverlay"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = windGui.DisplayOrder + 1
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    sg.IgnoreGuiInset = true
    sg.Parent = playerGui

    local images = {
        "rbxassetid://107142226685820",
        "rbxassetid://80586200988399",
        "rbxassetid://106259507228247"
    }

    local SIDEBAR_W = 190   -- lebar sidebar WindUI
    local HEADER_H  = 70    -- tinggi header title + tab bar
    local SECTION_H = 36    -- tinggi section "Script Information"
    local CAROUSEL_H = 160  -- tinggi carousel
    local PADDING    = 8

    -- Container carousel
    local carouselFrame = Instance.new("Frame")
    carouselFrame.Name = "CarouselFrame"
    carouselFrame.BackgroundTransparency = 1
    carouselFrame.ClipsDescendants = true
    carouselFrame.Parent = sg

    -- Gambar
    local imgLabel = Instance.new("ImageLabel")
    imgLabel.Size = UDim2.new(1, -PADDING*2, 1, -PADDING)
    imgLabel.Position = UDim2.new(0, PADDING, 0, PADDING/2)
    imgLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    imgLabel.Image = images[1]
    imgLabel.ScaleType = Enum.ScaleType.Crop
    imgLabel.ZIndex = 2
    imgLabel.Parent = carouselFrame

    Instance.new("UICorner", imgLabel).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(55, 55, 65)
    stroke.Thickness = 1
    stroke.Parent = imgLabel

    -- Dots
    local dotHolder = Instance.new("Frame")
    dotHolder.Name = "DotHolder"
    dotHolder.BackgroundTransparency = 1
    dotHolder.ZIndex = 3
    dotHolder.Parent = sg

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
            or Color3.fromRGB(75, 75, 90)
        dot.BorderSizePixel = 0
        dot.ZIndex = 4
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        dot.Parent = dotHolder
        table.insert(dots, dot)
    end

    -- Update dots
    local function updateDots(idx)
        for i, dot in ipairs(dots) do
            local on = i == idx
            TweenService:Create(dot,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad),
                {
                    Size = UDim2.new(0, on and 20 or 6, 0, 6),
                    BackgroundColor3 = on
                        and Color3.fromRGB(255, 255, 255)
                        or Color3.fromRGB(75, 75, 90)
                }
            ):Play()
        end
    end

    -- Slide logic
    local carouselIndex = 1
    local isTweening = false

    local function goNext()
        if isTweening then return end
        isTweening = true
        local nextIdx = (carouselIndex % #images) + 1

        imgLabel:TweenPosition(
            UDim2.new(-1.1, PADDING, 0, PADDING/2),
            Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.32, true,
            function()
                carouselIndex = nextIdx
                imgLabel.Image = images[carouselIndex]
                imgLabel.Position = UDim2.new(1.1, PADDING, 0, PADDING/2)
                updateDots(carouselIndex)
                imgLabel:TweenPosition(
                    UDim2.new(0, PADDING, 0, PADDING/2),
                    Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.32, true,
                    function() isTweening = false end
                )
            end
        )
    end

    -- Auto slide
    task.spawn(function()
        while sg and sg.Parent do
            task.wait(3)
            goNext()
        end
    end)

    -- =============================================
    -- REALTIME TRACKING: ikuti posisi & ukuran window WindUI
    -- =============================================
    RunService.RenderStepped:Connect(function()
        if not windFrame or not windFrame.Parent then return end
        if not sg or not sg.Parent then return end

        -- Ambil AbsolutePosition & AbsoluteSize window WindUI
        local winPos  = windFrame.AbsolutePosition
        local winSize = windFrame.AbsoluteSize

        -- Hitung ukuran content area (kanan sidebar)
        local contentX = winPos.X + SIDEBAR_W
        local contentW = winSize.X - SIDEBAR_W

        -- Posisi carousel: di bawah header + section "Script Information"
        local carY = winPos.Y + HEADER_H + SECTION_H

        -- Set ukuran & posisi carousel frame
        carouselFrame.Position = UDim2.fromOffset(contentX + PADDING, carY)
        carouselFrame.Size     = UDim2.fromOffset(contentW - PADDING*2, CAROUSEL_H)

        -- Set posisi dot holder tepat di bawah carousel
        dotHolder.Position = UDim2.fromOffset(contentX, carY + CAROUSEL_H + 2)
        dotHolder.Size     = UDim2.fromOffset(contentW, 14)

        -- Sembunyikan carousel kalau window tidak visible
        local isVisible = windFrame.Visible and windFrame.AbsoluteSize.X > 50
        sg.Enabled = isVisible
    end)
end)

-- =============================================
-- Sisa HOME TAB
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

local function cleanupFly()
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    pcall(function()
        local hum = getCharacter():WaitForChild("Humanoid")
        hum.PlatformStand = false
        hum.AutoRotate = true
    end)
end

local function ensureFlyObjects()
    local root = getCharacter():WaitForChild("HumanoidRootPart")
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

    local hum = getCharacter():WaitForChild("Humanoid")
    ensureFlyObjects()
    hum.PlatformStand = false
    hum.AutoRotate = false

    if flyConnection then flyConnection:Disconnect() end
    local smoothVel = Vector3.zero

    flyConnection = RunService.RenderStepped:Connect(function(dt)
        if not flyEnabled then return end
        local c = player.Character
        if not c or not c.Parent then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        local humanoid = c:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or not bodyGyro or not bodyVelocity then return end

        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        humanoid.AutoRotate = false

        local moveDir = humanoid.MoveDirection
        local targetVel = (moveDir.Magnitude > 0 and flySpeed > 0)
            and moveDir.Unit * flySpeed or Vector3.zero

        smoothVel = smoothVel:Lerp(targetVel, math.clamp((dt or 0.016) * 8, 0, 1))
        bodyVelocity.Velocity = smoothVel
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

FlyTab:Paragraph({ Title = "Fly Speed", Desc = "> 0\nMax 300\nMobile support aktif" })

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

FlyTab:Paragraph({ Title = "Keybind", Desc = "Tekan F untuk toggle fly di PC. Mobile pakai toggle UI." })

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
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local mRoot = myChar:FindFirstChild("HumanoidRootPart")
        if tRoot and mRoot then
            mRoot.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
            WindUI:Notify({ Title = "Teleported", Content = "Berhasil teleport ke " .. selectedPlayer, Icon = "check" })
        else
            WindUI:Notify({ Title = "Error", Content = "HumanoidRootPart tidak ditemukan", Icon = "alert-circle" })
        end
    end
})

TeleportTab:Paragraph({ Title = "Auto Update", Desc = "Daftar player update otomatis saat player masuk / keluar" })

Players.PlayerAdded:Connect(function() task.wait(0.5); applyDropdownOptions() end)
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if selectedPlayer == leavingPlayer.Name then selectedPlayer = nil end
    task.wait(0.1); applyDropdownOptions()
end)

task.delay(1, applyDropdownOptions)