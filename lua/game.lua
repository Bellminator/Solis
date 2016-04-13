GAME = {};
function GAME.Init( map, first )
	local starttime = os.clock();
	if not first then first = false; end
	game = {}
	game.World = love.physics.newWorld( );
	game.scale = 0.3;
	game.Fade = false;
	game.Map = map;
	global.Alpha = 255;
	game.Time = {};
	game.Time["m"] = 0;
	game.Time["s"] = 0; 
	game.CamX, game.CamY = 0, 0;

	planet = {}
	function planet:New( name, desc, ox, x, y, Col, Rad, img, Body, Shape, Clamp )
		local object = { name = name or "A strange planet", desc = desc or "It looks very strange", ox = ox or false, x = x, y = y, Col = Col, Rad = Rad, img = img, Body = Body, Shape = Shape }
		setmetatable( object, { __index = planet } );
		return object;
	end

	--Load up our map data.
	worldData = {}
	MAP[map](true);
	GLOBAL.createStars( worldData.starnum, worldData.stars, worldData.x + 500, worldData.y + 500);

	for i = 1, #planet do
		planet[i].Body = love.physics.newBody( game.World, planet[i].x, planet[i].y )
	    planet[i].Shape = love.physics.newCircleShape( 0, 0, planet[i].Rad )
	    planet[i].Clamp = love.physics.newFixture( planet[i].Body, planet[i].Shape );
	end

	worldData.curPlanet, worldData.curPlanetShape = planet[1].Body, planet[1].Shape;
	worldData.gravity = worldData.gravity or 0.5;

	--Set our physical world boundries.
	GAME.setWorldBounds()

	--lets create our player
	ply = {}
	ply.Pos = { x = worldData.spawnpoint.x, y = worldData.spawnpoint.y };
	ply.Left, ply.Right, ply.Up = { x = 0, y = 0 }, { x = 0, y = 0 }, {x = 0, y = 0 };
	ply.Size = 10;
	ply.Body = love.physics.newBody( game.World, ply.Pos.x, ply.Pos.y, "dynamic" );
	ply.Oxygen = 100;
	ply.Stars = 0;
	ply.Powerups = {};

	ply.Shape = love.physics.newPolygonShape( 
	    math.cos( ply.Body:getAngle() )*ply.Size,
	    math.sin( ply.Body:getAngle() )*ply.Size,
	    math.cos( ply.Body:getAngle() - 90 )*ply.Size,
	    math.sin( ply.Body:getAngle() - 90 )*ply.Size,
	    math.cos( ply.Body:getAngle() + 90 )*ply.Size,
	    math.sin( ply.Body:getAngle() + 90 )*ply.Size
	);

	ply.Clamp = love.physics.newFixture( ply.Body, ply.Shape );

	--Get our pause menu ready for use.
	PAUSE.Init();

	--Lets get rid of variables we don't need.
	menu = nil;

	--Remove any entities from the previous map load?
	entities = {};

	print("[Solis] Game initialized!");
	GLOBAL.getTime( "Game.lua", starttime, os.clock() );
end

function GAME.Draw()
	love.graphics.push();
  	love.graphics.scale( game.scale + 1, game.scale + 1 )
  	love.graphics.translate((love.graphics.getWidth()/((game.scale+1)*2)) - ply.Pos.x, (love.graphics.getHeight()/((game.scale+1)*2)) - ply.Pos.y)

	love.graphics.setColor( 255, 255, 255, global.curAlpha );
	love.graphics.setPointStyle("smooth")
	for i = 1, #worldData.stars do 
		if worldData.stars[i][1] > ( ply.Pos.x - ( love.graphics.getWidth()/2) ) and worldData.stars[i][1] < ( ply.Pos.x + ( love.graphics.getWidth()/2) ) then
			if worldData.stars[i][2] > ( ply.Pos.y - ( love.graphics.getHeight()/2) ) and worldData.stars[i][2] < ( ply.Pos.y + ( love.graphics.getHeight()/2) ) then
				love.graphics.setPointSize( worldData.stars[i][3]*(game.scale + 1) )
				love.graphics.point( worldData.stars[i][1], worldData.stars[i][2] );
			end
		end
	end

	for k,v in ipairs(planet) do
		if v.ox then	
			local scale = 1*(v.Rad/500);
			setColor( color.SkyBlue );
			love.graphics.draw( img.Base, v.x, v.y, 0, scale, scale, 500, 500 ); 
		end
		
		love.graphics.setColor( v.Col.r, v.Col.g, v.Col.b, global.curAlpha );
		love.graphics.circle( "fill", v.x, v.y, v.Rad, 100 );
		if v.img then love.graphics.draw( v.img, v.x, v.y, 0, 1, 1, 500, 500 ); end
	end

	--Draw our player
	local upx, upy = ply.Pos.x + ( ply.Up.x/2 ), ply.Pos.y + ( ply.Up.y/2 );
	local leftx, lefty = ply.Pos.x + ( ply.Left.x/2 ), ply.Pos.y + ( ply.Left.y/2 );
	local rightx, righty = ply.Pos.x + ( ply.Right.x/2 ), ply.Pos.y + ( ply.Right.y/2 );

	love.graphics.setColor( 255, 255, 255, global.curAlpha );
	love.graphics.polygon( "fill", ply.Body:getWorldPoints( ply.Shape:getPoints() ) );

	setColor( color.Blue );
	love.graphics.line( leftx, lefty, upx, upy, rightx, righty );

	--See if our mouse is hovering over a planet and if so display the planets info.
	for k,v in ipairs( planet ) do
		local hit = v.Clamp:testPoint( global.mouse.wx, global.mouse.wy );
		if hit then
			setColor( color.White );
			love.graphics.print( v.name, global.mouse.wx, global.mouse.wy, 0, 0.2, 0.2 );
			love.graphics.print( v.desc, global.mouse.wx, global.mouse.wy + 17, 0, 0.1, 0.1 );
		end
	end

	--Draw our entities
	ENT.Draw();

	--Pre-pop debug drawing
	if settings.debug then
		setColor( color.Green );
		love.graphics.line( ply.Pos.x, ply.Pos.y, ply.Pos.x + ply.Up.x, ply.Pos.y + ply.Up.y );
		setColor( color.Blue );
		love.graphics.line( ply.Pos.x, ply.Pos.y, ply.Pos.x + ply.Left.x, ply.Pos.y + ply.Left.y );
		setColor( color.Gold );
		love.graphics.line( ply.Pos.x, ply.Pos.y, ply.Pos.x + ply.Right.x, ply.Pos.y + ply.Right.y );

		setColor( color.Purple );
		love.graphics.print( math.floor(ply.Pos.x)..", "..math.floor(ply.Pos.y), ply.Pos.x, ply.Pos.y, 0, 0.2, 0.2 );

		--Draw planet gravitational pulls
		for k,v in ipairs( planet ) do
			if worldData.curPlanet == v.Body then setColor( color.Green );
			else setColor( color.Red ); end
			love.graphics.circle( "line", v.x, v.y, v.Rad*2.5 );
		end
	end

	love.graphics.pop();

	--Everything we want to keep in the same place on the screen.
	if settings.debug then
		setColor( color.Purple );
		love.graphics.print( math.floor(global.mouse.wx).."; "..math.floor(global.mouse.wy), global.mouse.x, global.mouse.y, 0, 0.2, 0.2 );
	end

	local function getSecond()
		if game.Time["s"] > 10 then return math.floor( game.Time["s"] ); 
		else return "0"..math.floor( game.Time["s"] ); end
	end

	setColor( color.White );

	if not pause.Enabled then
		love.graphics.print( "Time: "..game.Time["m"]..":"..getSecond(), 5, 5, 0, 0.2, 0.2 );
		love.graphics.print( "Stars: "..ply.Stars, 5, 25, 0, 0.2, 0.2 );
		love.graphics.print( "Oxygen: 100%", 5, 45, 0, 0.2, 0.2 );
	end 

	--Draw our pause menu
	if pause.Enabled then PAUSE.Draw(); end

	if game.Fade then
		global.Alpha = 0;
		if global.curAlpha < 1 then
			global.newState = MENU;
		end
	end
end

function GAME.Update(dt)
	--Update our pause menu, if its not enabled then update the world.
	game.CamX, game.CamY = (love.graphics.getWidth()/((game.scale+1)*2)) - ply.Pos.x, (love.graphics.getHeight()/((game.scale+1)*2)) - ply.Pos.y;
	if pause.Enabled then
		PAUSE.Update(dt);
	else
		if game.Time["start"] then
			game.Time["s"] = os.time() - game.Time["init"];
			if math.floor( game.Time["s"] ) >= 60 then 
				game.Time["m"] = game.Time["m"] + 1;
				game.Time["init"] = os.time();
			end
		end
		game.World:update(dt);

		GAME.mouseToWorld( );

		--Set our player directions
		GAME.gravityCalc();
		--local mAng = math.atan2( ((love.graphics.getWidth()/2) - global.mouse.y), ((love.graphics.getHeight()/2) - global.mouse.x) )
		mAng = math.atan2( (ply.Pos.y - global.mouse.wy), (ply.Pos.x - global.mouse.wx) )
		ply.Body:setAngle( mAng + math.rad( 180 ) );

		ply.Pos.x, ply.Pos.y = ply.Body:getPosition();

	    ply.Up.x = math.cos ( ply.Body:getAngle() )*(ply.Size*3);
	    ply.Up.y = math.sin ( ply.Body:getAngle() )*(ply.Size*3);

	    ply.Left.x = math.cos( ply.Body:getAngle() - 90 )*(ply.Size*3);
	    ply.Left.y = math.sin( ply.Body:getAngle() - 90 )*(ply.Size*3);

	    ply.Right.x = math.cos( ply.Body:getAngle() + 90 )*(ply.Size*3);
	    ply.Right.y = math.sin( ply.Body:getAngle() + 90 )*(ply.Size*3);

		--Movement 
		if not console.Enabled then
			if love.keyboard.isDown("w") then ply.Body:applyForce( ply.Up.x/2, ply.Up.y/2 ); end
			if love.keyboard.isDown("s") then ply.Body:applyForce( -ply.Up.x/2, -ply.Up.y/2 ); end
			if love.keyboard.isDown("a") then ply.Body:applyForce( ply.Left.x/2, ply.Left.y/2 ); end
			if love.keyboard.isDown("d") then ply.Body:applyForce( ply.Right.x/2, ply.Right.y/2 ); end
		end

		--Update our entities
		ENT.Update();

		--Check to see if the window is focused, if not pause the game.
		if not love.window.hasFocus() then
			pause.Enabled = true;
		end;
	end
end

function GAME.mousePressed( x, y, button, istouch )
	if pause.Enabled then
		PAUSE.mousePressed( x, y, button, istouch );
	else
		if button == "wu" and game.scale < 0.9 then game.scale = game.scale + 0.1; end
		if button == "wd" and game.scale > 0.1 then game.scale = game.scale - 0.1; end
		if button == "l" then ENT.Spawn("laser", ply.Pos.x, ply.Pos.y, ply.Up.x, ply.Up.y); end
		if button == "r" then ENT.Spawn("star_gold", global.mouse.wx, global.mouse.wy); end
	end

	if button == "escape" then
		pause.Enabled = not pause.Enabled;
	end
end

function GAME.keyPressed( key, unicode )
	if not game.Time["start"] then
		game.Time["start"] = true;
		game.Time["init"] = os.time();
	end;

	if key == "escape" then 
		pause.Enabled = not pause.Enabled; 
	end

	if pause.Enabled then
		PAUSE.keyPressed( key, unicode );
	else
		ENT.keyPressed( key, unicode );
	end
end

function GAME.mouseToWorld( )
	global.mouse.wx = ( ply.Pos.x - (love.graphics.getWidth()/2) ) + global.mouse.x;
	global.mouse.wy = ( ply.Pos.y - (love.graphics.getHeight()/2) ) + global.mouse.y;
end

function GAME.gravityCalc()
  --Grab the planet we want to work around. 
  for i = 1, #planet do
    local pdistance = math.sqrt( (ply.Pos.x - planet[i].Body:getX())^2 + (ply.Pos.y - planet[i].Body:getY())^2 )
    if pdistance < planet[i].Shape:getRadius()*2.5 and planet[i].Body~=worldData.curPlanet then
        worldData.curPlanet = planet[i].Body
        worldData.curPlanetShape = planet[i].Shape
    end
  end

  --Planet gravity
  --distance = sqr root of( (x2 - x1)^2  + (y2 - y1)^2 )
  local distance = math.sqrt( (ply.Pos.x - worldData.curPlanet:getX())^2 + (ply.Pos.y - worldData.curPlanet:getY())^2 )
  local x,y = (ply.Pos.x - worldData.curPlanet:getX()), (ply.Pos.y - worldData.curPlanet:getY())
  local area = math.pi*(worldData.curPlanetShape:getRadius()^2);
  local curDistance, cx, cy, gravityx, gravityy = nil, nil, nil, nil, nil;

  if curDistance ~= distance and (cx ~= x and cy ~= y) then
    if distance < worldData.curPlanetShape:getRadius()*2.5 then
      gravityx = (-x*(area/(distance^2)))*worldData.gravity
      gravityy = (-y*(area/(distance^2)))*worldData.gravity
    else
      gravityx = 0
      gravityy = 0
    end

    curDistance = distance
    cx, cy = x, y
  end

  ply.Body:applyForce( gravityx/2, gravityy/2 );
end

function GAME.setWorldBounds()
	--Top
		worldData.TWallB = love.physics.newBody( game.World, -worldData.x, -worldData.y );
		worldData.TWallS = love.physics.newRectangleShape( 0, 0, worldData.x*4, 1 );
		worldData.TWallC = love.physics.newFixture( worldData.TWallB, worldData.TWallS );
	--Bottom
		worldData.BWallB = love.physics.newBody( game.World, -worldData.x, worldData.y );
		worldData.BWallS = love.physics.newRectangleShape( 0, 0, worldData.x*4, 1 );
		worldData.BWallC = love.physics.newFixture( worldData.BWallB, worldData.BWallS );
	--Left
		worldData.LWallB = love.physics.newBody( game.World, -worldData.x, -worldData.y );
		worldData.LWallS = love.physics.newRectangleShape( 0, 0, 1, worldData.y*4 );
		worldData.LWallC = love.physics.newFixture( worldData.LWallB, worldData.LWallS );
	--Right
		worldData.RWallB = love.physics.newBody( game.World, worldData.x, -worldData.y );
		worldData.RWallS = love.physics.newRectangleShape( 0, 0, 1, worldData.y*4 );
		worldData.RWallC = love.physics.newFixture( worldData.RWallB, worldData.RWallS );
end