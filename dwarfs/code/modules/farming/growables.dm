/obj/item/growable
	name = "growable"
	desc = "Plant produce it."
	icon = 'dwarfs/icons/farming/growable.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/edible = FALSE // some types are edible; some seeds are edible
	var/list/food_reagents
	var/food_flags
	var/foodtypes
	var/max_volume
	var/eat_time
	var/list/tastes
	// var/list/eatverbs
	var/bite_consumption
	var/mood_event_type = /datum/mood_event/ate_raw_food
	var/mood_gain = -2
	var/mood_duration = 2 MINUTES
	var/fuel_value = 1

/obj/item/growable/proc/MakePressable()
	return

/obj/item/growable/proc/MakeGrindable()
	return

/obj/item/growable/proc/MakeProcessable()
	return

/obj/item/growable/proc/on_consume(mob/living/eater, mob/living/feeder)
	var/datum/component/mood/M = eater.GetComponent(/datum/component/mood)
	if(!M)
		return
	if(mood_event_type)
		M.add_event(null, "food", mood_event_type, mood_gain ? mood_gain : null, mood_duration ? mood_duration : null)

/obj/item/growable/Initialize()
	. = ..()
	if(edible)
		if(!food_reagents)
			food_reagents = list(/datum/reagent/consumable/nutriment=5)
		AddComponent(/datum/component/edible,\
				initial_reagents = food_reagents,\
				food_flags = food_flags,\
				foodtypes = foodtypes,\
				volume = max_volume,\
				eat_time = eat_time,\
				tastes = tastes,\
				bite_consumption = bite_consumption,\
				on_consume = CALLBACK(src, PROC_REF(on_consume)))
	MakeGrindable()
	MakePressable()
	MakeProcessable()

/obj/item/growable/pod
	name = "pod"
	desc = "Not edible structure containing seeds."

/obj/item/growable/Initialize()
	. = ..()
	pixel_x = base_pixel_x + rand(-8, 8)
	pixel_y = base_pixel_y + rand(-8, 8)
	START_PROCESSING(SSplants, src)
	// TODO: fruits rot when not in storage

/obj/item/growable/fruit/Destroy()
	. = ..()
	STOP_PROCESSING(SSplants, src)

/obj/item/growable/leaf
	name = "leaf"
	desc = "Green stuff that comes from plants."

/obj/item/growable/apple
	name = "apple"
	desc = "A crisp, juicy fruit favored by dwarves for its refreshing taste and versatility in cooking."
	icon_state = "apple"
	edible = TRUE
	foodtypes = FRUIT
	eat_time = 2
	tastes = list("apple" = 1)
	//bite_consumption = 1
	mood_gain = -1
	food_reagents = list(/datum/reagent/consumable/nutriment=5)

/obj/item/growable/apple/proc/On_Consume(var/mob/M)
	var/obj/item/growable/seeds/tree/apple/A = new()
	A.forceMove(loc)
	. = ..()

/obj/item/growable/apple/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/kitchen/knife))
		to_chat(user, span_notice("You start slicing [src]..."))
		if(do_after(user, 2 SECONDS))
			to_chat(user, span_notice("You sliced [src] and discarded the core."))
			/* Placeholder harvesting code for apple slices
			var/mob/living/carbon/human/H = user
			var/obj/item/apple/slices/S = new() // Pending new icon
			var/held_index = H.is_holding(src)
			if(held_index)
				H.put_in_hand(S, held_index)
			else
				S.forceMove(loc)
			*/
			var/obj/item/growable/seeds/tree/apple/A = new()
			A.forceMove(loc)
			var/obj/item/growable/apple/core/T = new()
			T.forceMove(loc)
			qdel(src)

/obj/item/growable/apple/core
	name = "apple core"
	desc = "The remnants of an apple, with most of the flesh eaten away. Dwarves often discard or burn these after enjoying the fruit."
	icon_state = "apple-core"
	edible = FALSE

/obj/item/growable/apple/core/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/kitchen/knife))
		to_chat(user, span_notice("You start slicing the seeds out of [src]..."))
		if(do_after(user, 2 SECONDS))
			to_chat(user, span_notice("You harvest the seeds from [src]."))
			var/obj/item/growable/seeds/tree/apple/A = new()
			A.forceMove(loc)
			qdel(src)

/obj/item/growable/apple/core/get_fuel()
	return fuel_value

/obj/item/growable/cave_wheat
	name = "cave wheat"
	desc = "Grey wheat, growing in dark caves. Dwarfs favorirte beer component."
	icon_state = "cave_wheat"
	mood_gain = -3
	food_reagents = list(/datum/reagent/consumable/nutriment=5)

/obj/item/growable/cave_wheat/MakeGrindable()
	AddComponent(/datum/component/grindable, /datum/reagent/grain/cave_wheat, 10)

/obj/item/growable/barley
	name = "barley"
	desc = "Grain growing on the surface, most common in the human cities."
	icon_state = "barley"
	mood_gain = -3
	food_reagents = list(/datum/reagent/consumable/nutriment=5)

/obj/item/growable/barley/MakeGrindable()
	AddComponent(/datum/component/grindable, /datum/reagent/grain/barley, 10)

/obj/item/growable/turnip
	name = "turnip"
	desc = "Turnips are easy to grow and provide nutritious roots."
	icon_state = "turnip"
	edible = TRUE
	mood_gain = -1
	food_reagents = list(/datum/reagent/consumable/nutriment=5)

/obj/item/growable/carrot
	name = "carrot"
	desc = "Everybody knows what a carrot is."
	icon_state = "carrot"
	edible = TRUE
	mood_gain = -1
	food_reagents = list(/datum/reagent/consumable/nutriment=5)

/obj/item/growable/cotton
	name = "cotton"
	desc = "No animal was harmed during picking these. Cannot say it about other humanoid species."
	icon_state = "cotton"

/obj/item/growable/cotton/attack_self(mob/user, modifiers)
	var/obj/item/stack/sheet/string/S = new(null, 2)
	var/held_index = user.is_holding(src)
	qdel(src)
	user.put_in_hand(S, held_index)
	to_chat(user, span_notice("You weave [src] into a string."))

/obj/item/growable/sweet_pod
	name = "sweet pod"
	desc = "Plant bearing a sweet fruits when grown."
	icon_state = "sweet_pod"
	edible = TRUE
	mood_gain = -1
	food_reagents = list(/datum/reagent/consumable/nutriment=5)

/obj/item/growable/sweet_pod/MakePressable()
	AddComponent(/datum/component/pressable, /datum/reagent/consumable/juice/sweet_pod, 10)

/obj/item/growable/grape
	name = "grape"
	desc = "Small, juicy fruits that can be eaten raw or used to make wine."
	icon_state = "grape"
	edible = TRUE
	mood_gain = -1
	food_reagents = list(/datum/reagent/consumable/nutriment=5)

/obj/item/growable/grape/MakePressable()
	AddComponent(/datum/component/pressable, /datum/reagent/consumable/juice/grape, 10)

/obj/item/growable/pig_tail
	name = "pig tail"
	desc = "Despite of its name, it's fully vegan. Maybe except the worms."
	icon_state = "pig_tail"

/obj/item/growable/pig_tail/attack_self(mob/user, modifiers)
	var/obj/item/stack/sheet/string/S = new()
	var/held_index = user.is_holding(src)
	qdel(src)
	user.put_in_hand(S, held_index)
	to_chat(user, span_notice("You weave [src] into a string."))

/obj/item/growable/plump_helmet
	name = "plump helmet"
	desc = "A big purple shrooms treasured by dwarves."
	icon_state = "plump_helmet"
	edible = TRUE
	mood_gain = -2
	food_reagents = list(/datum/reagent/consumable/nutriment=5)

/obj/item/growable/plump_helmet/MakePressable()
	AddComponent(/datum/component/pressable, /datum/reagent/consumable/juice/plump, 10)

/obj/item/growable/plump_helmet/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/slice/plump_helmet, 3, 2 SECONDS)
