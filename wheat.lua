--DEPRECATED

minetest.register_craftitem('farming_plus:wheat_seed', {
	description = 'Wheat Seeds',
	inventory_image = 'farming_wheat_seed.png',
	groups = { not_in_creative_inventory=1 },
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, 'farming:seed_wheat')
	end
})

core.register_alias( 'farming_plus:wheat_1', 'farming:wheat_3' )
core.register_alias( 'farming_plus:wheat_2', 'farming:wheat_3' )
core.register_alias( 'farming_plus:wheat_3', 'farming:wheat_3' )
core.register_alias( 'farming_plus:wheat_4', 'farming:wheat_3' )
core.register_alias( 'farming_plus:wheat_5', 'farming:wheat_3' )
core.register_alias( 'farming_plus:wheat_6', 'farming:wheat_3' )
core.register_alias( 'farming_plus:wheat_7', 'farming:wheat_3' )
core.register_alias( 'farming_plus:wheat_plant', 'farming:wheat_3' )
