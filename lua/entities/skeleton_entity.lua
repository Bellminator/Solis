--Skeleton entity
local entity = class:new();
function entity:Init(x, y)
	self.Name = "skeleton_entity";

	self.x, self.y = x, y;
end

function entity:Draw()

end

function entity:Update()

end

return entity;