--[[
    PEXI OPTIMAIZER (FINAL FIX)
    - Prevents duplicates (auto-delete old).
    - Fixed "PEXI INK" text visibility (ZIndex/Anchoring).
    - Added: Remove Animations, Remove Game GUI.
]]

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- --- CLEANUP OLD INSTANCES ---
if CoreGui:FindFirstChild("UniversalOptimizerClean") then
    CoreGui.UniversalOptimizerClean:Destroy()
end
if LocalPlayer.PlayerGui:FindFirstChild("UniversalOptimizerClean") then
    LocalPlayer.PlayerGui.UniversalOptimizerClean:Destroy()
end

-- --- CONFIGURATION ---
local SETTINGS = {
    SafeList = {
        "volcanic rock", "basalt core", "basalt rock", "basalt vein",
        "violet crystal", "boulder", "crimson crystal", "cyan crystal",
        "light crystal", "large ice crystal", "icy rock", "icy pebble",
        "icy boulder", "iceberg", "floating crystal", "lucky block",
        "small ice crystal", "rock", "pebble", "medium ice crystal"
    }
}

local STATE = {
    MiningMode = false,
    HidePlayers = false,
    Fullbright = false,
    AntiAFK = false,
    Rendering = true,
    NoAnims = false,
    NoGUI = false,
    -- FPS Flags
    NoTextures = false,
    NoShadows = false,
    SimpleMaterials = false,
    NoEffects = false
}

-- --- GUI CREATION ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalOptimizerClean"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
if pcall(function() ScreenGui.Parent = CoreGui end) then else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Variables for Dragging
local Dragging, DragInput, DragStart, StartPos

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 460, 0, 430) -- Increased height for new buttons
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -215)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- Deep Dark
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

local HeaderCover = Instance.new("Frame")
HeaderCover.Size = UDim2.new(1, 0, 0, 10)
HeaderCover.Position = UDim2.new(0, 0, 1, -10)
HeaderCover.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
HeaderCover.BorderSizePixel = 0
HeaderCover.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Text = "PEXI OPTIMAIZER"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Text = "FPS: 60"
FPSLabel.Font = Enum.Font.Code
FPSLabel.TextSize = 14
FPSLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
FPSLabel.Size = UDim2.new(0, 70, 1, 0)
FPSLabel.Position = UDim2.new(1, -110, 0, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Parent = TopBar

-- Minimize
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Text = "-"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 24
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Size = UDim2.new(0, 40, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -40, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Parent = TopBar

-- Content Area
local UIContent = Instance.new("Frame")
UIContent.Name = "Content"
UIContent.Size = UDim2.new(1, -20, 1, -55)
UIContent.Position = UDim2.new(0, 10, 0, 50)
UIContent.BackgroundTransparency = 1
UIContent.Parent = MainFrame

local Layout = Instance.new("UIGridLayout")
Layout.CellSize = UDim2.new(0, 215, 0, 45)
Layout.CellPadding = UDim2.new(0, 10, 0, 10)
Layout.Parent = UIContent

-- --- ANIMATION HELPERS ---
local function AnimateHover(btn, hovering)
    local targetColor = hovering and Color3.fromRGB(50, 50, 55) or Color3.fromRGB(40, 40, 45)
    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
end

-- --- FUNCTIONALITY ---

-- 1. Dragging
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then Dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
end)

-- 2. Minimize
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        UIContent.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 460, 0, 45), "Out", "Quad", 0.3, true)
    else
        MainFrame:TweenSize(UDim2.new(0, 460, 0, 430), "Out", "Quad", 0.3, true)
        task.wait(0.2)
        UIContent.Visible = true
    end
end)

-- 3. FPS Logic
RunService.RenderStepped:Connect(function(dt)
    if MainFrame.Visible then
        local fps = math.floor(1/dt)
        FPSLabel.Text = "FPS: " .. fps
    end
end)

-- --- TOGGLE BUILDER ---

local function CreateToggle(name, text, defaultVal, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.Text = ""
    Button.Parent = UIContent
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 6)
    BCorner.Parent = Button
    
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 36, 0, 18)
    Indicator.Position = UDim2.new(1, -46, 0.5, -9)
    Indicator.BackgroundColor3 = defaultVal and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(60, 60, 60)
    Indicator.Parent = Button
    
    local ICorner = Instance.new("UICorner")
    ICorner.CornerRadius = UDim.new(1, 0)
    ICorner.Parent = Indicator
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = defaultVal and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.Parent = Indicator
    
    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(1, 0)
    CCorner.Parent = Circle
    
    local active = defaultVal
    
    Button.MouseButton1Click:Connect(function()
        active = not active
        if active then
            TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}):Play()
            Circle:TweenPosition(UDim2.new(1, -16, 0.5, -7), "Out", "Quad", 0.2, true)
        else
            TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            Circle:TweenPosition(UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.2, true)
        end
        callback(active)
    end)
    
    Button.MouseEnter:Connect(function() AnimateHover(Button, true) end)
    Button.MouseLeave:Connect(function() AnimateHover(Button, false) end)
    
    return Button
end


-- --- OPTIMIZATION LOGIC ---

local function MatchesWhitelist(obj)
    local name = obj.Name:lower()
    for _, key in ipairs(SETTINGS.SafeList) do
        if name:find(key, 1, true) then return true end
    end
    return false
end

local function IsMyChar(part)
    if LocalPlayer.Character and part:IsDescendantOf(LocalPlayer.Character) then return true end
    return false
end

local function ProcessObject(obj)
    if IsMyChar(obj) then return end
    
    -- 1. MINING MODE
    if STATE.MiningMode then
        if MatchesWhitelist(obj) then
            if obj:IsA("BasePart") then
                obj.Transparency = 0
                obj.Material = Enum.Material.SmoothPlastic
                obj.CastShadow = false
            end
        else
            if obj:IsA("BasePart") then
                 if obj.Transparency < 1 then obj.Transparency = 1 end
                 obj.CastShadow = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") then
                obj:Destroy()
            end
        end
        return
    end
    
    -- 2. GENERAL
    if obj:IsA("BasePart") then
        if STATE.SimpleMaterials then obj.Material = Enum.Material.SmoothPlastic end
        if STATE.NoShadows then obj.CastShadow = false end
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        if STATE.NoTextures then obj.Transparency = 1 end
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        if STATE.NoEffects then obj.Enabled = false end
    end
end

local function RefreshGlobal()
    local c = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        ProcessObject(v)
        c = c + 1
        if c % 1000 == 0 then task.wait() end
    end
end

local Listener = nil
local function UpdateListener()
    if Listener then return end
    Listener = Workspace.DescendantAdded:Connect(function(v)
        if STATE.MiningMode or STATE.SimpleMaterials or STATE.NoTextures then
            task.defer(function() ProcessObject(v) end)
        end
    end)
end
UpdateListener()

-- Helpers
local function Toggle3DRender(enabled)
    STATE.Rendering = enabled
    pcall(function() RunService:Set3dRenderingEnabled(enabled) end)
    pcall(function() set3drenderingenabled(enabled) end)
    
    local bs = ScreenGui:FindFirstChild("BlackOverlay")
    if not enabled then
        if not bs then
            bs = Instance.new("Frame")
            bs.Name = "BlackOverlay"
            bs.Size = UDim2.new(1,0,1,0)
            bs.BackgroundColor3 = Color3.new(0,0,0)
            bs.ZIndex = 9999
            bs.BorderSizePixel = 0
            bs.Parent = ScreenGui
            
            local t = Instance.new("TextLabel")
            t.Name = "TitleInfo"
            t.Text = "PEXI INK"
            t.Font = Enum.Font.GothamBlack
            t.TextSize = 40
            t.TextColor3 = Color3.new(1,1,1)
            t.Size = UDim2.new(1,0,0,60)
            t.AnchorPoint = Vector2.new(0.5, 0.5)
            t.Position = UDim2.new(0.5, 0, 0.5, 0)
            t.BackgroundTransparency = 1
            t.ZIndex = 10000
            t.Parent = bs
        else
            local t = bs:FindFirstChild("TitleInfo")
            if t then t.Text = "PEXI INK" end
        end
        bs.Visible = true
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    else
        if bs then bs.Visible = false end
    end
end

local function ToggleFullbright(v)
    STATE.Fullbright = v
    if v then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end

local afkC = nil
local function ToggleAFK(v)
    STATE.AntiAFK = v
    if v then
        afkC = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    else
        if afkC then afkC:Disconnect() end
    end
end

-- NEW FUNCTIONS (ANIM / GUI)
local function ToggleAnims(disable)
    STATE.NoAnims = disable
    -- Disable Tracks (Live)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Humanoid") then
             for _, track in pairs(v:GetPlayingAnimationTracks()) do
                 track:Stop()
             end
        end
    end
end

local function ToggleGUI(disable)
    STATE.NoGUI = disable
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, gui in pairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "UniversalOptimizerClean" then
                gui.Enabled = not disable
            end
        end
    end
end


-- --- BUTTONS ---

CreateToggle("Btn_Mining", "Mining X-Ray", false, function(v) 
    STATE.MiningMode = v 
    task.spawn(RefreshGlobal) 
end)

CreateToggle("Btn_Players", "Hide Players", false, function(v)
    STATE.HidePlayers = v
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
           for _, part in pairs(p.Character:GetDescendants()) do
               if part:IsA("BasePart") then part.Transparency = v and 1 or 0 end
           end
        end
    end
end)

CreateToggle("Btn_Tex", "Remove Textures", false, function(v) STATE.NoTextures = v task.spawn(RefreshGlobal) end)
CreateToggle("Btn_Shadow", "Remove Shadows", false, function(v) STATE.NoShadows = v Lighting.GlobalShadows = not v task.spawn(RefreshGlobal) end)
CreateToggle("Btn_Mat", "Simple Materials", false, function(v) STATE.SimpleMaterials = v task.spawn(RefreshGlobal) end)
CreateToggle("Btn_FX", "Remove Effects", false, function(v) STATE.NoEffects = v task.spawn(RefreshGlobal) end)
CreateToggle("Btn_FB", "Fullbright", false, function(v) ToggleFullbright(v) end)
CreateToggle("Btn_AFK", "Anti-AFK", false, function(v) ToggleAFK(v) end)

-- New Optimizations
CreateToggle("Btn_Anim", "Remove Anims", false, function(v) ToggleAnims(v) end)
CreateToggle("Btn_GUI", "Delete Game GUI", false, function(v) ToggleGUI(v) end)

CreateToggle("Btn_Render", "3D Rendering", true, function(v) 
    Toggle3DRender(v) 
end)

CreateToggle("Btn_Close", "Unload Script", false, function(v) ScreenGui:Destroy() end)

-- Loop for players and keeping GUI hidden (some games force it back)
task.spawn(function()
    while true do
        task.wait(2)
        -- Keep Players Hidden
        if STATE.HidePlayers then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                   for _, part in pairs(p.Character:GetDescendants()) do
                       if part:IsA("BasePart") then part.Transparency = 1 end
                   end
                end
            end
        end
        -- Keep Animations Stopped
        if STATE.NoAnims then
             for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Humanoid") then
                     for _, track in pairs(v:GetPlayingAnimationTracks()) do
                         track:Stop()
                     end
                end
            end
        end
        -- Keep GUI Hidden
        if STATE.NoGUI then
             local pg = LocalPlayer:FindFirstChild("PlayerGui")
             if pg then
                for _, gui in pairs(pg:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Name ~= "UniversalOptimizerClean" then
                        gui.Enabled = false
                    end
                end
             end
        end
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "PEXI OPTIMAIZER";
    Text = "Loaded. Clean & Animated.";
    Duration = 5;
})
