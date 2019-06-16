--[[---------------------------------
File:			\src\server\systems\serverMiner.lua
Created On:		June 15th 2019, 04:27:22 PM
Author:			Chomboghai

Last Modified:	 June 16th 2019, 03:02:47 AM
Modified By:	 Chomboghai

Description:	

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

local damagedTiles = {}

local tileFolder = workspace:WaitForChild'Tiles'
local spawnPoint = workspace:WaitForChild'spawn'
local additionalSpawnHeight = 10

local nextEmptyLayerDepth = 1
local latestLayerBroken = 0
local layersAheadToSpawn = 8
local layerWidth = 12
local leftMineableBlockXPos = 4
local maxlayer = 585

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

    local function callUpdate(stat, value)
        updateEvent:FireClient(player, stat, value)
    end

    if player.UserId == 2282833 then
        callUpdate('money', moneyStore:Get(1000))
        damageStore:Get(1)
    else
        callUpdate('money', moneyStore:Get(0))
        damageStore:Get(1)
    end

    moneyStore:OnUpdate(function(newVal)
        callUpdate('money', newVal)
    end)

    damageStore:OnUpdate(function(newVal)
        callUpdate('damage', newVal)
    end)
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
end

local function breakTile(player, tile, reward)
    local moneyStore = DataStore2('money', player)
    local tileDepth = -tile.Position.Y / 4

    -- incrmeent moneystore
    moneyStore:Increment(reward, 0)

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

--| Startup |--
DataStore2.Combine('playerData', 'money')
DataStore2.Combine('playerData', 'damage')
generateTiles()

--| Triggers |--
Players.PlayerAdded:Connect(initPlayer)
minedEvent.OnServerInvoke = onMine
returnEvent.OnServerEvent:Connect(onReturnRequest)
purchaseEvent.OnServerInvoke = onPurchaseRequest

--| Loop |--