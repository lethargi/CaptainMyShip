package.path = package.path .. ";data/scripts/lib/?.lua"

-- namespace CMSLookAndBoost
CMSLookAndBoost = {}

local CMS = require("mods/CaptainMyShip/scripts/entity/ai/CMSlib")

-- local turndone = CMS.turnDone
-- local boosting = CMS.distanceControlDone

local turningUpdateRate = 0.025
local boostingUpdateRate = 0.5
local restingUpdateRate = 1.0

local updateRate = restingUpdateRate

local counter = 0

function CMSLookAndBoost.getUpdateInterval()
    return updateRate
end

function CMSLookAndBoost.initialize()
    return CMS.initialize()
end

-- this function will be executed every frame on the cient only
function CMSLookAndBoost.update(timeStep)

    if onClient() then
        counter = counter + 1
        local my_targ = mycraft.selectedObject
		if my_targ and my_targ.index ~= mycraft.index then

            -- local yaw, pitch = CMS.getYawPitchToTarget(my_targ)
            -- CMS.turnCheck(yaw,pitch)
            if not CMS.turnDone then
                updateRate = turningUpdateRate
                CMS.headingControlToTarget(my_targ)
                -- CMS.headingControl(yaw,pitch)
            elseif not CMS.distanceControlDone then
                local yaw, pitch = CMS.getYawPitchToTarget(my_targ)
                CMS.turnCheck(yaw,pitch)
                updateRate = boostingUpdateRate
                CMS.distanceControlToTarget(my_targ)
            else
                updateRate = restingUpdateRate
            end
        end
        print(counter,timeStep)
    end
--     counter = counter + 1
--     if counter == 3 then
--         updaterate = 3
--     end

    -- print(counter,updaterate)

-- 	if (not intialized) then
--         Entity():addScript("mods/CaptainMyShip/scripts/entity/ai/CMSLookAt.lua")
--         Entity():addScript("mods/CaptainMyShip/scripts/entity/ai/CMSBoostToTarget.lua")
--         initialized = true
--     end
    -- print(CMSLookAt.done,CMSBoostToTarget.done)
end
