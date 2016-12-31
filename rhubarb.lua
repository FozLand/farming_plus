-- main `S` code in init.lua
local S = farming.S

minetest.register_craftitem('farming_plus:rhubarb_seed', {
	description = S('Rhubarb Seeds'),
	inventory_image = "farming_rhubarb_seed.png",
	groups = { not_in_creative_inventory=1 },
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, 'farming_plus:rhubarb_1')
	end
})

minetest.register_node('farming_plus:rhubarb_1', {
	paramtype = 'light',
	walkable = false,
	drawtype = 'plantlike',
	waving = 1,
	drop = '',
	tiles = {'farming_rhubarb_1.png'},
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+5/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1,plant=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node('farming_plus:rhubarb_2', {
	paramtype = 'light',
	walkable = false,
	drawtype = 'plantlike',
	waving = 1,
	drop = '',
	tiles = {'farming_rhubarb_2.png'},
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+11/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1,plant=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node('farming_plus:rhubarb', {
	paramtype = 'light',
	walkable = false,
	drawtype = 'plantlike',
	waving = 1,
	tiles = {'farming_rhubarb_3.png'},
	drop = {
		max_items = 6,
		items = {
			{ items = {'farming_plus:rhubarb_seed'} },
			{ items = {'farming_plus:rhubarb_seed'}, rarity = 2},
			{ items = {'farming_plus:rhubarb_seed'}, rarity = 5},
			{ items = {'farming_plus:rhubarb_item'} },
			{ items = {'farming_plus:rhubarb_item'}, rarity = 2 },
			{ items = {'farming_plus:rhubarb_item'}, rarity = 5 }
		}
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1,plant=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_craftitem('farming_plus:rhubarb_item', {
	description = 'Rhubarb',
	inventory_image = 'rhubarb.png',
	on_use = minetest.item_eat(-4),
})

farming.add_plant('farming_plus:rhubarb', {'farming_plus:rhubarb_1', 'farming_plus:rhubarb_2'}, 50, 20)
