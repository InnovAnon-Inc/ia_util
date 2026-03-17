-- ia_util/strings.lua

--- Replaces a target word with a prefixed version while preserving case.
-- @param desc The original string (e.g., "Steel Sword")
-- @param target The word to find (e.g., "Sword")
-- @param prefix The adjective to add (e.g., "Rusty")
-- @return The rebranded string (e.g., "Rusty Steel Sword")
function ia_util.rebrand_item(desc, target, prefix)
    if not desc or desc == "" then return (prefix .. " " .. target) end

    -- Escape the target for Lua pattern safety
    local pattern = "([%a])" .. target:sub(2)

    return desc:gsub(pattern, function(first_char)
        -- Determine if the original was capitalized
        local is_upper = (first_char == first_char:upper())
        
        -- Format the prefix and target to match the original's case
        local p = is_upper and (prefix:sub(1,1):upper() .. prefix:sub(2)) 
                           or (prefix:sub(1,1):lower() .. prefix:sub(2))
        local t = is_upper and (target:sub(1,1):upper() .. target:sub(2)) 
                           or (target:sub(1,1):lower() .. target:sub(2))

        return p .. " " .. t
    end)
end
