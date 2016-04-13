PAUSE = {};
function PAUSE.Init()
	pause = {};
	pause.Enabled = false;

	pause.Poptions = {};
	function pause.Poptions:New( text, x, y, func, active )
		local object = { text = text, x = x, y = y, func = func, active }
		setmetatable( object, { __index = pause.Poptions } );
		return object;
	end

	local FBUTTON = {};
	FBUTTON.Resume = function()
		pause.Enabled = false;
	end
	FBUTTON.Restart = function()
		GAME.Init( game.Map, false );
	end
	FBUTTON.Options = function()
		print("Hey");
	end
	FBUTTON.Quit = function() game.Fade = true; end
	FBUTTON.Rage = function() love.event.quit(); end

	pause.Poptions[1] = pause.Poptions:New( "Resume", 50, 95, FBUTTON.Resume );
	pause.Poptions[2] = pause.Poptions:New( "Restart", 50, 133, FBUTTON.Restart );
	pause.Poptions[3] = pause.Poptions:New( "Options", 50, 174, FBUTTON.Options );
	pause.Poptions[4] = pause.Poptions:New( "Exit", 50, 700, FBUTTON.Quit );
end

function PAUSE.Draw()
	love.graphics.setColor( 50, 50, 50, 200 );
	love.graphics.rectangle( "fill", 0, 0, global.windowsize.x, global.windowsize.y );

	setColor( color.White );
	love.graphics.print( "Paused", 40, 20, 0, 0.7, 0.7 );

	for k,v in ipairs( pause.Poptions ) do
		local c = color.White;
		if v.active then c = color.Green; end
		setColor( c );

		love.graphics.print( v.text, v.x, v.y, 0, 0.5, 0.5 );
	end

	--Draw our world/player info box
	love.graphics.setColor( 25, 25, 25, 255 );
	love.graphics.rectangle( "fill", 350, 22, 650, global.windowsize.y );

	--Draw our world map.
	setColor( color.White );

	love.graphics.print( worldData.name, 400, 50, 0, 0.5, 0.5 );
	love.graphics.rectangle( "fill", 400, 100, 550, 200 );

	setColor( color.Black )
	love.graphics.rectangle( "fill", 405, 105, 540, 190 );
	--675, 200 is center
	
	for k,v in ipairs(planet) do
		love.graphics.setColor( v.Col.r, v.Col.g, v.Col.b, global.curAlpha );
		love.graphics.circle( "fill", v.x/(worldData.x/250) + 675, v.y/(worldData.y/80) + 200, v.Rad/25, 100 );
		--if v.img then love.graphics.draw( v.img, v.x, v.y, 0, 1, 1, 500, 500 ); end
	end

	setColor( color.White );
	love.graphics.circle( "fill", ply.Pos.x/(worldData.x/250) + 675, ply.Pos.y/(worldData.y/80) + 200, ply.Size/25, 50 );

	local function getSecond()
		if game.Time["s"] > 10 then return math.floor( game.Time["s"] ); 
		else return "0"..math.floor( game.Time["s"] ); end
	end

	--Data
	setColor( color.White );
	love.graphics.print( "Stars: "..ply.Stars, 400, 305, 0, 0.5, 0.5 );
	love.graphics.print( "Oxygen: "..ply.Oxygen.."%", 400, 355, 0, 0.5, 0.5 );
	love.graphics.print( "Time: "..game.Time["m"]..":"..getSecond(), 400, 410, 0, 0.5, 0.5 );
	love.graphics.print( "Powerups: ", 400, 465, 0, 0.5, 0.5 );
		love.graphics.print( "None", 425, 515, 0, 0.5, 0.5 );
end

function PAUSE.Update(dt)
	for k,v in ipairs( pause.Poptions ) do
		local width = string.len( v.text );
		if GLOBAL.checkHover( v.x, v.x + (width*30), v.y, v.y + 40 ) then
			if v.active ~= true and settings.sound then play( audio.Click ); end
			v.active = true;
		else
			v.active = false;
		end
	end
end

function PAUSE.mousePressed( x, y, button, istouch )
 	--Use global:checkHover();
 	if button == "l" then
	 	for k,v in ipairs( pause.Poptions ) do
	 		local width = string.len( v.text );
	 		if GLOBAL.checkHover( v.x, v.x + (width*30), v.y, v.y + 40 ) then
	 			v.func();
			end
	 	end
	end
end

function PAUSE.keyPressed( key, unicode )
	--Make arrow keys optional for button selection later fatass
end
