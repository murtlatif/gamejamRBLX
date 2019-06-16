--[[---------------------------------
File:			\src\client\clientcam.client.lua
Created On:		June 15th 2019, 03:06:15 PM
Author:			Chomboghai

Last Modified:	 June 15th 2019, 07:23:17 PM
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
local initialYOffset = 5

local cameraYOffset = initialYOffset

local miningZoneXLeft = 6
local miningZoneXRight = 54
local miningZoneYOffset = -2.5
local cameraYSpeed = 0.1

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local playerGui = player:WaitForChild'PlayerGui'
local returngui = playerGui:WaitForChild'returngui'
local returnframe = returngui:WaitForChild'Frame'
local returnbutton = returnframe:WaitForChild'To Top'
local hideguiYpos = 125
local showguiYpos = -125
local currentguiYpos = hideguiYpos
local guiSpeed = 0.1

--| Functions |--
local function onUpdate()
    if player.Character and player.Character:FindFirstChild'HumanoidRootPart' then
        local hrp = player.Character:FindFirstChild'HumanoidRootPart'

        -- scroll down cam if in mining zone
        local camX = camera.CFrame.p.X
        if camX > miningZoneXLeft and camX < miningZoneXRight then
            -- move camera
            if cameraYOffset > miningZoneYOffset then
                local difference = cameraYOffset - miningZoneYOffset
                cameraYOffset = cameraYOffset - (cameraYSpeed * difference)
            end

            -- bring up gui
            if currentguiYpos > showguiYpos then
                local difference = currentguiYpos - showguiYpos
                currentguiYpos = currentguiYpos - (guiSpeed * difference)
            end

        else
            if cameraYOffset < initialYOffset then
                local difference =  initialYOffset - cameraYOffset
                cameraYOffset = cameraYOffset + (cameraYSpeed * difference)
            end

            if currentguiYpos < hideguiYpos then
                local difference =  hideguiYpos - currentguiYpos
                currentguiYpos = currentguiYpos + (guiSpeed * difference)
            end
        end

        returnframe.Position = UDim2.new(1, -350, 1, currentguiYpos)
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