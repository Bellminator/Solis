--Particle System
PS = {};

function PS.Init()
	--Load our particles
	ps = {};
	ps.Star = love.graphics.newParticleSystem( img.Star );
		--ps.Star:Config( nil, { min = 5, max = 10 },   )
end

function PS.Update(dt)
	for k,v in pairs( ps ) do
		v:update();
	end
end

function PS.Draw()
end

function PS:Config( pos, rot, speed, col, spin, spread, duration, life, dir, emmission, gravity )
	if self then
		self:setPosition( pos.x or 0, pos.y or 0); 

		if rot then self:setRotation( rot.min, rot.max ); end
		if speed then self:setSpeed( speed.min, speed.max ); end
		if col then self:setColors( col.r, col.g, col.b, col.a or 255 ); end
		if spin then self:setSpin( spin.min, spin.max, spin.var or 0 ); end
		if spread then self:setSpread( spread ); end
		if dir then self:setDirection( dir ); end
		if emission then self:setEmissionRate( emission ); end
		if gravity then self:setGravity( gravity.min, gravity.max ); end

		self:setLifetime( duration or 5 );
		self:setParticleLife( life.min or 1, life.max or 5 );
	else
		print("ParticleSystem:Config() called but self isn't defined.");
	end
end	