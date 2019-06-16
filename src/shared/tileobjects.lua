--[[---------------------------------
File:			\src\shared\tileobjects.lua
Created On:		June 15th 2019, 04:55:48 PM
Author:			Chomboghai

Last Modified:	 June 15th 2019, 06:19:55 PM
Modified By:	 Chomboghai

Description:	

---------------CHANGES---------------
Date		Author		Comments
--]]---------------------------------

--| Services |--
local ServerStorage = game:GetService'ServerStorage'

--| Imports |--

--| Variables |--
local rng = Random.new(tick())

--| Local Functions |--
local function defineTile(objName, mindepth, maxdepth)
    return {
        obj = ServerStorage:WaitForChild(objName),
        minDepth = mindepth,
        maxDepth = maxdepth
    }
end

local function getTilesInDepth(tilesTable, depth)
    local tilesInDepth = {}
    for tileName, tileData in pairs(tilesTable) do
        if depth >= tileData.minDepth and depth <= tileData.maxDepth then
            table.insert(tilesInDepth, tileData) 
        end
    end

    return tilesInDepth, tileCount
end

--| Module Definition |--
local tiles = {
    dirtTile = defineTile('dirtTile', 0, 5),
    stoneTile = defineTile('stoneTile', 4, 25),
    copperTile = defineTile('copperTile', 4, 25)
}

function tiles:GetRandomTileInDepth(depth)
    local tiles = getTilesInDepth(depth)
    if tileCount == 0 then return end
    local tileIndex = rng:NextInteger(1, #tiles)
    local randomTile = tiles[tileIndex]
    return randomTile.obj:Clone()
end

--| Module Return |--
return tiles