package.path = package.path .. ";data/scripts/lib/?.lua"

-- namespace CMSLookAt
CMSLookAt = {}

CMSLookAt.yawdone = false
CMSLookAt.pitchdone = false
CMSLookAt.done = false
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
  transup = 2048,
  transdown = 4096,
  transleft = 512,
  transright = 1024
}
--]]
--local me = Player()
--local mycraft = Entity(me.craftIndex)
local intialized = nil


function CMSLookAt.getUpdateInterval()
    return 0.05
end

function CMSLookAt.update(timeStep)
	local isitdone = CMSLookAt.update_lookat(timeStep)
end

-- this function will be executed every frame on the cient only
function CMSLookAt.update_lookat(timeStep)

	if (not intialized) then
		me = Player()
		mycraft = Entity(me.craftIndex)
		my_v = Velocity(me.craftIndex) -- Velocity

		intialized = true
	end

	local my_targ = mycraft.selectedObject -- Entity
	local cms_lookatdone = false

    if onClient() then
		if my_targ and my_targ.index ~= mycraft.index then
            local myangularvel = my_v.localAngular
			local yaw, pitch = CMSLookAt.cms_getrottotarget(my_targ)
            -- local commands = get_command(yaw,pitch)
            local command = 0
            local des_yawrate = yaw - myangularvel.y
            local des_pitchrate = pitch - myangularvel.x

            if not CMSLookAt.yawdone then
                if des_yawrate > 0 then
                    command = command + 4
                else
                    command = command + 8
                end
            end
            if not CMSLookAt.pitchdone then
                if des_pitchrate > 0 then
                    command = command + 2
                else
                    command = command + 1
                end
            end
			mycraft.controlActions = command

--             print("====")
            -- print(yaw,pitch,mycraft.controlActions)

            -- check if the turns are done
			if math.abs(yaw) < 0.02 then
				CMSLookAt.yawdone = true
			else
				CMSLookAt.yawdone = false
			end

			if math.abs(pitch) < 0.02 then
				CMSLookAt.pitchdone = true
			else
				CMSLookAt.pitchdone = false
			end

            if CMSLookAt.pitchdone and CMSLookAt.yawdone then
				CMSLookAt.done = true
            else
				CMSLookAt.done = false
            end
            print(CMSLookAt.pitchdone,CMSLookAt.yawdone,CMSLookAt.done)
--             print(myangularvel.y,myangularvel.x)
            -- print(pitch,mycraft.controlActions)
            -- print(yaw,mycraft.controlActions)

            --[[
            local yaw_frac = yaw/math.pi
            local pitch_frac = pitch*(2/math.pi)


            -- 0.75 Kp gain on angle errors to get desired rate
            local des_yawrate = yaw_frac
            local des_pitchrate = pitch_frac


            -- estimate angle error
            local pitchrate_error = des_pitchrate - myangularvel.x
            local yawrate_error = des_yawrate - myangularvel.y

            -- set pitch command
            if (not pitchdone) then
                if (math.abs(pitchrate_error) > 0.08) then
                    if (pitchrate_error > 0) then
                        command = command + 1
                    elseif (pitchrate_error < 0) then
                        command = command + 2
                    end
                end
            end

            -- set yaw command
            if (not yawdone) then
                if (math.abs(yawrate_error) > 0.08) then
                    if (yawrate_error > 0) then
                        command = command + 8
                    elseif (yawrate_error < 0) then
                        command = command + 4
                    end
                end
            end


			mycraft.controlActions = command


            print("=======")
            print(timeStep,command)
            print(yaw,pitch)
            print(des_yawrate,des_pitchrate)
            print(yawrate_error,pitchrate_error)
            print(yawdone,pitchdone,cms_lookatdone)
            print("=======")
            --]]
		end
    end
	-- return cms_lookatdone
end

--- =========SUPPORTING FUNCTIONS======== ----------

function CMSLookAt.cms_getrottotarget(target)
	local myori = mycraft.orientation -- Matrix
	local mypos = mycraft.position.pos

	local targ_pos = target.position.pos
	local vec_totarg = targ_pos:__sub(mypos)
	local unit_vec_totarg = normalize(vec_totarg)
	local tranformed_unit_vec_totarg = myori:getInverse():transformNormal(unit_vec_totarg) -- THIS TRANSFORMS INERTIAL TO BODY!

	--- get relative euler angles to target; got this from stackexchage somewhere
	local yaw = math.atan2(tranformed_unit_vec_totarg.x,tranformed_unit_vec_totarg.z)
	local padj = math.sqrt(tranformed_unit_vec_totarg.x^2 + tranformed_unit_vec_totarg.z^2)
	local pitch = math.atan2(padj, tranformed_unit_vec_totarg.y) - math.pi/2
	return yaw, pitch
end

function CMSLookAt.getSign(x)
  return (x<0 and -1) or 1
end

function CMSLookAt.stopcont()
	mycraft.controlActions = 0
end
