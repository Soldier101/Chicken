/mob/living/simple_animal/bot/secbot/grievous //This bot is powerful. If you managed to get 4 eswords somehow, you deserve this horror. Emag him for best results.
	name = "General Beepsky"
	desc = "Is that a secbot with four eswords in its arms...?"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "grievous0"
	health = 150
	maxHealth = 150
	baton_type = /obj/item/melee/transforming/energy/sword
	base_speed = 4 //he's a fast fucker
	var/obj/item/weapon
	var/block_chance = 50


/mob/living/simple_animal/bot/secbot/grievous/toy //A toy version of general beepsky!
	name = "Genewul Bweepskee"
	desc = "An adorable looking secbot with four toy swords taped to its arms"
	health = 50
	maxHealth = 50
	baton_type = /obj/item/toy/sword

/mob/living/simple_animal/bot/secbot/grievous/bullet_act(obj/item/projectile/P)
	if(prob(block_chance))
		visible_message("[src] deflects [P] with its energy swords!")
		playsound(src, 'sound/weapons/blade1.ogg', 50, TRUE)
		return FALSE
	else
		. = ..()

/mob/living/simple_animal/bot/secbot/grievous/Crossed(atom/movable/AM)
	if(ismob(AM) && AM == target)
		visible_message("[src] flails his swords and cuts [AM]!")
		playsound(src,'sound/effects/beepskyspinsabre.ogg',100,TRUE,-1)
		stun_attack(AM)
		return
	..()

/mob/living/simple_animal/bot/secbot/grievous/turn_on()
	..()
	icon_state = "grievous[on]"

/mob/living/simple_animal/bot/secbot/grievous/turn_off()
	..()
	icon_state = "grievous[on]"

/mob/living/simple_animal/bot/secbot/grievous/update_onsprite()
	icon_state = "grievous[on]"

/mob/living/simple_animal/bot/secbot/grievous/Initialize()
	. = ..()
	weapon = new baton_type(src)
	weapon.attack_self(src)
	icon_state = "grievous[on]"

/mob/living/simple_animal/bot/secbot/grievous/attack_hand(mob/living/carbon/human/H)
	if((H.a_intent == INTENT_HARM) || (H.a_intent == INTENT_DISARM))
		if(mode == BOT_HUNT) //If he already has his swords out
			retaliate(H)
			if(try_block())
				return FALSE

	return ..()

/mob/living/simple_animal/bot/secbot/grievous/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weldingtool) && user.a_intent != INTENT_HARM)
		return
	if(!istype(W, /obj/item/screwdriver) && (W.force) && (!target) && (W.damtype != STAMINA) )
		retaliate(user)
		if(try_block())
			return FALSE
		else
			return ..()
	else
		return ..()

/mob/living/simple_animal/bot/secbot/grievous/proc/try_block()
	if(mode == BOT_HUNT)
		if(prob(block_chance))
			visible_message("[src] deflects the attack with his energy swords!")
			playsound(src, 'sound/weapons/blade1.ogg', 50, TRUE,-1)
			return TRUE
	else
		return FALSE

/mob/living/simple_animal/bot/secbot/grievous/stun_attack(mob/living/carbon/C) //Criminals don't deserve to live
//	playsound(loc, 'sound/weapons/blade1.ogg', 50, 1, -1)
	weapon.attack(C, src)
	playsound(src, 'sound/weapons/blade1.ogg', 50, TRUE, -1)
	if(C.stat == DEAD)
		addtimer(CALLBACK(src, .proc/update_onsprite), 2)
		back_to_idle()


/mob/living/simple_animal/bot/secbot/grievous/handle_automated_action()
	if(!on)
		return
	switch(mode)
		if(BOT_IDLE)		// idle
			update_onsprite()
			walk_to(src,0)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = BOT_START_PATROL	// switch to patrol mode
		if(BOT_HUNT)		// hunting for perp
			icon_state = "grievous-c"
			playsound(src,'sound/effects/beepskyspinsabre.ogg',100,TRUE,-1)
			// general beepsky doesn't give up so easily, jedi scum
			if(frustration >= 20)
				walk_to(src,0)
				back_to_idle()
				return
			if(target)		// make sure target exists
				if(Adjacent(target) && isturf(target.loc))	// if right next to perp
					stun_attack(target)
				//	mode = BOT_PREP_ARREST
					anchored = TRUE
					target_lastloc = target.loc
					return
				else								// not next to perp
					var/turf/olddist = get_dist(src, target)
					walk_to(src, target,1,4)
					if((get_dist(src, target)) >= (olddist))
						frustration++
					else
						frustration = 0
			else
				back_to_idle()

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()

/mob/living/simple_animal/bot/secbot/grievous/look_for_perp()
	anchored = FALSE
	var/judgement_criteria = judgement_criteria()
	for (var/mob/living/carbon/C in view(7,src)) //Let's find us a criminal
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = C.assess_threat(judgement_criteria, weaponcheck=CALLBACK(src, .proc/check_for_weapons))

		if(!threatlevel)
			continue

		else if(threatlevel >= 4)
			target = C
			oldtarget_name = C.name
			speak("Level [threatlevel] infraction alert!")
			playsound(src, pick('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg'), 50, FALSE)
			playsound(src,'sound/weapons/saberon.ogg',50,TRUE,-1)
			visible_message("[src] ignites his energy swords!")
			icon_state = "grievous-c"
			visible_message("<b>[src]</b> points at [C.name]!")
			mode = BOT_HUNT
			INVOKE_ASYNC(src, .proc/handle_automated_action)
			break
		else
			continue


/mob/living/simple_animal/bot/secbot/grievous/explode()

	walk_to(src,0)
	visible_message("<span class='boldannounce'>[src] lets out a huge cough as it blows apart!</span>")
	var/atom/Tsec = drop_location()

	var/obj/item/bot_assembly/secbot/Sa = new (Tsec)
	Sa.build_step = 1
	Sa.add_overlay("hs_hole")
	Sa.created_name = name
	new /obj/item/assembly/prox_sensor(Tsec)

	if(prob(50))
		drop_part(robot_arm, Tsec)

	do_sparks(3, TRUE, src)
	qdel(weapon)
	for(var/IS = 0 to 4)
		new /obj/item/melee/transforming/energy/sword/saber(Tsec)
	new /obj/effect/decal/cleanable/oil(loc)
	qdel(src)

/mob/living/simple_animal/bot/secbot/grievous/toy/explode()

	walk_to(src,0)
	visible_message("<span class='boldannounce'>[src] lets out a huge cough as it blows apart!</span>")
	var/atom/Tsec = drop_location()

	var/obj/item/bot_assembly/secbot/Sa = new (Tsec)
	Sa.build_step = 1
	Sa.add_overlay("hs_hole")
	Sa.created_name = name
	new /obj/item/assembly/prox_sensor(Tsec)

	if(prob(50))
		drop_part(robot_arm, Tsec)

	do_sparks(3, TRUE, src)
	qdel(weapon)
	for(var/IS = 0 to 4)
		new /obj/item/toy/sword(Tsec)
	new /obj/effect/decal/cleanable/oil(loc)
	qdel(src)
