package.path = package.path .. ";data/scripts/lib/?.lua"

-- namespace CMSlib
CMSlib = {}

--[[
local ControlActionMap = {
  rest = 0,
  pitchup = 1,
  pitchdown = 2,
  yawleft = 4,
  yawright = 8,
  rollccw = 16,
  rollcw = 32,
  boost = 256,
  transleft = 512,
  transright = 1024
  transup = 2048,
  transdown = 4096,
}
--]]

function CMSlib.getYawPitchToTarget(target)

	local targ_pos = target.position.pos
	local uvectotarg_ins = CMSlib.getUvecToPos(targ_pos)
	local uvectotarg_bdy = CMSlib.transformInsToBdy(uvectotarg_ins)

    return CMSlib.getYawPitchToVec(uvectotarg_bdy)
end

function CMSlib.transformInsToBdy(invec)
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

function CMSlib.initialize()
    me = Player()
    mycraft = Entity(me.craftIndex)
    my_v = Velocity(me.craftIndex) -- Velocity

    myeng = Engine(me.craftIndex)
    myenergy = EnergySystem(me.craftIndex)

    myaccl = myeng.acceleration
    mybrake = myeng.brakeThrust

    CMSlib.yawdone = false
    CMSlib.pitchdone = false
    CMSlib.turnDone = false
    CMSlib.zeroedcontrol = false

    CMSlib.distanceControlDone = false
    CMSlib.thrusterBrakeDone = false
end
----------------- CONTROLLERS


function CMSlib.headingControlToTarget(atarget)
    local yaw, pitch = CMSlib.getYawPitchToTarget(atarget)
    CMSlib.turnCheck(yaw,pitch)
    CMSlib.headingControl(yaw,pitch)
end

function CMSlib.headingControl(inyaw,inpitch,inKp_rate)

    -- local command = 0
    local myangularvel = my_v.localAngular

    local Kp_rate = inKp_rate or 2
    local des_yawrate = Kp_rate*(inyaw - myangularvel.y)
    local des_pitchrate = Kp_rate*(inpitch - myangularvel.x)

    if not CMSlib.yawdone then
        if math.abs(des_yawrate) > 0.01 then
            if des_yawrate > 0 then
                mycraft.controlActions = mycraft.controlActions + 4
            else
                mycraft.controlActions = mycraft.controlActions + 8
            end
        end
    end
    if not CMSlib.pitchdone then
        if math.abs(des_pitchrate) > 0.01 then
            if des_pitchrate > 0 then
                mycraft.controlActions = mycraft.controlActions + 2
            else
                mycraft.controlActions = mycraft.controlActions + 1
            end
        end
    end

end

function CMSlib.turnCheck(inyaw,inpitch,thresh)
    -- check if the turns are done
    local yawthresh = thresh or 0.025
    local pitchthresh = thresh or 0.025
    if math.abs(inyaw) < yawthresh then
        CMSlib.yawdone = true
    else
        CMSlib.yawdone = false
    end

    if math.abs(inpitch) < pitchthresh then
        CMSlib.pitchdone = true
    else
        CMSlib.pitchdone = false
    end

    if CMSlib.pitchdone and CMSlib.yawdone then
        CMSlib.turnDone = true
    elseif ((math.abs(inpitch) > pitchthresh*1.75) or (math.abs(inyaw) > yawthresh*1.75)) then
        CMSlib.turnDone = false
        CMSlib.zeroedcontrol = false
    end

end

--------------- SPEED/position CONTROL

function CMSlib.distanceControlToTarget(atarget)
    local yaw, pitch = CMSlib.getYawPitchToTarget(atarget)
    CMSlib.turnCheck(yaw,pitch)
    local dist_totarg = atarget:getNearestDistance(mycraft)

    if CMSlib.turnDone then
        CMSlib.distanceControl(dist_totarg,300,true)
    else
        mycraft.desiredVelocity = 0
    end
end

function CMSlib.distanceControl(distanceToPoint,stopdistance,useboost)
    local desiredVelocity
    if (distanceToPoint < stopdistance) then
        CMSlib.distanceControlDone = true
        desiredVelocity = 0
    else
        CMSlib.distanceControlDone = false
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
        CMSlib.zeroedcontrol = false
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
                mycraft.controlActions = mycraft.controlActions + 256
            end
        end
    elseif not CMSlib.zeroedcontrol then
        mycraft.desiredVelocity = 0
        -- mycraft.controlActions = 0
        CMSlib.zeroedcontrol = true
    end
end

function CMSlib.retroBurn(useboost)
    local cur_v = my_v.linear
    local energy_check = myenergy.productionRate-myenergy.requiredEnergy
    print(cur_v/myeng.brakeThrust)
    if (cur_v/myeng.brakeThrust > 1)  then
        local Vuvec = normalize(my_v.velocityf)
        local retrouvec = Vuvec:__unm()
        local retrouvec_bdy = CMSlib.transformInsToBdy(retrouvec)

        local yaw,pitch  = CMSlib.getYawPitchToVec(retrouvec_bdy)
        CMSlib.turnCheck(yaw,pitch)
        CMSlib.headingControl(yaw,pitch,8)
        if ((math.abs(yaw) < 0.4) and (math.abs(pitch) < 0.4)) then
            local a = 1 - (math.abs(yaw)-0.025)/(0.375)  --becomes bigger as heading approaches target
            local b = cur_v/myeng.maxVelocity   -- value of the current velocity ratio
            if (b < 0.5) then
                a = 0.5*a
            end
            mycraft.desiredVelocity = a
            if (cur_v > 0.75*myeng.maxVelocity) and useboost and (energy_check>0) then
                mycraft.controlActions = mycraft.controlActions + 256
            end
        end
    end
end

return CMSlib
