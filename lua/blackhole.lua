--Effects for the blackhole
--Complete credit to Maurice for this
TRANS = {};
function TRANS.Init()
	const = {}
	const.steps = 200
	const.halfwidth = love.graphics.getWidth()/2
	const.halfheight = love.graphics.getHeight()/2
	
	const.circledelay = 0.3
	const.circlespeed = 0.7
	
	const.remove = 0.7
	
	circletimer = 0
	
	circles = {}
	
	love.graphics.setPointSize(10)
	
	const.color = {50, 200, 255}
	
	love.graphics.setColor(unpack(const.color))
end

function TRANS.Update(dt)
	local delete = {}
	
	for i, v in pairs(circles) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(circles, v) --remove
	end
	
	circletimer = circletimer + dt
	while circletimer > const.circledelay do
		circletimer = circletimer - const.circledelay
		table.insert(circles, circle:new(circletimer))
	end
end

function TRANS.Draw()
	for i, v in pairs(circles) do
		v:draw()
	end
	love.graphics.setColor(const.color[1], const.color[2], const.color[3], 170)
	love.graphics.draw(img.Trans, const.halfwidth, const.halfheight, 0, 0.3, 0.3, 165, 165)
end

function TRANS.keyPressed(key, unicode)

end

function getdist(i)
	return getdistfunc(i)*(const.halfwidth)
end

function getdistfunc(i)
	return (i+.4)^10
end

circle = class:new()

function circle:init(t)
	self.t = 0.28
	self.r = 0
	self.rspeed = 0
	self.rtime = 0
	self.changes = {}
	self.rtimer = 0
	
	for i = 1, const.steps do
		if math.random(3) == 1 then
			self.changes[i] = true
		end
	end
	
	self:newtarget()
end

function circle:update(dt)
	self.t = self.t+(self.t^2)*dt*const.circlespeed
	self.r = self.r + self.rspeed*dt
	
	self.rtimer = self.rtimer + dt
	if self.rtimer > self.rtime then
		self.rtimer = 0
		self:newtarget()
	end
	
	if self.t > const.remove then
		return true
	end
	return false
end

function circle:newtarget()
	self.rspeed = (math.random()-.5)*4
	self.rtime = math.random(20)/10
end

function circle:draw()
	local alpha = math.min(255, (self.t-.28)*10000)
	
	love.graphics.setColor(const.color[1], const.color[2], const.color[3], alpha)
	
	local dist1 = getdist(self.t)
	local dist2 = getdist(self.t*1.03)
	love.graphics.setLineWidth(math.max(1.5, getdistfunc(self.t)*6))
	
	local current = "close"
	local first
	for i = 1, const.steps do
		local change = false
		if self.changes[i] then
			if current == "close" then
				current = "far"
			else
				current = "close"
			end
			change = true
		end
		
		if i == 1 then
			first = current
		end
		
		local dist
		if current == "far" then
			dist = dist2
		else
			dist = dist1
		end
		
		local x = math.cos(self.r+(i/const.steps)*math.pi*2)*dist+const.halfwidth
		local y = math.sin(self.r+(i/const.steps)*math.pi*2)*dist+const.halfheight
		
		local x2 = math.cos(self.r+((i+1)/const.steps)*math.pi*2)*dist+const.halfwidth
		local y2 = math.sin(self.r+((i+1)/const.steps)*math.pi*2)*dist+const.halfheight
		
		love.graphics.line(x, y, x2, y2)
		
		if change and i ~= 1 then				
			local x = math.cos(self.r+(i/const.steps)*math.pi*2)*dist1+const.halfwidth
			local y = math.sin(self.r+(i/const.steps)*math.pi*2)*dist1+const.halfheight
			
			local x2 = math.cos(self.r+(i/const.steps)*math.pi*2)*dist2+const.halfwidth
			local y2 = math.sin(self.r+(i/const.steps)*math.pi*2)*dist2+const.halfheight
		
			love.graphics.line(x, y, x2, y2)
		end
			
		if i == const.steps and current ~= first then
			i = i + 1
			local x = math.cos(self.r+(i/const.steps)*math.pi*2)*dist1+const.halfwidth
			local y = math.sin(self.r+(i/const.steps)*math.pi*2)*dist1+const.halfheight
			
			local x2 = math.cos(self.r+(i/const.steps)*math.pi*2)*dist2+const.halfwidth
			local y2 = math.sin(self.r+(i/const.steps)*math.pi*2)*dist2+const.halfheight
		
			love.graphics.line(x, y, x2, y2)
		end
	end
end
