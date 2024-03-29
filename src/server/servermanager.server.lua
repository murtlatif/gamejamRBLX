--[[---------------------------------
File:			\src\server\systems\servermanager.server.lua
Created On:		June 15th 2019, 04:27:22 PM
Author:			Chomboghai

Last Modified:	 June 16th 2019, 05:48:47 AM
Modified By:	 Chomboghai

Description:	manages server side functionality

---------------CHANGES---------------
Date		Author		Comments
--]]---------------------------------

--| Services |--
local CollectionService = game:GetService'CollectionService'
local ReplicatedStorage = game:GetService'ReplicatedStorage'
local Players = game:GetService'Players'
local DataStore2 = require(1936396537)

--| Imports |--
local source = ReplicatedStorage:WaitForChild'Source'
local getTileData = require(source:WaitForChild'tiledata')
local tileObjects = require(source:WaitForChild'tileobjects')
local shopData = require(source:WaitForChild'shopdata')

--| Variables |--
local debuglevel = 3

local minedEvent = ReplicatedStorage:WaitForChild'mined'
local updateEvent = ReplicatedStorage:WaitForChild'update'
local returnEvent = ReplicatedStorage:WaitForChild'return'
local purchaseEvent = ReplicatedStorage:WaitForChild'purchase'
local resetmineEvent = ReplicatedStorage:WaitForChild'resetmine'

local damagedTiles = {}

local tileFolder = workspace:WaitForChild'Tiles'
local spawnPoint = workspace:WaitForChild'spawn'
local additionalSpawnHeight = 10

local nextEmptyLayerDepth = 0
local latestLayerBroken = 0
local layersAheadToSpawn = 8
local layerWidth = 12
local leftMineableBlockXPos = 4
local maxlayer = 180

local minezoneGuard = workspace:WaitForChild'minezoneGuard'
--| Functions |--
local function dprint(level, ...)
    if debuglevel >= level then
        print(...)
    end
end

local function posToString(vector3pos)
    return string.format('%d,%d,%d', vector3pos.X, vector3pos.Y, vector3pos.Z)
end

local function initPlayer(player)
    local moneyStore = DataStore2('money', player)
    local damageStore = DataStore2('damage', player)
    local blocksMinedStore = DataStore2('blocksMined', player)
    local insaniumStore = DataStore2('insanium', player)
    
    -- add a leaderstats
    local leaderstats = Instance.new'Folder'
    leaderstats.Name = 'leaderstats'

    -- add some stats
    local cash = Instance.new'IntValue'
    cash.Name = 'Cash'
    cash.Value = 0
    cash.Parent = leaderstats

    local blocksMined = Instance.new'IntValue'
    blocksMined.Name = 'Blocks Mined'
    blocksMined.Value = 0
    blocksMined.Parent = leaderstats

    local insaniumMined = Instance.new'IntValue'
    insaniumMined.Name = 'Insanium Mined'
    insaniumMined.Value = 0
    insaniumMined.Parent = leaderstats
    
    local function callUpdate(stat, value)
        updateEvent:FireClient(player, stat, value)
    end

    -- if player.UserId == 2282833 then
    --     callUpdate('money', moneyStore:Get(0))
    --     callUpdate('damage', damageStore:Get(1))
    -- else
    callUpdate('money', moneyStore:Get(0))
    callUpdate('damage', damageStore:Get(1))
    blocksMined.Value = blocksMinedStore:Get(0)
    insaniumMined.Value = insaniumStore:Get(0)
    -- end

    moneyStore:OnUpdate(function(newVal)
        callUpdate('money', newVal)
        cash.Value = newVal
    end)

    damageStore:OnUpdate(function(newVal)
        callUpdate('damage', newVal)
    end)

    blocksMinedStore:OnUpdate(function(newVal)
        blocksMined.Value = newVal
    end)

    insaniumStore:OnUpdate(function(newVal)
        insaniumMined.Value = newVal
    end)

    leaderstats.Parent = player
end

local function generateTiles()
    if nextEmptyLayerDepth >= maxlayer then return end
    dprint(3, 'generating... nextempty:', nextEmptyLayerDepth, 'latest layer:', latestLayerBroken)
    while nextEmptyLayerDepth <= latestLayerBroken + layersAheadToSpawn do
        for i = 1, layerWidth do
            local newTile = tileObjects:GetRandomTileInDepth(nextEmptyLayerDepth)
            if not newTile then
                warn'Failed to get new tile'
            else
                newTile.Position = Vector3.new(leftMineableBlockXPos + (i * 4), nextEmptyLayerDepth * -4, 0)
                newTile.Parent = tileFolder
            end
        end
        nextEmptyLayerDepth = nextEmptyLayerDepth + 1
    end

    if nextEmptyLayerDepth > 0 and minezoneGuard.CanCollide then
        minezoneGuard.CanCollide = false
    end
end

local function breakTile(player, tile, reward)
    local moneyStore = DataStore2('money', player)
    local blocksMinedStore = DataStore2('blocksMined', player)
    local insaniumStore = DataStore2('insanium', player)

    local tileDepth = -tile.Position.Y / 4

    -- increment moneystore and blocksmined store (and maybe insanium store)
    moneyStore:Increment(reward, 0)
    blocksMinedStore:Increment(1, 0)
    if CollectionService:HasTag(tile, 'Insanium') then
        insaniumStore:Increment(1, 0)
    end
    -- record new depth and spawn new layers if lowest depth
    if tileDepth > latestLayerBroken then
        latestLayerBroken = tileDepth
        -- generate tiles
        generateTiles()
    end

    -- destroy tile
    tile:Destroy()
end

local function onMine(player, tile)
    dprint(4, '[server-onmine] Received mine')
    if not tile then
        warn('invalid tile:', tile)
    elseif tile and CollectionService:HasTag(tile, 'Mineable') then
        local damageStore = DataStore2('damage', player)
        local playerDmg = damageStore:Get(1)

        local tilePosStr = posToString(tile.Position)
        local tileData = getTileData(tile)
        local tilehp = damagedTiles[tilePosStr]

        if not tileData then
            warn('failed to get tile data for tile named', tile)
            return false
        end

        if tilehp then
            if tilehp - playerDmg <= 0 then
                breakTile(player, tile, tileData.r)
                return true
            else
                damagedTiles[tilePosStr] = tilehp - playerDmg
            end
        else
            tilehp = tileData.hp
            if tilehp - playerDmg <= 0 then
                breakTile(player, tile, tileData.r)
                return true
            else
                damagedTiles[tilePosStr] = tilehp - playerDmg
            end
        end
    else
        warn('onMine received for tile without mineable tag:', tile)
    end

    return false
end

local function onPurchaseRequest(player)
    local moneyStore = DataStore2('money', player)
    local damageStore = DataStore2('damage', player)
    local currentDamage = damageStore:Get(1)
    local purchaseData = shopData[currentDamage]
    if not purchaseData then
        warn('unable to get purchase data for player:', player)
        return
    end

    local currentMoney = moneyStore:Get(0)
    if currentMoney >= purchaseData.c then
        -- spend money
        moneyStore:Increment(-purchaseData.c)
        -- upgrade damage
        damageStore:Set(purchaseData.newdmg)

        return true
    else
        return false
    end
end

local function onReturnRequest(player)
    local char = player.Character
    if not char then
        warn('no char found for player:', player)
        return
    end

    local hrp = char:FindFirstChild'HumanoidRootPart'
    if not hrp then
        warn('no hrp found for player:', player)
        return
    end

    hrp.CFrame = CFrame.new(spawnPoint.Position.X, spawnPoint.Position.Y + additionalSpawnHeight, hrp.Position.Z)
end

local function resetMine()
    minezoneGuard.CanCollide = true
    for _, player in pairs(Players:GetPlayers()) do
        onReturnRequest(player)
    end

    wait(1)
    tileFolder:ClearAllChildren()
    damagedTiles = {}
    latestLayerBroken = 0
    nextEmptyLayerDepth = 0
    generateTiles()
end

--| Startup |--
DataStore2.Combine('playerData', 'money')
DataStore2.Combine('playerData', 'damage')
DataStore2.Combine('playerData', 'blocksMined')
DataStore2.Combine('playerData', 'insanium')
generateTiles()

-- reset mine on timer
spawn(function()
    repeat
        wait(300)
        resetmineEvent:FireAllClients()
        wait(5)
        resetMine()
    until false
end)

--| Triggers |--
Players.PlayerAdded:Connect(initPlayer)
minedEvent.OnServerInvoke = onMine
returnEvent.OnServerEvent:Connect(onReturnRequest)
purchaseEvent.OnServerInvoke = onPurchaseRequest

--| Loop |--