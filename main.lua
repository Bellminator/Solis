--Solis by Nick Bellamy
--Main file
function love.load()
	local start = os.clock();

	settings = {};
	settings.debug = false;
	settings.sound = true;
	settings.fullscreen = false;
	settings.curMaps = 1;

	global = {}
	global.curAlpha = 255;
	global.Alpha = 255;
	global.font = love.graphics.newFont( "font.ttf", 64 );
		love.graphics.setFont( global.font );
	global.mouse = { x = 0, y = 0, wx = 0, wy = 0 };
	global.time = 0;
	global.stime = os.time();

	--Required files for running
	local files = love.filesystem.getDirectoryItems( "lua" );

	--Load all our files in a shitty way
	for k,v in pairs( files ) do
	 	local length = string.len( v );
	 	local ns = string.sub( v, 1, length - 4 );
	 	if ns ~= "enti" and ( string.sub( v, 1, 1 ) ~= "_" ) then require( "lua/"..ns ); print( "[Solis] Loading module: " .. ns .. ";"); end;
	end;

	--Load json along with it
	require( "json/json" );

	--Colors
	  color.Green = color:New( 51, 160, 0 );
	  color.Blue = color:New( 50, 50, 200 );
	  color.Red = color:New( 255, 50, 50 );
	  color.Purple = color:New( 200, 0, 150 );
	  color.Gold = color:New( 255, 215, 0 );
	  color.White = color:New( 255, 255, 255 );
	  color.Grey = color:New( 100, 100, 100 );
	  color.Black = color:New( 0, 0, 0 );
	  color.Sand = color:New( 237, 201, 175 );
	  color.SkyBlue = color:New( 135, 206, 250 );

	--img
	img = {};

		img.Base = love.graphics.newImage( "img/atmosphere_new.png" );
		img.Sound = love.graphics.newImage( "img/sound.png" );
		img.NoSound = love.graphics.newImage( "img/nosound.png" );
		img.Trans = love.graphics.newImage("img/trans.png")
		img.Star = love.graphics.newImage("img/star.png");
		img.Dino = love.graphics.newImage("img/dino-man.png");
		img.Drone = love.graphics.newImage("img/drone.png");

	--Set background color and mode
		global.windowsize = { x = 1024, y = 768 };
		love.graphics.setBackgroundColor( 0, 0, 0 );

		--(x, y, fullscreen, vsycn, fsaa)
		love.window.setMode( global.windowsize.x, global.windowsize.y, {fullscreen=false, vsync=false, fsaa=0} );

	--audio/music
		--in-game songs
		audio.Song = {};
		audio.Song[1] = love.audio.newSource( "audio/music/bills.ogg" );
		audio.Song[2] = love.audio.newSource( "audio/music/early.ogg" );
		audio.Song[3] = love.audio.newSource( "audio/music/moomba.ogg" );
		audio.Song[4] = love.audio.newSource( "audio/music/partywizards.ogg" );
		audio.Song[5] = love.audio.newSource( "audio/music/titans.ogg" );

		--Menu music
		audio.Menu  = love.audio.newSource( "audio/music/menu.ogg" );
		audio.Click = love.audio.newSource( "audio/button_click.ogg" );

		--Sound effects
		audio.Ding = love.audio.newSource( "audio/ding_edit.ogg" );

	--Initialize all of our required components
		CONSOLE.Init();
	
	--Start up our gamestates
	global.newState = MENU;
	local stop = os.clock();
	GLOBAL.getTime( "Main.lua", start, stop );
end

function love.draw()
	if global and global.gameState then
		global.gameState.Draw();
	end;

	--Console drawing, leave at the bottom.
	if console.Enabled then CONSOLE.Draw(); end;
	if settings.debug then 
		setColor( color.Purple );
		love.graphics.print( love.timer.getFPS(), global.windowsize.x - 25, 0, 0, 0.2, 0.2 );
	end;

	if global.mouse.draw then
		love.graphics.draw( global.mouse.image, global.mouse.x, global.mouse.y );
	end;
end

function love.update(dt)
	global.time = os.time() - global.stime;
	timer:Update(dt);

	if global and global.gameState then 
		global.gameState.Update( dt );
	end;

	global.mouse.x = love.mouse.getX();
	global.mouse.y = love.mouse.getY();

	if global.newState ~= global.gameState then
		global.newState.Init( global.map, true );
		global.gameState = global.newState;
	end;

	if console.Enabled then CONSOLE.Update(dt); end;

	if global.Alpha ~= global.curAlpha then
		if global.Alpha > global.curAlpha then
			global.curAlpha = global.curAlpha + 5;
		elseif ( global.Alpha < global.curAlpha ) then
			global.curAlpha = global.curAlpha - 5;
		end;
	end;
end;

function love.keypressed( key, unicode )
	if key ~= "" or nil then
		if console.Enabled or key == "~" or key == "`" then CONSOLE.keyPressed( key, unicode ); end;
		global.gameState.keyPressed( key, unicode );
	end;
end;

function love.mousepressed( x, y, button )
	global.gameState.mousePressed( x, y, button );
end;

--Class system
--[[
Copyright (c) 2009 Bart Bes

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]--

__HAS_SECS_COMPATIBLE_CLASSES__ = true

local class_mt = {}

function class_mt:__index(key)
    return self.__baseclass[key]
end

class = setmetatable({ __baseclass = {} }, class_mt)

function class:new(...)
    local c = {}
    c.__baseclass = self
    setmetatable(c, getmetatable(self))
    if c.init then
        c:init(...)
    end
    return c
end