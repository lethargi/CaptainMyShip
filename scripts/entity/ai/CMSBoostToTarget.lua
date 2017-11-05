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

-- this function will be executed every frame on the cient only
function CMSBoostToTarget.update_boosttotarget(timeStep)
	if (not intialized) then
		me = Player()
		mycraft = Entity(me.craftIndex)
		my_v = Velocity(me.craftIndex) -- Velocity
		myeng = Engine(me.craftIndex)
		myenergy = EnergySystem(me.craftIndex)

		myaccl = myeng.acceleration
        mybrake = myeng.brakeThrust
		intialized = true
	end

	local my_targ = mycraft.selectedObject

    if onClient() then
		if my_targ and my_targ.index ~= mycraft.index then

			local yaw, pitch = CMS.getrottotarget(my_targ)
			local dist_totarg = my_targ:getNearestDistance(mycraft)
            local desiredVelocity
            local vel_ratio, vel_error
            local cur_v = my_v.linear
            local nextVelocity = 100

            local energy_check = myenergy.productionRate-myenergy.requiredEnergy

			if ((math.abs(yaw)<0.1) and (math.abs(pitch)<0.1)) then

                if (dist_totarg < 300) then
                    CMSBoostToTarget.done = true
                    desiredVelocity = 0
                elseif (dist_totarg < 800) then
                    desiredVelocity = math.sqrt(2*mybrake*(dist_totarg-300))
                else
                    desiredVelocity = math.sqrt((myeng.maxVelocity*0.75)^2 + 2*mybrake*(dist_totarg-800))
                end

                -- find the error and ratio if i want to set to max velocity
                if desiredVelocity then
                    zeroedcontrol = false
                    vel_ratio = desiredVelocity/myeng.maxVelocity
                    vel_error = desiredVelocity - cur_v
                else
                    vel_ratio = 0
                    vel_error = 0
                end

                -- take control action
                if (desiredVelocity > 0) then
                    mycraft.desiredVelocity = vel_ratio

                    -- boosting logic
                    if (energy_check>0) then
                        if ((vel_error > 0) and ((vel_ratio > 1) or  (cur_v/desiredVelocity < 0.8))) then
                            mycraft.controlActions = 256
                        else
                            mycraft.controlActions = 0
                        end
                    else
                        mycraft.controlActions = 0
                    end
                elseif not zeroedcontrol then
                    mycraft.desiredVelocity = 0
                    mycraft.controlActions = 0
                    zeroedcontrol = true
                end
			else
				mycraft.desiredVelocity = 0
				mycraft.controlActions = 0
			end
		end
    end
end

