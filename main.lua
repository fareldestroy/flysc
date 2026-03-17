-- [[ FarelDestroyer - Fly Script ]] --
-- Developer: Farel Destroyer

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local UIS             = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser     = game:GetService("VirtualUser")

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
    Title      = "FarelDestroyer - Fly Script",
    Author     = "t.me/nyxdestroy",
    Theme      = "Dark",
    Size       = UDim2.fromOffset(660, 430),
    Folder     = "farel_fly_script_mobile_pro",
    SideBarWidth = 190,
    ScrollBarEnabled = true
})

Window:SetBackgroundImage("rbxassetid://76527064525832")
Window:SetBackgroundImageTransparency(0.85)

WindUI:Notify({
    Title   = "Farel Fly Script Loaded",
    Content = "Mobile support | Fly | Teleport | AutoClick",
    Icon    = "check",
    Duration = 5
})

task.spawn(function()
    while task.wait(0.03) do
        Window:EditWindow({ TitleColor = Color3.fromHSV((tick() % 5) / 5, 1, 1) })
    end
end)

-- ============================================
-- TABS
-- ============================================
local HomeTab       = Window:Tab({ Title = "Home",          Icon = "home"     })
local PlayerMenuTab = Window:Tab({ Title = "Player Menu",   Icon = "user"     })
local TeleportTab   = Window:Tab({ Title = "Teleport Menu", Icon = "map-pin"  })

-- ============================================
-- HOME TAB
-- ============================================
local executor = identifyexecutor and identifyexecutor()
    or getexecutorname and getexecutorname()
    or "Unknown"

local gameName = "Unknown"
pcall(function()
    gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

HomeTab:Section({ Title = "Script Information" })
HomeTab:Paragraph({
    Title   = "Farel Destroyer",
    Content = "Creator  : Farel\nScript   : Fly Script\nVersion  : 1.0 Beta\nExecutor : " .. executor
})

HomeTab:Section({ Title = "Script Status" })
HomeTab:Paragraph({
    Title   = "Status",
    Content = "Status : Running\nPlayer : " .. player.Name .. "\nGame   : " .. gameName
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
HomeTab:Button({ Title = "Telegram", Callback = function() safeClipboardCopy("Telegram", "https://t.me/nyxdestroy") end })
HomeTab:Button({ Title = "WhatsApp", Callback = function() safeClipboardCopy("WhatsApp", "https://wa.me/6282172505548") end })

-- ============================================
-- HELPER
-- ============================================
local function getChar()  return player.Character or player.CharacterAdded:Wait() end
local function getHum()   return getChar():WaitForChild("Humanoid") end
local function getRoot()  return getChar():WaitForChild("HumanoidRootPart") end

-- ============================================
-- PLAYER MENU TAB
-- ============================================

-- ---- FLY ----
PlayerMenuTab:Section({ Title = "Fly" })

local flyEnabled    = false
local flySpeed      = 0        -- slider value (0 = pakai default 16)
local flyConn       = nil
local bodyGyro      = nil
local bodyVel       = nil
local smoothVel     = Vector3.zero
local flyToggle     = nil

local function cleanFly()
    if flyConn  then flyConn:Disconnect();   flyConn  = nil end
    if bodyGyro then bodyGyro:Destroy();     bodyGyro = nil end
    if bodyVel  then bodyVel:Destroy();      bodyVel  = nil end
    smoothVel = Vector3.zero
    pcall(function()
        local h = getHum()
        h.PlatformStand = false
        h.AutoRotate    = true
    end)
end

local function startFly()
    cleanFly()
    local root = getRoot()

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P           = 9e4
    bodyGyro.MaxTorque   = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame      = workspace.CurrentCamera.CFrame
    bodyGyro.Parent      = root

    bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent   = root

    local hum = getHum()
    hum.PlatformStand = true   -- matikan walk system Roblox sepenuhnya
    hum.AutoRotate    = false

    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not flyEnabled then return end
        local c = player.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        local h2 = c:FindFirstChildOfClass("Humanoid")
        if not r or not h2 or not bodyGyro or not bodyVel then return end

        h2.PlatformStand = true
        h2.AutoRotate    = false

        local cam     = workspace.CurrentCamera
        local speed   = math.max(flySpeed, 16)   -- 0 = 16 default

        -- Arah gerak: pakai MoveDirection humanoid (support PC+mobile)
        local md = h2.MoveDirection
        local move = Vector3.zero

        if md.Magnitude > 0 then
            -- Terbang sesuai arah kamera (termasuk naik/turun)
            local look  = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            local flat  = Vector3.new(md.X, 0, md.Z).Unit
            -- gabung horizontal dari joystick dengan arah kamera
            local camFlat  = Vector3.new(look.X,  0, look.Z).Unit
            local camRight = Vector3.new(right.X, 0, right.Z).Unit
            local fwd   = camFlat  * -flat.Z   -- Z negatif = maju
            local str   = camRight * flat.X
            move = fwd + str
            if move.Magnitude > 0 then move = move.Unit end
        end

        -- Naik / turun (PC: Space & C, mobile lewat kamera pitch)
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            move = move + Vector3.new(0, 1, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl)
        or UIS:IsKeyDown(Enum.KeyCode.C) then
            move = move + Vector3.new(0, -1, 0)
        end

        if move.Magnitude > 0 then move = move.Unit end

        bodyGyro.CFrame = cam.CFrame
        local alpha = math.clamp(dt * 10, 0, 1)
        smoothVel = smoothVel:Lerp(move * speed, alpha)
        bodyVel.Velocity = smoothVel
    end)
end

local function setFly(state)
    flyEnabled = state
    if flyToggle and flyToggle.SetTitle then
        flyToggle:SetTitle("Fly (" .. (state and "Active" or "Nonactive") .. ")")
    end
    if state then
        startFly()
        WindUI:Notify({ Title = "Fly ON", Content = "Terbang aktif | Speed min 16", Icon = "check" })
    else
        cleanFly()
        WindUI:Notify({ Title = "Fly OFF", Content = "Fly dimatikan", Icon = "x" })
    end
end

flyToggle = PlayerMenuTab:Toggle({
    Title    = "Fly (Nonactive)",
    Value    = false,
    Callback = function(v) setFly(v) end
})

PlayerMenuTab:Slider({
    Title = "Fly Speed  (0 = default 16)",
    Step  = 1,
    Value = { Min = 0, Max = 300, Default = 0 },
    Callback = function(v) flySpeed = v end
})

PlayerMenuTab:Paragraph({
    Title = "Kontrol Fly",
    Content = "PC   : WASD bergerak | Space naik | C turun\nMobile : Joystick bergerak"
})

-- Keybind F
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        local newState = not flyEnabled
        setFly(newState)
        if flyToggle and flyToggle.SetValue then
            pcall(function() flyToggle:SetValue(newState) end)
        end
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    smoothVel = Vector3.zero
    if flyEnabled then startFly() else cleanFly() end
end)

-- ---- WALK SPEED ----
PlayerMenuTab:Section({ Title = "Walk Speed" })

local wsEnabled = false
local wsValue   = 0
local wsToggle  = nil

local wsLoop = task.spawn(function()
    while true do
        task.wait(0.1)
        if wsEnabled and not flyEnabled then
            pcall(function()
                local h = getHum()
                h.WalkSpeed = math.max(wsValue, 16)   -- 0 = 16 default
            end)
        end
    end
end)

wsToggle = PlayerMenuTab:Toggle({
    Title    = "Walk Speed (Nonactive)",
    Value    = false,
    Callback = function(v)
        wsEnabled = v
        if wsToggle and wsToggle.SetTitle then
            wsToggle:SetTitle("Walk Speed (" .. (v and "Active" or "Nonactive") .. ")")
        end
        if not v then
            pcall(function() getHum().WalkSpeed = 16 end)
        end
        WindUI:Notify({ Title = v and "WalkSpeed ON" or "WalkSpeed OFF", Content = v and "Speed aktif" or "Reset ke 16", Icon = v and "check" or "x" })
    end
})

PlayerMenuTab:Slider({
    Title = "Walk Speed  (0 = default 16)",
    Step  = 1,
    Value = { Min = 0, Max = 300, Default = 0 },
    Callback = function(v) wsValue = v end
})

-- ---- JUMP POWER ----
PlayerMenuTab:Section({ Title = "Jump Power" })

local jpEnabled = false
local jpValue   = 0
local jpToggle  = nil

-- Loop paksa set JumpPower terus biar ga di-reset Roblox
task.spawn(function()
    while true do
        task.wait(0.05)
        if jpEnabled then
            pcall(function()
                local h = getHum()
                local actual = jpValue == 0 and 50 or jpValue
                h.JumpPower     = actual
                h.JumpHeight    = actual / 5   -- sync JumpHeight juga
                h.UseJumpPower  = true         -- pastikan pakai JumpPower bukan JumpHeight
            end)
        end
    end
end)

jpToggle = PlayerMenuTab:Toggle({
    Title    = "Jump Power (Nonactive)",
    Value    = false,
    Callback = function(v)
        jpEnabled = v
        if jpToggle and jpToggle.SetTitle then
            jpToggle:SetTitle("Jump Power (" .. (v and "Active" or "Nonactive") .. ")")
        end
        if not v then
            pcall(function()
                local h = getHum()
                h.JumpPower = 50
                h.UseJumpPower = true
            end)
        end
        WindUI:Notify({ Title = v and "JumpPower ON" or "JumpPower OFF", Content = v and "Jump aktif" or "Reset ke default", Icon = v and "check" or "x" })
    end
})

PlayerMenuTab:Slider({
    Title = "Jump Power  (0 = default 50)",
    Step  = 1,
    Value = { Min = 0, Max = 300, Default = 0 },
    Callback = function(v) jpValue = v end
})

-- ---- NOCLIP ----
PlayerMenuTab:Section({ Title = "Noclip" })

local noclipEnabled = false
local noclipConn    = nil
local noclipToggle  = nil

local function setNoclip(state)
    noclipEnabled = state
    if noclipToggle and noclipToggle.SetTitle then
        noclipToggle:SetTitle("Noclip (" .. (state and "Active" or "Nonactive") .. ")")
    end
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            local c = player.Character
            if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.CanCollide = false
                end
            end
        end)
        WindUI:Notify({ Title = "Noclip ON", Content = "Bisa nembus wall", Icon = "check" })
    else
        pcall(function()
            local c = player.Character
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end)
        WindUI:Notify({ Title = "Noclip OFF", Content = "Collision normal", Icon = "x" })
    end
end

noclipToggle = PlayerMenuTab:Toggle({
    Title    = "Noclip (Nonactive)",
    Value    = false,
    Callback = function(v) setNoclip(v) end
})

-- ---- AUTO CLICK ----
PlayerMenuTab:Section({ Title = "Auto Click" })

local acEnabled = false
local acSpeed   = 0
local acToggle  = nil
local acConn    = nil

-- interval berdasarkan speed: 0=16cps, 150=50cps, 300=100cps
local function getAcInterval(spd)
    local s = math.max(spd, 16)
    if s <= 150 then
        -- 16->0.0625s, 150->0.02s
        return 0.0625 - (s - 16) / (150 - 16) * (0.0625 - 0.02)
    else
        -- 150->0.02s, 300->0.01s
        return 0.02 - (s - 150) / (300 - 150) * (0.02 - 0.01)
    end
end

local function doClick()
    pcall(function()
        local ms = player:GetMouse()
        local pos = Vector2.new(ms.X, ms.Y)
        VirtualUser:Button1Down(pos, workspace.CurrentCamera.CFrame)
        task.wait(0.005)
        VirtualUser:Button1Up(pos, workspace.CurrentCamera.CFrame)
    end)
end

local function startAc()
    if acConn then acConn:Disconnect(); acConn = nil end
    task.spawn(function()
        while acEnabled do
            doClick()
            task.wait(getAcInterval(acSpeed))
        end
    end)
end

acToggle = PlayerMenuTab:Toggle({
    Title    = "Auto Click (Nonactive)",
    Value    = false,
    Callback = function(v)
        acEnabled = v
        if acToggle and acToggle.SetTitle then
            acToggle:SetTitle("Auto Click (" .. (v and "Active" or "Nonactive") .. ")")
        end
        if v then
            startAc()
            WindUI:Notify({ Title = "Auto Click ON", Content = "Klik otomatis aktif", Icon = "check" })
        else
            WindUI:Notify({ Title = "Auto Click OFF", Content = "Klik otomatis nonaktif", Icon = "x" })
        end
    end
})

PlayerMenuTab:Slider({
    Title = "Auto Click Speed  (0 = 16 CPS default)",
    Step  = 1,
    Value = { Min = 0, Max = 300, Default = 0 },
    Callback = function(v)
        acSpeed = v
        -- kalau lagi aktif, restart biar kecepatan update
        if acEnabled then startAc() end
    end
})

PlayerMenuTab:Paragraph({
    Title   = "Info Auto Click",
    Content = "0 = 16 CPS  |  150 = 50 CPS  |  300 = 100 CPS"
})

-- ============================================
-- TELEPORT TAB
-- ============================================
TeleportTab:Section({ Title = "Player Teleport" })

local selectedPlayer = nil
local dropdown       = nil

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
    if     dropdown.SetOptions then dropdown:SetOptions(names)
    elseif dropdown.SetValues  then dropdown:SetValues(names)
    elseif dropdown.Refresh    then dropdown:Refresh(names)
    end
end

dropdown = TeleportTab:Dropdown({
    Title    = "Teleport To",
    Values   = getPlayerNames(),
    Callback = function(v) selectedPlayer = v end
})

TeleportTab:Button({
    Title = "TELEPORT",
    Desc  = "Teleport ke player terpilih",
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

TeleportTab:Paragraph({ Title = "Auto Update", Desc = "Daftar player update otomatis" })

Players.PlayerAdded:Connect(function()   task.wait(0.5); applyDropdownOptions() end)
Players.PlayerRemoving:Connect(function(lp)
    if selectedPlayer == lp.Name then selectedPlayer = nil end
    task.wait(0.1); applyDropdownOptions()
end)

task.delay(1, applyDropdownOptions)