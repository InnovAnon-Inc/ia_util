-- ia_util/logging.lua

ia_util.log_levels = {
	NONE  = 0,
	ERROR = 1,
	WARN  = 2,
	INFO  = 3,
	DEBUG = 4,
	TRACE = 5,
}

function ia_util.dump(value, indent)
    indent = indent or ""
    if type(value) ~= "table" then
        return tostring(value)
    end
    local result = "{\n"
    for k, v in pairs(value) do
        local key = type(k) == "string" and '["'..k..'"]' or "["..tostring(k).."]"
        result = result .. indent .. "  " .. key .. " = " .. ia_util.dump(v, indent .. "  ") .. ",\n"
    end
    return result .. indent .. "}"
end

local function get_prefix(modname)
	return "[" .. modname .. "] "
end

function ia_util.get_log_setting_name(modname)
	return modname .. ".log_level"
end

function ia_util.get_log_level(modname)
	local setting_name  = ia_util.get_log_setting_name(modname)
	return tonumber(minetest.settings:get(setting_name)) or ia_util.log_levels.INFO
end

function ia_util.log(modname, msg_level, message)
	local current_level = ia_util.get_log_level(modname)
	if msg_level > current_level then
		return
	end
	local prefix        = get_prefix(modname)
	minetest.log("action", prefix .. message)
end

function ia_util.get_logger(modname)
	return function(msg_level, message)
		ia_util.log(modname, msg_level, message)
	end
end

-- Explicit Assertion with Recursive Dump
function ia_util.assert(modname, condition, message, context)
    if condition then
	    return
    end
    local prefix = get_prefix(modname)
    local err    = prefix ..  " ASSERTION FAILED: " .. (message or "Unknown Error")
    if context then
	    err  = err .. "\nContext: " .. ia_util.dump(context)
    end
    error(err)
end

function ia_util.get_assert(modname)
	return function(condition, message, context)
		ia_util.assert(modname, condition, message, context)
	end
end

function ia_util.trace(modname, f, ...)
	local log  = ia_util.get_logger(modname)
	local args = {...}
	
	log(ia_util.log_levels.TRACE, "CALLING function with args: " .. ia_util.dump(args))
	
	-- Capture all return values
	local results = {f(...)}
	
	log(ia_util.log_levels.TRACE, "RETURNED values: " .. ia_util.dump(results))
	
	return unpack(results)
end

function ia_util.get_traced(modname, f)
	return function(...)
		return ia_util.trace(modname, f, ...)
	end
end

function ia_util.get_traced(modname, f)
	return function(...)
		return ia_util.trace(modname, f, ...)
	end
end
