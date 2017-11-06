package.path = package.path .. ";data/scripts/lib/?.lua"
require ("stringutility")

-- namespace CMSCollisionRadar
CMSCollisionRadar = {}

local CMS = require("mods/CaptainMyShip/scripts/entity/ai/CMSlib")

function CMSCollisionRadar.getUpdateInterval()
    return 0.5
end

function CMSCollisionRadar.initialize()
    CMS.initialize()
end

function CMSCollisionRadar.update(timeStep)
    if onClient() then
    end
end
