/turf/simulated/shuttle/floor/mining
	icon = 'icons/locations/shuttles/shuttle_mining.dmi'

/turf/simulated/shuttle/floor/shuttle_new
	icon = 'icons/locations/shuttles/shuttle.dmi'

/turf/simulated/shuttle/floor/wagon
	name = "floor"
	icon = 'icons/locations/shuttles/wagon.dmi'
	icon_state = "floor"

/turf/simulated/shuttle/floor/erokez
	name = "floor"
	icon = 'icons/locations/shuttles/erokez.dmi'
	icon_state = "floor1"

/turf/simulated/shuttle/floor/cargo
	name = "floor"
	icon = 'icons/locations/shuttles/cargofloor.dmi'
	icon_state = "1"

/turf/simulated/shuttle/floor/evac
	name = "floor"
	icon = 'icons/locations/shuttles/evac_shuttle.dmi'
	icon_state = "floor"

/turf/simulated/shuttle/floor/evac/medbay
	icon_state = "floormed"

/turf/simulated/shuttle/floor/evac/eng1
	icon_state = "flooreng1"

/turf/simulated/shuttle/floor/evac/eng2
	icon_state = "flooreng2"

/turf/simulated/shuttle/floor/evac/sec1
	icon = 'icons/locations/shuttles/evac_shuttle.dmi'
	icon_state = "floorsec"

/turf/simulated/shuttle/floor/evac/sec2
	icon = 'icons/locations/shuttles/evac_shuttle.dmi'
	icon_state = "floorsec2"

/turf/simulated/shuttle/floor/evac/inv
	icon = 'icons/locations/shuttles/evac_shuttle.dmi'
	icon_state = "floorinv"

/turf/simulated/shuttle/floor/evac/ex
	icon = 'icons/locations/shuttles/evac_shuttle.dmi'
	icon_state = "floorex"

/turf/simulated/shuttle/floor/evac/place
	icon = 'icons/locations/shuttles/evac_shuttle.dmi'
	icon_state = "floorplace"

/turf/simulated/shuttle/floor/evac/place2
	icon = 'icons/locations/shuttles/evac_shuttle.dmi'
	icon_state = "floorplace2"

/turf/simulated/shuttle/floor/evac/eva
	icon = 'icons/locations/shuttles/evac_shuttle.dmi'
	icon_state = "floorengeva"

/turf/simulated/shuttle/floor4/evac
	icon = 'icons/locations/shuttles/evac_shuttle.dmi'
	icon_state = "floor"

/turf/simulated/shuttle/floor/vox
	name = "floor"
	icon = 'icons/locations/shuttles/vox_shuttle.dmi'
	icon_state = "floor"
	nitrogen = 103.984
	oxygen = 0

//Временный и очень грубый костыль для космоса, в шаттлконтроллере он не заменяется на движущийся.
//Скоро бэй обновит шаттлконтроллеры, там и сделаем по человечески.
//======
//Привет! Как дела?
//======
//Привет! Как дела?
// =====
// Привет от транс депа! Как дела?
/turf/environment/space/shuttle
	icon = 'icons/locations/shuttles/space.dmi'
	icon_state = "1swall_s"

/turf/environment/space/shuttle/New()
	icon_state = "[rand(1,4)]swall_s"
