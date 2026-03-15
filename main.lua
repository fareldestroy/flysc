
-- [[ FarelDestroyer - Fly Script ]] --
-- Developer: Farel Destroyer

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- WINDOW
local Window = WindUI:CreateWindow({
    Title = "FarelDestroyer - Fly Script",
    Author = "t.me/nyxdestroy",
    Theme = "Dark",
    Size = UDim2.fromOffset(660,430),
    Folder = "farel_fly_script",
    SideBarWidth = 200,
    ScrollBarEnabled = true
})

Window:SetBackgroundImage("rbxassetid://76527064525832")
Window:SetBackgroundImageTransparency(0.8)

WindUI:Notify({
    Title = "Farel Fly Script Loaded",
    Content = "Fly + Teleport ready",
    Icon = "check",
    Duration = 5
})

-- RGB TITLE
task.spawn(function()
    while task.wait() do
        local hue = tick() % 5 / 5
        Window:EditWindow({
            TitleColor = Color3.fromHSV(hue,1,1)
        })
    end
end)

-- TABS
local FlyTab = Window:Tab({Title="Fly Main",Icon="rocket"})
local TeleportTab = Window:Tab({Title="Teleport",Icon="map-pin"})

------------------------------------------------------------------
-- FLY SYSTEM (SMOOTH PHYSICS)
------------------------------------------------------------------

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local flyEnabled = false
local flySpeed = 0
local maxSpeed = 300

local bodyGyro
local bodyVelocity

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function stopFly()
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVelocity then bodyVelocity:Destroy() end
    bodyGyro = nil
    bodyVelocity = nil
end

local function startFly()

    local char = getCharacter()
    local root = char:WaitForChild("HumanoidRootPart")

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.Parent = root

    RunService.RenderStepped:Connect(function()

        if not flyEnabled then return end

        local cam = workspace.CurrentCamera
        bodyGyro.CFrame = cam.CFrame

        local move = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

        if move.Magnitude == 0 then
            bodyVelocity.Velocity = Vector3.new(0,0,0)
        else
            bodyVelocity.Velocity = move.Unit * flySpeed
        end

    end)

end

-- UI: SPEED
FlyTab:Slider({
    Title="Fly Speed",
    Step=1,
    Value={Min=0,Max=300,Default=0},
    Callback=function(v)
        flySpeed = v
    end
})

-- UI: FLY TOGGLE
FlyTab:Toggle({
    Title="FLY (${active ? nonactive})",
    Value=false,
    Callback=function(v)
        flyEnabled = v
        if v then
            startFly()
        else
            stopFly()
        end
    end
})

-- KEYBIND (F)
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        flyEnabled = not flyEnabled
        if flyEnabled then
            startFly()
        else
            stopFly()
        end
    end
end)

------------------------------------------------------------------
-- TELEPORT SYSTEM
------------------------------------------------------------------

TeleportTab:Section({Title="Player Teleport"})

local selectedPlayer = nil

local dropdown = TeleportTab:Dropdown({
    Title="Teleport To ${player}",
    Values={},
    Callback=function(v)
        selectedPlayer = v
    end
})

local function refreshPlayers()

    local list = {}

    for _,p in pairs(game.Players:GetPlayers()) do
        if p ~= player then
            table.insert(list,p.Name)
        end
    end

    dropdown:SetValues(list)

end

TeleportTab:Button({
    Title="Refresh Player List",
    Callback=refreshPlayers
})

TeleportTab:Button({
    Title="TELEPORT",
    Callback=function()

        if not selectedPlayer then
            WindUI:Notify({
                Title="Error",
                Content="Pilih player dulu!",
                Icon="alert-circle"
            })
            return
        end

        local target = game.Players:FindFirstChild(selectedPlayer)

        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then

            local myChar = player.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then

                myChar.HumanoidRootPart.CFrame =
                    target.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)

            end
        end

    end
})

refreshPlayers()
