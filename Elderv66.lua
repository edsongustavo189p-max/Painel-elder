-- ⚡ ELDER BONITAO SUPREME V66.9 [FINAL ELITE EDITION]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local Mouse = player:GetMouse()

local AIM_TARGET_PART = "Head"
local FOV_RADIUS = 120
local BRING_LIMIT = 300
local current_speed_idx = 4
local aim_speed_names = {"SUAVE", "MÉDIO", "RÁPIDO", "INSTANTÂNEO ⚡"}
local aim_lerp_values = {0.05, 0.1, 0.2, 1}

local states = {
    speed=false, jump=false, noclip=false, bring=false, 
    hitbox=false, aim_legit=false, aim_rage=false, esp=false, 
    hide_fov=false, tpTool=false, stalker=false, 
    bright=false, streamer=false, ghost=false, hide_icon=false,
    fast_attack=false, antikb=false
}

-- FUNÇÃO LIMPEZA ESP
local function clearESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local e = p.Character:FindFirstChild("ELDER_ESP")
            if e then e:Destroy() end
        end
    end
end

-- FOV
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5; fovCircle.Color = Color3.fromRGB(0, 255, 255); fovCircle.Filled = false; fovCircle.Visible = true

local function isTargetVisible(targetPart)
    local obs = Camera:GetPartsObscuringTarget({targetPart.Position}, {player.Character, targetPart.Parent})
    return #obs == 0
end

-- GUI PRINCIPAL
local gui = Instance.new("ScreenGui", game:GetService("CoreGui")); gui.Name = "ELDER_BONITAO_V66"
local frame = Instance.new("Frame", gui); frame.Size = UDim2.new(0, 340, 0, 520); frame.Position = UDim2.new(0.08, 0, 0.2, 0); frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); frame.Active = true; frame.ClipsDescendants = true; frame.Visible = true; Instance.new("UICorner", frame)

local stroke = Instance.new("UIStroke", frame); stroke.Thickness = 2; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local title = Instance.new("TextLabel", frame); title.Size = UDim2.new(1, 0, 0, 45); title.Text = " ⚡ ELDER BONITAO"; title.BackgroundColor3 = Color3.fromRGB(15, 15, 20); title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.Active = true
local titleStroke = Instance.new("UIStroke", title); titleStroke.Thickness = 1

-- ARRASTE PELA BARRA
local dragging, dragInput, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = frame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
title.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- BOLINHA DELTA
local icon = Instance.new("TextButton", gui)
icon.Size = UDim2.new(0, 65, 0, 65); icon.Position = UDim2.new(0.02, 0, 0.2, 0)
icon.BackgroundColor3 = Color3.fromRGB(10, 10, 10); icon.Text = "⚡"; icon.TextColor3 = Color3.new(1, 1, 1); icon.TextSize = 30; icon.Visible = false; icon.Active = true; icon.Draggable = true
local iconCorner = Instance.new("UICorner", icon); iconCorner.CornerRadius = UDim.new(1, 0)
local iconStroke = Instance.new("UIStroke", icon); iconStroke.Thickness = 3

task.spawn(function()
    while true do
        local hue = tick() % 5 / 5
        local color = Color3.fromHSV(hue, 1, 1)
        stroke.Color = color; titleStroke.Color = color; iconStroke.Color = color; task.wait()
    end
end)

local function updateIconVisuals()
    if states.hide_icon then icon.BackgroundTransparency = 1; icon.TextTransparency = 1; iconStroke.Transparency = 1
    else icon.BackgroundTransparency = 0; icon.TextTransparency = 0; iconStroke.Transparency = 0 end
end

local btnMin = Instance.new("TextButton", title)
btnMin.Size = UDim2.new(0, 40, 0, 40); btnMin.Position = UDim2.new(1, -45, 0, 2); btnMin.Text = "-"; btnMin.TextColor3 = Color3.new(1,1,1); btnMin.BackgroundTransparency = 1; btnMin.TextSize = 30
btnMin.MouseButton1Click:Connect(function() frame.Visible = false; icon.Visible = true; updateIconVisuals() end)
icon.MouseButton1Click:Connect(function() frame.Visible = true; icon.Visible = false end)

local container = Instance.new("Frame", frame); container.Size = UDim2.new(1,0,1,-45); container.Position = UDim2.new(0,0,0,45); container.BackgroundTransparency = 1
local gamerFrame = Instance.new("ScrollingFrame", container); gamerFrame.Size = UDim2.new(1, 0, 1, -50); gamerFrame.Position = UDim2.new(0, 0, 0, 50); gamerFrame.BackgroundTransparency = 1; gamerFrame.CanvasSize = UDim2.new(0, 0, 4.5, 0)
local aimFrame = gamerFrame:Clone(); aimFrame.Parent = container; aimFrame.Visible = false

local function createBtn(parent, text, y, stateKey)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, -24, 0, 42); b.Position = UDim2.new(0, 12, 0, y); b.Text = text .. ": OFF"; b.BackgroundColor3 = Color3.fromRGB(45, 45, 50); b.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        b.BackgroundColor3 = states[stateKey] and Color3.fromRGB(0, 120, 180) or Color3.fromRGB(45, 45, 50)
        b.Text = text .. (states[stateKey] and ": ON" or ": OFF")
        if stateKey == "esp" and not states.esp then clearESP() end
        if stateKey == "hide_icon" and not frame.Visible then updateIconVisuals() end
    end)
end

-- BOTOES ABA 1
createBtn(gamerFrame, "🛡️ Ghost TP (Seguro)", 10, "ghost")
createBtn(gamerFrame, "🛡️ Anti-Knockback", 60, "antikb")
createBtn(gamerFrame, "🏃 Speed Boost Turbo", 110, "speed")
createBtn(gamerFrame, "📺 Modo Streamer", 160, "streamer")
createBtn(gamerFrame, "☀️ FullBright", 210, "bright")
createBtn(gamerFrame, "📍 TP Tool", 260, "tpTool")
createBtn(gamerFrame, "👤 Follow Player", 310, "stalker")
createBtn(gamerFrame, "👻 Noclip", 360, "noclip")
createBtn(gamerFrame, "🧲 Bring (300m)", 410, "bring")
createBtn(gamerFrame, "🪂 Pulo Infinito", 460, "jump")
createBtn(gamerFrame, "🟦 Hitbox", 510, "hitbox")

-- BOTOES ABA 2
createBtn(aimFrame, "🎯 Legit Bot", 10, "aim_legit")
createBtn(aimFrame, "🔥 Rage Bot", 60, "aim_rage")
createBtn(aimFrame, "🔵 ESP Highlights", 110, "esp")
createBtn(aimFrame, "🙈 Ocultar FOV", 160, "hide_fov")
createBtn(aimFrame, "💀 Fast Attack (I'm Kill)", 210, "fast_attack")
createBtn(aimFrame, "👻 Ocultar Painel", 260, "hide_icon")

local bAimS = Instance.new("TextButton", aimFrame); bAimS.Size = UDim2.new(1,-24,0,42); bAimS.Position = UDim2.new(0,12,0,310); bAimS.Text = "⚡ Mira: "..aim_speed_names[current_speed_idx]; bAimS.BackgroundColor3 = Color3.fromRGB(0, 120, 180); bAimS.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", bAimS)
bAimS.MouseButton1Click:Connect(function() current_speed_idx = (current_speed_idx >= 4) and 1 or current_speed_idx + 1; bAimS.Text = "⚡ Mira: "..aim_speed_names[current_speed_idx] end)

local bFov = bAimS:Clone(); bFov.Parent = aimFrame; bFov.Position = UDim2.new(0, 12, 0, 360); bFov.Text = "📏 Tamanho FOV: "..FOV_RADIUS; bFov.BackgroundColor3 = Color3.fromRGB(40,40,45)
bFov.MouseButton1Click:Connect(function() FOV_RADIUS = (FOV_RADIUS >= 400) and 50 or FOV_RADIUS + 50; bFov.Text = "📏 Tamanho FOV: "..FOV_RADIUS end)

-- LÓGICA ANTI-KB
RunService.Heartbeat:Connect(function()
    if states.antikb and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        player.Character.HumanoidRootPart.RotVelocity = Vector3.new(0,0,0)
    end
end)

-- FAST ATTACK + I'M KILL SHAKE
RunService.Heartbeat:Connect(function()
    if states.fast_attack and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local rotShake = CFrame.Angles(math.rad(math.random(-15,15)), math.rad(math.random(-15,15)), math.rad(math.random(-15,15)))
        local posShake = Vector3.new(math.random(-10,10)/20, math.random(-10,10)/20, math.random(-10,10)/20)
        hrp.CFrame = hrp.CFrame * rotShake + posShake
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if states.noclip and player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

-- RENDERS (AIMBOT, FOV, BRIGHT)
RunService.RenderStepped:Connect(function()
    if states.bright then Lighting.Ambient = Color3.new(1, 1, 1); Lighting.ClockTime = 14 end
    fovCircle.Visible = (not states.hide_fov and not states.streamer); fovCircle.Radius = FOV_RADIUS; fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    if states.aim_legit or states.aim_rage then
        local target = nil; local shortest = FOV_RADIUS
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild(AIM_TARGET_PART) and p.Character:FindFirstChild("Humanoid") then
                if p.Character.Humanoid.Health > 0 then
                    local head = p.Character[AIM_TARGET_PART]; local pos, onS = Camera:WorldToViewportPoint(head.Position)
                    if onS then
                        local mag = (Vector2.new(pos.X, pos.Y) - fovCircle.Position).Magnitude
                        if mag < shortest then
                            if states.aim_legit then if isTargetVisible(head) then target = head; shortest = mag end else target = head; shortest = mag end
                        end
                    end
                end
            end
        end
        if target then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), aim_lerp_values[current_speed_idx]) end
    end
end)

-- HEARTBEAT (MOVIMENTO)
RunService.Heartbeat:Connect(function()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = player.Character.HumanoidRootPart
    if states.speed and player.Character.Humanoid.MoveDirection.Magnitude > 0 then hrp.CFrame += (player.Character.Humanoid.MoveDirection * 2.5) end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local tP = p.Character.HumanoidRootPart; local dist = (hrp.Position - tP.Position).Magnitude
            if states.bring and dist <= BRING_LIMIT then tP.CFrame = hrp.CFrame * CFrame.new(0,0,-2) end
            if states.hitbox then tP.Size = Vector3.new(16,16,16); tP.Transparency = 0.7; tP.CanCollide = false 
            elseif not states.hitbox and tP.Size.X > 2 then tP.Size = Vector3.new(2,2,1); tP.Transparency = 1 end
        end
    end
    if states.stalker then
        local target = nil; local minD = 1000
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                local d = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < minD then minD = d; target = p.Character.HumanoidRootPart end
            end
        end
        if target then hrp.CFrame = target.CFrame * CFrame.new(0, 0, 3.5) end
    end
end)

-- GHOST TP & TOOLS
task.spawn(function()
    while true do
        if states.ghost and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local h = player.Character.HumanoidRootPart; local offsets = {7, -14, 7}
            for _, offX in ipairs(offsets) do if states.ghost then h.CFrame *= CFrame.new(offX, 0, 0); task.wait(0.25) end end
        else task.wait(0.5) end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if states.esp and not states.streamer then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and not p.Character:FindFirstChild("ELDER_ESP") then
                    Instance.new("Highlight", p.Character).Name = "ELDER_ESP"
                end
            end
        end
        if states.tpTool and not player.Backpack:FindFirstChild("TP_ELDER") and not (player.Character and player.Character:FindFirstChild("TP_ELDER")) then
            local t = Instance.new("Tool"); t.Name = "TP_ELDER"; t.RequiresHandle = false; t.Parent = player.Backpack
            t.Activated:Connect(function() player.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0)) end)
        end
    end
end)

UIS.InputBegan:Connect(function(i, g) 
    if not g and i.KeyCode == Enum.KeyCode.K then 
        if frame.Visible then frame.Visible = false; icon.Visible = true; updateIconVisuals()
        else frame.Visible = true; icon.Visible = false end
    end 
end)
UIS.JumpRequest:Connect(function() if states.jump then player.Character.Humanoid:ChangeState(3) end end)

local bG = Instance.new("TextButton", container); bG.Size = UDim2.new(0.48,0,0,35); bG.Position = UDim2.new(0,4,0,8); bG.Text = "🎮 Gamer"; bG.BackgroundColor3 = Color3.fromRGB(40,40,45); bG.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", bG)
local bA = bG:Clone(); bA.Parent = container; bA.Position = UDim2.new(0,170,0,8); bA.Text = "🎯 Mira"
bG.MouseButton1Click:Connect(function() gamerFrame.Visible = true; aimFrame.Visible = false end)
bA.MouseButton1Click:Connect(function() gamerFrame.Visible = false; aimFrame.Visible = true end)
