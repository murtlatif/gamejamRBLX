--[[---------------------------------
File:			\src\server\systems\serverMiner.lua
Created On:		June 15th 2019, 04:27:22 PM
Author:			Chomboghai

Last Modified:	 June 15th 2019, 06:56:42 PM
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
local getTileData = require(ReplicatedStorage:WaitForChild'Source':WaitForChild'tiledata')
local tileObjects = require(ReplicatedStorage:WaitForChild'Source':WaitForChild'tileobjects')

--| Variables |--
local minedEvent = ReplicatedStorage:WaitForChild'mined'
local updateEvent = ReplicatedStorage:WaitForChild'update'
local returnEvent = ReplicatedStorage:WaitForChild'return'
local damagedTiles = {}

local tileFolder = workspace:WaitForChild'Tiles'
local spawnPoint = workspace:WaitForChild'spawn'
local additionalSpawnHeight = 10

local nextEmptyLayerDepth = 2
local latestLayerBroken = 0
local layersAheadToSpawn = 6
local layerWidth = 12
local leftMineableBlockXPos = 8

--| Functions |--
local function posToString(vector3pos)
    return string.format('%d,%d,%d', vector3pos.X, vector3pos.Y, vector3pos.Z)
end

local function initPlayer(player)
    local moneyStore = DataStore2('money', player)
    local damageStore = DataStore2('damage', player)

    local function callUpdate(stat, value)
        updateEvent:FireClient(player, stat, value)
    end

    callUpdate('money', moneyStore:Get(0))
    damageStore:Get(1)
    moneyStore:OnUpdate(function(newVal)
        callUpdate('money', newVal)
    end)
end

local function generateTiles()
    if nextEmptyLayerDepth < latestLayerBroken + layersAheadToSpawn then
        for i = 1, layerWidth do
            local newTile = tileObjects:GetRandomTileInDepth(nextEmptyLayerDepth)
            newTile.Position = Vector3.new(leftMineableBlockXPos + (i * 4), nextEmptyLayerDepth * 4, 0)
            newTile.Parent = tileFolder
        end
    end
end

local function breakTile(player, tile, reward)
    local moneyStore = DataStore2('money', player)
    local tileDepth = tile.Position.Y / 4

    -- incrmeent moneystore
    moneyStore:Increment(reward, 0)

    -- record new depth and spawn new layers if lowest depth
    if tileDepth > latestLayerBroken then
        tileDepth = latestLayerBroken
        -- generate tiles
        generateTiles()
    end
    -- destroy tile
    tile:Destroy()
end

local function onMine(player, tile)
    print'[server-onmine] Received mine'
    if not tile then
        warn('invalid tile:', tile)
    elseif tile and CollectionService:HasTag(tile, 'Mineable') then
        local damageStore = DataStore2('damage', player)
        local playerDmg = damageStore:Get(1)
        local moneyStore = DataStore2('money', player)

        local tilePosStr = posToString(tile.Position)
        local tileData = getTileData(tile)
        local tilehp = damagedTiles[tilePosStr]
        local tileDepth = tile.Position.Y / 4

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

--| Triggers |--
Players.PlayerAdded:Connect(initPlayer)
minedEvent.OnServerInvoke = onMine
returnEvent.OnServerEvent:Connect(onReturnRequest)


--| Loop |--