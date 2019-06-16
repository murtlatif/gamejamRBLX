--[[---------------------------------
File:			\src\client\clientManager.client.lua
Created On:		June 15th 2019, 04:07:46 PM
Author:			Chomboghai

Last Modified:	 June 16th 2019, 04:33:57 AM
Modified By:	 Chomboghai

Description:	

---------------CHANGES---------------
Date		Author		Comments
--]]---------------------------------

--| Services |--
local CollectionService = game:GetService'CollectionService'
local Players = game:GetService'Players'
local ReplicatedStorage = game:GetService'ReplicatedStorage'
local SoundService = game:GetService'SoundService'
local TweenService = game:GetService'TweenService'

--| Imports |--
local shopdata = require(ReplicatedStorage:WaitForChild'Source':WaitForChild'shopdata')

--| Variables |--
local debuglevel = 3
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local mineCooldown = 0
local minedRecently = false
local mineEvent = ReplicatedStorage:WaitForChild'mined'
local updateEvent = ReplicatedStorage:WaitForChild'update'
local returnEvent = ReplicatedStorage:WaitForChild'return'
local purchaseEvent = ReplicatedStorage:WaitForChild'purchase'
local resetmineEvent = ReplicatedStorage:WaitForChild'resetmine'
local mineConnection = nil
local playerGui = player:WaitForChild'PlayerGui'
local moneygui = playerGui:WaitForChild'moneygui'
local moneytext = moneygui:WaitForChild'money'
local digsound = SoundService:WaitForChild'dig'
local minesound = SoundService:WaitForChild'mine'
local digbreak = SoundService:WaitForChild'digbreak'
local minebreak = SoundService:WaitForChild'minebreak'
local buysuccess = SoundService:WaitForChild'buysuccess'
local buyfail = SoundService:WaitForChild'buyfail'
local mouseBox = playerGui:WaitForChild'SelectionBox'
local maxReachRange = 10
local rng = Random.new(tick())
local returngui = playerGui:WaitForChild'returngui'
local returnframe = returngui:WaitForChild'Frame'
local returnbutton = returnframe:WaitForChild'To Top'
local resetmineFrame = returngui:WaitForChild'resetFrame'
local resetTimer = resetmineFrame:WaitForChild'resetTimer'
local recentlyReturned = false
local returnCooldown = 2
local shopgui = playerGui:WaitForChild'shopgui'
local shopframe = shopgui:WaitForChild'Frame'
local upgradeButton = shopframe:WaitForChild'upgrade'
local shopguiCurrentDamage = shopframe:WaitForChild'currentDamage'
local shopguiNewDamage = shopframe:WaitForChild'newDamage'
local shopguiUpgradeCost = shopframe:WaitForChild'upgradeCost'
local recentlyAttemptedPurchase = false
local purchaseCooldown = 3.5
local currentDamage = 1

local goal = {
    Position = UDim2.new(0.5, -175, 1, -55)
}
local reversedGoal = {
    Position = UDim2.new(0.5, -175, 1, 0)
}
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local showtween = TweenService:Create(resetmineFrame, tweenInfo, goal)
local hidetween = TweenService:Create(resetmineFrame, tweenInfo, reversedGoal)

--| Functions |--
local function dprint(level, ...)
    if debuglevel >= level then
        print(...)
    end
end

local function playsfx(sound)
    local soundspeed = rng:NextNumber(0.9, 1.1)
    sound.PlaybackSpeed = soundspeed
    SoundService:PlayLocalSound(sound)
end

local function onMouseMove(target)
    if not target then return end

    if CollectionService:HasTag(target, 'Mineable') then
        mouseBox.Adornee = target
    else
        mouseBox.Adornee = nil
    end
end

local function sendMineSignal(tile)
    if CollectionService:HasTag(tile, 'Mineable') then
        local tag = ''
        if CollectionService:HasTag(tile, 'Dig') then
            playsfx(digsound)
            tag = 'Dig'
        elseif CollectionService:HasTag(tile, 'Mine') then
            playsfx(minesound)
            tag = 'Mine'
        else
            warn('no sound tag for tile:', tile)
        end

        local blockBroken = mineEvent:InvokeServer(tile)

        if blockBroken then
            if tag == 'Dig' then
                playsfx(digbreak)
            elseif tag == 'Mine' then
                playsfx(minebreak)
            else
                warn('broken tile:', tile, ' has no tag so playing minebreak')
                playsfx(minebreak)
            end
        end
        dprint(4, '[client-sendmine] sent mine signal')
    end
end

local function clientMiner()
    if mineConnection then
        mineConnection:Disconnect()
    end
    mineConnection = mouse.Button1Down:Connect(function()
        if minedRecently then return end
        local target = mouse.Target
        if target then
            if CollectionService:HasTag(target, 'Mineable') then
                if player.Character and player:DistanceFromCharacter(target.Position) < maxReachRange then
                    minedRecently = true
                    sendMineSignal(target)
                    wait(mineCooldown)
                    minedRecently = false
                end
            end
        end
    end)
    return true
end

local function returnToTop()
    if recentlyReturned then return end
    recentlyReturned = true
    returnEvent:FireServer()
    wait(returnCooldown)
    recentlyReturned = false
end

local function updateShop()
    shopguiCurrentDamage.Text = 'Current Damage: ' .. tostring(currentDamage)
    if currentDamage == shopdata.MaxDamage then
        shopguiNewDamage.Text = 'Max level reached.'
        shopguiUpgradeCost.Text = 'Max level reached.'
        upgradeButton.Text = 'No more upgrades.'
    else
        shopguiNewDamage.Text = 'New Damage: ' .. tostring(shopdata[currentDamage].newdmg)
        shopguiUpgradeCost.Text = 'Upgrade Cost: ' .. tostring(shopdata[currentDamage].c)
    end
end

local function purchaseRequest()
    if recentlyAttemptedPurchase then return end
    if currentDamage == shopdata.MaxDamage then return end
    recentlyAttemptedPurchase = true
    upgradeButton.Text = 'Purchasing...'
    local purchaseSuccess = purchaseEvent:InvokeServer()
    if purchaseSuccess then
        SoundService:PlayLocalSound(buysuccess)
        upgradeButton.Text = 'Success!'
    else
        SoundService:PlayLocalSound(buyfail)
        upgradeButton.Text = 'Not enough funds.'
    end
    wait(purchaseCooldown)
    if currentDamage == shopdata.MaxDamage then
        upgradeButton.Text = 'No more upgrades.'
    else
        upgradeButton.Text = 'Upgrade!'
    end
    recentlyAttemptedPurchase = false
end

local function onupdate(stat, value)
    if stat == 'money' then
        moneytext.Text = tostring(value)
    elseif stat == 'damage' then
        currentDamage = value
        updateShop()
    else
        warn('[client-onupdate] invalid stat:', stat)
    end
end

local function onresetmineSignal()
    resetTimer.Text = 'Mine resetting in 5'
    showtween:Play()
    wait(1)
    resetTimer.Text = 'Mine resetting in 4'
    wait(1)
    resetTimer.Text = 'Mine resetting in 3'
    wait(1)
    resetTimer.Text = 'Mine resetting in 2'
    wait(1)
    resetTimer.Text = 'Mine resetting in 1'
    wait(1)
    resetTimer.Text = 'Mine resetting...'
    returnEvent:FireServer()
    wait(3)
    hidetween:Play()
end

--| Startup |--
-- run systems
clientMiner()

--| Triggers |--
updateEvent.OnClientEvent:Connect(onupdate)
returnbutton.MouseButton1Click:Connect(returnToTop)
upgradeButton.MouseButton1Click:Connect(purchaseRequest)
resetmineEvent.OnClientEvent:Connect(onresetmineSignal)
mouse.Move:Connect(function()
    local target = mouse.Target
    if not target then return end
    onMouseMove(target)
end)
--| Loop |--