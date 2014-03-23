--Test enemy
local entity = class:new();
function entity:Init(x, y, w, h)
	self.Name = "test_enemy";
	self.canHit = true;

	self.x, self.y = x, y;
	self.w, self.h = w, h;
	self.hitBox = { x = x, y = y };
end

function entity:Draw()
	setColor( color.White );
	--love.graphics.rectangle( "fill", self.x, self.y, self.w, self.h )
	love.graphics.draw( img.Dino, self.x, self.y, 0, 0.25, 0.25 );
end

function entity:Update()
	self.x, self.y = self.x + ( ( ply.Pos.x - self.x )/50 ), self.y + ( ( ply.Pos.y - self.y )/50 );
end

return entity;