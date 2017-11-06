package.path = package.path .. ";data/scripts/lib/?.lua"
-- package.path = package.path .. ";data/scripts/entity/?.lua"
-- package.path = package.path .. ";mods/CaptainMyShip/scripts/entity/ai/?.lua"

-- namespace CMSBoostToTarget
CMSBoostToTarget = {}

local CMS = require("mods/CaptainMyShip/scripts/entity/ai/CMSlib")

function CMSBoostToTarget.getUpdateInterval()
    return 0.25
end

function CMSBoostToTarget.initialize()
    CMS.initialize()
end

function CMSBoostToTarget.update(timeStep)
    if onClient() then
        local my_targ = mycraft.selectedObject
		if my_targ and my_targ.index ~= mycraft.index then
            mycraft.controlActions = 0
            mycraft.desiredVelocity = 0
            CMS.distanceControlToTarget(my_targ)
		end
        -- print(CMS.distanceControlDone)
    end
end

