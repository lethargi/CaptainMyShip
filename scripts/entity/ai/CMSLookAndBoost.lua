package.path = package.path .. ";data/scripts/lib/?.lua"

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
    -- print(CMSLookAt.done,CMSBoostToTarget.done)
end
