package.path = package.path .. ";data/scripts/lib/?.lua"

local yawdone = false
local pitchdone = false
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
--local me = Player()
--local mycraft = Entity(me.craftIndex)
local intialized = nil

function getUpdateInterval()
    return 1
end

function update(timeStep)
	local isitdone = update_lookat(timeStep)
end

-- this function will be executed every frame on the cient only
function update_lookat(timeStep)

	if (not intialized) then
		me = Player()
		mycraft = Entity(me.craftIndex)
		my_v = Velocity(me.craftIndex) -- Velocity		

		intialized = true
	end

	local my_targ = mycraft.selectedObject -- Entity
	local cms_lookatdone = false

    if onClient() then
		if my_targ and my_targ.index ~= mycraft.index then
			local yaw, pitch = cms_getrottotarget(my_targ)

			--- setup controller pulse frequency and duty %
			local contfreq = 10
			local contduty = 1
			--- do yaw and than pitch
			if not yawdone then
				trackangle(contfreq,contduty,0,0.025)
			elseif (yawdone and not pitchdone) then
				trackangle(contfreq,contduty,1,0.025)
			end

			--- check which motions have been done
			if math.abs(yaw) < 0.025 then
				yawdone = true
				cms_lookatdone = false
			else
				yawdone = false
				cms_lookatdone = false
			end
			if math.abs(pitch) < 0.025 then
				pitchdone = true
				cms_lookatdone = true
			else
				pitchdone = false
				cms_lookatdone = false
			end
		end
    end
	return cms_lookatdone
end

--- =========SUPPORTING FUNCTIONS======== ----------

function cms_getrottotarget(target)
	local myori = mycraft.orientation -- Matrix
	local mypos = mycraft.position.pos

	local targ_pos = target.position.pos
	local vec_totarg = targ_pos:__sub(mypos)
	local unit_vec_totarg = normalize(vec_totarg)
	local tranformed_unit_vec_totarg = myori:getInverse():transformNormal(unit_vec_totarg) -- THIS TRANSFORMS INERTIAL TO BODY!

	--- get relative euler angles to targer; got this from stackexchage someswhere			
	local yaw = math.atan2(tranformed_unit_vec_totarg.x,tranformed_unit_vec_totarg.z)
	local padj = math.sqrt(tranformed_unit_vec_totarg.x^2 + tranformed_unit_vec_totarg.z^2)
	local pitch = math.atan2(padj, tranformed_unit_vec_totarg.y) - math.pi/2
	return yaw, pitch
end

function getSign(x)
  return (x<0 and -1) or 1
end

function stopcont()
	mycraft.controlActions = 0
end

-- function that breaks down the second into little bits; there maybe another way...
function trackangle(freq,duty,angleerror,erroraxis)
	local t = 0.05
	local period = 1/freq
	local dt_cont = period*duty

	while (t<1) do
		deferredCallback(t,"tracker",angleerror,erroraxis)
		t = t + dt_cont
	end	
	deferredCallback(1,"stopcont")
end

-- this function is to complicating; needs more factoring and simplification
function tracker(erroraxis,anglethresh)
	-- set temporary variables to correct control values
	local ifneg, ifpos, angleerror, anglevel, anglevel_error,desiredrate

	local mypos = mycraft.position.pos
	local myori = mycraft.orientation -- Matrix
	local myangularvel = my_v.localAngular
    local my_targ = mycraft.selectedObject -- Entity

	-- do stuff if i have a target
	if my_targ and my_targ.index ~= mycraft.index then
		local yaw, pitch = cms_getrottotarget(my_targ)

		-- do some setup before giving the commands
		if (erroraxis == 0) then		--yaw axis
			-- hardcoding yaw commands
			ifneg = 4
			ifpos = 8
			angleerror = yaw
			anglevel = myangularvel.y
			errorfraction = math.abs(angleerror)/math.pi
		elseif (erroraxis == 1) then	--pitch axis
			-- hardcoding pitch commands
			ifneg = 2
			ifpos = 1
			angleerror = pitch
			anglevel = myangularvel.x
			errorfraction = math.abs(angleerror)/math.pi/2
		end
		-- find the desired rotation rate
		local errorfraction = math.abs(angleerror)/math.pi
		desiredrate = getSign(angleerror)*0.2
		if (errorfraction > 0.3) then
			desiredrate = getSign(angleerror)*1
		elseif (errorfraction > 0.1) then
			desiredrate = getSign(angleerror)*0.5
		elseif (math.abs(angleerror)<anglethresh) then
			desiredrate = 0
		end

		-- calculate the error between angular velocity
		anglevel_error = desiredrate - anglevel
		-- give rotation command
		if (math.abs(anglevel_error) > 0.08) then
			if (anglevel_error > 0) then
				mycraft.controlActions = ifneg
			elseif (anglevel_error < 0) then
				mycraft.controlActions = ifpos
			end
		else
			mycraft.controlActions = 0
		end
	end
end
