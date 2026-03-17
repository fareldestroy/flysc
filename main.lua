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
-- TABS
-- =============================================
local HomeTab      = Window:Tab({ Title = "Home", Icon = "home" })
local TeleportTab  = Window:Tab({ Title = "Teleport Menu",  Icon = "map-pin" })
local PlayerTab    = Window:Tab({ Title = "Player Menu", Icon = "user" })

-- =============================================
-- HOME TAB
-- =============================================
local executor = identifyexecutor and identifyexecutor()
    or getexecutorname and getexecutorname()
    or "Unknown"

local gameName = "Unknown"
pcall(function()
    gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

HomeTab:Section({ Title = "Script Information" })
HomeTab:Paragraph({
    Title = "Farel Destroyer",
    Content =
        "Creator : Farel\n" ..
        "Script  : Fly Script\n" ..
        "Version : 1.0 Beta\n" ..
        "Executor: " .. executor
})

HomeTab:Section({ Title = "Script Status" })
HomeTab:Paragraph({
    Title = "Status",
    Content =
        "Status  : Running\n" ..
        "Player  : " .. player.Name .. "\n" ..
        "Game    : " .. gameName
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

TeleportTab:Section({ Title = "Save & Load Position" })

local savedPosition = nil

TeleportTab:Button({
    Title = "Save Position",
    Desc = "Simpan posisi karakter sekarang",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            savedPosition = char.HumanoidRootPart.CFrame
            WindUI:Notify({ Title = "Position Saved", Content = "Posisi berhasil disimpan!", Icon = "bookmark" })
        else
            WindUI:Notify({ Title = "Error", Content = "Karakter tidak ditemukan", Icon = "alert-circle" })
        end
    end
})

TeleportTab:Button({
    Title = "Load Position",
    Desc = "Kembali ke posisi yang disimpan",
    Callback = function()
        if not savedPosition then
            WindUI:Notify({ Title = "Error", Content = "Belum ada posisi tersimpan!", Icon = "alert-circle" })
            return
        end
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = savedPosition
            WindUI:Notify({ Title = "Position Loaded", Content = "Berhasil kembali ke posisi!", Icon = "check" })
        else
            WindUI:Notify({ Title = "Error", Content = "Karakter tidak ditemukan", Icon = "alert-circle" })
        end
    end
})

TeleportTab:Section({ Title = "Teleport to Spawn" })

TeleportTab:Button({
    Title = "Go to Spawn",
    Desc = "Teleport ke spawn point map",
    Callback = function()
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            WindUI:Notify({ Title = "Error", Content = "Karakter tidak ditemukan", Icon = "alert-circle" })
            return
        end
        local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
        if spawn then
            char.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
            WindUI:Notify({ Title = "Teleported", Content = "Berhasil teleport ke spawn!", Icon = "check" })
        else
            -- fallback ke 0,100,0 kalau ga ada SpawnLocation
            char.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
            WindUI:Notify({ Title = "Teleported", Content = "Spawn tidak ditemukan, teleport ke center map", Icon = "info" })
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

-- =============================================
-- PLAYER MENU TAB
-- =============================================

--local flyEnabled = false
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
        hum.WalkSpeed = 16
        hum.JumpPower = 50
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

    -- 🔥 FIX UTAMA
    hum.PlatformStand = true
    hum.AutoRotate = false
    hum.WalkSpeed = 0
    hum.JumpPower = 0

    if flyConnection then flyConnection:Disconnect() end
    local smoothVel = Vector3.zero

    flyConnection = RunService.RenderStepped:Connect(function(dt)
        if not flyEnabled then return end

        local c = player.Character
        if not c or not c.Parent then return end

        local root = c:FindFirstChild("HumanoidRootPart")
        local humanoid = c:FindFirstChildOfClass("Humanoid")

        if not root or not humanoid or not bodyGyro or not bodyVelocity then return end

        local cam = workspace.CurrentCamera
        bodyGyro.CFrame = cam.CFrame

        -- 🔥 MATIIN ANIMASI JALAN TOTAL
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)

        -- MOBILE + PC SUPPORT
        local direction = Vector3.zero

        -- 📱 MOBILE (ANALOG)
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude > 0 then
            direction += (cam.CFrame.LookVector * -moveDir.Z)
            direction += (cam.CFrame.RightVector * moveDir.X)
        end

        -- 💻 PC (WASD)
        if UIS:IsKeyDown(Enum.KeyCode.W) then
            direction += cam.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            direction -= cam.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            direction -= cam.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            direction += cam.CFrame.RightVector
        end

        -- SPEED FIX (0 = default)
        local speed = (flySpeed <= 0 and 16 or flySpeed)

        local targetVel = direction.Magnitude > 0 and direction.Unit * speed or Vector3.zero
        smoothVel = smoothVel:Lerp(targetVel, 0.25)

        bodyVelocity.Velocity = smoothVel

        -- HOVER FIX
        if direction.Magnitude == 0 then
            bodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
        end
    end)

    WindUI:Notify({
        Title = "Fly Enabled",
        Content = "Fly aktif dengan smooth physics",
        Icon = "check"
    }) 
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

PlayerTab:Paragraph({ Title = "Fly Speed", Desc = "Mobile support aktif" })

PlayerTab:Slider({
    Title = "Fly Speed",
    Step = 1,
    Value = { Min = 0, Max = flyMax, Default = 0 },
    Callback = function(v) flySpeed = v end
})

currentToggle = PlayerTab:Toggle({
    Title = "FLY (Nonactive)",
    Value = false,
    Callback = function(v) setFlyState(v) end
})

PlayerTab:Paragraph({ Title = "Keybind", Desc = "Tekan F untuk toggle fly di PC.\nMobile pakai toggle UI." })

-- ---- INVISIBLE ----
PlayerTab:Section({ Title = "Invisible" })

local invisEnabled = false
local invisToggle

invisToggle = PlayerTab:Toggle({
    Title = "Invisible (Nonactive)",
    Desc = "Sembunyikan karakter dari player lain",
    Value = false,
    Callback = function(v)
        invisEnabled = v

        -- update title
        invisToggle:SetTitle("Invisible (" .. (v and "Active" or "Nonactive") .. ")")

        local char = player.Character
        if not char then return end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.LocalTransparencyModifier = v and 1 or 0
            elseif part:IsA("Decal") or part:IsA("SpecialMesh") then
                part.Transparency = v and 1 or 0
            end
        end

        WindUI:Notify({
            Title = v and "Invisible ON" or "Invisible OFF",
            Content = v and "Karakter disembunyikan" or "Karakter terlihat kembali",
            Icon = v and "eye-off" or "eye"
        })
    end
})

-- ---- JUMP POWER ----
PlayerTab:Section({ Title = "Jump Power" })

local jumpEnabled = false
local jumpValue = 50
local jumpToggle

-- APPLY FUNCTION (biar selalu ke apply)
local function applyJump()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum.UseJumpPower = true

    if jumpEnabled then
        hum.JumpPower = (jumpValue <= 0 and 50 or jumpValue)
    else
        hum.JumpPower = 50 -- balik default
    end
end

-- TOGGLE
jumpToggle = PlayerTab:Toggle({
    Title = "Jump (Nonactive)",
    Value = false,
    Callback = function(v)
        jumpEnabled = v
        jumpToggle:SetTitle("Jump (" .. (v and "Active" or "Nonactive") .. ")")
        applyJump()
    end
})

-- SLIDER
PlayerTab:Slider({
    Title = "Jump Power",
    Desc = "Max: 100",
    Step = 5,
    Value = { Min = 0, Max = 100, Default = 50 },
    Callback = function(v)
        jumpValue = v
        if jumpEnabled then
            applyJump()
        end
    end
})

-- AUTO APPLY (anti di-reset game)
RunService.RenderStepped:Connect(function()
    if jumpEnabled then
        applyJump()
    end
end)

-- RESPAWN FIX
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyJump()
end)

-- ---- WALK SPEED ----
PlayerTab:Section({ Title = "Walk Speed" })

PlayerTab:Slider({
    Title = "Walk Speed",
    Desc = "Default: 16",
    Step = 2,
    Value = { Min = 0, Max = 200, Default = 16 },
    Callback = function(v)
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = (v <= 0 and 16 or v) end
        end
    end
})

-- ---- NOCLIP ----
PlayerTab:Section({ Title = "Noclip" })

local noclipEnabled = false
local noclipConn = nil

PlayerTab:Toggle({
    Title = "Noclip",
    Desc = "Tembus semua objek",
    Value = false,
    Callback = function(v)
        noclipEnabled = v
        if noclipEnabled then
            noclipConn = RunService.Stepped:Connect(function()
                local char = player.Character
                if not char then return end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end)
            WindUI:Notify({ Title = "Noclip ON", Content = "Bisa tembus objek", Icon = "zap" })
        else
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            WindUI:Notify({ Title = "Noclip OFF", Content = "Collision kembali normal", Icon = "zap-off" })
        end
    end
})
