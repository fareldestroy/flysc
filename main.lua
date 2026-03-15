-- [[ FarelDestroyer - Fly Script ]] --
-- Developer: Farel Destroyer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

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

local FlyTab = Window:Tab({ Title = "Fly Main", Icon = "rocket" })
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })

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
    Title = "Teleport To ${player}",
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
