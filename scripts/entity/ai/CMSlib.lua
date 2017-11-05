package.path = package.path .. ";data/scripts/lib/?.lua"

-- namespace CMSlib
CMSlib = {}

function CMSlib.getYawPitchToTarget(target)

	local targ_pos = target.position.pos
	local uvectotarg_ins = CMSlib.getUvecToPos(targ_pos)
	local uvectotarg_bdy = CMSlib.transfromInsToBdy(uvectotarg_ins)

    return CMSlib.getYawPitchToVec(uvectotarg_bdy)
end

function CMSlib.transfromInsToBdy(invec)
	local myori = mycraft.orientation -- Matrix
    local T_ins2bdy = myori:getInverse()
	local outvec = T_ins2bdy:transformNormal(invec) -- THIS TRANSFORMS INERTIAL TO BODY!
    return outvec
end

function CMSlib.getYawPitchToVec(invec)
	--- get relative euler angles to target; got this from stackexchage somewhere
	local yaw = math.atan2(invec.x,invec.z)
	local padj = math.sqrt(invec.x^2 + invec.z^2)
	local pitch = math.atan2(padj, invec.y) - math.pi/2
	return yaw, pitch
end

function CMSlib.getUvecToPos(inpos)
	local mypos = mycraft.position.pos
	local vectopos = inpos:__sub(mypos)
	local uvectopos = normalize(vectopos)
    return uvectopos
end

function CMSlib.getSign(x)
  return (x<0 and -1) or 1
end


-- CMSlib.initalized = false
function CMSlib.initialize()
	-- if (not CMSlib.intialized) then
    me = Player()
    mycraft = Entity(me.craftIndex)
    my_v = Velocity(me.craftIndex) -- Velocity

    myeng = Engine(me.craftIndex)
    myenergy = EnergySystem(me.craftIndex)

    myaccl = myeng.acceleration
    mybrake = myeng.brakeThrust

    -- CMSlib.initalized = true
	-- end
end

----------------- CONTROLLERS

CMSlib.yawdone = false
CMSlib.pitchdone = false
CMSlib.turndone = false
CMSlib.zeroedcontrol = false

function CMSlib.headingControl(inyaw,inpitch)

    local command = 0
    local myangularvel = my_v.localAngular

    local des_yawrate = 2*(inyaw - myangularvel.y)
    local des_pitchrate = 2*(inpitch - myangularvel.x)

    if not CMSlib.yawdone then
        if math.abs(des_yawrate) > 0.02 then
            if des_yawrate > 0 then
                command = command + 4
            else
                command = command + 8
            end
        end
    end
    if not CMSlib.pitchdone then
        if math.abs(des_pitchrate) > 0.02 then
            if des_pitchrate > 0 then
                command = command + 2
            else
                command = command + 1
            end
        end
    end

    -- check if the turns are done
    if math.abs(inyaw) < 0.05 then
        CMSlib.yawdone = true
    else
        CMSlib.yawdone = false
    end

    if math.abs(inpitch) < 0.05 then
        CMSlib.pitchdone = true
    else
        CMSlib.pitchdone = false
    end

    if CMSlib.pitchdone and CMSlib.yawdone then
        CMSlib.turndone = true
    else
        CMSlib.turndone = false
        CMSlib.zeroedcontrol = false
    end

    -- apply control action
    if not CMSlib.turndone then
        mycraft.controlActions = command
    elseif not CMSlib.zeroedcontrol then
        mycraft.controlActions = 0
        CMSlib.zeroedcontrol = true
    end
    print(CMSlib.yawdone,CMSlib.pitchdone,CMSlib.turndone,mycraft.controlActions)
end

--------------- SPEED/position CONTROL

function CMSlib.distanceControlToTarget(atarget)
    local yaw, pitch = CMSlib.getYawPitchToTarget(atarget)
    local dist_totarg = atarget:getNearestDistance(mycraft)

    if ((math.abs(yaw)<0.1) and (math.abs(pitch)<0.1)) then
        CMSlib.distanceControl(dist_totarg,300,true)
    else
        mycraft.desiredVelocity = 0
        mycraft.controlActions = 0
    end
end

function CMSlib.distanceControl(distanceToPoint,stopdistance,useboost)
    local desiredVelocity
    if (distanceToPoint < stopdistance) then
        CMSlib.distanceControlDone = true
        desiredVelocity = 0
    else
        desiredVelocity = math.sqrt(2*mybrake*(distanceToPoint-stopdistance))
    end
    CMSlib.speedControl(desiredVelocity,useboost)
end

function CMSlib.speedControl(desiredVelocity,useboost)
    -- find the error and ratio if i want to set to max velocity
    local vel_ratio, vel_error
    local cur_v = my_v.linear
    local energy_check = myenergy.productionRate-myenergy.requiredEnergy

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
        if (energy_check>0) and useboost then
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
end

return CMSlib
