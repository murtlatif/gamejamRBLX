--[[---------------------------------
File:			\src\shared\tileobjects.lua
Created On:		June 15th 2019, 04:55:48 PM
Author:			Chomboghai

Last Modified:	 June 16th 2019, 01:34:38 AM
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
local function defineTile(objName, mindepth, maxdepth, numTickets)
    return {
        obj = ServerStorage:WaitForChild(objName),
        minDepth = mindepth,
        maxDepth = maxdepth,
        tickets = numTickets
    }
end

local function getTilesInDepth(tilesTable, depth)
    local tilesInDepth = {}
    local totalTickets = 0
    for _, tileData in pairs(tilesTable) do
        if type(tileData) ~= 'function' then
            if depth >= tileData.minDepth and depth <= tileData.maxDepth then
                table.insert(tilesInDepth, tileData)
                totalTickets = totalTickets + tileData.tickets
            end
        end
    end

    return tilesInDepth, totalTickets
end

--| Module Definition |--
local tiles = {
    dirtTile = defineTile('dirtTile', 0, 8, 60),
    stoneTile = defineTile('stoneTile', 1, 150, 70),
    copperTile = defineTile('copperTile', 1, 25, 15),
    tinTile = defineTile('tinTile', 7, 40, 12),
    ironTile = defineTile('ironTile', 10, 75, 12)
}

function tiles:GetRandomTileInDepth(depth)
    local tilesInDepth, totaltickets = getTilesInDepth(self, depth)
    if #tilesInDepth == 0 then return end
    local accumulatedTickets = 0

    -- select a random tile based on ticket weight
    local ticketNum = rng:NextInteger(1, totaltickets)

    for _, tileData in pairs(tilesInDepth) do
        if tileData.tickets + accumulatedTickets >= ticketNum then
            return tileData.obj:Clone()
        end
        accumulatedTickets = accumulatedTickets + tileData.tickets
    end
end

--| Module Return |--
return tiles