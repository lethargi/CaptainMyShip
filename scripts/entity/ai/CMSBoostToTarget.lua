package.path = package.path .. ";data/scripts/lib/?.lua"
-- package.path = package.path .. ";data/scripts/entity/?.lua"
-- package.path = package.path .. ";mods/CaptainMyShip/scripts/entity/ai/?.lua"

-- namespace CMSBoostToTarget
CMSBoostToTarget = {}

local CMS = require("mods/CaptainMyShip/scripts/entity/ai/CMSlib")

function CMSBoostToTarget.getUpdateInterval()
    return 0.5
end

function CMSBoostToTarget.update(timeStep)
	local my_targ = mycraft.selectedObject

    if onClient() then
		if my_targ and my_targ.index ~= mycraft.index then
            CMS.distanceControlToTarget(my_targ)
		end
    end
end

function CMSBoostToTarget.initialize()
    CMS.initialize()
end
