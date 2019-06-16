--[[---------------------------------
File:			\src\shared\tileobjects.lua
Created On:		June 15th 2019, 04:55:48 PM
Author:			Chomboghai

Last Modified:	 June 16th 2019, 04:42:09 AM
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
    dirtTile = defineTile('dirtTile', 0, 8, 100),
    stoneTile = defineTile('stoneTile', 1, 150, 150),
    lessRareDirtTile = defineTile('dirtTile', 9, 150, 10),
    coalTile = defineTile('coalTile',2, 120, 20),
    ironTile = defineTile('ironTile', 10, 140, 20),
    goldTile = defineTile('goldTile', 25, 150, 7),
    lapisTile = defineTile('lapisTile', 35, 150, 25),
    rubyTile = defineTile('rubyTile', 70, 150, 15),
    emeraldTile = defineTile('emeraldTile', 90, 150, 5),
    glowrockTile = defineTile('glowrockTile', 115, 150, 3),
    diamondTile = defineTile('diamondTile', 130, 150, 2),
    insaniumTile = defineTile('insaniumTile',140, 150, 1),
    bedrockTile = defineTile('bedrockTile', 151, 9999, 1)
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