GLOBAL_VAR_INIT(temperature_seed, 0)

/datum/map_generator/caves
	var/name = "Caves"

/datum/map_generator/caves/generate_terrain(list/turfs)
	if(CONFIG_GET(flag/disable_generation))
		return
	to_chat(world, "Generating terrain for [name]...")
	if(!GLOB.temperature_seed)
		GLOB.temperature_seed = rand(1, 2000)
	var/start_time = REALTIMEOFDAY
	var/list/height_values = fbm(world.maxx, world.maxy)
	var/turf/first_turf = turfs[1]
	var/list/temp_values = fbm3d(world.maxx, world.maxy, first_turf.z, GLOB.temperature_seed, frequency=0.006, lacunarity=0.4, persistence=0.4)
	for(var/turf/T in turfs)
		var/height = text2num(height_values[world.maxx * (T.y - 2) + T.x])
		var/temp = text2num(temp_values[world.maxx * (T.y - 2) + T.x])
		var/turf/turf_type
		switch(height)
			if(-INFINITY to -0.7)
				turf_type = /turf/open/water
			if(-0.7 to -0.45)
				turf_type = /turf/open/floor/dirt
				generate_turf_flora(T, 8)
			if(-0.45 to -0.3)
				if(temp > 0)
					turf_type = /turf/open/floor/sand
				else
					turf_type = /turf/open/floor/rock
					generate_turf_flora(T, 1)
			if(-0.3 to INFINITY)
				if(temp > 0)
					turf_type = /turf/closed/mineral/random/sand
				else
					turf_type = /turf/closed/mineral/random/dwarf_lustress
		T.ChangeTurf(turf_type, initial(turf_type.baseturfs))
	to_chat(world, span_green(" -- #<b>[name]</b>:> <b>[(REALTIMEOFDAY - start_time)/10]s</b> -- "))
	log_world("[name] is done job for [(REALTIMEOFDAY - start_time)/10]s!")

/datum/map_generator/caves/generate_turf_flora(turf, chance)
	if(prob(chance))
		var/obj/structure/plant/tree/towercap/temp = new (turf)
		temp.growthstage = rand(0, temp.growthstages)
		temp.growthdelta = rand(temp.growthdelta, 400) SECONDS
		temp.update_appearance()

/datum/map_generator/caves/upper
	name = "Upper Caves"

/datum/map_generator/caves/middle
	name = "Middle Caves"

/datum/map_generator/caves/bottom
	name = "Bottom Caves"

/area/dwarf/cavesgen
	name = "Caverns"
	icon_state = "cavesgen"
	static_lighting = TRUE
	base_lighting_alpha = 0
	ambientsounds = AWAY_MISSION
	area_flags = CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED
	sound_environment = SOUND_ENVIRONMENT_CAVE
	ambientsounds = list('sound/ambience/caves8.ogg', 'sound/ambience/caves_old.ogg')
	map_generator = /datum/map_generator/caves

/area/dwarf/cavesgen/upper_level
	map_generator = /datum/map_generator/caves/upper

/area/dwarf/cavesgen/middle_level
	map_generator = /datum/map_generator/caves/middle

/area/dwarf/cavesgen/bottom_level
	map_generator = /datum/map_generator/caves/bottom


/datum/map_generator/surface
	var/name = "Surface"
/datum/map_generator/surface/generate_terrain(list/turfs)
	if(CONFIG_GET(flag/disable_generation))
		return
	to_chat(world, "Generating terrain for [name]...")
	var/start_time = REALTIMEOFDAY
	var/list/height_values = fbm(world.maxx, world.maxy)
	var/turf/first_turf = turfs[1]
	var/list/temp_values = fbm3d(world.maxx, world.maxy, first_turf.z, GLOB.temperature_seed, frequency=0.006, lacunarity=0.4, persistence=0.4)

	for(var/turf/T in turfs)
		var/height = text2num(height_values[world.maxx * (T.y - 2) + T.x])
		var/temp = text2num(temp_values[world.maxx * (T.y - 2) + T.x])
		var/turf/turf_type
		switch(height)
			if(-INFINITY to -0.7)
				turf_type = /turf/open/water
			if(-0.7 to -0.45)
				if(temp > 0)
					turf_type = /turf/open/floor/dirt
					generate_turf_flora(T, 5)
				else
					turf_type = /turf/open/floor/dirt/grass
					generate_turf_flora(T, 8)
			if(-0.45 to -0.3)
				if(temp > 0)
					turf_type = /turf/open/floor/sand
				else if(temp < 0)
					turf_type = /turf/open/floor/rock/surface
					generate_turf_flora(T, 1)
			if(-0.3 to INFINITY)
				turf_type = /turf/open/floor/dirt/grass
		T.ChangeTurf(turf_type, initial(turf_type.baseturfs))
	generate_river(first_turf.z)

	to_chat(world, span_green(" -- #<b>[name]</b>:> <b>[(REALTIMEOFDAY - start_time)/10]s</b> -- "))
	log_world("[name] is done job for [(REALTIMEOFDAY - start_time)/10]s!")

/datum/map_generator/surface/generate_turf_flora(turf, chance)
	if(prob(chance))
		var/obj/structure/plant/tree/apple/temp = new (turf)
		temp.growthstage = rand(0, temp.growthstages)
		temp.growthdelta = rand(temp.growthdelta, 400) SECONDS
		temp.update_appearance()

/datum/map_generator/proc/generate_river(z_level)
	var/river_x = rand(1, world.maxx)
	var/river_y = 1
	while(river_y <= world.maxy)
		to_chat(world, "Generating river at [river_x], [river_y], [z_level]")
		var/turf/T = locate(river_x, river_y, z_level)
		if(T)
			T.ChangeTurf(/turf/open/water)
		handle_river_direction_change(river_x)
		handle_river_fork(river_x, river_y, z_level)
		river_y += 1

// Just widens the river a bit
/datum/map_generator/proc/handle_river_direction_change(var/river_x)
	if(prob(5)) // 5% chance to change direction
		river_x += rand(-1, 1)
		if(river_x < 1) river_x = 1
		if(river_x > world.maxx) river_x = world.maxx

// Doesn't seem to work yet
/datum/map_generator/proc/handle_river_fork(var/river_x, var/river_y, var/z_level)
	if(prob(2)) // 2% chance to fork
		var/fork_x = river_x + rand(-1, 1)
		if(fork_x >= 1 && fork_x <= world.maxx)
			var/fork_y = river_y + 1
			while(fork_y <= world.maxy)
				var/turf/F = locate(fork_x, fork_y, z_level)
				if(F)
					F.ChangeTurf(/turf/open/water)
				handle_river_direction_change(fork_x)
				fork_y += 1

/area/dwarf/surfacegen
	name = "Surface"
	icon_state = "surfacegen"
	static_lighting = TRUE
	base_lighting_alpha = 255
	always_lit = TRUE
	light_range = 2
	light_power = 0.75
	//ambientsounds = AWAY_MISSION
	//area_flags = CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED
	//sound_environment = SOUND_ENVIRONMENT_CAVE
	//ambientsounds = list('sound/ambience/caves8.ogg', 'sound/ambience/caves_old.ogg')
	map_generator = /datum/map_generator/surface

/area/dwarf/surfacegen/Initialize(mapload)
	var/L = new/datum/light_source(src, src)
	light = L
	. = ..()
