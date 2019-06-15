--[[---------------------------------
File:			\src\client\clientcam.client.lua
Created On:		June 15th 2019, 03:06:15 PM
Author:			Chomboghai

Last Modified:	 June 15th 2019, 06:01:21 PM
Modified By:	 Chomboghai

Description:	

---------------CHANGES---------------
Date		Author		Comments
--]]---------------------------------

--| Services |--
local RunService = game:GetService'RunService'
local Players = game:GetService'Players'

--| Imports |--

--| Variables |--
local cameraZ = 35
local minZ = 15
local maxZ = 45
local zStep = 2.5
local cameraYOffset = 5

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local mouse = player:GetMouse()

--| Functions |--
local function onUpdate()
    if player.Character and player.Character:FindFirstChild'HumanoidRootPart' then
        local hrp = player.Character:FindFirstChild'HumanoidRootPart'

        camera.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + cameraYOffset, cameraZ)
	end
end

local function scroll(scrollIn)
    if scrollIn then
        if cameraZ - zStep < minZ then
            cameraZ = minZ
        else
            cameraZ = cameraZ - zStep
        end
    else
        if cameraZ + zStep > maxZ then
            cameraZ = maxZ
        else
            cameraZ = cameraZ + zStep
        end
    end 
end

--| Startup |--

--| Triggers |--
RunService:BindToRenderStep('Camera', Enum.RenderPriority.Camera.Value, onUpdate)
mouse.WheelForward:Connect(function()
    scroll(true)
end)

mouse.WheelBackward:Connect(function()
    scroll(false)
end)

--| Loop |--