--[[---------------------------------
File:			\src\shared\tiledata.lua
Created On:		June 15th 2019, 04:55:48 PM
Author:			Chomboghai

Last Modified:	 June 16th 2019, 04:42:21 AM
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

    Coal = {
        hp = 7,
        r = 2
    },
    Iron = {
        hp = 12,
        r = 5
    },
    Gold = {
        hp = 15,
        r = 15
    },
    Lapis = {
        hp = 10,
        r = 4
    },
    Ruby = {
        hp = 50,
        r = 35
    },
    Emerald = {
        hp = 100,
        r = 50
    },
    Glowrock = {
        hp = 50,
        r = 100
    },
    Diamond = {
        hp = 250,
        r = 500
    },
    Insanium = {
        hp = 500,
        r = 5000
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