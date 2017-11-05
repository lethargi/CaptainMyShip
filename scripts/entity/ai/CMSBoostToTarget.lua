package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/entity/?.lua"
package.path = package.path .. ";mods/CaptainMyShip/scripts/entity/ai/?.lua"

-- namespace CMSBoostToTarget
CMSBoostToTarget = {}
CMSBoostToTarget.done = false

local CMS = require("mods/CaptainMyShip/scripts/entity/ai/CMSlib")
local intialized = nil
local zeroedcontrol = false

function CMSBoostToTarget.getUpdateInterval()
    return 0.5
end

function CMSBoostToTarget.update(timeStep)
	CMSBoostToTarget.update_boosttotarget(timeStep)
end

function CMSBoostToTarget.initialize()
    CMSlib.initialize()
end

-- this function will be executed every frame on the cient only
function CMSBoostToTarget.update_boosttotarget(timeStep)

	local my_targ = mycraft.selectedObject

    if onClient() then
		if my_targ and my_targ.index ~= mycraft.index then
            CMS.distanceControlToTarget(my_targ)
		end
    end
end

