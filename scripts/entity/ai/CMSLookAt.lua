package.path = package.path .. ";data/scripts/lib/?.lua"

-- namespace CMSLookAt
CMSLookAt = {}

local CMS = require("mods/CaptainMyShip/scripts/entity/ai/CMSlib")

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
local intialized = nil
local zeroedcontrol = false

function CMSLookAt.getUpdateInterval()
    return 0.02
end

function CMSLookAt.update(timeStep)
	CMSLookAt.update_lookat(timeStep)
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

    if onClient() then
		if my_targ and my_targ.index ~= mycraft.index then
            local command = 0
            local myangularvel = my_v.localAngular
			local yaw, pitch = CMS.getrottotarget(my_targ)
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
                zeroedcontrol = false
            end

            -- apply control action
            if not CMSLookAt.done then
                mycraft.controlActions = command
            elseif CMSLookAt.done and not zeroedcontrol then
                mycraft.controlActions = 0
                zeroedcontrol = true
            end

		end
    end
end


