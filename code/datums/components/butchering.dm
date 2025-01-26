/datum/component/butchering
	/// Time in deciseconds taken to butcher something
	var/speed = 8 SECONDS
	/// Percentage effectiveness; numbers above 100 yield extra drops
	var/effectiveness = 100
	/// Percentage increase to bonus item chance
	var/bonus_modifier = 0
	/// Sound played when butchering
	var/butcher_sound = 'sound/effects/butcher.ogg'
	/// Whether or not this component can be used to butcher currently. Used to temporarily disable butchering
	var/butchering_enabled = TRUE
	/// Whether or not this component is compatible with blunt tools.
	var/can_be_blunt = FALSE
	/// Callback for butchering
	var/datum/callback/butcher_callback

/datum/component/butchering/Initialize(_speed, _butcher_sound, disabled, _can_be_blunt, _butcher_callback)
	if(_speed)
		speed = _speed
	if(_butcher_sound)
		butcher_sound = _butcher_sound
	if(disabled)
		butchering_enabled = FALSE
	if(_can_be_blunt)
		can_be_blunt = _can_be_blunt
	if(_butcher_callback)
		butcher_callback = _butcher_callback
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(onItemAttack))

/datum/component/butchering/proc/onItemAttack(obj/item/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER

	if(user.a_intent != INTENT_HARM)
		return
	if(!isanimal(M))
		return
	var/mob/living/simple_animal/A = M
	if(A.stat == DEAD && A.butcher_results) //can we butcher it?
		if(butchering_enabled && !A.skinned && A.hide_type)
			INVOKE_ASYNC(src, PROC_REF(startSkin), source, A, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN
		if(butchering_enabled && (can_be_blunt || source.get_sharpness()))
			INVOKE_ASYNC(src, PROC_REF(startButcher), source, A, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/butchering/proc/startButcher(obj/item/source, mob/living/simple_animal/M, mob/living/user)
	to_chat(user, span_notice("You start butchering [M]..."))
	playsound(M.loc, butcher_sound, 50, TRUE, -1)
	if(do_mob(user, M, speed*user.mind.get_skill_modifier(/datum/skill/butchering, SKILL_SPEED_MODIFIER)) && M.Adjacent(source))
		Butcher(user, M)

/datum/component/butchering/proc/startSkin(obj/item/source, mob/living/simple_animal/M, mob/living/user)
	to_chat(user, span_notice("You start skinning [M]..."))
	playsound(M.loc, butcher_sound, 50, TRUE, -1)
	if(do_mob(user, M, speed*user.mind.get_skill_modifier(/datum/skill/skinning, SKILL_SPEED_MODIFIER)) && M.Adjacent(source))
		Skin(user, M)

/datum/component/butchering/proc/Skin(mob/living/butcher, mob/living/simple_animal/A)
	var/full_chance = butcher.mind.get_skill_modifier(/datum/skill/skinning, SKILL_PROBS_MODIFIER)
	var/damaged_chance = butcher.mind.get_skill_modifier(/datum/skill/skinning, SKILL_PROBS2_MODIFIER)
	if(prob(full_chance))
		butcher.visible_message(span_notice("[butcher] skins [A]."), \
			span_notice("You skin [A]."))
		new A.hide_type(get_turf(A))
		butcher.mind.adjust_experience(/datum/skill/skinning, 37)
	else if(prob(damaged_chance))
		butcher.visible_message(span_notice("[butcher] poorly skins [A]."), \
			span_notice("You poorly skin [A]."))
		var/dam_hidetype = initial(A.hide_type.damaged_type)
		new dam_hidetype(get_turf(A))
		butcher.mind.adjust_experience(/datum/skill/skinning, 19)
	else
		butcher.visible_message(span_notice("[butcher] fails to skin [A]."), \
			span_warning("You fail to skin [A]."))
		butcher.mind.adjust_experience(/datum/skill/skinning, 7)
	A.skinned = TRUE
	if(A.icon_skinned)
		A.icon_state = A.icon_skinned

/**
 * Handles the butchering of a target mob, producing loot based on butcher_results and the butcher's skill level
 *
 * Arguments:
 * - [butcher][/mob/living]: The mob doing the butchering
 * - [A][/mob/living]: The mob being butchered
 */
/datum/component/butchering/proc/Butcher(mob/living/butcher, mob/living/simple_animal/A)
	var/list/results = list()
	var/turf/T = A.drop_location()
	var/lower_modifier = butcher.mind.get_skill_modifier(/datum/skill/butchering, SKILL_AMOUNT_MIN_MODIFIER)
	var/upper_modifier = butcher.mind.get_skill_modifier(/datum/skill/butchering, SKILL_AMOUNT_MAX_MODIFIER)
	for(var/V in A.butcher_results)
		var/obj/bones = V
		var/amount_lower = A.butcher_results[bones][1] + lower_modifier
		var/amount_upper = A.butcher_results[bones][2] + upper_modifier
		if(amount_lower < 1 && amount_upper < 1)
			continue
		for(var/_i in 1 to rand(amount_lower, amount_upper))
			results += new bones (T)
			butcher.mind.adjust_experience(/datum/skill/butchering, 12)

		A.butcher_results.Remove(bones) //in case you want to, say, have it drop its results on gib

	if(butcher)
		butcher.visible_message(span_notice("[butcher] butchers [A]."), \
			span_notice("You butcher [A]."))
	butcher_callback?.Invoke(butcher, A)
	A.harvest(butcher)
	A.gib(FALSE, FALSE, TRUE)
