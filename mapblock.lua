-- ia_util/mapblock.lua

--- Calculates and deletes the specific 16x16x16 mapblock containing a position.
--- @param pos table {x, y, z} The coordinate to target.
--- @return table, table The min and max corners of the deleted block.
function ia_util.delete_mapblock_at_pos(pos)
    -- Assertions to ensure valid input before modification
    assert(pos ~= nil, "delete_mapblock_at_pos: pos is nil")
    assert(pos.x and pos.y and pos.z, "delete_mapblock_at_pos: missing coordinates")

    -- Calculate the exact 16-node aligned boundaries
    local min_p = {
        x = math.floor(pos.x / 16) * 16,
        y = math.floor(pos.y / 16) * 16,
        z = math.floor(pos.z / 16) * 16,
    }

    local max_p = {
        x = min_p.x + 15,
        y = min_p.y + 15,
        z = min_p.z + 15,
    }

    -- Logging the coordinates to be deleted for audit/debugging
    minetest.log("action", string.format("[Mod] Deleting mapblock: %s to %s", 
        minetest.pos_to_string(min_p), minetest.pos_to_string(max_p)))

    local success = minetest.delete_area(min_p, max_p)
    
    -- Ensure the deletion actually happened before returning
    assert(success == true, "delete_mapblock_at_pos: minetest.delete_area failed")

    return min_p, max_p
end

--- Deletes a mapblock and forces an immediate regeneration.
--- @param pos table {x, y, z} The coordinate to target.
function ia_util.regenerate_mapblock_at_pos(pos)
    -- 1. Call the deletion function to clear the database entry
    local min_p, max_p = ia_util.delete_mapblock_at_pos(pos)

    -- 2. Request the mapgen to "emerge" (generate) the area again
    -- We use a callback to ensure we know when the generation is finished.
    minetest.emerge_area(min_p, max_p, function(block_pos, action, calls_remaining, param)
        if calls_remaining == 0 then
            minetest.log("action", "[Mod] Regeneration finished for: " .. minetest.pos_to_string(min_p))

            -- Fix lighting to prevent black blocks or ghost shadows
            minetest.fix_light(min_p, max_p)
        end
    end)

    -- Logging the request start
    minetest.log("action", "[Mod] Emerge request sent for regeneration.")
end

--- Ensures pos1 is the minimum and pos2 is the maximum.
function ia_util.sort_pos(pos1, pos2)
    return {
        x = math.min(pos1.x, pos2.x),
        y = math.min(pos1.y, pos2.y),
        z = math.min(pos1.z, pos2.z)
    }, {
        x = math.max(pos1.x, pos2.x),
        y = math.max(pos1.y, pos2.y),
        z = math.max(pos1.z, pos2.z)
    }
end

----- Resets a large volume by breaking it into mapblock-sized chunks.
----- @param pos1 table Start corner
----- @param pos2 table End corner
--function ia_util.regenerate_large_area(pos1, pos2)
--    -- Assertion: Ensure bounds are valid
--    assert(pos1 and pos2, "regenerate_large_area: positions missing")
--
--    local minp, maxp = ia_util.sort_pos(pos1, pos2)
--
--    -- Logging the start of a large-scale operation
--    minetest.log("action", string.format("[ia_util] LARGE RESET STARTED: %s to %s",
--        minetest.pos_to_string(minp), minetest.pos_to_string(maxp)))
--
--    -- Snap coordinates to mapblock boundaries (16 nodes)
--    local b_min = {
--        x = math.floor(minp.x / 16) * 16,
--        y = math.floor(minp.y / 16) * 16,
--        z = math.floor(minp.z / 16) * 16,
--    }
--    local b_max = {
--        x = math.floor(maxp.x / 16) * 16,
--        y = math.floor(maxp.y / 16) * 16,
--        z = math.floor(maxp.z / 16) * 16,
--    }
--
--    local count = 0
--    -- Iterate through every mapblock in the volume
--    for x = b_min.x, b_max.x, 16 do
--        for y = b_min.y, b_max.y, 16 do
--            for z = b_min.z, b_max.z, 16 do
--                local current_pos = {x = x, y = y, z = z}
--                -- Reuse your existing mapblock logic
--                ia_util.regenerate_mapblock_at_pos(current_pos)
--                count = count + 1
--            end
--        end
--    end
--
--    minetest.log("action", string.format("[ia_util] LARGE RESET QUEUED: %d mapblocks affected.", count))
--    return count
--end

----- HIGH-SPEED COUNTRY RESET
----- Deletes the entire volume in one database hit, then emerges in LVM-sized chunks.
----- @param pos1 table Start corner
----- @param pos2 table End corner
--function ia_util.regenerate_large_area(pos1, pos2)
--    assert(pos1 and pos2, "regenerate_large_area: positions missing")
--    local minp, maxp = ia_util.sort_pos(pos1, pos2)
--
--    -- 1. BULK DELETE (The Fast Part)
--    -- We delete the entire country in ONE engine call.
--    minetest.log("action", string.format("[ia_util] BULK DELETE: %s to %s",
--        minetest.pos_to_string(minp), minetest.pos_to_string(maxp)))
--
--    local success = minetest.delete_area(minp, maxp)
--    assert(success == true, "regenerate_large_area: bulk delete failed")
--
--    -- 2. CHUNKED EMERGE (The Lag-Management Part)
--    -- We emerge in 80x80x80 chunks (roughly the LVM limit/safe engine volume).
--    local chunk_size = 80
--    local count = 0
--
--    for x = minp.x, maxp.x, chunk_size do
--        for y = minp.y, maxp.y, chunk_size do
--            for z = minp.z, maxp.z, chunk_size do
--                local c_min = {x = x, y = y, z = z}
--                local c_max = {
--                    x = math.min(x + chunk_size - 1, maxp.x),
--                    y = math.min(y + chunk_size - 1, maxp.y),
--                    z = math.min(z + chunk_size - 1, maxp.z)
--                }
--
--                -- We call emerge on this specific sub-volume
--                minetest.emerge_area(c_min, c_max, function(block_pos, action, calls_remaining)
--                    if calls_remaining == 0 then
--                        minetest.fix_light(c_min, c_max)
--                    end
--                end)
--                count = count + 1
--            end
--        end
--    end
--
--    minetest.log("action", "[ia_util] Bulk delete complete. Emerge queued in " .. count .. " chunks.")
--    return count
--end
---- ia_util/mapblock.lua
--
---- Existing helper functions (sort_pos, etc.) should remain above this.
--
----- HIGH-SPEED THROTTLED COUNTRY RESET
----- Deletes in bulk, then emerges in chunks over time to prevent lag.
----- @param pos1 table Start corner
----- @param pos2 table End corner
----- @param pname string Player name for status updates
--function ia_util.regenerate_large_area(pos1, pos2, pname)
--    assert(pos1 and pos2, "regenerate_large_area: positions missing")
--    local minp, maxp = ia_util.sort_pos(pos1, pos2)
--
--    -- 1. BULK DELETE (Instant Database Hit)
--    minetest.log("action", "[ia_util] BULK DELETE STARTED by " .. (pname or "unknown"))
--    --local success = minetest.delete_area(minp, maxp)
--    --assert(success == true, "regenerate_large_area: bulk delete failed")
--    --minetest.log("action", "[ia_util] BULK DELETE FINISHED")
--
--    -- 2. COROUTINE SETUP
--    local chunk_size = 80 -- 5x5x5 mapblocks per chunk
--    local chunks = {}
--    
--    -- Pre-calculate chunks to avoid logic overhead inside the coroutine
--    -- FIXME takes too long. needs to go in the coro. very high latency
--    for x = minp.x, maxp.x, chunk_size do
--        for y = minp.y, maxp.y, chunk_size do
--            for z = minp.z, maxp.z, chunk_size do
--                table.insert(chunks, {
--                    min = {x = x, y = y, z = z},
--                    max = {
--                        x = math.min(x + chunk_size - 1, maxp.x),
--                        y = math.min(y + chunk_size - 1, maxp.y),
--                        z = math.min(z + chunk_size - 1, maxp.z)
--                    }
--                })
--            end
--        end
--    end
--
--    local total_chunks = #chunks
--    minetest.log("action", string.format("[ia_util] Queuing %d super-chunks for %s", total_chunks, pname))
--
--    -- 3. THE COROUTINE WORKER
--    local function routine()
--        for i, chunk in ipairs(chunks) do
--            -- Emerge the chunk
--            local success = minetest.delete_area(chunk.min, chunk.max)
--	    assert(success)
----	    if success then
--            minetest.emerge_area(chunk.min, chunk.max)
----    	    end
--            
--            -- Provide status updates every 5 chunks (or if it's the last one)
--            if pname and (i % 5 == 0 or i == total_chunks) then
--                local percent = math.floor((i / total_chunks) * 100)
--                minetest.chat_send_player(pname, 
--                    string.format("Regenerating: %d%% (%d/%d chunks)", percent, i, total_chunks))
--            end
--
--            -- YIELD: Wait 0.2 seconds before the next chunk to let the engine breathe
--            local co = coroutine.running()
--            minetest.after(0.2, function()
--                coroutine.resume(co)
--            end)
--            coroutine.yield()
--        end
--        
--        if pname then
--            minetest.chat_send_player(pname, "Regeneration of country complete!")
--        end
--        minetest.log("action", "[ia_util] LARGE RESET COMPLETE for " .. pname)
--    end
--
--    -- Start the coroutine
--    local co = coroutine.create(routine)
--    coroutine.resume(co)
--
--    return total_chunks
--end
-- ia_util/mapblock.lua

-- 

--- HIGH-SPEED THROTTLED COUNTRY RESET
--- Calculates, Deletes, and Emerges inside a coroutine to eliminate startup latency.
--- @param pos1 table Start corner
--- @param pos2 table End corner
--- @param pname string Player name for status/HUD updates
function ia_util.regenerate_large_area(pos1, pos2, pname)
    assert(pos1 and pos2, "regenerate_large_area: positions missing")
    local minp, maxp = ia_util.sort_pos(pos1, pos2)
    local player = minetest.get_player_by_name(pname)

    -- HUD Setup
--    local hud_id = nil -- didn't work
--    if player then
--        hud_id = player:hud_add({
--            hud_elem_type = "statbar",
--            position = {x = 0.5, y = 0.5},
--            offset = {x = -100, y = 150},
--            text = "default_dirt.png", -- Use dirt icon for the bar
--            number = 0,
--            item = 20, -- Max length of the bar
--            direction = 0,
--            size = {x = 24, y = 24},
--        })
--    end

    -- 1. THE COROUTINE WORKER
    local function routine()
        local chunk_size = 80
        
        -- Calculate total iterations for progress tracking
        local total_x = math.ceil((maxp.x - minp.x + 1) / chunk_size)
        local total_y = math.ceil((maxp.y - minp.y + 1) / chunk_size)
        local total_z = math.ceil((maxp.z - minp.z + 1) / chunk_size)
        local total_chunks = total_x * total_y * total_z
        local current_chunk = 0

        minetest.log("action", string.format("[ia_util] Coroutine started for %s: %d chunks", pname, total_chunks))

        -- Moving the loops INSIDE the coro eliminates the startup freeze
        for x = minp.x, maxp.x, chunk_size do
            for y = minp.y, maxp.y, chunk_size do
                for z = minp.z, maxp.z, chunk_size do
                    current_chunk = current_chunk + 1
                    
                    local c_min = {x = x, y = y, z = z}
                    local c_max = {
                        x = math.min(x + chunk_size - 1, maxp.x),
                        y = math.min(y + chunk_size - 1, maxp.y),
                        z = math.min(z + chunk_size - 1, maxp.z)
                    }

                    -- Delete and Emerge this specific chunk
                    local success = minetest.delete_area(c_min, c_max)
                    assert(success, "regenerate_large_area: delete_area failed at " .. minetest.pos_to_string(c_min))
                    minetest.emerge_area(c_min, c_max)

                    -- HUD and Chat Updates
                    if player and minetest.get_player_by_name(pname) then
                        local percent = (current_chunk / total_chunks)
                        -- Update HUD bar (0 to 20 icons)
--                        player:hud_change(hud_id, "number", math.floor(percent * 20))
                        
                        --if current_chunk % 10 == 0 or current_chunk == total_chunks then
                            minetest.chat_send_player(pname, string.format("Restoring Country: %d%% (%d)", math.floor(percent * 100), current_chunk))
                        --end
                    end

                    -- YIELD: Give the engine 0.1s to process everything else
                    local co = coroutine.running()
                    minetest.after(0.1, function()
                        if coroutine.status(co) == "suspended" then
                            coroutine.resume(co)
                        end
                    end)
                    coroutine.yield()
                end
            end
        end

        -- Cleanup
        if player and minetest.get_player_by_name(pname) then
            player:hud_remove(hud_id)
            minetest.chat_send_player(pname, "World reset successful.")
        end
        minetest.log("action", "[ia_util] LARGE RESET COMPLETE for " .. pname)
    end

    -- Start the process
    local co = coroutine.create(routine)
    coroutine.resume(co)

    return true
end
