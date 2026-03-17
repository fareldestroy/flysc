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

-- =============================================
-- CAROUSEL: Inject ke dalam WindUI object langsung
-- =============================================
task.spawn(function()
    task.wait(0.5)

    local playerGui = player:WaitForChild("PlayerGui")

    -- -------------------------------------------------------
    -- Step 1: Cari WindUI ScreenGui (satu-satunya ScreenGui
    --         besar yang ada di PlayerGui setelah kita load)
    -- -------------------------------------------------------
    local windGui = nil
    for _ = 1, 60 do
        task.wait(0.05)
        for _, v in ipairs(playerGui:GetChildren()) do
            if v:IsA("ScreenGui") and #v:GetDescendants() > 20 then
                windGui = v
                break
            end
        end
        if windGui then break end
    end
    if not windGui then return end

    -- -------------------------------------------------------
    -- Step 2: Cari ScrollingFrame yang merupakan content
    --         area tab (hanya ada 1 per tab di WindUI)
    -- -------------------------------------------------------
    local function getBiggestScrollingFrame()
        local best = nil
        local bestCount = 0
        for _, v in ipairs(windGui:GetDescendants()) do
            if v:IsA("ScrollingFrame") then
                local count = #v:GetChildren()
                if count > bestCount then
                    bestCount = count
                    best = v
                end
            end
        end
        return best
    end

    local scroll = getBiggestScrollingFrame()
    if not scroll then return end

    -- -------------------------------------------------------
    -- Step 3: Lihat UIListLayout di scroll untuk tahu cara
    --         WindUI mengatur posisi child-nya
    -- -------------------------------------------------------
    local listLayout = scroll:FindFirstChildOfClass("UIListLayout")

    -- -------------------------------------------------------
    -- Step 4: Cari frame "Section Script Information" untuk
    --         tahu LayoutOrder-nya dan inject carousel tepat setelahnya
    -- -------------------------------------------------------
    local sectionOrder = 1
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then
            -- Cari TextLabel bertuliskan "Script Information"
            for _, desc in ipairs(child:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Text == "Script Information" then
                    sectionOrder = child.LayoutOrder
                    break
                end
            end
        end
    end

    -- Geser semua item setelah sectionOrder ke bawah (+100)
    -- agar carousel punya ruang
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") and child.LayoutOrder > sectionOrder then
            child.LayoutOrder = child.LayoutOrder + 100
        end
    end

    -- -------------------------------------------------------
    -- Step 5: Buat carousel dan masukkan ke scroll
    -- -------------------------------------------------------
    local images = {
        "rbxassetid://107142226685820",
        "rbxassetid://80586200988399",
        "rbxassetid://106259507228247"
    }

    local PAD = 8
    local CAROUSEL_H = 160

    -- Wrapper carousel (langsung child scroll, pakai LayoutOrder)
    local wrapper = Instance.new("Frame")
    wrapper.Name = "CarouselWrapper"
    wrapper.Size = UDim2.new(1, 0, 0, CAROUSEL_H + 20) -- +20 untuk dots
    wrapper.BackgroundTransparency = 1
    wrapper.LayoutOrder = sectionOrder + 1              -- tepat setelah Section
    wrapper.Parent = scroll

    -- Clip area (mencegah gambar keluar batas)
    local clip = Instance.new("Frame")
    clip.Size = UDim2.new(1, -(PAD*2), 0, CAROUSEL_H)
    clip.Position = UDim2.new(0, PAD, 0, 0)
    clip.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    clip.ClipsDescendants = true
    clip.Parent = wrapper
    Instance.new("UICorner", clip).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(55, 55, 65)
    stroke.Thickness = 1
    stroke.Parent = clip

    -- ImageLabel tunggal (swap image saat slide)
    local imgLabel = Instance.new("ImageLabel")
    imgLabel.Size = UDim2.new(1, 0, 1, 0)
    imgLabel.Position = UDim2.new(0, 0, 0, 0)
    imgLabel.BackgroundTransparency = 1
    imgLabel.Image = images[1]
    imgLabel.ScaleType = Enum.ScaleType.Crop
    imgLabel.ZIndex = 2
    imgLabel.Parent = clip
    Instance.new("UICorner", imgLabel).CornerRadius = UDim.new(0, 12)

    -- Dot indicators
    local dotHolder = Instance.new("Frame")
    dotHolder.Size = UDim2.new(1, 0, 0, 14)
    dotHolder.Position = UDim2.new(0, 0, 0, CAROUSEL_H + 3)
    dotHolder.BackgroundTransparency = 1
    dotHolder.Parent = wrapper

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
                        or Color3.fromRGB(75, 75, 90)
                }
            ):Play()
        end
    end

    local carouselIndex = 1
    local isTweening = false

    local function goNext()
        if isTweening then return end
        isTweening = true
        local nextIdx = (carouselIndex % #images) + 1

        imgLabel:TweenPosition(
            UDim2.new(-1.05, 0, 0, 0),
            Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true,
            function()
                carouselIndex = nextIdx
                imgLabel.Image = images[carouselIndex]
                imgLabel.Position = UDim2.new(1.05, 0, 0, 0)
                updateDots(carouselIndex)
                imgLabel:TweenPosition(
                    UDim2.new(0, 0, 0, 0),
                    Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true,
                    function() isTweening = false end
                )
            end
        )
    end

    -- Auto slide
    task.spawn(function()
        while wrapper and wrapper.Parent do
            task.wait(3)
            goNext()
        end
    end)

    -- -------------------------------------------------------
    -- Step 6: Fix scroll canvas size agar carousel ikut discroll
    -- -------------------------------------------------------
    if listLayout then
        local function updateCanvas()
            local contentHeight = listLayout.AbsoluteContentSize.Y
            scroll.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 10)
        end
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        updateCanvas()
    end
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