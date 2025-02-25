// Contains everything related to earning research points

/datum/experiment_data
	var/list/saved_best_score = list(
		"Explosion" = 0,
		"Empulse" = 0,
		"Anomalous means" = 0,
	)

	var/list/earned_score = list(
		"Explosion" = 0,
		"Empulse" = 0,
		"Anomalous means" = 0,
	)


	//Determines maximum amount of points that can be earned by certain methods.
	//Total points that can be earned equal highest score multiplied by this number
	var/cap_coeff = 2

	var/list/tech_points = list(
		"materials" = 200,
		"engineering" = 250,
		"phorontech" = 500,
		"powerstorage" = 300,
		"bluespace" = 1000,
		"biotech" = 300,
		"combat" = 500,
		"magnets" = 350,
		"programming" = 400,
		"syndicate" = 5000,
	)

	// How much likely this tech is already known from the start.
	// In this list there is no "syndicate", since it shouldn't be known from the beggining.
	var/list/tech_points_rarity = list(
		"bluespace" = 3,
		"phorontech" = 3,
		"magnets" = 2,
		"combat" = 2,
		"engineering" = 1,
		"powerstorage" = 1,
		"programming" = 1,
		"materials" = 0,
		"biotech" = 0,
	)

	var/list/saved_tech_levels = list() // list("materials" = list(1, 4, ...), ...)
	var/list/saved_autopsy_weapons = list()
	var/list/saved_symptoms = list()
	var/list/saved_slimecores = list()
	//xenoarcheology stuff
	var/list/saved_artifacts = list()

/datum/experiment_data/proc/init_known_tech()
	for(var/tech in tech_points_rarity)
		var/cap_at = rand(0, 4) - tech_points_rarity[tech]
		if(cap_at > 0)
			if(!saved_tech_levels[tech])
				saved_tech_levels[tech] = list()

			for(var/i in 1 to cap_at)
				saved_tech_levels[tech] |= i

/datum/experiment_data/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/datum/experiment_data/proc/get_object_research_value(obj/item/I, ignoreRepeat = FALSE)
	var/list/temp_tech = ConvertReqString2List(I.origin_tech)
	var/item_tech_points = 0
	var/has_new_tech = FALSE
	var/is_board = istype(I, /obj/item/weapon/circuitboard)

	for(var/T in temp_tech)
		if(tech_points[T])
			if(ignoreRepeat)
				item_tech_points += temp_tech[T] * tech_points[T]
			else
				if(saved_tech_levels[T] && (temp_tech[T] in saved_tech_levels[T])) // You only get a fraction of points if you researched items with this level already
					if(!is_board) // Boards are cheap to make so we don't give any points for repeats
						item_tech_points += temp_tech[T] * tech_points[T] * 0.1
				else
					item_tech_points += temp_tech[T] * tech_points[T]
					has_new_tech = TRUE

	if(!ignoreRepeat && !has_new_tech) // We are deconstucting the same items, cut the reward really hard
		item_tech_points = min(item_tech_points, 400)

	return round(item_tech_points)

/datum/experiment_data/proc/do_research_object(obj/item/I)
	var/list/temp_tech = ConvertReqString2List(I.origin_tech)

	for(var/T in temp_tech)
		if(!saved_tech_levels[T])
			saved_tech_levels[T] = list()

		if(!(temp_tech[T] in saved_tech_levels[T]))
			saved_tech_levels[T] += temp_tech[T]

// Returns amount of research points received
/datum/experiment_data/proc/read_science_tool(obj/item/device/science_tool/I)
	var/points = 0

	for(var/weapon in I.scanned_autopsy_weapons)
		if(!(weapon in saved_autopsy_weapons))
			saved_autopsy_weapons += weapon

			// These give more points because they are rare or special
			var/list/special_weapons = list(
				"large organic needle" = 10000,
				"Hulk Foot" = 10000,
				"Explosive blast" = 5000,
				"Electronics meltdown" = 4000,
				"Low Pressure" = 3000,
				"Facepalm" = 2000,
				)
			if(special_weapons[weapon])
				points += special_weapons[weapon]
			else
				points += rand(1,5) * 100 // 100-500 points for random weapon

	for(var/list/scanning_artifact in I.scanned_artifacts)
		var/already_scanned = FALSE
		for(var/list/stored_artifact in saved_artifacts)
			if(stored_artifact["type"] == scanning_artifact["type"] && stored_artifact["first_effect"] == scanning_artifact["first_effect"] && stored_artifact["second_effect"] == scanning_artifact["second_effect"])
				already_scanned = TRUE
				break

		if(!already_scanned)
			points += 10000 //10000 points for main effect
			if(scanning_artifact["second_effect"] != "")
				points += 5000 //5000 points for secondary effect
			saved_artifacts += list(scanning_artifact)

	for(var/symptom in I.scanned_symptoms)
		if(saved_symptoms[symptom])
			continue

		var/list/level_to_points = list(200,500,1000,2500,10000)
		var/level = I.scanned_symptoms[symptom]
		if(level_to_points[level])
			points += level_to_points[level]

		saved_symptoms[symptom] = level

	for(var/core in I.scanned_slimecores)
		if(core in saved_slimecores)
			continue

		var/reward = 1000
		switch(core)
			if(/obj/item/slime_extract/gold)
				reward = 2000
			if(/obj/item/slime_extract/adamantine)
				reward = 3000
			if(/obj/item/slime_extract/bluespace)
				reward = 5000
			if(/obj/item/slime_extract/rainbow)
				reward = 10000
		points += reward
		saved_slimecores += core

	I.clear_data()
	return round(points)

/datum/experiment_data/proc/merge_with(datum/experiment_data/O)
	for(var/tech in O.saved_tech_levels)
		if(!saved_tech_levels[tech])
			saved_tech_levels[tech] = list()

		saved_tech_levels[tech] |= O.saved_tech_levels[tech]

	for(var/weapon in O.saved_autopsy_weapons)
		saved_autopsy_weapons |= weapon

	for(var/list/scanning_artifact in O.saved_artifacts)
		var/has_artifact = FALSE
		for(var/list/stored_artifact in saved_artifacts)
			if(stored_artifact["type"] == scanning_artifact["type"] && stored_artifact["first_effect"] == scanning_artifact["first_effect"] && stored_artifact["second_effect"] == scanning_artifact["second_effect"])
				has_artifact = TRUE
				break
		if(!has_artifact)
			saved_artifacts += list(scanning_artifact)

	for(var/symptom in O.saved_symptoms)
		saved_symptoms[symptom] = O.saved_symptoms[symptom]

	for(var/core in O.saved_slimecores)
		saved_slimecores |= core

	for(var/interaction_type in saved_best_score)
		saved_best_score[interaction_type] = max(saved_best_score[interaction_type], O.saved_best_score[interaction_type])


// Grants research points when explosion happens nearby
/obj/item/device/radio/beacon/interaction_watcher
	name = "Kinetic Energy Scanner"
	desc = "Scans the level of kinetic energy from explosions"

	channels = list("Science" = 1)

	var/sensitivity_radius = 10

	var/message_scientists = TRUE

	// This thing should be really hard to destroy by any means.
	// Some destruction methods(Lord Singuloo) are expected, and not considered anomalous.
	var/anomalous_destruction = TRUE

/obj/item/device/radio/beacon/interaction_watcher/singularity_act()
	anomalous_destruction = FALSE
	return ..()

/obj/item/device/radio/beacon/interaction_watcher/ex_act(severity)
	return

/obj/item/device/radio/beacon/interaction_watcher/emp_act(severity)
	return

/obj/item/device/radio/beacon/interaction_watcher/atom_init()
	. = ..()
	global.interaction_watcher_list += src
	RegisterSignal(SSexplosions, COMSIG_EXPLOSIONS_EXPLODE, PROC_REF(react_explosion))
	RegisterSignal(SSexplosions, COMSIG_EXPLOSIONS_EMPULSE, PROC_REF(react_empulse))

/obj/item/device/radio/beacon/interaction_watcher/attack_self(mob/living/carbon/human/user)
	message_scientists = !message_scientists
	to_chat(user, "<span class='notice'>You toggle [src]'s messaging module [message_scientists ? "on" : "off"]</span>")

/obj/item/device/radio/beacon/interaction_watcher/autosay(message, from, channel, freq = 1459)
	if(!message_scientists)
		return
	return ..()

/obj/item/device/radio/beacon/interaction_watcher/Destroy()
	global.interaction_watcher_list -= src

	if(anomalous_destruction)
		var/calculated_research_points = research_interaction("Anomalous means", 20000, new_score_coeff=1, repeat_score_coeff=0)

		if(calculated_research_points > 0)
			autosay("Destroyed via anomalous means, received [calculated_research_points] research points", name ,"Science", freq = radiochannels["Science"])
		else
			autosay("Destroyed via anomalous means, R&D console is missing or broken", name ,"Science", freq = radiochannels["Science"])

	return ..()

/obj/item/device/radio/beacon/interaction_watcher/proc/research_interaction(inter_type, score, new_score_coeff=800, repeat_score_coeff=160)
	var/calculated_research_points = -1
	for(var/obj/machinery/computer/rdconsole/RD as anything in global.RDcomputer_list)
		if(RD.id == DEFAULT_SCIENCE_CONSOLE_ID)
			var/saved_interaction_score = RD.files.experiments.saved_best_score[inter_type]
			var/saved_earned_points = max(RD.files.experiments.earned_score[inter_type], 1)

			var/added_score = max(0, score - saved_interaction_score)
			var/already_earned_score = min(saved_interaction_score, score)
			var/repetition_cap = max(score, saved_interaction_score) * RD.files.experiments.cap_coeff * new_score_coeff

			var/softcap_coeff = max(repetition_cap / saved_earned_points - 1, 0)

			calculated_research_points = added_score * new_score_coeff + min(already_earned_score * round(repeat_score_coeff * softcap_coeff), repetition_cap - saved_earned_points)

			if(HAS_ROUND_ASPECT(ROUND_ASPECT_ALTERNATIVE_RESEARCH))
				calculated_research_points /= 5

			if(score > saved_interaction_score)
				RD.files.experiments.saved_best_score[inter_type] = score

			RD.files.experiments.earned_score[inter_type] += calculated_research_points
			RD.files.research_points += calculated_research_points

	return calculated_research_points

/obj/item/device/radio/beacon/interaction_watcher/proc/react_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range)

	if(get_dist(epicenter,get_turf(src)) > sensitivity_radius)
		return

	// this is part of old explosions before SS, moved here to keep science same:
	var/power = devastation_range * 2 + heavy_impact_range + light_impact_range //The ranges add up, ie light 14 includes both heavy 7 and devestation 3. So this calculation means devestation counts for 4, heavy for 2 and light for 1 power, giving us a cap of 27 power.

	power = round(power)
	var/calculated_research_points = research_interaction("Explosion", power, new_score_coeff=1600, repeat_score_coeff=320)

	if(calculated_research_points > 0)
		autosay("Detected explosion with power level [power] ([devastation_range]:[heavy_impact_range]:[light_impact_range]), received [calculated_research_points] research points", name ,"Science", freq = radiochannels["Science"])
	else if (calculated_research_points == 0)
		autosay("Detected explosion with power level [power] ([devastation_range]:[heavy_impact_range]:[light_impact_range]), could not acquire any more research points", name ,"Science", freq = radiochannels["Science"])
	else
		autosay("Detected explosion with power level [power] ([devastation_range]:[heavy_impact_range]:[light_impact_range]), R&D console is missing or broken", name ,"Science", freq = radiochannels["Science"])

/obj/item/device/radio/beacon/interaction_watcher/proc/react_empulse(datum/source, turf/epicenter, heavy_range, light_range)

	if(get_dist(epicenter,get_turf(src)) > sensitivity_radius)
		return

	var/power = heavy_range * 2 + light_range

	power = round(power)
	var/calculated_research_points = research_interaction("Empulse", power, new_score_coeff=600, repeat_score_coeff=120)

	if(calculated_research_points > 0)
		autosay("Detected EMP with power level [power], received [calculated_research_points] research points", name ,"Science", freq = radiochannels["Science"])
	else if (calculated_research_points == 0)
		autosay("Detected EMP with power level [power], could not acquire any more research points", name ,"Science", freq = radiochannels["Science"])
	else
		autosay("Detected EMP with power level [power], R&D console is missing or broken", name ,"Science", freq = radiochannels["Science"])

// Universal tool to get research points from autopsy reports, virus info reports, archeology reports, slime cores
/obj/item/device/science_tool
	name = "science tool"
	icon_state = "science"
	item_state = "sciencetool"
	desc = "A hand-held device capable of extracting usefull data from various sources, such as paper reports and slime cores."
	flags = CONDUCT | NOBLUDGEON | NOATTACKANIMATION
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 3
	w_class = SIZE_TINY
	throw_speed = 4
	throw_range = 10
	m_amt = 200
	origin_tech = "engineering=1;biotech=1"

	var/datum/experiment_data/experiments
	var/list/scanned_autopsy_weapons = list()
	var/list/scanned_artifacts = list()
	var/list/scanned_symptoms = list()
	var/list/scanned_slimecores = list()
	var/datablocks = 0

/obj/item/device/science_tool/atom_init()
	. = ..()
	experiments = new

/obj/item/device/science_tool/attack(mob/living/M, mob/living/user)
	return

/obj/item/device/science_tool/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	var/scanneddata = 0

	if(istype(target, /obj/item/weapon/disk/research_points))
		var/obj/item/weapon/disk/research_points/disk = target
		to_chat(user, "<span class='notice'>[disk] stores approximately [disk.stored_points] research points</span>")
		return

	if(istype(target,/obj/item/weapon/paper/autopsy_report))
		var/obj/item/weapon/paper/autopsy_report/report = target
		for(var/datum/autopsy_data/W in report.autopsy_data)
			if(!(W.weapon in scanned_autopsy_weapons))
				scanneddata += 1
				scanned_autopsy_weapons += W.weapon

	if(istype(target, /obj/item/weapon/paper/artifact_info))
		var/obj/item/weapon/paper/artifact_info/report = target
		if(report.artifact_type)
			for(var/list/scanning_artifact in scanned_artifacts)
				if(scanning_artifact["type"] == report.artifact_type && scanning_artifact["first_effect"] == report.artifact_first_effect && scanning_artifact["second_effect"] == report.artifact_second_effect)
					to_chat(user, "<span class='notice'>[src] already has data about this artifact report</span>")
					return

			scanned_artifacts += list(list(
				"type" = report.artifact_type,
				"first_effect" = report.artifact_first_effect,
				"second_effect" = report.artifact_second_effect,
			))
			scanneddata += 1

	if(istype(target, /obj/item/weapon/paper/virus_report))
		var/obj/item/weapon/paper/virus_report/report = target
		for(var/symptom in report.symptoms)
			if(!scanned_symptoms[symptom])
				scanneddata += 1
				scanned_symptoms[symptom] = report.symptoms[symptom]
	if(istype(target, /obj/item/slime_extract))
		if(!(target.type in scanned_slimecores))
			scanned_slimecores += target.type
			scanneddata += 1

	if(scanneddata > 0)
		datablocks += scanneddata
		to_chat(user, "<span class='notice'>[src] received [scanneddata] data block[scanneddata>1?"s":""] from scanning [target]</span>")
	else if(isitem(target))
		var/science_value = experiments.get_object_research_value(target)
		if(science_value > 0)
			to_chat(user, "<span class='notice'>Estimated research value of [target.name] is [science_value]</span>")
		else
			to_chat(user, "<span class='notice'>[target] has no research value</span>")

/obj/item/device/science_tool/proc/clear_data()
	scanned_autopsy_weapons = list()
	scanned_artifacts = list()
	scanned_symptoms = list()
	scanned_slimecores = list()
	datablocks = 0

/obj/item/weapon/disk/research_points
	name = "Important Disk"
	desc = "Looks a disk with some important information stored. Scientists might know what to do with it"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = SIZE_TINY
	m_amt = 30
	g_amt = 10
	var/stored_points

/obj/item/weapon/disk/research_points/atom_init()
	. = ..()
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

	stored_points = rand(1,10)*1000

/obj/item/weapon/disk/research_points/rare/atom_init()
	. = ..()

	stored_points = rand(10, 20)*1000
