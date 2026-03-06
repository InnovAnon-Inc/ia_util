function ia_util.appliances_cb_on_production(self, timer_step)
    -- [2026-02-27] Assertions to make API assumptions explicit and catch inconsistencies
    assert(timer_step, "cb_on_production: timer_step is missing")
    assert(timer_step.pos, "cb_on_production: timer_step.pos is missing")
    assert(timer_step.meta, "cb_on_production: timer_step.meta is missing")
    assert(timer_step.inv, "cb_on_production: timer_step.inv is missing")

    local pos = timer_step.pos
    local meta = timer_step.meta
    local inv = timer_step.inv

    -- [2026-02-28] Log attempt to process production to aid in debugging if logic fails
    --minetest.log("action", "[fakery] refinery_lv:cb_on_production triggered at " .. minetest.pos_to_string(pos))

    -- Integration logic for Pipeworks and Technic
    assert(minetest.get_modpath("pipeworks"))
    assert(minetest.get_modpath("technic"))
    --if minetest.get_modpath("pipeworks") and minetest.get_modpath("technic") then
        local node = minetest.get_node(pos)
        local x_velocity = 0
        local z_velocity = 0

        -- Direction logic: Eject to the LEFT side relative to the machine's face.
        -- Derived from technic.handle_machine_pipeworks
        if node.param2 == 3 then z_velocity = -1 end
        if node.param2 == 2 then x_velocity = -1 end
        if node.param2 == 1 then z_velocity =  1 end
        if node.param2 == 0 then x_velocity =  1 end

        -- Check for a receiving tube at the output position
        local pos1 = vector.add(pos, {x = x_velocity, y = 0, z = z_velocity})
        local node1 = minetest.get_node(pos1)

        if minetest.get_item_group(node1.name, "tubedevice") > 0 then
            -- Use the stack name defined in the appliance instance (e.g., "output" or "dst")
            local list = inv:get_list(self.output_stack)

            local has_items = false
            if list then
                for _, stack in ipairs(list) do
                    if not stack:is_empty() then
                        has_items = true
                        break
                    end
                end
            end

            if has_items then
                -- [2026-03-06] Use Technic's native item handler to inject into the network.
                -- This handles inventory removal and Pipeworks entity spawning.
                technic.send_items(pos, x_velocity, z_velocity, 'output') -- TODO theoretically, out could be output_stack name aware
            end
        end
    --end
end

