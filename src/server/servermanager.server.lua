--[[---------------------------------
File:			\src\server\systems\serverMiner.lua
Created On:		June 15th 2019, 04:27:22 PM
Author:			Chomboghai

Last Modified:	 June 15th 2019, 06:20:23 PM
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

--| Variables |--
local minedEvent = ReplicatedStorage:WaitForChild'mined'
local updateEvent = ReplicatedStorage:WaitForChild'update'
local damagedTiles = {}

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

        if not tileData then
            warn('failed to get tile data for tile named', tile)
            return false
        end

        if tilehp then
            if tilehp - playerDmg <= 0 then
                tile:Destroy()
                moneyStore:Increment(tileData.r, 0)
                return true
            else
                damagedTiles[tilePosStr] = tilehp - playerDmg
            end
        else
            tilehp = tileData.hp
            if tilehp - playerDmg <= 0 then
                tile:Destroy()
                moneyStore:Increment(tileData.r, 0)
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
print'almost yay'
--| Startup |--
DataStore2.Combine('playerData', 'money')
DataStore2.Combine('playerData', 'damage')
print'yay'
--| Triggers |--
Players.PlayerAdded:Connect(initPlayer)
minedEvent.OnServerInvoke = onMine

--| Loop |--