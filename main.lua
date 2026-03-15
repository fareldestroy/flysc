
-- Farel Destroyer Fly Script
-- Designed for executors like Delta

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- UI BUILD
local gui = Instance.new("ScreenGui")
gui.Name = "FarelDestroyerFlyUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Loading Screen
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0,300,0,120)
loadingFrame.Position = UDim2.new(0.5,-150,0.5,-60)
loadingFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
loadingFrame.Parent = gui

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1,0,0.4,0)
loadingText.BackgroundTransparency = 1
loadingText.Text = "Loading..."
loadingText.TextColor3 = Color3.new(1,1,1)
loadingText.TextScaled = true
loadingText.Parent = loadingFrame

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0.9,0,0.2,0)
barBg.Position = UDim2.new(0.05,0,0.65,0)
barBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
barBg.Parent = loadingFrame

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0,0,1,0)
bar.BackgroundColor3 = Color3.fromRGB(0,170,255)
bar.Parent = barBg

for i=1,100 do
    bar.Size = UDim2.new(i/100,0,1,0)
    task.wait(0.01)
end

loadingFrame:Destroy()

-- MAIN UI
local main = Instance.new("Frame")
main.Size = UDim2.new(0,260,0,140)
main.Position = UDim2.new(0.5,-130,0.4,0)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.Parent = gui
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Farel Destroyer Fly Script"
title.TextColor3 = Color3.fromRGB(0,200,255)
title.TextScaled = true
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-30,0,0)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextColor3 = Color3.new(1,1,1)
close.Parent = main

close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1,0,0,30)
speedLabel.Position = UDim2.new(0,0,0,40)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.TextScaled = true
speedLabel.Text = "Airspeed: 0"
speedLabel.Parent = main

local plus = Instance.new("TextButton")
plus.Size = UDim2.new(0.4,0,0,30)
plus.Position = UDim2.new(0.05,0,0,80)
plus.Text = "+"
plus.BackgroundColor3 = Color3.fromRGB(0,170,255)
plus.TextScaled = true
plus.Parent = main

local minus = Instance.new("TextButton")
minus.Size = UDim2.new(0.4,0,0,30)
minus.Position = UDim2.new(0.55,0,0,80)
minus.Text = "-"
minus.BackgroundColor3 = Color3.fromRGB(255,120,0)
minus.TextScaled = true
minus.Parent = main

local flyToggle = Instance.new("TextButton")
flyToggle.Size = UDim2.new(0.9,0,0,30)
flyToggle.Position = UDim2.new(0.05,0,1,-35)
flyToggle.Text = "Fly: OFF"
flyToggle.BackgroundColor3 = Color3.fromRGB(0,200,120)
flyToggle.TextScaled = true
flyToggle.Parent = main

-- FLY SYSTEM
local flying = false
local speed = 0
local maxSpeed = 100

local bodyGyro
local bodyVel

local function startFly()
    bodyGyro = Instance.new("BodyGyro", root)
    bodyGyro.P = 9e4
    bodyGyro.maxTorque = Vector3.new(9e9,9e9,9e9)
    bodyGyro.cframe = root.CFrame

    bodyVel = Instance.new("BodyVelocity", root)
    bodyVel.velocity = Vector3.new(0,0,0)
    bodyVel.maxForce = Vector3.new(9e9,9e9,9e9)

    while flying do
        local cam = workspace.CurrentCamera
        bodyGyro.cframe = cam.CFrame
        bodyVel.velocity = cam.CFrame.LookVector * speed
        task.wait()
    end

    bodyGyro:Destroy()
    bodyVel:Destroy()
end

flyToggle.MouseButton1Click:Connect(function()
    flying = not flying

    if flying then
        flyToggle.Text = "Fly: ON"
        startFly()
    else
        flyToggle.Text = "Fly: OFF"
    end
end)

plus.MouseButton1Click:Connect(function()
    speed = math.clamp(speed + 5,0,maxSpeed)
    speedLabel.Text = "Airspeed: "..speed
end)

minus.MouseButton1Click:Connect(function()
    speed = math.clamp(speed - 5,0,maxSpeed)
    speedLabel.Text = "Airspeed: "..speed
end)
