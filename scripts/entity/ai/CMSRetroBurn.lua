package.path = package.path .. ";data/scripts/lib/?.lua"

-- namespace CMSRetroBurn
CMSRetroBurn = {}

local CMS = require("mods/CaptainMyShip/scripts/entity/ai/CMSlib")

local turningUpdateRate = 0.025

local updateRate = turningUpdateRate

function CMSRetroBurn.getUpdateInterval()
    return updateRate
end

function CMSRetroBurn.initialize()
    return CMS.initialize()
end

function CMSRetroBurn.update(timeStep)
    if onClient() then
        mycraft.controlActions = 0
        mycraft.desiredVelocity = 0
        CMS.retroBurn(true)
        print(mycraft.controlActions,mycraft.desiredVelocity)
    end
end
