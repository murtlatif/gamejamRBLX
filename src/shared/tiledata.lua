--[[---------------------------------
File:			\src\shared\tiledata.lua
Created On:		June 15th 2019, 04:55:48 PM
Author:			Chomboghai

Last Modified:	 June 16th 2019, 01:33:25 AM
Modified By:	 Chomboghai

Description:	

---------------CHANGES---------------
Date		Author		Comments
--]]---------------------------------

--| Services |--
local CollectionService = game:GetService'CollectionService'

--| Imports |--

--| Variables |--
local tileData = {
    Dirt = {
        hp = 1,
        r = 0
    },
    Stone = {
        hp = 3,
        r = 1
    },
    Copper = {
        hp = 5,
        r = 2
    },
    Tin = {
        hp = 8,
        r = 5
    },
    Iron = {
        hp = 12,
        r = 10
    }
}
--| Local Functions |--

--| Module Definition |--
local function getTileData(tile)
    for _, tag in pairs(CollectionService:GetTags(tile)) do
        if tileData[tag] then
            return tileData[tag]
        end
    end
end

--| Module Return |--
return getTileData