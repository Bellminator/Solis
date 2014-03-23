--Blue star
local entity = class:new();
function entity:Init(num, x, y)
	self.ID = num;
	self.Name = "blue_star";
	self.roll = 0;

	self.x, self.y = x, y;
end

function entity:Draw()
	setColor( color.Blue );
	love.graphics.draw( img.Star, self.x, self.y, self.roll, 0.05, 0.05, 250, 250 )
end

function entity:Update()
	self.roll = self.roll + 0.05;

	--Check if the player is touching the star.
	if GLOBAL.checkHover( self.x - 20, self.x + 20, self.y - 20, self.y + 20, ply.Pos ) then
		if settings.sound then play( audio.Ding ); end
		ply.Stars = ply.Stars + 2;
		ENT.Remove( self.ID );
	end
end

return entity;