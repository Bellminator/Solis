--Maps
--planet:New( x, y, color, rad, Body, Shape, Effects )
MAP = {}
MAP[1] = function( planets )
	worldData.name = "A Beginners Trek";
	worldData.button = { x = 200, y = 200, size = 100, color = color.Blue };
	worldData.x, worldData.y = 2048, 1536;
	worldData.spawnpoint = { x = 1024, y = 100 };
	worldData.starnum = 3000;
	worldData.stars = {};

	if planets then
		planet[1] = planet:New( "Sun", "A fiery ball of gas.", false, 0, 0, color.Gold, 300, img.Base );
		planet[2] = planet:New( "Kigo", "A sandy red planet with no life forms.", false, 2048/2, 1536/2, color.Red, 150 );
		planet[3] = planet:New( "Htwo", "A planet that is nearly all water. Many aquatic animals live here.", true, 1140, -700, color.Blue, 100 );
	end
end

MAP[2] = function( planets )
	worldData.name = "Halla";
	worldData.button = { x = 150, y = 400, size = 50, color = color.Red };
	worldData.x, worldData.y = 3072, 2304;
	worldData.spawnpoint = { x = 1024, y = 100 };
	worldData.starnum = 4000;
	worldData.stars = {};

	if planets then
		planet[1] = planet:New( "Sun", "A fiery ball of gas.", false, 0, 0, color.Gold, 300, img.Base );
		planet[2] = planet:New( "Cloral", "A planet that is 99% water.", true, 1500, 2200, color.Blue, 200 );
		planet[3] = planet:New( "Denduron", "A green planet with small water masses.", true, -2000, -200, color.Green, 150 );
		planet[4] = planet:New( "Eelong", "A rainforest planet with large trees covering the general area.", true, 500, 1500, color.Green, 175 );
		planet[5] = planet:New( "Veelox", "A planet with grey colored rectangles jutting out from it.", true, -750, 2000, color.Grey, 125 );
		planet[6] = planet:New( "Zadaa", "A desert world inhabited by wilflife.", true, 1800, -600, color.Sand, 225 );
	end
end