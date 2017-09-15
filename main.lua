-- simple particle gravity

--http://board.flashkit.com/board/showthread.php?629375-HELP-2D-gravity-simulator-multiple-mass-points
--http://board.flashkit.com/board/showthread.php?610432-Advanced-Gravity&p=3195515&viewfull=1#post3195515

--[[
F=G*m*M/(r*r)
F=force in the direction of the object.
G=Gravitational constant=6.67E-11
m=mass of small object
M=mass of big object
r=distance (radius) between the objects centers
]]--

print( "Tap to generate gravity well." )
print( "Draw to generate particles." )
print( "5 particles will spawn every 10 seconds." )

display.setStatusBar(display.HiddenStatusBar)

sWidth, sHeight = display.contentWidth, display.contentHeight

local universe = display.newGroup()
local gravities = display.newGroup()
local particles = display.newGroup()
universe:insert(gravities)
universe:insert(particles)
--universe.xScale, universe.yScale = .5, .5

local count = display.newText( "0", sWidth/2, 20, nil, 50 )

-- create gravities
function newGravity(x,y,g)
	local circle = display.newCircle(gravities, x, y, g)
	circle:setFillColor(255,0,0)
	
	-- our magic constant
	circle.G = g
	
	return circle
end

max = 0
-- create particles
function newParticle(x,y,vx,vy,r,max)
	local circle = display.newCircle(particles, x, y, r)
	circle:setFillColor(0,255,0)
	
	-- set up initial velocity
	circle.xv = vx
	circle.yv = vy
	
	-- set speed limit
	circle.max = max or 30
	
	-- we use scale to represent mass, higher mass requires greater force to move...
--	circle.mass = 200/gravities[1].G
	
	function circle:update()
		for i=1, gravities.numChildren do
			local gravity = gravities[i]
			
			-- find distance squared
			local xd = gravity.x - circle.x
			local yd = gravity.y - circle.y
			local d2 = xd*xd + yd*yd
			
			-- remove if too close to sun
			if (math.sqrt(d2) < 10) then
				circle:removeSelf()
				return
			end
			
			-- calculate force
			local xf = xd / d2
			local yf = yd / d2
			
			-- apply force to velocity
			circle.xv = circle.xv + xf*gravity.G -- /circle.mass
			circle.yv = circle.yv + yf*gravity.G -- /circle.mass
		end
		
		-- throttle velocity
		local len = math.sqrt(circle.xv*circle.xv + circle.yv*circle.yv)
		if (len > circle.max) then
			local f = circle.max / len
			circle.xv = circle.xv * f
			circle.yv = circle.yv * f
			-- print("limited: ",math.sqrt(circle.xv*circle.xv + circle.yv*circle.yv))
		end
		
		-- apply velocity to position
		circle.x = circle.x + circle.xv
		circle.y = circle.y + circle.yv
	end
	
	return circle
end

newGravity(sWidth/3*2,sHeight/2,50)
--newGravity(sWidth/4*3,sHeight/2,50)
--newGravity(350,200,5)
speedLimit = 12

local function generate()
	for i=1, 5 do
		newParticle( math.random(100,200),math.random(100,200), math.random(1,7),math.random(1,7), 15, speedLimit )
	end
end
timer.performWithDelay( 10000, generate, 0 )
generate()

function enterFrame()
	for i=particles.numChildren, 1, -1 do
		particles[i]:update()
	end
	count.text = particles.numChildren
end
Runtime:addEventListener("enterFrame", enterFrame)

function tap(e)
	newGravity(e.x,e.y,50)
	return true
end
Runtime:addEventListener("tap",tap)

function touch(e)
	if (e.phase == "moved") then
		newParticle(e.x,e.y, math.random(-5,5),math.random(-5,5), 15, speedLimit )
	end
	return true
end
Runtime:addEventListener("touch",touch)
