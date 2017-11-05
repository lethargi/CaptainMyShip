package.path = package.path .. ";data/scripts/lib/?.lua"

-- namespace CMSLookAt
CMSLookAt = {}

local CMS = require("mods/CaptainMyShip/scripts/entity/ai/CMSlib")

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

function CMSLookAt.getUpdateInterval()
    return 0.02
end

function CMSLookAt.update(timeStep)
	CMSLookAt.update_lookat(timeStep)
end

function CMSLookAt.initialize()
    CMSlib.initialize()
end

-- this function will be executed every frame on the cient only
function CMSLookAt.update_lookat(timeStep)

    if onClient() then
        local my_targ = mycraft.selectedObject

		if my_targ and my_targ.index ~= mycraft.index then
			local yaw, pitch = CMS.getYawPitchToTarget(my_targ)
            CMS.headingControl(yaw,pitch)
		end
    end
end

