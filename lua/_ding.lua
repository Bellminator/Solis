DING = {};
DING.module = {};
function DING.Init()
	--Set our new mouse courser
	--love.mouse.setVisible( false );

	--Colors bitches
	DING.color = {}
	function DING.color:New( r, g, b )
		if not ( r or g or b ) then
			print("(DING) ERROR: DING.color missing paremeters!");
			return;
		end

		local object = { r = r, g = g, b = b };
		setmetatable( object, { __index = DING.color } );
		return object;
	end

	DING.color["red"] = DING.color:New( 255, 0, 0 );
	DING.color["blue"] = DING.color:New( 0, 0, 255 );
	DING.color["lblue"] = DING.color:New( 0, 100, 255 );
	DING.color["green"] = DING.color:New( 0, 255, 0 );
	DING.color["black"] = DING.color:New( 0, 0, 0 );
	DING.color["white"] = DING.color:New( 255, 255, 255 );
	DING.color["grey"] = DING.color:New( 100, 100, 100 );

	--Themes
	DING.theme = {}
	function DING.theme:New( background, forground, textcolor )
		if not( background or forground or text ) then
			print("(DING) ERROR: DING.theme missing paremeters!");
			return;
		end

		local object = { background = background, forground = forground, textcolor = textcolor };
		setmetatable( object, { __index = DING.theme } );
		return object;
	end

	DING.theme["default"] = DING.theme:New( DING.color["grey"], DING.color["white"], DING.color["black"] );

	--Panels
	DING.panel = {};
	function DING.panel:New( x, y, w, h, drag, resize, name, close, theme, content )
		if not ( x or y or w or h or drag or resize or name or close ) then 
			print("(DING) ERROR: DING.panel missing paremeters!" );
			return;
		end

		if not theme then theme = DING.theme["default"]; end
		if not importance then importance = 3; end
		local object = { x = x, y = y, w = w, h = h, drag = drag, resize = resize, name = name, close = close, theme = theme, content = content };
		setmetatable( object, { __index = DING.panel } );
		return object;
	end

	--Buttons
	DING.button = {};
	function DING.button:New( x, y, w, h, text, func, panel, enabled )
		if not ( x or y or w or h or text ) then
			print("(DING) ERROR: DING.button missing paremeters!");
			return;
		end

		if not enabled then enabled = true; end
		local object = { x = x, y = y, w = w, h = h, text = text, func = func, panel = panel, enabled = enabled };
		setmetatable( object, { __index = DING.button } );
		return object;
	end 
end

function DING.Update(dt)
	if DING.module["console"] and console.Enabled then console_Update(dt); end

	--Figure out if our panel is draggable and if it is check if its in the correct state to be dragged.
	for i = 1, #DING.panel do
		if not DING.panel[i].closed then --Is our panel closed? if so skip it, no need to do equations we don't need.
			local pan = DING.panel[i];
			DING.isDragging( pan );

			--Onto resizing!
			DING.isResizing( pan );

			--Mouse is down? Are we touching the border of a panel? If so put it into drag mode.
			if love.mouse.isDown( "l" ) then
				if pan.draggable and pan.importance == 1 then
					pan.x = love.mouse.getX() - pan.clamp.x;
					pan.y = love.mouse.getY() + pan.clamp.y;
				end

				if pan.sizeable and pan.importance == 1 then
					if pan.text then pan.wrap = DING.wrap( pan.text, pan.w/6.2 ) end
					pan.w = math.max( 50, love.mouse.getX() - pan.clamp.w );
					pan.h = math.max( 50, love.mouse.getY() - pan.clamp.h );
				end
			else
				--Save our clamp positions.
				pan.clamp = { x = love.mouse.getX() - pan.x, y = love.mouse.getY() - pan.y + 25, w = love.mouse.getX() - pan.w, h = love.mouse.getY() - pan.h };
			end
		end
	end
end

function DING.isDragging( pan )
	if pan.drag then --draggable?
		local x, y = pan.x - 10, pan.y - 25; --min x,y pos
		local x2, y2 = pan.x + pan.w + 10, pan.y + 25; --max x,y pos
		--take our x and y values and use them to check and see if were touching the border
		if ( DING.CheckHover( x, y, x2, y2 ) and not DING.CheckHover( x + 10, y + 25, x2 - 10, y2 - 25 ) and ( not love.mouse.isDown("l" ) ) ) then
			pan.draggable = true;
		elseif ( pan.draggable == true and ( not love.mouse.isDown("l") ) ) then
			pan.draggable = false;
		end
	end
end

function DING.isResizing( pan )
	if pan.resize then
		local x, y = pan.x - 10, pan.y;
		local x2, y2 = pan.x + pan.w + 10, pan.y + pan.h + 10;
		if( DING.CheckHover( x, y, x2, y2 ) and not DING.CheckHover( x + 10, y, x2 - 10, y2 - 25 ) and (not pan.sizable) and ( not love.mouse.isDown("l") ) ) then
			pan.sizeable = true;
		elseif ( pan.sizeable and ( not love.mouse.isDown("l") ) ) then
			pan.sizeable = false;
		end
	end
end

function DING.Draw()
	for i = 1, #DING.panel do
		if not DING.panel[i].closed then
			local pan = DING.panel[i];
			local theme = pan.theme;
			local background = theme.background;
			local forground = theme.forground;
			local textcolor = theme.textcolor;

			love.graphics.setColor( background.r, background.g, background.b, 255 );
			love.graphics.rectangle( "fill", pan.x - 10, pan.y - 25, pan.w + 20, pan.h + 35 );

			love.graphics.setColor( forground.r, forground.g, forground.b, 255 );
			love.graphics.rectangle( "fill", pan.x, pan.y, pan.w, pan.h );

			local len = string.len( pan.name )*6.5;
			local n = pan.name
			if len > pan.w then n = string.sub( pan.name, 1, 4 ).."..."; end
			love.graphics.setColor( textcolor.r, textcolor.g, textcolor.b, 255 );
			love.graphics.print( n, pan.x, pan.y - 17, 0, 1, 1 );

			if pan.close then
				love.graphics.setColor( 255, 0, 0, 255 );
				love.graphics.print( "x", pan.x + pan.w - 7, pan.y - 20, 0, 1, 1 ); 
			end

			if pan.text then
				love.graphics.setColor( textcolor.r, textcolor.g, textcolor.b, 255 );
				love.graphics.print( pan.wrap, pan.x + 5, pan.y + 5, 0, 1, 1 );
			end
		end
	end

	--Buttons
	for i = 1, #DING.button do
		local button = DING.button[i];
		local theme = DING.theme["default"];
		if button.panel then theme = button.panel.theme; end
		if button.theme then theme = button.theme; end
		local background = theme.background;
		local textcolor = theme.textcolor;

		love.graphics.setColor( background.r, background.g, background.b, 255 );
		love.graphics.rectangle( "fill", button.x, button.y, button.w, button.h );

		love.graphics.setColor( textcolor.r, textcolor.g, textcolor.b, 255 );
		love.graphics.print( button.text, button.x, button.y, 0, 1, 1 );
	end

	if DING.module["console"] and console.Enabled then console_Draw(); end
end

function DING.CheckHover( x, y, x2, y2 )
	local mouse = { x = love.mouse.getX(), y = love.mouse.getY() };
	if ( ( mouse.x > ( x ) ) and ( mouse.x < ( x2 ) ) and ( mouse.y > ( y ) ) and ( mouse.y < ( y2 ) ) ) then 
		return true;
	else 
		return false;
	end
end

function DING.keyPressed( key, unicode )
end

function DING.mousePressed( x, y, button, istouch )
	if DING.module["console"] and console.Enabled then return false; end

	if button == "l" then
		for i = 1, #DING.panel do
			if not DING.panel[i].closed then
				local pan = DING.panel[i];

				--Should we close our panel?
				if pan.close then
					local x, y = pan.x + pan.w - 7, pan.y - 17;
					local x2, y2 = (pan.x + pan.w - 1), (pan.y - 9);
					if DING.CheckHover( x, y, x2, y2 ) then
						pan.closed = true;
						pan.draggable = false;
						pan.scaleable = false;
						return;
					end
				end

				--Check if our panels going to be dragged and if it is move it up in the draw list.
				DING.getImportance( pan );
			end

			for i = 1, #DING.button do
				local button = DING.button[i];
				local x, y = button.x, button.y;
				local x2, y2 = button.x + button.w, button.y + button.h;
				if DING.CheckHover( x, y, x2, y2 ) then
					button.func();
				end
			end
		end
	end
end

function DING.getImportance( pan )
	if pan.draggable or pan.sizeable then
		for i = 1, #DING.panel do
			if DING.panel[i] ~= pan then
				if DING.panel[i].importance == 1 then DING.panel[i].importance = 2;
				else DING.panel[i].importance = 3; end
			end
		end
		pan.importance = 1;
		table.sort( DING.panel, function(a, b) return a.importance > b.importance; end );
	end			
end

function DING.wrap( str, limit )
	local len = string.len( str );
	local limit = limit or 32;
	local sections = {};
	if len > limit then 
		local num = 0;
		repeat
			sections[num + 1] = str:sub( limit*num, limit*(num + 1) - 1 );
			num = num + 1;
		until sections[num] == "" or sections[num] == " " or sections[num] == nil;
		for i = 1, #sections do sections[i] = sections[i].."\n"; end
		
		local final = "";
		local num = 0;
		repeat 
			if sections[num + 1] then final = final .. sections[num + 1]; else break; end
			num = num + 1;
		until sections[num] == "" or sections[num] == " " or sections[num] == nil;
		return final;
	end
end

