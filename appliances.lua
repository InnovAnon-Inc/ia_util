-- ia_util/appliances.lua

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
                --technic.send_items(pos, x_velocity, z_velocity, 'output') -- TODO theoretically, out could be output_stack name aware
                technic.send_items(pos, x_velocity, z_velocity, self.output_stack)
            end
        end
    --end
end



-- [2026-03-06] Modified get_formspec to support multi-slot inventories
-- Uses self.input_stack_width and self.output_stack_width to define grid layout
function ia_util.appliances_get_formspec(self, meta, production_percent, consumption_percent)
    -- [2026-02-27] Assertion to ensure stack widths are defined
    assert(self.input_stack_width, "input_stack_width must be defined")

    local progress;
    -- Calculate height based on total size / width
    local input_h = math.ceil(self.input_stack_size / self.input_stack_width)
    local output_h = math.ceil(self.output_stack_size / (self.output_stack_width or 2))

    -- Update input list coordinates
    -- We use self.input_stack_width instead of a hardcoded '1'
    local input_list = self:get_formspec_list("context", self.input_stack, 1.5, 0.25, self.input_stack_width, input_h);

    local use_list = self:get_formspec_list("context", self.use_stack, 1.5, 1.5, 1, 1);
    local use_listring = "listring[context;"..self.use_stack.."]" ..
                         "listring[current_player;main]";

    if self.have_usage then
        -- Logic for appliances with a 'use' slot (like fuel)
        progress = "image[3.6,0.5;5.5,0.95;appliances_production_progress_bar.png^[transformR270]]";
        if production_percent then
            progress = "image[3.6,0.5;5.5,0.95;appliances_production_progress_bar.png^[lowpart:" ..
                  (production_percent) ..
                  ":appliances_production_progress_bar_full.png^[transformR270]]";
        end
        -- ... (consumption progress logic remains same)
    else
        -- Logic for appliances without fuel (direct electric)
        progress = "image[3.6,0.9;5.5,0.95;appliances_production_progress_bar.png^[transformR270]]";
        if production_percent then
            progress = "image[3.6,0.9;5.5,0.95;appliances_production_progress_bar.png^[lowpart:" ..
                  (production_percent) ..
                  ":appliances_production_progress_bar_full.png^[transformR270]]";
        end

        -- Repositioned for larger grids if no usage slot exists
        input_list = self:get_formspec_list("context", self.input_stack, 1.5, 0.8, self.input_stack_width, input_h);
        use_list = "";
        use_listring = "";
    end

    local formspec =  "size[12.75,8.5]" ..
                      "background[-1.25,-1.25;15,10;appliances_appliance_formspec.png]" ..
                      progress..
                      self:get_player_inv() ..
                      input_list ..
                      use_list ..
                      -- Dynamic output list size
                      self:get_formspec_list("context", self.output_stack, 9, 0.4, (self.output_stack_width or 2), output_h)..
                      "listring[current_player;main]" ..
                      "listring[context;"..self.input_stack.."]" ..
                      "listring[current_player;main]" ..
                      use_listring ..
                      "listring[context;"..self.output_stack.."]" ..
                      "listring[current_player;main]";
    return formspec;
end





















-- [2026-03-06] Helper to check if an item stack matches a recipe requirement (name or group)
function ia_util.item_matches(stack, requirement)
    assert(stack, "ia_util.item_matches: stack is missing")
    assert(requirement, "ia_util.item_matches: requirement is missing")

    local item_name = stack:get_name()
    local req_name = ItemStack(requirement):get_name()

    -- Handle groups
    if req_name:sub(1, 6) == "group:" then
        local group = req_name:sub(7)
        return minetest.get_item_group(item_name, group) > 0
    end

    -- Fallback to direct name comparison
    return item_name == req_name
end

-- [2026-03-06] Helper to find a matching recipe in a dictionary/list while respecting groups
-- Useful for single-slot lookups and usage lookups
function ia_util.find_recipe_match(recipes, stack)
    if not recipes or stack:is_empty() then return nil end

    -- Check for exact match first (optimization for performance)
    local direct = recipes[stack:get_name()]
    if direct then return direct end

    -- Iterate to check for group matches
    for req_name, def in pairs(recipes) do
        if ia_util.item_matches(stack, req_name) then
            return def
        end
    end
    return nil
end

-- [2026-03-06] Checks if a stack satisfies any of the requirements in a recipe's require_usage table
function ia_util.check_require_usage(stack, require_usage)
    if not require_usage then return true end
    for req_name, _ in pairs(require_usage) do
        if ia_util.item_matches(stack, req_name) then return true end
    end
    return false
end

-- [2026-03-06] Safely retrieves a recipe requirement for a specific slot index
function ia_util.get_input_requirement(recipe, index)
    return recipe and recipe.inputs and recipe.inputs[index]
end










function ia_util.appliances_recipe_aviable_input(self, inventory)
  local input = nil;
  if (self.have_input) then
    if (self.input_stack_size <= 1) then
      local input_stack = inventory:get_stack(self.input_stack, 1)
      local input_name = input_stack:get_name();
      --input = self.recipes.inputs[input_name];
      input = ia_util.find_recipe_match(self.recipes.inputs, input_stack)
      if (input==nil) then
        return nil, nil
      end
      minetest.log('appliances:recipe_aviable_input() input_stack count: '..input_stack:get_count())
      minetest.log('appliances:recipe_aviable_input() input.inputs     : '..input.inputs)
      if (input_stack:get_count()<input.inputs) then
        return nil, nil
      end
    else
      for _, check in pairs(self.recipes.inputs) do
        local valid = true;
        for ch_i, ch_val in pairs(check.inputs) do
          local input_stack = inventory:get_stack(self.input_stack, ch_i);
          local check_stack = ItemStack(ch_val);
          --if (input_stack:get_name()~=check_stack:get_name())  then
	  if not ia_util.item_matches(input_stack, ch_val) then
            valid = false;
            break;
          end
          if (input_stack:get_count() < check_stack:get_count()) then
            valid = false;
            break;
          end
        end
        if valid and (check.require_usage~=nil) then
          valid = false
          if (self.have_usage) then
            local usage_stack = inventory:get_stack(self.use_stack, 1)
            local usage_name = usage_stack:get_name();
            --if (check.require_usage[usage_name]) then
	    if ia_util.check_require_usage(usage_stack, check.require_usage) then
              valid = true
            end
          end
        end
        if valid then
          input = check;
          break;
        end
      end
      
      if (input == nil) then
        return nil, nil
      end
    end
  end
  
  local usage_name = nil;
  if (self.have_usage) then
    local usage_stack = inventory:get_stack(self.use_stack, 1)
    usage_name = usage_stack:get_name();
    
    if (input~=nil) and (input.require_usage~=nil) then
      --if (not input.require_usage[usage_name]) then
      if not ia_util.check_require_usage(usage_stack, input.require_usage) then
        return nil, nil
      end
    end
  end
  
  local usage = nil;
  if self.recipes.usages then
    if (usage_name==nil) then
      return nil, nil
    end
    --usage = self.recipes.usages[usage_name];
    usage = ia_util.find_recipe_match(self.recipes.usages, usage_stack);
    if (usage==nil) then
      return nil, nil
    end
  end
  
  return input, usage
end


function ia_util.appliances_recipe_inventory_can_put(self, pos, listname, index, stack, player_name)
  if player_name then
    if minetest.is_protected(pos, player_name) then
      return 0
    end
  end
  
  if listname == self.input_stack then
    if (self.input_stack_size <= 1) then
      --return self.recipes.inputs[stack:get_name()] and
      --            stack:get_count() or 0
      return ia_util.find_recipe_match(self.recipes.inputs, stack) and stack:get_count() or 0
    else
      local meta = minetest.get_meta(pos);
      local inventory = meta:get_inventory();
      
      for _, check in pairs(self.recipes.inputs) do
        local valid = true;
        for ch_i, ch_val in pairs(check.inputs) do
          local input_stack = inventory:get_stack(self.input_stack, ch_i);
          local input_name = input_stack:get_name();
          local check_stack = ItemStack(ch_val);
          --if ((input_name~="") and (input_name~=check_stack:get_name())) then
          if (input_name ~= "") and not ia_util.item_matches(input_stack, ch_val) then
            valid = false;
            break;
          end
        end
        if valid then
          --local check_stack = check.inputs[index];
	  local check_req = ia_util.get_input_requirement(check, index);
          --if check_stack then
            --check_stack = ItemStack(check_stack);
            --if (stack:get_name()==check_stack:get_name())
          if check_req then
            if ia_util.item_matches(stack, check_req) then
              return stack:get_count();
            end
          end
        end
      end
      
      return 0;
    end
  end
  if listname == self.use_stack then
    --return self.recipes.usages[stack:get_name()] and
    --             stack:get_count() or 0
    return ia_util.find_recipe_match(self.recipes.usages, stack) and stack:get_count() or 0
  end
  return 0
end

function ia_util.appliances_recipe_inventory_can_take(self, pos, listname, index, stack, player_name)
  if player_name then
    if minetest.is_protected(pos, player_name) then
      return 0
    end
  end
  local count = stack:get_count();
  local meta = minetest.get_meta(pos);
  if (listname==self.input_stack) then
    local production_time = meta:get_int("production_time") or 0
    if (production_time>0) then
      --local input = self.recipes.inputs[stack:get_name()];
      local input = ia_util.find_recipe_match(self.recipes.inputs, stack)
      if input then
        count = count-input.inputs;
        if (count<0) then count = 0; end
      else
        minetest.log("error", "[Appliances]: Input item missing in recipes list.")
      end
    end
  elseif (listname==self.use_stack) then
    local consumption_time = meta:get_int("consumption_time") or 0
    if (consumption_time>0) then
      count = count - 1;
      if (count<0) then count = 0; end;
    end
  end
  
  return count;
end

