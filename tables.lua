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

function ia_util.deepmerge(t1, t2) -- placeable_buckets
	if not t2 then
		return
	end

	t1 = t1 or {}

	for k, v in pairs(t2) do
		if type(v) == "table" then
			deepmerge(t1[k], v)
		else
			t1[k] = v
		end
	end
end
