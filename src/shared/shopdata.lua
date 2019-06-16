--[[---------------------------------
File:			\src\shared\shopdata.lua
Created On:		June 16th 2019, 02:00:19 AM
Author:			Chomboghai

Last Modified:	 June 16th 2019, 03:08:52 AM
Modified By:	 Chomboghai

Description:	

---------------CHANGES---------------
Date		Author		Comments
--]]---------------------------------

--| Services |--

--| Imports |--

--| Variables |--

--| Local Functions |--
local function defineNewPurchase(newDamage, cost)
    return {
        newdmg = newDamage,
        c = cost
    }
end
--| Module Definition |--
local shopdata = {
    MaxDamage = 25,
    [1] = defineNewPurchase(2, 10),
    [2] = defineNewPurchase(4, 20),
    [4] = defineNewPurchase(6, 35),
    [6] = defineNewPurchase(10, 50),
    [10] = defineNewPurchase(15, 150),
    [15] = defineNewPurchase(25, 250)
}

--| Module Return |--
return shopdata