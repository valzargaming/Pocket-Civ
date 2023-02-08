/mob/living/simple_animal/hostile/retaliate/caverncrab
	name = "Cavern crab"
	desc = "An ancient inhabitant of the underground."
	icon_state = "caverncrab"
	icon_living = "caverncrab"
	icon_dead = "caverncrab_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak = list("Chchek","Kek","Tach")
	emote_see = list("clacks its claws.", "shakes.")
	speak_chance = 2
	turns_per_move = 5
	maxHealth = 250
	health = 250
	melee_damage_lower = 25
	melee_damage_upper = 25
	butcher_results = list(/obj/item/food/meat/slab = list(2,4))
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "pokes"
	response_disarm_simple = "poke"
	response_harm_continuous = "bashes"
	response_harm_simple = "bash"
	density = FALSE
	faction = list("hostile")
	attack_sound = 'sound/effects/snap.ogg'
	mob_size = MOB_SIZE_HUMAN
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/hostile/retaliate/caverncrab/Initialize()
	. = ..()