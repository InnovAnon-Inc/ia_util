-- ia_util/tables.lua

function ia_util.merge_groups(target, source)
    local result = table.copy(target)
    if source then
        for k, v in pairs(source) do
            result[k] = v
        end
    end
    return result
end
