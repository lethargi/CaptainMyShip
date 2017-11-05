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
        print("helloWorld")
--         if Keyboard():keyPressed("f") then
--             print("f pressed")
--             for index, name in pairs(mycraft:getScripts()) do
--                 print(index,name)
--                 if string.match(name, "mods/CaptainMyShip/scripts/entity/ai/CMSCollisionRadar.lua") then
--                     mycraft:removeScript(index)
--                 end
--             end
--         end
    end
end
