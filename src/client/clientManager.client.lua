--[[---------------------------------
File:			\src\client\clientManager.client.lua
Created On:		June 15th 2019, 04:07:46 PM
Author:			Chomboghai

Last Modified:	 June 15th 2019, 05:39:37 PM
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
--| Imports |--

--| Variables |--
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local mineCooldown = 0.5
local minedRecently = false
local mineEvent = ReplicatedStorage:WaitForChild'mined'
local updateEvent = ReplicatedStorage:WaitForChild'update'
local mineConnection = nil
local playerGui = player:WaitForChild'PlayerGui'
local moneygui = playerGui:WaitForChild'moneygui'
local moneytext = moneygui:WaitForChild'money'
local digsound = SoundService:WaitForChild'dig'
local minesound = SoundService:WaitForChild'mine'
local digbreak = SoundService:WaitForChild'digbreak'
local minebreak = SoundService:WaitForChild'minebreak'
local rng = Random.new(tick())

--| Functions |--
local function playsfx(sound)
    local soundspeed = rng:NextNumber(0.9, 1.1)
    sound.PlaybackSpeed = soundspeed
    SoundService:PlayLocalSound(sound)
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
        print'[client-sendmine] sent mine signal'
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
                minedRecently = true
                sendMineSignal(target)
                wait(mineCooldown)
                minedRecently = false
            end
        end
    end)
    return true
end

local function onupdate(stat, value)
    if stat == 'money' then
        moneytext.Text = tostring(value)
    else
        warn('[client-onupdate] invalid stat:', stat)
    end
end

--| Startup |--
-- run systems
clientMiner()

--| Triggers |--
updateEvent.OnClientEvent:Connect(onupdate)

--| Loop |--