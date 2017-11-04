package.path = package.path .. ";data/scripts/lib/?.lua"
--local boosttotarget  = require "data/scripts/entity/ai/cmsboosttotarget"
--local lookat  = require "data/scripts/entity/ai/cmslookat"
package.path = package.path .. ";data/scripts/entity/?.lua"
package.path = package.path .. ";mods/CaptainMyShip/scripts/entity/CaptainMyShip.lua"

require ("mods/CaptainMyShip/scripts/entity/ai/CMSBoostToTarget")
require ("mods/CaptainMyShip/scripts/entity/ai/CMSLookAt")

local lookatdone = false
local boostdone = false

function getUpdateInterval()
    return 1
end

-- this function will be executed every frame on the cient only
function update(timeStep)

    if onClient() then
		if not lookatdone then
			lookatdone = update_lookat(timeStep)
			boostdone = false
		elseif (not boostdone and lookatdone) then
			boostdone = update_boosttotarget(timeStep)
		elseif (boostdone and lookatdone) then
			lookatdone = update_lookat(timeStep)
		end
	end
end
