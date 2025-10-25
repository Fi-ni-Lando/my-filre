local P, UIS, RS, Cam = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService"), workspace.CurrentCamera
local LP = P.LocalPlayer

local A = {Enabled=true, Active=false, LockPart="Head", FOV=100}
local Holding = false
local Locked

local FOV = Drawing.new("Circle")
FOV.Visible = true
FOV.Thickness = 1.5
FOV.Radius = A.FOV
FOV.Color = Color3.fromRGB(148,0,211)
FOV.Transparency = 0.8

local Txt = Drawing.new("Text")
Txt.Size = 18
Txt.Center = true
Txt.Outline = true
Txt.Position = Vector2.new(Cam.ViewportSize.X-100, 50)
Txt.Text = "Aimbot: OFF"
Txt.Color = Color3.fromRGB(255,80,80)
Txt.Transparency = 0
Txt.Visible = true

local OrigSens

local function UpdateIndicator()
    Txt.Text = A.Active and "Aimbot: ON" or "Aimbot: OFF"
    FOV.Color = A.Active and Color3.fromRGB(0,255,0) or Color3.fromRGB(148,0,211)
    FOV.Radius = A.FOV
end

local function ClosestInFOV()
    local target, minDist = nil, A.FOV
    local mousePos = UIS:GetMouseLocation()
    for _, plr in pairs(P:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local part = plr.Character:FindFirstChild(A.LockPart)
            if hum and hum.Health > 0 and part then
                local screenPos, onScreen = Cam:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist <= A.FOV and dist < minDist then
                        target, minDist = plr, dist
                    end
                end
            end
        end
    end
    return target
end

local function DisableMouse()
    if not OrigSens then pcall(function() OrigSens = UIS.MouseDeltaSensitivity end) end
    pcall(function() UIS.MouseDeltaSensitivity = 0 end)
end

local function RestoreMouse()
    if OrigSens then
        pcall(function() UIS.MouseDeltaSensitivity = OrigSens end)
        OrigSens = nil
    else
        pcall(function() UIS.MouseDeltaSensitivity = 1 end)
    end
end

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
        if not Locked then
            local closest = ClosestInFOV()
            if closest then
                Locked = closest
                A.Active = true
                DisableMouse()
                UpdateIndicator()
            end
        end
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
        A.Active = false
        Locked = nil
        RestoreMouse()
        UpdateIndicator()
    end
end)

RS.RenderStepped:Connect(function()
    local mousePos = UIS:GetMouseLocation()
    FOV.Position = mousePos
    Txt.Position = Vector2.new(Cam.ViewportSize.X-100, 50)

    if Holding and A.Enabled then
        if Locked then
            local part = Locked.Character and Locked.Character:FindFirstChild(A.LockPart)
            local hum = Locked.Character and Locked.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                Cam.CFrame = CFrame.new(Cam.CFrame.Position, part.Position)
            else
                local closest = ClosestInFOV()
                if closest then
                    Locked = closest
                else
                    Locked = nil
                    A.Active = false
                    RestoreMouse()
                    UpdateIndicator()
                end
            end
        else
            local closest = ClosestInFOV()
            if closest then
                Locked = closest
                A.Active = true
                DisableMouse()
                UpdateIndicator()
            end
        end
    end
end)

local function Cleanup()
    RestoreMouse()
    if FOV and FOV.Remove then pcall(FOV.Remove, FOV) end
    if Txt and Txt.Remove then pcall(Txt.Remove, Txt) end
end

if syn and syn.on_script_exit then syn.on_script_exit(Cleanup,true) end
if KRNL_LOADED and krnl and krnl.on_script_reset then krnl.on_script_reset(Cleanup) end