package.path = package.path .. ";data/scripts/lib/?.lua"

-- namespace CMSRetroBurn
CMSRetroBurn = {}

local CMS = require("mods/CaptainMyShip/scripts/entity/ai/CMSlib")

local turningUpdateRate = 0.025
local brakingUpdateRate = 0.25
local restingUpdateRate = 1.0

local updateRate = turningUpdateRate

local counter = 0

function CMSRetroBurn.getUpdateInterval()
    return updateRate
end

function CMSRetroBurn.initialize()
    return CMS.initialize()
end

function CMSRetroBurn.update(timeStep)
    if onClient() then
        local cur_v = my_v.linear
        if cur_v/myeng.brakeThrust > 1  then
            local Vuvec = normalize(my_v.velocityf)
            local retrouvec = Vuvec:__unm()
            local retrouvec_bdy = CMS.transformInsToBdy(retrouvec)

            local yaw,pitch  = CMS.getYawPitchToVec(retrouvec_bdy)
            CMS.turnCheck(yaw,pitch,math.pi/8)
            if not CMS.turnDone then
                -- updateRate = turningUpdateRate
                CMS.headingControl(yaw,pitch,8)
                mycraft.desiredVelocity = 0
            else
                -- updateRate = brakingUpdateRate
                CMS.thrusterBrake(true)
--             else
--                 updateRate = restingUpdateRate
--                 mycraft.desiredVelocity = 0
--                 mycraft.controlActions = 0
            end
        end
        -- vvec_bdy =
--         print("===")
--         print(Vuvec:__tostring())
--         print(retrouvec:__tostring())
--         print(retrouvec_bdy:__tostring())
        -- local my_targ = mycraft.selectedObject
-- 		if my_targ and my_targ.index ~= mycraft.index then
--             if not CMS.turnDone then
--                 updateRate = turningUpdateRate
--                 CMS.headingControlToTarget(my_targ)
--             elseif not CMS.distanceControlDone then
--                 updateRate = boostingUpdateRate
--                 local yaw, pitch = CMS.getYawPitchToTarget(my_targ)
--                 CMS.turnCheck(yaw,pitch)
--                 CMS.distanceControlToTarget(my_targ)
--             else
--                 updateRate = restingUpdateRate
--             end
--         end
    end
end
