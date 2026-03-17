-- [[ FarelDestroyer - Fly Script ]] --
-- Developer: Farel Destroyer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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

local HomeTab = Window:Tab({ Title = "Home", Icon = "home" })
HomeTab:Section({ Title = "Script Information" })
HomeTab:Section({ Title = "Gallery" })

local galleryFrame = Instance.new("Frame")
galleryFrame.Size = UDim2.new(1,0,0,180)
galleryFrame.BackgroundTransparency = 1
galleryFrame.ClipsDescendants = true
repeat task.wait() until HomeTab.Container
galleryFrame.Parent = HomeTab.Container -- INI KUNCI

local layout = Instance.new("UIPageLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.TweenTime = 0.4
layout.EasingStyle = Enum.EasingStyle.Quad
layout.EasingDirection = Enum.EasingDirection.Out
layout.Padding = UDim.new(0,10)
layout.Parent = galleryFrame
layout.GamepadInputEnabled = false
layout.TouchInputEnabled = true

local images = {
    "rbxassetid://107142226685820",
    "rbxassetid://80586200988399",
    "rbxassetid://106259507228247"
}

for i,id in ipairs(images) do
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, -10, 1, -10)
    img.Position = UDim2.new(0,5,0,5)
    img.BackgroundColor3 = Color3.fromRGB(40,40,40)
    img.Image = id
    img.ScaleType = Enum.ScaleType.Crop
    img.LayoutOrder = i
    img.Parent = galleryFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,12)
    corner.Parent = img
end

task.wait()
layout:JumpToIndex(1)

-- AUTO SLIDE
local index = 1
task.spawn(function()
    while true do
        task.wait(3)

        index += 1
        if index > #images then
            index = 1
        end

        for _,v in pairs(galleryFrame:GetChildren()) do
            if v:IsA("ImageLabel") and v.LayoutOrder == index then
                layout:JumpTo(v)
                break
            end
        end
    end
end)

local FlyTab = Window:Tab({ Title = "Fly Menu", Icon = "rocket" })
local TeleportTab = Window:Tab({ Title = "Teleport Menu", Icon = "map-pin" })

local function safeClipboardCopy(label, url)
    if setclipboard then
        setclipboard(url)
        WindUI:Notify({
            Title = label,
            Content = "Link copied to clipboard",
            Duration = 3
        })
    else
        WindUI:Notify({
            Title = label,
            Content = url,
            Duration = 5
        })
    end
end

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

HomeTab:Section({ Title = "Contact Developer" })
HomeTab:Button({
    Title = "Telegram",
    Callback = function()
        safeClipboardCopy("Telegram", "https://t.me/nyxdestroy")
    end
})

HomeTab:Button({
    Title = "WhatsApp",
    Callback = function()
        safeClipboardCopy("WhatsApp", "https://wa.me/6282172505548")
    end
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

-- CLEAN INFO
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
    local char = getCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char:WaitForChild("Humanoid")
end

local function cleanupFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    pcall(function()
        local hum = getHumanoid()
        hum.PlatformStand = false
        hum.AutoRotate = true
    end)
end

local function ensureFlyObjects()
    local root = getRoot()

    if bodyGyro then
        bodyGyro:Destroy()
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
    end

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
        WindUI:Notify({
            Title = "Fly Disabled",
            Content = "Fly dimatikan",
            Icon = "x"
        })
        return
    end

    local hum = getHumanoid()
    ensureFlyObjects()

    hum.PlatformStand = false
    hum.AutoRotate = false

    if flyConnection then
        flyConnection:Disconnect()
    end

    local smoothVelocity = Vector3.zero

    flyConnection = RunService.RenderStepped:Connect(function(dt)
        if not flyEnabled then
            return
        end

        local char = player.Character
        if not char or not char.Parent then
            return
        end

        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or not bodyGyro or not bodyVelocity then
            return
        end

        local cam = workspace.CurrentCamera
        local moveDir = humanoid.MoveDirection

        bodyGyro.CFrame = cam.CFrame
        humanoid.AutoRotate = false

        local targetVelocity
        if moveDir.Magnitude > 0 and flySpeed > 0 then
            targetVelocity = moveDir.Unit * flySpeed
        else
            targetVelocity = Vector3.zero
        end

        local alpha = math.clamp((dt or 0.016) * 8, 0, 1)
        smoothVelocity = smoothVelocity:Lerp(targetVelocity, alpha)
        bodyVelocity.Velocity = smoothVelocity
    end)

    WindUI:Notify({
        Title = "Fly Enabled",
        Content = "Fly aktif dengan smooth physics",
        Icon = "check"
    })
end

player.CharacterAdded:Connect(function()
    task.wait(1)
    if flyEnabled then
        setFlyState(true)
    else
        cleanupFly()
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        setFlyState(not flyEnabled)
        if currentToggle and currentToggle.SetValue then
            pcall(function()
                currentToggle:SetValue(flyEnabled)
            end)
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
    Value = {
        Min = 0,
        Max = flyMax,
        Default = 0
    },
    Callback = function(v)
        flySpeed = v
    end
})

currentToggle = FlyTab:Toggle({
    Title = "FLY (Nonactive)",
    Value = false,
    Callback = function(v)
        setFlyState(v)
    end
})

FlyTab:Paragraph({
    Title = "Keybind",
    Desc = "Tekan F untuk toggle fly di PC. Mobile pakai toggle UI."
})

-- TELEPORT
TeleportTab:Section({ Title = "Player Teleport" })

local selectedPlayer = nil
local dropdown = nil

local function getPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(names, plr.Name)
        end
    end
    table.sort(names, function(a, b)
        return a:lower() < b:lower()
    end)
    return names
end

local function applyDropdownOptions()
    if not dropdown then
        return
    end

    local names = getPlayerNames()

    if dropdown.SetOptions then
        dropdown:SetOptions(names)
    elseif dropdown.SetValues then
        dropdown:SetValues(names)
    elseif dropdown.Refresh then
        dropdown:Refresh(names)
    end
end

dropdown = TeleportTab:Dropdown({
    Title = "Teleport To",
    Values = getPlayerNames(),
    Callback = function(v)
        selectedPlayer = v
    end
})

TeleportTab:Button({
    Title = "TELEPORT",
    Desc = "Teleport ke player terpilih",
    Callback = function()
        if not selectedPlayer or selectedPlayer == "" then
            WindUI:Notify({
                Title = "Error",
                Content = "Pilih player dulu!",
                Icon = "alert-circle"
            })
            return
        end

        local target = Players:FindFirstChild(selectedPlayer)
        local myChar = player.Character
        if not target or not target.Character or not myChar then
            WindUI:Notify({
                Title = "Error",
                Content = "Target tidak tersedia",
                Icon = "alert-circle"
            })
            return
        end

        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")

        if targetRoot and myRoot then
            myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
            WindUI:Notify({
                Title = "Teleported",
                Content = "Berhasil teleport ke " .. selectedPlayer,
                Icon = "check"
            })
        else
            WindUI:Notify({
                Title = "Error",
                Content = "HumanoidRootPart tidak ditemukan",
                Icon = "alert-circle"
            })
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
    if selectedPlayer == leavingPlayer.Name then
        selectedPlayer = nil
    end
    task.wait(0.1)
    applyDropdownOptions()
end)

task.delay(1, applyDropdownOptions)
