-- ia_util/authoritative.lua

--- Resolves the authoritative item from a map based on a priority list.
-- @param item_map Table of { modname = "item_string" }
-- @param priority_list Table of modnames in order of preference
-- @return winner_id (string or nil), winner_mod (string or nil), losers (table)
function ia_util.resolve_authority(item_map, priority_list)
    local existing_items = {}
    
    -- 1. Collect everything that actually exists in the game
    for mod, id in pairs(item_map) do
        if minetest.registered_items[id] then
            existing_items[mod] = id
        end
    end

    -- 2. If the universe has no matching items, return nil (the "False" signal)
    if not next(existing_items) then 
        return nil, nil, {} 
    end

    local winner_id, winner_mod

    -- 3. Check priority list for a preferred winner
    for _, mod in ipairs(priority_list) do
        if existing_items[mod] then
            winner_id = existing_items[mod]
            winner_mod = mod
            break
        end
    end

    -- 4. Fallback: If no preferred mods are found, pick the first available item
    if not winner_id then
        winner_mod, winner_id = next(existing_items)
    end

    -- 5. Alias the losers to the winner to keep the inventory clean
    local losers = {}
    for mod, id in pairs(existing_items) do
        if id ~= winner_id then
            minetest.register_alias_force(id, winner_id)
            table.insert(losers, id)
        end
    end

    return winner_id, winner_mod, losers
end
