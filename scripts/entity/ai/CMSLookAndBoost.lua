package.path = package.path .. ";data/scripts/lib/?.lua"

-- namespace CMSLookAndBoost
CMSLookAndBoost = {}

local CMS = require("mods/CaptainMyShip/scripts/entity/ai/CMSlib")

local turningUpdateRate = 0.025
local boostingUpdateRate = 0.25
local restingUpdateRate = 1.0

local updateRate = restingUpdateRate

function CMSLookAndBoost.getUpdateInterval()
    return updateRate
end

function CMSLookAndBoost.initialize()
    return CMS.initialize()
end

-- this function will be executed every frame on the cient only
function CMSLookAndBoost.update(timeStep)
    if onClient() then
        mycraft.controlActions = 0
        mycraft.desiredVelocity = 0
        local my_targ = mycraft.selectedObject
		if my_targ and my_targ.index ~= mycraft.index then
            mycraft.controlActions = 0
            if not CMS.turnDone then
                updateRate = turningUpdateRate
                CMS.headingControlToTarget(my_targ)
            elseif not CMS.distanceControlDone then
                updateRate = boostingUpdateRate
                local yaw, pitch = CMS.getYawPitchToTarget(my_targ)
                CMS.turnCheck(yaw,pitch)
                CMS.distanceControlToTarget(my_targ)
            else
                updateRate = restingUpdateRate
            end
        end
    end
end
