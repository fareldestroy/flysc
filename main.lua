-- [[ AETHER SCRIPT V1.0 ULTIMATE RGB ]] --
-- Developer: Farel Destroyer

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- [[ 1. WINDOW SETUP DENGAN TRANSPARANSI ]] --
local Window = WindUI:CreateWindow({
    Title = "FarelDestroyer - Fly Script", -- Judul Utama
    Author = "t.me/nyxdestroy",     -- Link Telegram di Sub-Title
    Theme = "Dark",
    Size = UDim2.fromOffset(660, 430),
    Folder = "aetherscript_farel",
    SideBarWidth = 200,
    ScrollBarEnabled = true
})

-- Efek Background Keren
Window:SetBackgroundImage("rbxassetid://76527064525832")
Window:SetBackgroundImageTransparency(0.8) -- Lebih transparan agar estetik

-- [[ NOTIFIKASI SUKSES ]] --
WindUI:Notify({
    Title = "Farel Fly Script Loaded!",
    Content = "Made by FarelDestroyer. Enjoy!",
    Icon = "check",
    Duration = 5
})

-- [[ 2. EFEK RGB PADA TITLE (FOXNAME STYLE) ]] --
task.spawn(function()
    while task.wait() do
        local hue = tick() % 5 / 5
        local color = Color3.fromHSV(hue, 1, 1)
        Window:EditWindow({
            TitleColor = color -- Membuat judul berubah warna terus-menerus
        })
    end
end)

-- [[ 3. TABS DECLARATION ]] --
local InfoTab = Window:Tab({ Title = "Home Info", Icon = "home" })
local FlyTab = Window:Tab({ Title = "Fly Main", Icon = "fly" })
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local MiscTab = Window:Tab({ Title = "Misc & Settings", Icon = "settings" })

-- [[ 4. HOME / INFO TAB ]] --
InfoTab:Section({ Title = "Status Script" })
InfoTab:Paragraph({
    Title = "Farel Fly Script V1.0 - Premium",
    Desc = "Status: Online\nUser: " .. game.Players.LocalPlayer.DisplayName .. "\nSupport: Farel Destroyer",
    Image = "rbxassetid://10723415535",
    ImageSize = 45
})

InfoTab:Section({ Title = "Community" })
InfoTab:Button({
    Title = "Copy Telegram Link",
    Desc = "Join t.me/nyxdestroy",
    Callback = function()
        setclipboard("https://t.me/nyxdestroy")
        WindUI:Notify({ Title = "Copied", Content = "Link Telegram disalin ke Clipboard!", Icon = "copy" })
    end
})

-- [[ 5. FISHING TAB (MENU UTAMA) ]] --
FlyTab:Section({ Title = "Main Farm" })
FlyTab:Button({
    Title = "Execute Auto Fly",
    Desc = "Menjalankan script auto flying lengkap",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/FarelDestroyer/Script/main/Farel Fly ScriptFlyit.lua'))()
    end
})

FlyTab:Section({ Title = "Movement Utility" })
FlyTab:Toggle({
    Title = "Walk on Water",
    Value = false,
    Callback = function(state)
        _G.WaterWalk = state
        if state then
            task.spawn(function()
                while _G.WaterWalk do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.Velocity = Vector3.new(char.HumanoidRootPart.Velocity.X, 0, char.HumanoidRootPart.Velocity.Z)
                        end
                    end)
                    task.wait()
                end
            end)
        end
    end
})

-- [[ 6. TELEPORT TAB ]] --
TeleportTab:Section({ Title = "Player Teleport" })
local PlayerDropdown = TeleportTab:Dropdown("Pilih Player", {}, function(selected)
    _G.SelectedPlayer = selected
end)

local function RefreshPlayers()
    local pList = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then table.insert(pList, p.Name) end
    end
    PlayerDropdown:SetOptions(pList)
end

TeleportTab:Button({ Title = "Refresh Player List", Callback = RefreshPlayers })
TeleportTab:Button({
    Title = "Teleport ke Player",
    Callback = function()
        if _G.SelectedPlayer then
            local target = game.Players:FindFirstChild(_G.SelectedPlayer)
            if target and target.Character then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            end
        else
            WindUI:Notify({ Title = "Error", Content = "Pilih player dulu!", Icon = "alert-circle" })
        end
    end
})

-- [[ 7. MISC TAB ]] --
MiscTab:Section({ Title = "Optimization" })
MiscTab:Button({
    Title = "FPS Boost (Full)",
    Desc = "Menghapus texture untuk HP kentang",
    Callback = function()
        for _, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
        end
        WindUI:Notify({ Title = "Optimized", Content = "Game lebih ringan sekarang!", Icon = "zap" })
    end
})

MiscTab:Section({ Title = "Client Settings" })
MiscTab:Toggle({
    Title = "Anti-Staff Detector",
    Value = false,
    Callback = function(state)
        _G.StaffCheck = state
        game.Players.PlayerAdded:Connect(function(plr)
            if _G.StaffCheck and plr:GetRankInGroup(0) > 100 then
                game.Players.LocalPlayer:Kick("Admin Detected: " .. plr.Name)
            end
        end)
    end
})

-- Inisialisasi
RefreshPlayers()



-- [[ FAREL FLY STABILITY PATCH ]] --
-- Ensures character does not drift when no movement input

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local inputState = {W=false,A=false,S=false,D=false,Space=false,Ctrl=false}

UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode==Enum.KeyCode.W then inputState.W=true end
    if i.KeyCode==Enum.KeyCode.A then inputState.A=true end
    if i.KeyCode==Enum.KeyCode.S then inputState.S=true end
    if i.KeyCode==Enum.KeyCode.D then inputState.D=true end
    if i.KeyCode==Enum.KeyCode.Space then inputState.Space=true end
    if i.KeyCode==Enum.KeyCode.LeftControl then inputState.Ctrl=true end
end)

UIS.InputEnded:Connect(function(i,g)
    if g then return end
    if i.KeyCode==Enum.KeyCode.W then inputState.W=false end
    if i.KeyCode==Enum.KeyCode.A then inputState.A=false end
    if i.KeyCode==Enum.KeyCode.S then inputState.S=false end
    if i.KeyCode==Enum.KeyCode.D then inputState.D=false end
    if i.KeyCode==Enum.KeyCode.Space then inputState.Space=false end
    if i.KeyCode==Enum.KeyCode.LeftControl then inputState.Ctrl=false end
end)

RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local moving = inputState.W or inputState.A or inputState.S or inputState.D or inputState.Space or inputState.Ctrl
    if not moving then
        local bv = root:FindFirstChildOfClass("BodyVelocity")
        if bv then
            bv.Velocity = Vector3.new(0,0,0)
        end
    end
end)




-- [[ FAREL FLY SYSTEM ]] --
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local flyEnabled = false
local flySpeed = 0

local input = {W=false,A=false,S=false,D=false,Space=false,Ctrl=false}

UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode==Enum.KeyCode.W then input.W=true end
    if i.KeyCode==Enum.KeyCode.A then input.A=true end
    if i.KeyCode==Enum.KeyCode.S then input.S=true end
    if i.KeyCode==Enum.KeyCode.D then input.D=true end
    if i.KeyCode==Enum.KeyCode.Space then input.Space=true end
    if i.KeyCode==Enum.KeyCode.LeftControl then input.Ctrl=true end
end)

UIS.InputEnded:Connect(function(i,g)
    if g then return end
    if i.KeyCode==Enum.KeyCode.W then input.W=false end
    if i.KeyCode==Enum.KeyCode.A then input.A=false end
    if i.KeyCode==Enum.KeyCode.S then input.S=false end
    if i.KeyCode==Enum.KeyCode.D then input.D=false end
    if i.KeyCode==Enum.KeyCode.Space then input.Space=false end
    if i.KeyCode==Enum.KeyCode.LeftControl then input.Ctrl=false end
end)

local gyro, vel

local function startFly()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    
    gyro = Instance.new("BodyGyro", root)
    gyro.P = 9e4
    gyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    
    vel = Instance.new("BodyVelocity", root)
    vel.MaxForce = Vector3.new(9e9,9e9,9e9)
    
    RunService.RenderStepped:Connect(function()
        if not flyEnabled then return end
        
        local cam = workspace.CurrentCamera
        gyro.CFrame = cam.CFrame
        
        local dir = Vector3.zero
        
        if input.W then dir += cam.CFrame.LookVector end
        if input.S then dir -= cam.CFrame.LookVector end
        if input.A then dir -= cam.CFrame.RightVector end
        if input.D then dir += cam.CFrame.RightVector end
        if input.Space then dir += Vector3.new(0,1,0) end
        if input.Ctrl then dir -= Vector3.new(0,1,0) end
        
        if dir.Magnitude == 0 then
            vel.Velocity = Vector3.new(0,0,0)
        else
            vel.Velocity = dir.Unit * flySpeed
        end
    end)
end

