package.path = package.path .. ";data/scripts/lib/?.lua"
--local boosttotarget  = require "data/scripts/entity/ai/cmsboosttotarget"
--local lookat  = require "data/scripts/entity/ai/cmslookat"
package.path = package.path .. ";data/scripts/entity/?.lua"
package.path = package.path .. ";mods/CaptainMyShip/scripts/entity/CaptainMyShip.lua"

require ("mods/CaptainMyShip/scripts/entity/ai/CMSBoostToTarget")
require ("mods/CaptainMyShip/scripts/entity/ai/CMSLookAt")

local lookatadded = false
local boostadded = false

function getUpdateInterval()
    return 1
end

-- this function will be executed every frame on the cient only
function update(timeStep)

    if onClient() then
		if not lookatadded then
			Entity():addScript("mods/CaptainMyShip/scripts/entity/ai/CMSLookAt.lua")
			lookatadded = true
			-- boostdone = false
		elseif (not boostadded and lookatadded and CMSLookAt.done) then
			Entity():addScript("mods/CaptainMyShip/scripts/entity/ai/CMSBoostToTarget.lua")
			boostadded = true
		elseif (CMSBoostToTarget.done and CMSLookAt.done) then
            Entity():removeScript("mods/CaptainMyShip/scripts/entity/ai/CMSBoostToTarget.lua")
			Entity():removeScript("mods/CaptainMyShip/scripts/entity/ai/CMSLookAt.lua")
		end
        print(CMSLookAt.done,CMSBoostToTarget.done)
	end
end
