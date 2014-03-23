--Golden star (Default)
local entity = class:new();
function entity:Init(x, y)
	self.Name = "gold_star";
	self.roll = 0;

	self.x, self.y = x, y;
	self.follow = false;
end

function entity:Draw()
	setColor( color.Gold );
	love.graphics.draw( img.Star, self.x, self.y, self.roll, 0.05, 0.05, 250, 250 )
end

function entity:Update()
	self.roll = self.roll + 0.01;

	--Check if the player is touching the star.
	if not self.follow then
		if GLOBAL.checkHover( self.x - 20, self.x + 20, self.y - 20, self.y + 20, ply.Pos ) then
			if settings.sound then play( audio.Ding ); end
			ply.Stars = ply.Stars + 1;
			self.Num = ply.Stars;
			self.follow = true;
		end
	else
		local r = 50 + ( ply.Stars*2 );
		local t = (2*math.pi*self.Num)/ply.Stars;
		local x = math.round( ( r )*math.cos(t) );
		local y = math.round( ( r )*math.sin(t) );
		self.x = ( ( ply.Pos.x + x ) );
		self.y = ( ( ply.Pos.y + y ) );
	end;
end

return entity;