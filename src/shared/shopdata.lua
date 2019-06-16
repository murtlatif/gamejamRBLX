--[[---------------------------------
File:			\src\shared\shopdata.lua
Created On:		June 16th 2019, 02:00:19 AM
Author:			Chomboghai

Last Modified:	 June 16th 2019, 05:06:46 AM
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
    MaxDamage = 50,
    [1] = defineNewPurchase(2, 10),
    [2] = defineNewPurchase(3, 35),
    [3] = defineNewPurchase(5, 75),
    [5] = defineNewPurchase(8, 150),
    [8] = defineNewPurchase(10, 250),
    [10] = defineNewPurchase(15, 500),
    [15] = defineNewPurchase(20, 1000),
    [20] = defineNewPurchase(25, 2500),
    [25] = defineNewPurchase(30, 5000),
    [30] = defineNewPurchase(40, 17500),
    [40] = defineNewPurchase(50, 50000)
}

--| Module Return |--
return shopdata