-- ia_util/farming.lua

function ia_util.has_bonemeal_redo()
	if not minetest.get_modpath('bonemeal') then return false end
	if not bonemeal                         then return false end
	if not bonemeal.mod                     then return false end
	return (bonemeal.mod == 'ia')
end

function ia_util.has_drinks_redo()
	if not minetest.get_modpath('drinks') then return false end
	if not drinks                         then return false end
	if not drinks.mod                     then return false end
	return (drinks.mod == 'ia')
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

function ia_util.has_wooden_bucket_redo()
	if not minetest.get_modpath('wooden_bucket') then return false end
	if not wooden_bucket                         then return false end
	if not wooden_bucket.mod                     then return false end
	return (wooden_bucket.mod == 'ia')
end

