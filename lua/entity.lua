--entity system
ENT = {};
entities = {};

--[[
	Just a list of variables our entities can use
	canHit
	captureMouse
	captureKeyboard
	hitBox
]]--

function ENT.Draw()
	for i = 1, #entities do
		entities[i]:Draw();
	end
end

function ENT.Update()
	for i = 1, #entities do
		if entities[i] then
			entities[i]:Update();
		end
	end 
end

function ENT.mousePressed( x, y, button )
	for i = 1, #entities do
		if entities[i] and entities[i].captureMouse then
			entities[i]:mousePressed( x, y, button );
		end
	end
end

function ENT.keyPressed( key, unicode )
	for i = 1, #entities do
		if entities[i] and entities[i].captureKeyboard then
			entities[i]:keyPressed( key, unicode );
		end
	end
end

function ENT.Spawn(ent, x, y, ...)
	--This is the hackiest entity system ever made I swear.
	ent = love.filesystem.load( "lua/entities/"..ent..".lua")(); --Load our entity
	local entnum = #entities + 1;
	entities[entnum] = ent;
	entities[entnum].ID = entnum;
	entities[entnum]:Init(x, y, ...);
end

function ENT.Remove( id )
	table.remove( entities, id );

	--Recreate our table so that our Update and Draw functions don't get confuzzled
	local redo = {};
	for i = 1, #entities do
		if entities[i] ~= nil then 
			redo[#redo + 1] = entities[i]; 
			redo[#redo].ID = #redo;
		end
	end
	entities = redo;
end