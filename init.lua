-- ia_util/init.lua

ia_util                          = {}
ia_util.mod_dir_blacklist        = { 'init.lua' }

function ia_util.get_header_vars(modname)
	assert(modname ~= nil)
	local modpath            = minetest.get_modpath(modname)
	local S                  = minetest.get_translator(modname)
	return modpath, S
end

function ia_util.format_file_error(path, err)
	assert(path ~= nil)
	return (path .. ': ' .. tostring(err))

end

function ia_util.file_error(path, err)
	assert(path ~= nil)
	local message            = ia_util.format_file_error(path, err)
	--error(err)
	error(message)
end

local function handle_loadfile_error(path, chunk, err)
	assert(path ~= nil)
	if not chunk then
		ia_util.file_error(path, err)
	end
	assert(chunk)
end

local function handle_pcall_error(path, status, err)
	assert(path ~= nil)
	if not status then
		ia_util.file_error(path, err)
	end
	assert(status)
end

function ia_util.loadfile(file)
	assert(file ~= nil)
	local chunk, err         = loadfile(file)
	handle_loadfile_error(file, chunk, error)
	return chunk, err
end

function ia_util.pcall(path, chunk)
	assert(chunk ~= nil)
	local status, err        = pcall(chunk)
	handle_pcall_error(path, status, err)
	return status, err
end

function ia_util.dofile(file)
	assert(file ~= nil)
	--local chunk,  err        = ia_util.loadfile(file)
	--local status, err        = ia_util.pcall   (file, chunk)
	dofile(file)
	-- TODO log file as done ?
end

function ia_util.dofiles(modpath, files)
	assert(modpath ~= nil)
	assert(files   ~= nil)
	for _, file in ipairs(files) do
		--local path       = modpath..DIR_DELIM..file..'.lua'
		local path       = modpath..DIR_DELIM..file
		ia_util.dofile(path)
	end
end

function ia_util.lua_file_filter(filename)
	assert(filename ~= nil)
	return filename:sub(-4) == ".lua"
end

function ia_util.list_to_table(list)
	assert(list ~= nil)
	local is_listed = {}
	for _, name in ipairs(list) do
		is_listed[name]  = true
	end
	return is_listed
end

local function filter_list_helper(list, filter, blacktable, item)
	assert(list       ~= nil)
	assert(blacktable ~= nil)
	if blacktable[item] then
		return false
	end
	if filter and not filter(item) then
		return false
	end
	table.insert(list, item)
	return true
end

function ia_util.filter_list(list, filter, blacktable)
	assert(list       ~= nil)
	assert(blacktable ~= nil)
	local filtered           = {}
	for _, item in ipairs(list) do
		filter_list_helper(filtered, filter, blacktable, item)
	end
	return filtered
end

function ia_util.get_dir_list(dirpath, filter, blacklist)
	assert(dirpath   ~= nil)
	assert(blacklist ~= nil)
	local dirlist            = minetest.get_dir_list(dirpath, false) -- files only
	local blacktable         = ia_util.list_to_table(blacklist)
	local files              = ia_util.filter_list(dirlist, filter, blacktable)
	table.sort(files)
	return files
end

function ia_util.loadmod(modname)
	assert(modname ~= nil)
	local modpath, S         = ia_util.get_header_vars(modname)
	local files              = ia_util.get_dir_list(modpath, ia_util.lua_file_filter, ia_util.mod_dir_blacklist)
	ia_util.dofiles(modpath, files)
	-- TODO log number of files loaded
	return modpath, S
end

-- TODO logging helpers? especially with mod-level settings to enable/disable debugging, tracing, etc.
-- TODO can do a trace_call(func, ...) that handles ^^^ ???

local modname                    = minetest.get_current_modname() or "ia_util"
local storage                    = minetest.get_mod_storage()
local modpath, S                 = ia_util.loadmod(modname)
