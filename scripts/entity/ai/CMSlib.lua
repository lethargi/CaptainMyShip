package.path = package.path .. ";data/scripts/lib/?.lua"

-- namespace CMSlib
CMSlib = {}

function CMSlib.getrottotarget(target)
	local myori = mycraft.orientation -- Matrix
	local mypos = mycraft.position.pos

	local targ_pos = target.position.pos
	local vec_totarg = targ_pos:__sub(mypos)
	local unit_vec_totarg = normalize(vec_totarg)
	local tranformed_unit_vec_totarg = myori:getInverse():transformNormal(unit_vec_totarg) -- THIS TRANSFORMS INERTIAL TO BODY!

	--- get relative euler angles to target; got this from stackexchage somewhere
	local yaw = math.atan2(tranformed_unit_vec_totarg.x,tranformed_unit_vec_totarg.z)
	local padj = math.sqrt(tranformed_unit_vec_totarg.x^2 + tranformed_unit_vec_totarg.z^2)
	local pitch = math.atan2(padj, tranformed_unit_vec_totarg.y) - math.pi/2
	return yaw, pitch
end

function CMSlib.getSign(x)
  return (x<0 and -1) or 1
end

return CMSlib
