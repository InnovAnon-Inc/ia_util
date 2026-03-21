-- ia_util/farming.lua
-- TODO airtanks
-- TODO biofuel
-- TODO claycrafter
-- TODO fakery
-- TODO hopper_compat
-- TODO waffles

function ia_util.has_beds_redo()
	if not minetest.get_modpath('beds') then return false end
	if not beds                         then return false end
	if not beds.mod                     then return false end
	return (beds.mod == 'ia')
end

function ia_util.has_bonemeal_redo()
	if not minetest.get_modpath('bonemeal') then return false end
	if not bonemeal                         then return false end
	if not bonemeal.mod                     then return false end
	return (bonemeal.mod == 'ia')
end

function ia_util.has_composting_redo()
	if not minetest.get_modpath('composting') then return false end
	if not composting                         then return false end
	if not composting.mod                     then return false end
	return (composting.mod == 'ia')
end

function ia_util.has_drinks_redo()
	if not minetest.get_modpath('drinks') then return false end
	if not drinks                         then return false end
	if not drinks.mod                     then return false end
	return (drinks.mod == 'ia')
end

function ia_util.has_edit_skin_redo()
	if not minetest.get_modpath('edit_skin') then return false end
	if not edit_skin                         then return false end
	if not edit_skin.mod                     then return false end
	return (edit_skin.mod == 'ia')
end

function ia_util.has_farming_redo()
	if not minetest.get_modpath('farming') then return false end
	-- FIXME better check (farming undef'd)
	if not farming                         then return false end
	if not farming.mod                     then return false end
	return (farming.mod == 'redo')
end

function ia_util.has_hunger_ng_redo()
	if not minetest.get_modpath('hunger_ng') then return false end
	if not hunger_ng                         then return false end
	if not hunger_ng.mod                     then return false end
	return (hunger_ng.mod == 'ia')
end

function ia_util.has_lightning_redo()
	if not minetest.get_modpath('lightning') then return false end
	if not lightning                         then return false end
	if not lightning.mod                     then return false end
	return (lightning.mod == 'ia')
end

function ia_util.has_mcg_lockworkshop_redo()
	if not minetest.get_modpath('mcg_lockworkshop') then return false end
	if not mcg_lockworkshop                         then return false end
	if not mcg_lockworkshop.mod                     then return false end
	return (mcg_lockworkshop.mod == 'ia')
end

function ia_util.has_placeable_buckets_redo()
	if not minetest.get_modpath('placeable_buckets') then return false end
	if not placeable_buckets                         then return false end
	if not placeable_buckets.mod                     then return false end
	return (placeable_buckets.mod == 'ia')
end

function ia_util.has_pooper_redo()
	if not minetest.get_modpath('pooper') then return false end
	if not pooper                         then return false end
	if not pooper.mod                     then return false end
	return (pooper.mod == 'ia')
end

function ia_util.has_snowcone_redo()
	if not minetest.get_modpath('snowcone') then return false end
	if not snowcone                         then return false end
	if not snowcone.mod                     then return false end
	return (snowcone.mod == 'ia')
end


function ia_util.has_wooden_bucket_redo()
	if not minetest.get_modpath('wooden_bucket') then return false end
	if not wooden_bucket                         then return false end
	if not wooden_bucket.mod                     then return false end
	return (wooden_bucket.mod == 'ia')
end

