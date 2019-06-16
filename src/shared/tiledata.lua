--[[---------------------------------
File:			\src\shared\tiledata.lua
Created On:		June 15th 2019, 04:55:48 PM
Author:			Chomboghai

Last Modified:	 June 15th 2019, 06:19:55 PM
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
        hp = 2,
        r = 0
    },
    Copper = {
        hp = 8,
        r = 1
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