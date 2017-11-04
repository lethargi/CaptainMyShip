package.path = package.path .. ";data/scripts/lib/?.lua"

require ("stringutility")

function getIcon()
    return "data/textures/icons/freedom-dove.png"
end

local numButtons = 0
function ButtonRect(w, h)

    local width = w or 230
    local height = h or 35

    local space = math.floor((window.size.y - 80) / (height + 10))

    local row = math.floor(numButtons % space)
    local col = math.floor(numButtons / space)

    local lower = vec2((width + 10) * col, (height + 10) * row)
    local upper = lower + vec2(width, height)

    numButtons = numButtons + 1

    return Rect(lower, upper)
end

function onSectorChanged()
    -- only required on server, client script gets newly created when changing the sector
	removeSpecialOrders()
end

function initialize()

end

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function interactionPossible(playerIndex, option)
    -- Only works if your in your own craft
    if Entity().index ~= Player().craftIndex then
        return false
    end

    -- ordering other crafts can only work on your own crafts
    if Faction().index ~= playerIndex then
        return false
    end	
    return true
end

-- create all required UI elements for the client side
function initUI()
	local res = getResolution()
	local size = vec2(250, 300)

	local menu = ScriptUI()
	window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))  

	window.caption = "CaptainMyShip"
	window.showCloseButton = 1
	window.moveable = 1

	menu:registerWindow(window, "CaptainMyShip")

	local tabbedWindow = window:createTabbedWindow(Rect(vec2(10, 10), size - 10))
    local tab = tabbedWindow:createTab("Entity", "data/textures/icons/winged-shield.png", "Ship Commands")

    numButtons = 0
-- 	local subWindow = menu:createWindow(Rect(vec2(10, 10), size - 10))
-- 	subWindow.center = window.center
-- 	numButtons = 0

	tab:createButton(ButtonRect(), "RemoveOrders", "onIdleButtonPressed")
	tab:createButton(ButtonRect(), "LookAt", "onLookAtPressed")
	tab:createButton(ButtonRect(), "Boost2Targ", "boosttotargetButtonPressed")
	tab:createButton(ButtonRect(), "LookAndBoost", "lookandboostButtonPressed")

end

function cms_checkCaptain()
    local captains = Entity(Player().craftIndex):getCrewMembers(CrewProfessionType.Captain)
    if captains and captains > 0 then
        return true
    end
	return false
end

function printnocaptain()
    Player():sendChatMessage("", 1, "You are the only captain aboard sir!"%_t)
	return
end

function onIdleButtonPressed()
    ScriptUI():stopInteraction()
    removeSpecialOrders()
    return
end

function onLookAtPressed()
	removeSpecialOrders()
    if onClient() then
		if cms_checkCaptain() then
			Entity():addScript("mods/CaptainMyShip/scripts/entity/ai/CMSLookAt.lua")
		else
	        invokeServerFunction("printnocaptain")
		end
        ScriptUI():stopInteraction()
		return
	end
end

function boosttotargetButtonPressed()
	removeSpecialOrders()
    if onClient() then
		if cms_checkCaptain() then
			Entity():addScript("mods/CaptainMyShip/scripts/entity/ai/CMSBoostToTarget.lua")
		else
	        invokeServerFunction("printnocaptain")		
		end
        ScriptUI():stopInteraction()
		return
	end
end

function lookandboostButtonPressed()
	removeSpecialOrders()
    if onClient() then
		if cms_checkCaptain() then
			Entity():addScript("mods/CaptainMyShip/scripts/entity/ai/CMSLookAndBoost.lua")
		else
	        invokeServerFunction("printnocaptain")		
		end
        ScriptUI():stopInteraction()
		return
	end
end

function removeSpecialOrders()

    local entity = Entity()

	if entity then
		for index, name in pairs(entity:getScripts()) do
		    if string.match(name, "data/scripts/entity/ai/") then
		        entity:removeScript(index)
				--print("Removed: ", index, name)
		    end
		    if string.match(name, "mods/CaptainMyShip/scripts/entity/ai/") then
		        entity:removeScript(index)
				--print("Removed: ", index, name)
		    end
		end
	end
end

-- this function will be executed every frame both on the server and the client
--function update(timeStep)
--
--end
--
---- this function gets called every time the window is shown on the client, ie. when a player presses F
--function onShowWindow()
--
--end
--
---- this function gets called every time the window is shown on the client, ie. when a player presses F
--function onCloseWindow()
--
--end
