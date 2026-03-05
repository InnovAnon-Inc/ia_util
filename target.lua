-- ia_util/target.lua (or inside your util init)
function ia_util.get_target_name(target)
    if not target then return "" end
    
    if target.type == "node" then 
        return target.name 
    end
    
    if target.type == "player" or target.type == "entity" then
        if target.ref and target.ref.get_wielded_item then
            local wielded = target.ref:get_wielded_item()
            if not wielded:is_empty() then
                return wielded:get_name()
            end
        end
    end
    
    return ""
end
