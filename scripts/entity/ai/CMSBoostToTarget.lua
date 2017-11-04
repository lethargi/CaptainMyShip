package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/entity/?.lua"
package.path = package.path .. ";mods/CaptainMyShip/scripts/entity/CaptainMyShip.lua"

require ("mods/CaptainMyShip/scripts/entity/ai/CMSLookAt")

-- namespace CMSBoostToTarget
CMSBoostToTarget = {}
CMSBoostToTarget.done = false

local intialized = nil

function CMSBoostToTarget.getUpdateInterval()
    return 1
end

function CMSBoostToTarget.update(timeStep)
	local isitdone = CMSBoostToTarget.update_boosttotarget(timeStep)
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
		if (myeng.brakeThrust > myaccl*0.75) then
			mybrake = myeng.brakeThrust
		else
			mybrake = myaccl*0.75
		end
		intialized = true
	end

	local my_targ = mycraft.selectedObject
	local cms_boostdone = false

    if onClient() then
		if my_targ and my_targ.index ~= mycraft.index then

			local yaw, pitch = CMSLookAt.cms_getrottotarget(my_targ)
			local dist_totarg = my_targ:getNearestDistance(mycraft)

			--- heading check; make sure almost looking at right direction
			if ((math.abs(yaw)<0.2) and (math.abs(pitch)<0.2)) then
				cms_boostdone = CMSBoostToTarget.velocitycontroller(5,1)
			else
				mycraft.desiredVelocity = 0
				mycraft.controlActions = 0
				cms_boostdone = true
			end
		end
    end
	return cms_boostdone
end

--- =========SUPPORTING FUNCTIONS======== ----------

-- function that breaks down the second into little bits; there maybe another way...
function CMSBoostToTarget.velocitycontroller(freq,duty)
	local t = 0.05
	local period = 1/freq
	local dt_cont = period*duty
	local dt_rest = period-dt_cont

	while (t<1) do
		deferredCallback(t,"controlvelocity")
		t = t + dt_cont
	end
end

function CMSBoostToTarget.controlvelocity()
	local cur_v = my_v.linear
	local donecheck = false
	local my_targ = mycraft.selectedObject

	local nextDistrange, nextVelocity

	if my_targ and my_targ.index ~= mycraft.index then
		local dist_totarg = my_targ:getNearestDistance(mycraft)

		---set desired velocity; kinda discretized selection; also set next target for control
		---can try PID or sth
		local desiredVelocity=0;
		if (dist_totarg < 200) then
			donecheck = true
            CMSBoostToTarget.done = true
			desiredVelocity = 0
			nextVelocity = 0
			nextDistrange = 1
		elseif (dist_totarg < 400) then
			desiredVelocity = 20
			nextVelocity = 0
			nextDistrange = 200
		elseif (dist_totarg < 1000) then
			desiredVelocity = 75
			nextVelocity = 20
			nextDistrange = 400
		else
			desiredVelocity = myeng.maxVelocity
			nextVelocity = 75
			nextDistrange = 1000
		end

		-- calculate the maximum possible velocity based on set boundaries
		local distleft = dist_totarg - nextDistrange
		local curmaxvel = math.sqrt(nextVelocity^2 + 2*mybrake*distleft)
		local vel_ratio, vel_error

		-- find the error and ratio if i want to set to max velocity
		if curmaxvel then
			vel_ratio = curmaxvel/myeng.maxVelocity
			vel_error = curmaxvel - cur_v
		else
			vel_ratio = 0
			vel_error = 0
		end

		local energy_check = myenergy.productionRate-myenergy.requiredEnergy
		-- take control action
		if ((vel_error > 0) and (not donecheck)) then
			if (vel_ratio > 1) then
				mycraft.desiredVelocity = 1
				if (energy_check>0) then
					mycraft.controlActions = 256
				end
			else
				mycraft.desiredVelocity = vel_ratio
				if ((cur_v/desiredVelocity < 0.8) and (energy_check>0)) then
					mycraft.controlActions = 256
				end
			end
		elseif ((math.abs(vel_ratio) < 1) and (not donecheck)) then
			mycraft.controlActions = 0
			mycraft.desiredVelocity = vel_ratio
		else
			mycraft.controlActions = 0
			mycraft.desiredVelocity = 0
			--may implement retro-burn for big errors ??
		end

	end
	return donecheck
end
