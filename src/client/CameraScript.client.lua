--[[---------------------------------
File:			\src\client\clientcam.client.lua
Created On:		June 15th 2019, 03:06:15 PM
Author:			Chomboghai

Last Modified:	 June 16th 2019, 03:04:29 AM
Modified By:	 Chomboghai

Description:	

---------------CHANGES---------------
Date		Author		Comments
--]]---------------------------------

--| Services |--
local RunService = game:GetService'RunService'
local Players = game:GetService'Players'
local SoundService = game:GetService'SoundService'
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
local hideReturnGuiYPos = 125
local showReturnGuiYPos = -125
local currentReturnGuiYPos = hideReturnGuiYPos

local shopgui = playerGui:WaitForChild'shopgui'
local shopframe = shopgui:WaitForChild'Frame'
local hideShopGuiYScale = 1.5
local showShopGuiYScale = 0.5
local currentShopGuiYScale = hideShopGuiYScale
local shopLeftPos = -17
local shopRightPos = -9
local guiSpeed = 0.1

local music = {
    defaultbgm = SoundService:WaitForChild'defaultbgm',
    mining1 = SoundService:WaitForChild'mining1',
    shop = SoundService:WaitForChild'shop'
}
local musicChanging = false
local currentMusic = nil

--| Functions |--
local function changeMusic(newMusic)
    if currentMusic == newMusic then return end
    if musicChanging then return end
    print('now playing:', newMusic)

    musicChanging = true
    if (currentMusic) then
        for i = 0.3, 0, -0.05 do
            currentMusic.Volume = i
            wait(0.1)
        end

        currentMusic:Stop()
    end
    if newMusic then
        newMusic.TimePosition = 0
        newMusic.Volume = 0
        newMusic:Play()
        for i = 0, 0.3, 0.05 do
            newMusic.Volume = i
            wait(0.1)
        end
    end

    currentMusic = newMusic
    musicChanging = false
end

local function onUpdate()
    if player.Character and player.Character:FindFirstChild'HumanoidRootPart' then
        local hrp = player.Character:FindFirstChild'HumanoidRootPart'

        -- scroll down cam if in mining zone
        local camX = camera.CFrame.p.X
        local camY = camera.CFrame.p.Y
        if camX > miningZoneXLeft and camX < miningZoneXRight then
            -- move camera
            if cameraYOffset > miningZoneYOffset then
                local difference = cameraYOffset - miningZoneYOffset
                cameraYOffset = cameraYOffset - (cameraYSpeed * difference)
            end

            -- bring up guis
            if currentReturnGuiYPos > showReturnGuiYPos then
                local difference = currentReturnGuiYPos - showReturnGuiYPos
                currentReturnGuiYPos = currentReturnGuiYPos - (guiSpeed * difference)
            end

        else
            if cameraYOffset < initialYOffset then
                local difference =  initialYOffset - cameraYOffset
                cameraYOffset = cameraYOffset + (cameraYSpeed * difference)
            end

            if currentReturnGuiYPos < hideReturnGuiYPos then
                local difference =  hideReturnGuiYPos - currentReturnGuiYPos
                currentReturnGuiYPos = currentReturnGuiYPos + (guiSpeed * difference)
            end
        end

        -- shop zone
        if camX > shopLeftPos and camX < shopRightPos then
            -- bring up shop gui
            if currentShopGuiYScale > showShopGuiYScale then
                local difference = currentShopGuiYScale - showShopGuiYScale
                currentShopGuiYScale = currentShopGuiYScale - (guiSpeed * difference)
            end

            -- start playing shop music
            if currentMusic ~= music.shop then
                changeMusic(music.shop)
            end
        else
            if currentShopGuiYScale < hideShopGuiYScale then
                local difference = hideShopGuiYScale - currentShopGuiYScale
                currentShopGuiYScale = currentShopGuiYScale + (guiSpeed * difference)
            end

            -- play regular bgm
            if camY >= -25 then
                if currentMusic ~= music.defaultbgm then
                    changeMusic(music.defaultbgm)
                end
            elseif camY >= -1000 then
                if currentMusic ~= music.mining1 then
                    changeMusic(music.mining1)
                end
            else
                if currentMusic ~= music.defaultbgm then
                    changeMusic(music.defaultbgm)
                end
            end

        end

        returnframe.Position = UDim2.new(1, -350, 1, currentReturnGuiYPos)
        shopframe.Position = UDim2.new(0.5, -200, currentShopGuiYScale, -100)
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