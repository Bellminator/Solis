--Laser
local entity = class:new();
function entity:Init(x, y, dx, dy)
	self.Name = "player_laser";

	self.x, self.y = x, y;
	self.dx, self.dy = dx, dy;
end

function entity:Draw()
	setColor( color.Blue );
	love.graphics.setLineWidth( 2 );
	love.graphics.setLineStyle( "smooth" );
	love.graphics.line( self.dx + self.x, self.dy + self.y, self.x, self.y );
	love.graphics.setLineWidth( 1 ); --Set our lines back to normal ( for debugging lines )
end

function entity:Update()
	--Update the bullets position.
	self.x, self.y = self.x + self.dx, self.y + self.dy;

	--Hit some stuff yo;
	for i = 1, #entities do
		if entities[i].canHit then
			if GLOBAL.checkHover( entities[i].hitBox.x, entities[i].hitBox.x + entities[i].w, entities[i].hitBox.y, entities[i].hitBox.y + entities[i].h, entities[self.ID]) then
				ENT.Remove( entities[i].ID );
				ENT.Remove( self.ID );
				break;
			end
		end
	end

	--Remove the bullet/laser if it goes outside the worlds bounds.
	if ( self.x > ( worldData.x + 1000 ) or self.y > ( worldData.y + 1000 ) or self.x < ( -worldData.x - 1000 ) or self.y < ( -worldData.y - 1000 ) ) then
		ENT.Remove( self.ID )
	end	
end

return entity;