CONSOLE = {};
function CONSOLE.Init()
	local start = os.clock();
	console = {}
	console.Enabled = false;
	console.Shift = false;

	console.CText = "";
	console.LNum = 0;
	console.cLine = ((love.graphics.getHeight()/1.25) - 60)
	console.Lines = {}
	console.Blink = "|";
	console.BTime = 0;

	function console.Lines:New( text, col )
		local object = { text = text, col = col }
		setmetatable( object, { __index = console.Lines } );
		return object;
	end

	console.ShiftLines = { 
		["0"] = ")", ["1"] = "!", ["2"] = "@", ["3"] = "#", ["4"] = "$", ["5"] = "%", ["6"] = "^", ["7"] = "&", ["8"] = "*", ["9"] = "(",
		["-"] = "_", ["="] = "+", [";"] = ":"
	};


	console.Replacements = {};
	console.Replacements["kp/"] = "/"; console.Replacements["kp*"] = "*"; console.Replacements["kp-"] = "-"; console.Replacements["kp+"] = "+";
	console.Replacements["kp."] = ".";
	for i = 0, 9 do console.Replacements["kp"..i] = tostring( i ); end

	console.Blacklist = {
		"`", "up", "down", "left", "right", "backspace", "return", "lshift", "rshift", "tab", "capslock", "lctrl", "rctrl", "lalt", "ralt",
		"escape", "insert", "home", "delete", "end", "pageup", "pagedown", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12",
		"print", "scrollock", "pause", "numlock", "lsuper", "menu", "kpenter",
	}

	console.Commands = { "Run", "Clear", "Print", "Help" }
		COMMAND = {}
		COMMAND.Run = function(text)
			if text then 
				local stuff = GLOBAL.findPattern( text, "%b()" )
				local string = loadstring(stuff); 
				string();
			else return console_AddLine( "You did not specify enough text!", color.Red ); end
		end
		COMMAND.Clear = function(text)
			console.CText = "";
			console.LNum = 0;
			console.Lines = {};
			function console.Lines:New( text, col )
				local object = { text = text, col = col }
				setmetatable( object, { __index = console.Lines } );
				return object;
			end
			
			console.cLine = ((love.graphics.getHeight()/1.25) - 60);
			console_AddLine( "Console cleared!", color.Green );
		end
		COMMAND.Print = function(text)
			if text then
				local text = GLOBAL.findPattern( text, "%b()" );
				print(tostring(text));
			end
		end
		COMMAND.Help = function()
			console_AddLine( "Available commands: ", color.Green );
				console_AddLine( "	run( [code] )", color.Green );
				console_AddLine( "	clear", color.Green );
				console_AddLine( "	print( [text] )", color.Green );
		end

	console_AddLine( "Type 'help' for a list of commands.", color.Red );

	GLOBAL.getTime( "Console.lua", start, os.clock() )
end

function CONSOLE.Draw()
	local c = color;

	--Draw our background
	love.graphics.setColor( c.Grey.r, c.Grey.g, c.Grey.b, 150 );
	love.graphics.rectangle( "fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight()/1.25 );

	--Draw the current text being written
	love.graphics.setFont( global.font );
	love.graphics.setColor( c.White.r, c.White.g, c.White.b, 255 );
	love.graphics.print( ">> "..console.CText..console.Blink, 5, ( love.graphics.getHeight()/1.25 ) - 25, 0, 0.2, 0.2 );

	for i = 1, #console.Lines do
		local v = console.Lines
		local c = color.White;
		if console.Lines.col then c = console.Lines.col; end
		love.graphics.setColor( c.r, c.g, c.b, 255 );
		love.graphics.print( "> "..v[i].text, 3, console.cLine - (((console.LNum - 1) - i)*20), 0, 0.2, 0.2 );
	end
end

function CONSOLE.Update(dt)
	if love.keyboard.isDown("lshift") then console.Shift = true; else console.Shift = false; end
	console.BTime = console.BTime + 1*dt;
	if console.BTime >= 1 then console.Blink = "|";
	else console.Blink = " "; end
	if console.BTime > 2 then console.BTime = 0; end
end

function CONSOLE.keyPressed( key, unicode )
	if key == "`" or key == "~" then 
		console.Enabled = not console.Enabled; 
		if console.Enabled then love.keyboard.setKeyRepeat( 0.5, 0.1 );
		else love.keyboard.setKeyRepeat( 0, 0 ); end
	end

	if key == "backspace" then console_Type( key, "remove" ); end
	if key == "return" then console_Type( key, "enter" ); end

	for i = 1, #console.Blacklist do
		if key == console.Blacklist[i] then 
			return;
		elseif i == #console.Blacklist then
			local key = key;
			if console.Shift then 
				key = console_Shift(key);
			end
			key = console_Replace(key);
			console_Type( key, "add" );
		end
	end
end

function console_Type( key, func )
	if func then
		if func == "add" then console.CText = (console.CText..key); end
		if func == "remove" then console.CText = string.sub( console.CText, 1, -2 ); end
		if func == "enter" then console_AddLine( console.CText ); end
	else return end
end

function console_AddLine( text, color )
	local text = text
	local color = color
	console_checkString( text );
	console.LNum = console.LNum + 1;
	console.Lines[console.LNum] = console.Lines:New( text, color );
	console.CText = "";
end

function console_checkString( text )
	for i = 1, #console.Commands do
		if string.starts( text, string.lower(console.Commands[i]) ) then
			local pstring = "COMMAND."..console.Commands[i].."(\""..tostring(text).."\")";
			local string = loadstring( tostring(pstring) );
			string();
		end
	end
end

function console_Shift( key )
	local char = console.ShiftLines[key]
	if char then return char; else return string.upper(key); end
end

function console_Replace( key )
	local char = console.Replacements[key];
	if char then return char; else return key; end
end