--Drone entity
local entity = class:new();
function entity:Init( x, y )
	self.Name = "drone";
	self.x, self.y = x, y;
	self.w, self.h = 30, 30;
	self.canHit = true;
	self.Ang = 0;
	self.hitBox = { x = self.x - 15, y = self.y - 15 };
	self.Rand = math.random(1,5); --Give our entities random positions around the player
end;

function entity:Draw()
	setColor( color.White );
	love.graphics.draw( img.Drone, self.x, self.y, self.Ang, 0.10, 0.10, 250, 250 );
	love.graphics.rectangle( "line", self.hitBox.x, self.hitBox.y, self.w, self.h ); --For debugging purpouses
end;

function entity:Update()
	if( math.abs( self.x - ply.Pos.x ) < 500 and math.abs( self.y- ply.Pos.y ) < 500 ) then
		self.x, self.y = self.x + ( ( ply.Pos.x - self.x )/(self.Rand*100) ), self.y + ( ( ply.Pos.y - self.y )/( self.Rand*100 ) );
		self.hitBox.x, self.hitBox.y = self.x - 15, self.y - 15;
		self.Ang = ( math.atan2( (ply.Pos.y - self.y), ( ply.Pos.x - self.x ) ) + math.rad(90) );
	end;
end;

function entity:attack()

end;

return entity;