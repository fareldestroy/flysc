
-- [[ FarelDestroyer - Fly Script ]] --
-- Mobile Support + Smooth Fly Physics
-- Only: Fly + Teleport

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- UI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "FarelDestroyer - Fly Script",
    Author = "t.me/nyxdestroy",
    Theme = "Dark",
    Size = UDim2.fromOffset(660,430),
    Folder = "farel_fly_script",
    SideBarWidth = 200,
    ScrollBarEnabled = true
})

-- Tabs
local FlyTab = Window:Tab({ Title = "Fly Main", Icon = "rocket" })
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })

--------------------------------------------------
-- FLY SYSTEM
--------------------------------------------------

FlyTab:Section({ Title = "Fly Controller" })

local flyEnabled = false
local flySpeed = 0
local bodyGyro
local bodyVelocity
local connection

local function startFly()

    local char = player.Character
    if not char then return end

    local root = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")

    humanoid.PlatformStand = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 90000
    bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    bodyGyro.Parent = root

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.Parent = root

    connection = RunService.RenderStepped:Connect(function()

        if not flyEnabled then return end

        local cam = workspace.CurrentCamera
        local moveDir = humanoid.MoveDirection

        bodyGyro.CFrame = cam.CFrame

        if moveDir.Magnitude > 0 then

            local direction = cam.CFrame:VectorToWorldSpace(moveDir)
            bodyVelocity.Velocity = direction * flySpeed

        else

            bodyVelocity.Velocity = Vector3.new(0,0,0)

        end

    end)

end

local function stopFly()

    if connection then
        connection:Disconnect()
        connection = nil
    end

    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end

end

FlyTab:Slider({
    Title = "Fly Speed",
    Step = 1,
    Value = { Min = 0, Max = 300, Default = 0 },
    Callback = function(v)
        flySpeed = v
    end
})

FlyTab:Toggle({
    Title = "FLY (Active / Nonactive)",
    Value = false,
    Callback = function(state)

        flyEnabled = state

        if state then
            startFly()
        else
            stopFly()
        end

    end
})

--------------------------------------------------
-- TELEPORT SYSTEM
--------------------------------------------------

TeleportTab:Section({ Title = "Player Teleport" })

local selectedPlayer

local function getPlayers()

    local list = {}

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(list,p.Name)
        end
    end

    return list

end

local dropdown = TeleportTab:Dropdown({
    Title = "Teleport To ${player}",
    Values = getPlayers(),
    Callback = function(v)
        selectedPlayer = v
    end
})

local function refresh()

    local list = getPlayers()

    if dropdown.SetOptions then
        dropdown:SetOptions(list)
    end

end

Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(refresh)

TeleportTab:Button({
    Title = "TELEPORT",
    Callback = function()

        if not selectedPlayer then return end

        local target = Players:FindFirstChild(selectedPlayer)
        if not target then return end

        local myChar = player.Character
        local targetChar = target.Character

        if not myChar or not targetChar then return end

        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")

        if myRoot and targetRoot then
            myRoot.CFrame = targetRoot.CFrame + Vector3.new(0,3,0)
        end

    end
})
