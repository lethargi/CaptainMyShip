package.path = package.path .. ";data/scripts/lib/?.lua"
--local boosttotarget  = require "data/scripts/entity/ai/cmsboosttotarget"
--local lookat  = require "data/scripts/entity/ai/cmslookat"
-- package.path = package.path .. ";data/scripts/entity/?.lua"
-- package.path = package.path .. ";mods/CaptainMyShip/scripts/entity/CaptainMyShip.lua"

-- require ("mods/CaptainMyShip/scripts/entity/ai/CMSBoostToTarget")
-- require ("mods/CaptainMyShip/scripts/entity/ai/CMSLookAt")
-- local lookatadded = false
-- local boostadded = false
-- local t = 0
local intialized = false

function getUpdateInterval()
    return 2
end

-- this function will be executed every frame on the cient only
function update(timeStep)

	if (not intialized) then
        Entity():addScript("mods/CaptainMyShip/scripts/entity/ai/CMSLookAt.lua")
        Entity():addScript("mods/CaptainMyShip/scripts/entity/ai/CMSBoostToTarget.lua")
        initialized = true
    end
    --[[
	if (not intialized) then
		me = Player()
		mycraft = Entity(me.craftIndex)
		my_v = Velocity(me.craftIndex) -- Velocity

		intialized = true
	end
	local my_targ = mycraft.selectedObject -- Entity

    if onClient() then
		if my_targ and my_targ.index ~= mycraft.index then
            if not CMSLookAt.done then
                CMSLookAt.update_lookat(timeStep)
            else
                mycraft.controlActions = 0
            end
-- 		if not lookatadded then
-- 			Entity():addScript("mods/CaptainMyShip/scripts/entity/ai/CMSLookAt.lua")
-- 			lookatadded = true
-- 			-- boostdone = false
-- 		elseif (not boostadded and lookatadded and CMSLookAt.done) then
-- 			Entity():addScript("mods/CaptainMyShip/scripts/entity/ai/CMSBoostToTarget.lua")
-- 			boostadded = true
-- 		elseif (CMSBoostToTarget.done and CMSLookAt.done) then
--             Entity():removeScript("mods/CaptainMyShip/scripts/entity/ai/CMSBoostToTarget.lua")
-- 			Entity():removeScript("mods/CaptainMyShip/scripts/entity/ai/CMSLookAt.lua")
-- 		end
        else
			mycraft.controlActions = 0
        end
        print(CMSLookAt.done)
	end
    --]]
end
