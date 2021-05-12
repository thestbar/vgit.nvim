local M = {}

M.assign = function(state, config)
    if not config then
        return state
    end
    local function assign(state_segment, config_segment)
        local state_segment_type = type(state_segment)
        local config_segment_type = type(config_segment)
        assert(state_segment_type == config_segment_type, 'invalid config')
        if config_segment_type == 'table' then
            for key, state_value in pairs(state_segment) do
                local config_value = config_segment[key]
                if config_value ~= nil then
                    local state_value_type = type(state_value)
                    local config_value_type = type(config_value)
                    if config_value_type == 'table' then
                        assign(state_segment[key], config_segment[key])
                    else
                        assert(state_value_type == config_value_type, 'invalid config')
                        state_segment[key] = config_value
                    end
                end
            end
        end
    end
    assign(state, config)
    return state
end

return M
