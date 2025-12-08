-- LocalScript в StarterPlayerScripts

local uis = game:GetService("UserInputService")
local cam = workspace.CurrentCamera

local locked = false
local loop -- ссылка на цикл

uis.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.Y then

		locked = not locked

		if locked then
			local saved = cam.CFrame
			cam.CameraType = Enum.CameraType.Scriptable

			-- запускаем цикл и сохраняем ссылку
			loop = task.spawn(function()
				while locked do
					cam.CFrame = saved
					task.wait()
				end
			end)

		else
			-- останавливаем цикл корректно
			locked = false
			cam.CameraType = Enum.CameraType.Custom
		end
	end
end)-- LocalScript в StarterPlayerScripts

local uis = game:GetService("UserInputService")
local cam = workspace.CurrentCamera

local locked = false
local loop -- ссылка на цикл

uis.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.Y then

		locked = not locked

		if locked then
			local saved = cam.CFrame
			cam.CameraType = Enum.CameraType.Scriptable

			-- запускаем цикл и сохраняем ссылку
			loop = task.spawn(function()
				while locked do
					cam.CFrame = saved
					task.wait()
				end
			end)

		else
			-- останавливаем цикл корректно
			locked = false
			cam.CameraType = Enum.CameraType.Custom
		end
	end
end)
