package.path = package.path .. ";data/scripts/lib/?.lua"

-- namespace CMSLookAt
CMSLookAt = {}

local CMS = require("mods/CaptainMyShip/scripts/entity/ai/CMSlib")

function CMSLookAt.getUpdateInterval()
    return 0.025
end

function CMSLookAt.update(timeStep)
	CMSLookAt.update_lookat(timeStep)
end

function CMSLookAt.initialize()
    CMS.initialize()
end

-- this function will be executed every frame on the cient only
function CMSLookAt.update_lookat(timeStep)

    if onClient() then
        local my_targ = mycraft.selectedObject

		if my_targ and my_targ.index ~= mycraft.index then
            CMS.headingControlToTarget(my_targ)
		end
    end
end

