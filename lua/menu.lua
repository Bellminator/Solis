MENU = {};
function MENU.Init()
	local start = os.clock();

	--Get our config options
	GLOBAL.getConfig();

	if settings.sound then 
		play( audio.Menu ); 
		timer:Create( "ReplayMusic", 230, MENU.replayMusic );
	end

	menu = {}
	menu.Stars = {}
	GLOBAL.createStars( 250, menu.Stars, global.windowsize.x, global.windowsize.y );

	menu.Buttons = {}
	function menu.Buttons:New( text, x, y, rad, col, func, scale, state, crad, active )
		local object = { text = text, x = x, y = y, rad = rad, col = col, func = func, scale = scale, state = state or "main", crad = 0, active = false }
		setmetatable( object, { __index = menu.Buttons } );
		return object;
	end

	local FBUTTON = {}
	FBUTTON.Play = function() menu.State = "t"; menu.newState = "maps"; end
	FBUTTON.Resolution = function() 
		if settings.fullscreen then
			menu.Buttons[2].text = "Fullscreen";
			settings.fullscreen = false;
			global.windowsize.x, global.windowsize.y = 1024, 768;
			love.window.setMode( 1024, 768, {fullscreen=false, vsync=true} );
			GLOBAL.saveConfig();
		else
			local modes = love.window.getFullscreenModes()
			table.sort(modes, function(a, b) return a.width*a.height > b.width*b.height end)

			menu.Buttons[2].text = "Windowed";
			settings.fullscreen = true;
			global.windowsize.x, global.windowsize.y = modes[1].width, modes[1].height;
			love.window.setMode( modes[1].width, modes[1].height, {fullscreen=false, vsync=true} );
			GLOBAL.saveConfig();
		end
	end
	FBUTTON.Help = function() print("Coming soon"); end
	FBUTTON.Sound = function() 
		settings.sound = not settings.sound;
		GLOBAL.saveConfig();
		if settings.sound then 
			love.audio.play( audio.Menu );
			timer:Create( "ReplayMusic", 230, MENU.replayMusic );
		else 
			timer:Destroy( "ReplayMusic" ); 
			love.audio.stop( audio.Menu ); 
		end
	end
	FBUTTON.Quit = function() love.event.quit(); end
	FBUTTON.ChangeMap = function( number ) 
		local number = number;
		menu.Fade = number;
	end

	--Main menu buttons
	menu.Buttons[1] = menu.Buttons:New( "Play", 200, 200, 100, color.Blue, FBUTTON.Play, 0.7);
	menu.Buttons[2] = menu.Buttons:New( "Fullscreen", 250, 560, 60, color.Purple, FBUTTON.Resolution, 0.15 ); --Blank
	menu.Buttons[3] = menu.Buttons:New( "Help", 690, 140, 75, color.Green, FBUTTON.Help, 0.5 );
	menu.Buttons[4] = menu.Buttons:New( "", 820, 370, 65, color.Gold, FBUTTON.Sound ); --Sound on/off
	menu.Buttons[5] = menu.Buttons:New( "Quit", 800, 560, 55, color.Red, FBUTTON.Quit, 0.35 );

	--Map buttons
	for i = 1, #MAP do
		worldData = {}; --Clear our previous data.
		MAP[i](false); --Load our map data so we can use it to make the buttons.
		local v = worldData
		menu.Buttons[i + 5] = menu.Buttons:New( v.name, v.button.x, v.button.y, v.button.size, v.button.color, FBUTTON.ChangeMap, 0.15, "maps" );
	end

	--Did the user set the fullscreen to be true the last time he loaded the config? 
	if settings.fullscreen then 
		local modes = love.window.getFullscreenModes()
		table.sort(modes, function(a, b) return a.width*a.height > b.width*b.height end)

		menu.Buttons[2].text = "Windowed";
		settings.fullscreen = true;
		global.windowsize.x, global.windowsize.y = modes[1].width, modes[1].height;
		love.window.setMode( modes[1].width, modes[1].height, {fullscreen=false, vsync=true, fsaa=2} );
	end

	menu.Rotate = 0;
	menu.SlowRotate = 0;
	menu.lastState = "main";
	menu.newState = "main";
	menu.State = "main";
	menu.SunSize = 150;
	menu.SunFull = false;
	menu.SunAlpha = 255;
	menu.ButtonAlpha = 255;
	menu.Fade = false;
	menu.lines = {};
	global.Alpha = 255;

	--Lets get rid of variables we don't need.
	game = nil;

	print("[Solis] Menu initialized!");
	local stop = os.clock();
	GLOBAL.getTime( "Menu.lua", start, stop );
end

function MENU.Draw()
	local c = color;

	love.graphics.setColor( c.White.r, c.White.g, c.White.b, global.curAlpha );
	love.graphics.points( menu.Stars );
--[[
	for i = 1, #menu.Stars do
		love.graphics.setPointSize( menu.Stars[i][3] )
		love.graphics.point( menu.Stars[i][1], menu.Stars[i][2] );
	end
]]--
	love.graphics.setColor( 255, 255, 255, GLOBAL.getAlpha( 150 ) );

	--Draw our sunbeams
	for i = 1, 21 do
		if menu.lines[i] then
			love.graphics.line( 512, 384, 512 + menu.lines[i].x, 384 + menu.lines[i].y );
		end
	end

	--Draw our sun
	love.graphics.setColor( c.Gold.r, c.Gold.g, c.Gold.b, 255 );
	love.graphics.draw( img.Base, 512, 384, 0, 1, 1, 500, 500 ); -- Part of framerate problem, why?
	love.graphics.circle( "fill", 512, 384, menu.SunSize, 100 ); -- Same
	love.graphics.setColor( 255, 255, 255, 255 );

	local x, y = GLOBAL.getTextPos( "Solis", 512, 384, 1 );
	love.graphics.print( "Solis", x, y );

	love.graphics.push();
	love.graphics.translate( love.graphics.getWidth()/(love.graphics.getWidth()/3), love.graphics.getHeight()/(love.graphics.getHeight()/3) );

	--Our main menu
	--Draw our buttons
	for i = 1, #menu.Buttons do
		if menu.Buttons[i].state == menu.State or menu.Buttons[i].state == menu.lastState then
			local ax, ay = math.cos( menu.Rotate + i )*10, math.sin( menu.Rotate + i)*10;
			local v = menu.Buttons[i]

			--Draw dem circles
			--Grey 
			if menu.Buttons[i].state == "maps" then 
				if ( i - 5 ) > settings.curMaps then
					love.graphics.setColor( 50, 50, 50, GLOBAL.getAlpha( menu.ButtonAlpha ) );
				else
					love.graphics.setColor( c.Grey.r, c.Grey.g, c.Grey.b, GLOBAL.getAlpha( menu.ButtonAlpha ) );
				end
			else
				love.graphics.setColor( c.Grey.r, c.Grey.g, c.Grey.b, GLOBAL.getAlpha( menu.ButtonAlpha ) );
			end

				love.graphics.circle( "fill", v.x + ax, v.y + ay, v.rad, 100 ); -- Same
			--Colored
			if menu.Buttons[i].state == "maps" then 
				if ( i - 5 ) > settings.curMaps then
				else
					love.graphics.setColor( v.col.r, v.col.g, v.col.b, GLOBAL.getAlpha( menu.ButtonAlpha ) );
					love.graphics.circle( "fill", v.x + ax, v.y + ay, v.crad, 100 );
				end
			else
				love.graphics.setColor( v.col.r, v.col.g, v.col.b, GLOBAL.getAlpha( menu.ButtonAlpha ) );
				love.graphics.circle( "fill", v.x + ax, v.y + ay, v.crad, 100 );
			end

			if i == 4 then 
				love.graphics.setColor( 255, 255, 255, GLOBAL.getAlpha( menu.ButtonAlpha ) );
				if settings.sound then love.graphics.draw( img.Sound, v.x + ax, v.y + ay, 0, 0.3, 0.3, 250, 250 )
				else love.graphics.draw( img.NoSound, v.x + ax, v.y + ay, 0, 0.3, 0.3, 250, 250 ) end
			end

			--Text
			if v.text then
				if menu.Buttons[i].state == "maps" then
					if ( i - 5 ) > settings.curMaps then
					else
						local x, y = GLOBAL.getTextPos( v.text, v.x, v.y, v.scale );
						love.graphics.setColor( 255, 255, 255, GLOBAL.getAlpha( menu.ButtonAlpha ) );
						love.graphics.print( v.text, x + ax, y + ay, 0, v.scale, v.scale );
					end
				else
					local x, y = GLOBAL.getTextPos( v.text, v.x, v.y, v.scale );
					love.graphics.setColor( 255, 255, 255, GLOBAL.getAlpha( menu.ButtonAlpha ) );
					love.graphics.print( v.text, x + ax, y + ay, 0, v.scale, v.scale );
				end
			end
		end
	end

	love.graphics.pop();

	--Draw our sun overlay
	if menu.SunFull then
		love.graphics.setColor( color.Gold.r, color.Gold.g, color.Gold.b, menu.SunAlpha );
		love.graphics.rectangle( "fill", 0, 0, global.windowsize.x, global.windowsize.y );

		love.graphics.setColor( 255, 255, 255, 255 );
		local x, y = GLOBAL.getTextPos( "Solis", 512, 384, 1 );
		love.graphics.print( "Solis", x, y );
		local x, y = GLOBAL.getTextPos( "By Nick Bellamy", 512, 768/1.85, 0.2 );
		love.graphics.print("By Nick Bellamy", x, y, 0, 0.2, 0.2 );
	end
end

function MENU.Update(dt)
	if menu.newState ~= menu.State and menu.State ~= "t" then menu.State = "t"; end

	menu.Rotate = menu.Rotate + 1*dt;
	if menu.Rotate > 360 then menu.Rotate = 0; end
	menu.SlowRotate = menu.SlowRotate + 0.05*dt;
	if menu.SlowRotate > 360 then menu.SlowRotate = 0; end

	for i = 1, #menu.Buttons do
		if menu.Buttons[i].state == menu.State then
			local v = menu.Buttons[i];
			if v.active and v.rad > v.crad then v.crad = v.rad;
			elseif not v.active and v.crad > 0 then v.crad = 0; end
		end
	end

	--Check if the mouse is hovering over one of our buttons
	for  i = 1, #menu.Buttons do
		if menu.Buttons[i].state == menu.State then
			local ax, ay = math.cos( menu.Rotate + i )*10, math.sin( menu.Rotate + i)*10;
			local v = menu.Buttons[i];
			if GLOBAL.checkHover( v.x - v.rad + ax, v.x + v.rad + ax, v.y - v.rad + ay, v.y + v.rad + ay ) then
				if not v.active then v.active = true; end
			else
				if v.active then v.active = false; end
			end
		end
	end

	if menu.State == "t" then
		if menu.ButtonAlpha > 1 then menu.ButtonAlpha = menu.ButtonAlpha - 500*dt; end

		menu.SunSize = menu.SunSize + 200*dt;
		if menu.SunSize > global.windowsize.x then
			menu.State = menu.newState;
			menu.SunFull = true;
			menu.SunSize = 150;
		end
	end

	if menu.SunFull then
		if menu.SunAlpha > 1 then
			menu.lastState = menu.State;
			menu.SunAlpha = menu.SunAlpha - 100*dt;
			menu.ButtonAlpha = menu.ButtonAlpha + 100*dt;
		else
			menu.SunFull = false;
			menu.SunAlpha = 255;
			menu.ButtonAlpha = 255;
		end
	end

	if menu.Fade then
		global.Alpha = 0;
		if global.curAlpha < 1 then
			global.newState = GAME;
			global.curAlpha = 255;
			global.map = menu.Fade
		end
	end
	
	--Turn our sunbeams around
	for i = 1, 21 do
		local x = math.cos( menu.SlowRotate + i )*global.windowsize.x*(global.curAlpha/255);
		local y = math.sin( menu.SlowRotate + i )*global.windowsize.y*(global.curAlpha/255);
		menu.lines[i] = { x = x, y = y }
	end
end

function MENU.mousepressed( x, y, button, istouch )
 	if button == 1 then
		for i = 1, #menu.Buttons do
			if menu.Buttons[i].state == menu.State then
				local ax, ay = math.cos( menu.Rotate + i )*10, math.sin( menu.Rotate + i)*10;
				local v = menu.Buttons[i]
				if GLOBAL.checkHover( v.x - v.rad + ax, v.x + v.rad + ax, v.y - v.rad + ay, v.y + v.rad + ay ) then
					if v.state == "maps" then v.func( i - 5 ); print(i-5); else v.func(); end
					break;
				end
			end
		end
	end
end

function MENU.keyPressed( key, unicode )
end

function MENU.replayMusic()
	stop( audio.Menu );
	play( audio.Menu );
	timer:Create( "ReplayMusic", 230, MENU.replayMusic );
end;