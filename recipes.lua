-- ia_util/recipes.lua

function ia_util.recipe_exists(item)
    -- 1. Resolve the alias if one exists
    -- If 'item' is an alias, this returns the target name.
    -- If 'item' is a real ID, it returns the ID itself.
    local canonical_name = minetest.registered_aliases[item] or item

    -- 2. Query for recipes using the canonical name
    local recipes = minetest.get_all_craft_recipes(canonical_name)

    if not recipes then
        return false
    end

    return (#recipes > 0)
end
