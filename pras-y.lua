-- Камера фиксируется на выбранной точке по нажатию Y (toggle)
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Сохраняем позицию камеры в момент активации
local saved = false
local savedCFrame

-- Фунция для фиксации камеры
local function toggleCameraLock()
    saved = not saved
    if saved then
        savedCFrame = camera.CFrame
        camera.CameraType = Enum.CameraType.Scriptable
        -- Зафиксировать постоянно CFrame на сохранённой позиции
        spawn(function()
            while saved do
                camera.CFrame = savedCFrame
                wait()
            end
        end)
    else
        camera.CameraType = Enum.CameraType.Custom
    end
end

-- Обработчик клика по клавише Y (английская)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Y then
        toggleCameraLock()
    end
end)
-- Новый универсальный анти-АФК скрипт (2025)
local VirtualUser = game:GetService("VirtualUser")
game.Players.LocalPlayer.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
--fps and ping show
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаём ScreenGui и TextLabel для отображения текста
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSPingHUD"
screenGui.Parent = playerGui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 150, 0, 40)
label.Position = UDim2.new(1, -160, 0, 10) -- справа сверху
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(30, 255, 30)
label.Font = Enum.Font.Code
label.TextSize = 24
label.TextXAlignment = Enum.TextXAlignment.Right
label.Parent = screenGui

local fps = 0
local lastUpdate = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastUpdate >= 1 then
        fps = frameCount
        frameCount = 0
        lastUpdate = now

        local ping = 0
        local networkStats = Stats:FindFirstChild("Network")
        if networkStats then
            local pingStat = networkStats:FindFirstChild("Ping")
            if pingStat then
                ping = math.floor(pingStat.Value + 0.5)
            end
        end

        label.Text = "FPS: "..fps.."\nPing: "..ping.." ms"
    end
end)

