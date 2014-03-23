--Global functions

--Lets redefine some love functions shall we?
audio = {}
function play( song ) love.audio.play( song ); end
function pause( song ) if song then love.audio.pause( song ); else love.audio.pause(); end end
function resume( song ) if song then love.audio.resume( song ) else love.audio.resume(); end end
function rewind( song ) if song then love.audio.rewind( song ); else love.audio.rewind(); end end
function stop( song ) if song then love.audio.stop( song ) else love.audio.stop(); end end

function volume( self, num ) 
	if self then 
		if num or num == 0 then self:setVolume( num )
		else return self:getVolume(); end
	else
		if num then love.audio.setVolume( num )
		else return love.audio.getVolume(); end
	end
end

--Shorter, less annoying version of love.graphics.setColor();
function setColor( col )
	if col then
		love.graphics.setColor( col.r, col.g, col.b, global.curAlpha );
	end
end

--Vector tables
vec = {}
function vec:New( x, y, z )
	local object = { x = x, y = y, z = z }
	setmetatable( object, { __index = vec } )
	return object;
end

--Color tables
color = {}
function color:New( r, g, b, a )
	local object = { r = r, g = g, b = b, a = a or 255 }
	setmetatable( object, { __index = color } )
	return object;
end

--All of our global functions
GLOBAL = {};

--Save and retreive our config files.
function GLOBAL.getConfig()
	--Is there a config file made? If so, grab the values, otherwise we make one.
	if love.filesystem.exists("config.txt") then
		print("[Solis] Config file found! Grabbing file data.")
		local s = love.filesystem.read( "config.txt" )
		settings = json.decode( s );
	else
		print("[Solis] No config file found, creating one.");
		love.filesystem.write( "config.txt", json.encode( settings ) );
	end
end

function GLOBAL.saveConfig()
	love.filesystem.write( "config.txt", json.encode( settings ) );
end

function GLOBAL.createStars( num, table, x, y )
	for i = 1, num do
		local x = math.random(-x, x);
		local y = math.random(-y, y);
		table[i] = { x, y, math.random(2,4) }
	end 
end

--I forget what this does
function GLOBAL.findPatternSub( text, pattern )
  if string.find( text, pattern, 2 ) == nil then return 0, 0
  else return string.find( text, pattern, 2 ) end
end

--Pattern function
--findPattern("hey", "%b()", true )
--Return false on r if you'd like your pattern to be cut at the ends.
function GLOBAL.findPattern( text, pattern, r )
	local raw = string.sub( text, GLOBAL.findPatternSub( text, pattern ) )
 	if r == true then return raw 
    	else return string.sub( raw, 2, -2 ) end
end

function GLOBAL.getTextPos( text, x, y, scale )
	local s = 1;
	if scale then s = scale; end
	local len = string.len(text);
	for i = 1, len do
		x = x - (20.8*s);
	end

	y = y - (64*s);
	return x, y;
end

function GLOBAL.getAlpha( alpha )
	if global.curAlpha > alpha then return alpha; 
	else return global.curAlpha; end
end

function GLOBAL.checkHover( x, x2, y, y2, ent )
  if not ent then ent = global.mouse; end
  if console.Enabled then
    return false;
  else
  	if ( ( ent.x > ( x ) ) and ( ent.x < ( x2 ) ) and ( ent.y > ( y ) ) and ( ent.y < ( y2 ) ) ) then 
  		return true;
  	else
  		return false;
  	end
  end
end

function GLOBAL.setMouse( image, bool )
	if image then 
		global.mouse.draw = true;
		global.mouse.image = image;
	end
	
	if bool then
		love.mouse.setVisible( true );
	else
		love.mouse.setVisible( false );
	end
end

function GLOBAL.getTime(name, start, stop)
	local num = stop-start;
	print("[Solis] "..name.." loaded in "..num.." seconds!");
end

--String functions
function string.starts( string, start )
	return string.sub( string, 1, string.len( start ) ) == start;
end

function string.ends( string, ends )
	return ends == '' or string.sub( string, -string.len(ends) ) == ends;
end

--Table functions
function table.random( tables )
	local num = math.floor( math.random( 1, #tables + 0.4 ) );
	return tables[num];
end

--Math functions
function math.tau() 
	return tonumber((math.pi)*2); 
end

function math.round( num, idp )
	local mult = 10^(idp or 0);
	return math.floor(num*mult+0.5)/mult;
end; 


--Timers
timer = {}
timer.num = 0;

function timer:Create( name, time, func )
	local name, time, func = name, time, func;
	timer.num = timer.num + 1;
	timer[timer.num]= { name, time + os.time(), true, func };
end

function timer:Destroy( name )
	for i = 1, #timer do
		if timer[i][1] == name then
			timer[i][2] = -1;
			break;
		end
	end
end

function timer:Update( dt )
	for i = 1, #timer do
		if timer[i][3] then 
			if timer[i][2] == os.time() then timer[i][3] = false; print('lol'); timer[i][4](); end
		end
	end
end