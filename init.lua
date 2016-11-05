local load_time_start = os.clock()

if farming.add_plant
or farming.plant_index
or farming.generate_tree
or farming.seeds then
	error("[farming_plus] some field(s) already exist")
end

farming.plant_index = {}

-- Boilerplate to support localized strings if intllib mod is installed.
if (minetest.get_modpath("intllib")) then
	dofile(minetest.get_modpath("intllib").."/intllib.lua")
	farming.S = intllib.Getter(minetest.get_current_modname())
else
	farming.S = function ( s ) return s end
end

function farming.add_plant(full_grown, names, interval, chance)
	minetest.register_abm({
		nodenames = names,
		interval = interval,
		chance = chance,
		action = function(pos, node)
			pos.y = pos.y-1
			if minetest.get_node(pos).name ~= "farming:soil_wet" then
				return
			end
			pos.y = pos.y+1
			local light = minetest.get_node_light(pos)
			if not light
			or light < 8 then
				return
			end
			local step = nil
			for i,name in ipairs(names) do
				if name == node.name then
					step = i
					break
				end
			end
			if step == nil then
				return
			end
			local new_node = {name=names[step+1]}
			if new_node.name == nil then
				new_node.name = full_grown
			end
			minetest.set_node(pos, new_node)
		end
	})

	table.insert(farming.plant_index, {
		full_grown = full_grown,
		names = names,
		interval = interval,
		chance = chance,
	})
end

function farming.generate_tree(pos, trunk, leaves, underground, replacements)
	pos.y = pos.y-1
	local nodename = minetest.get_node(pos).name
	local ret = true
	for _,name in ipairs(underground) do
		if nodename == name then
			ret = false
			break
		end
	end
	pos.y = pos.y+1
	if not minetest.get_node_light(pos) then
		return
	end
	if ret or minetest.get_node_light(pos) < 8 then
		return
	end

	local node = {name = ""}
	for dy=1,4 do
		pos.y = pos.y+dy
		if minetest.get_node(pos).name ~= "air" then
			return
		end
		pos.y = pos.y-dy
	end
	node.name = trunk
	for dy=0,4 do
		pos.y = pos.y+dy
		minetest.set_node(pos, node)
		pos.y = pos.y-dy
	end

	if not replacements then
		replacements = {}
	end

	node.name = leaves
	pos.y = pos.y+3
	for dx=-2,2 do
		for dz=-2,2 do
			for dy=0,3 do
				pos.x = pos.x+dx
				pos.y = pos.y+dy
				pos.z = pos.z+dz

				if dx == 0 and dz == 0 and dy==3 then
					if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
						minetest.set_node(pos, node)
						for name,rarity in pairs(replacements) do
							if math.random(1, rarity) == 1 then
								minetest.set_node(pos, {name=name})
							end
						end
					end
				elseif dx == 0 and dz == 0 and dy==4 then
					if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
						minetest.set_node(pos, node)
						for name,rarity in pairs(replacements) do
							if math.random(1, rarity) == 1 then
								minetest.set_node(pos, {name=name})
							end
						end
					end
				elseif math.abs(dx) ~= 2 and math.abs(dz) ~= 2 then
					if minetest.get_node(pos).name == "air" then
						minetest.set_node(pos, node)
						for name,rarity in pairs(replacements) do
							if math.random(1, rarity) == 1 then
								minetest.set_node(pos, {name=name})
							end
						end
					end
				else
					if math.abs(dx) ~= 2 or math.abs(dz) ~= 2 then
						if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
							minetest.set_node(pos, node)
							for name,rarity in pairs(replacements) do
								if math.random(1, rarity) == 1 then
								minetest.set_node(pos, {name=name})
								end
							end
						end
					end
				end

				pos.x = pos.x-dx
				pos.y = pos.y-dy
				pos.z = pos.z-dz
			end
		end
	end
end

farming.seeds = {
	["farming:pumpkin_seed"]=60,
	["farming_plus:strawberry_seed"]=30,
	["farming_plus:rhubarb_seed"]=30,
	["farming_plus:corn_seed"]=30,
	["farming_plus:potatoe_seed"]=30,
	["farming_plus:tomato_seed"]=30,
	["farming_plus:orange_seed"]=30,
	["farming_plus:carrot_seed"]=30,
}


-- ========= GENERATE PLANTS IN THE MAP =========
minetest.register_on_generated(function(minp, maxp, seed)
	if maxp.y >= 2 and minp.y <= 0 then
		-- Generate plants (code from flowers)
		local perlin1 = minetest.get_perlin(974, 3, 0.6, 100)
		-- Assume X and Z lengths are equal
		local divlen = 16
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=0,divs-1 do
		for divz=0,divs-1 do
			local x0 = minp.x + math.floor((divx+0)*divlen)
			local z0 = minp.z + math.floor((divz+0)*divlen)
			local x1 = minp.x + math.floor((divx+1)*divlen)
			local z1 = minp.z + math.floor((divz+1)*divlen)
			-- Determine flowers amount from perlin noise
			local grass_amount = math.floor(perlin1:get2d({x=x0, y=z0}) ^ 3 * 9)
			-- Find random positions for flowers based on this random
			local pr = PseudoRandom(seed+456)
			for i=0,grass_amount do
				local x = pr:next(x0, x1)
				local z = pr:next(z0, z1)
				-- Find ground level (0...15)
				local ground_y = nil
				for y=30,0,-1 do
					if minetest.get_node({x=x,y=y,z=z}).name ~= "air" then
						ground_y = y
						break
					end
				end

				if ground_y then
					local p = {x=x,y=ground_y+1,z=z}
					local nn = minetest.get_node(p).name
					-- Check if the node can be replaced
					if minetest.registered_nodes[nn] and
						minetest.registered_nodes[nn].buildable_to then
						nn = minetest.get_node({x=x,y=ground_y,z=z}).name
						if nn == "default:dirt_with_grass" then
							--local plant_choice = pr:next(1, #farming.plant_index)
							local plant_choice = math.floor(perlin1:get2d({x=x,y=z})*(#farming.plant_index))
							local plant = farming.plant_index[plant_choice]
							if plant then
								minetest.set_node(p, {name=plant.full_grown})
							end
						end
					end
				end

			end
		end
		end
	end
end)

--[[

-- ========= ALIASES FOR FARMING MOD BY SAPIER =========
-- potatoe -> potatoe
minetest.register_alias("farming:potatoe_node", "farming_plus:potatoe")
--minetest.register_alias("farming:potatoe", "farming:potatoe_item") cant do this
minetest.register_alias("farming:potatoe_straw", "farming_plus:potatoe")
minetest.register_alias("farming:seed_potatoe", "farming_plus:potatoe_seed")
for lvl = 1, 6, 1 do
	minetest.register_entity(":farming:potatoe_lvl"..lvl, {
		on_activate = function(self, staticdata)
			minetest.set_node(self.object:getpos(), {name="farming_plus:potatoe_1"})
		end
	})
end


--minetest.register_alias("farming:cotton", "farming:cotton_3")
minetest.register_alias("farming:wheat_harvested", "farming:wheat")
minetest.register_abm({
	nodenames = {"farming:wheat"},
	interval = 1,
	chance = 1,
	action = function(pos)
		minetest.set_node(pos, {name="farming:wheat_8"})
	end,
})
]]--

local modpath = minetest.get_modpath('farming_plus')
dofile(modpath.."/bananas.lua")
dofile(modpath.."/carrots.lua")
dofile(modpath.."/cocoa.lua")
dofile(modpath.."/corn.lua")
dofile(modpath.."/cotton.lua")
dofile(modpath.."/strawberries.lua")
dofile(modpath.."/rhubarb.lua")
dofile(modpath.."/potatoes.lua")
dofile(modpath.."/tomatoes.lua")
dofile(modpath.."/oranges.lua")
dofile(modpath.."/pumpkin.lua")
dofile(modpath.."/weed.lua")
dofile(modpath.."/wheat.lua")
dofile(modpath.."/craft.lua")

minetest.log(
	'action',
	string.format(
		'['..minetest.get_current_modname()..'] loaded in %.3fs',
		os.clock() - load_time_start
	)
)
