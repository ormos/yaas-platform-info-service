local date = require('date')

local function _active_time_range(from, till)
    local active_from, active_till
    if from ~= nil then
        active_from = date(from)
    end
    if till ~= nil then
        active_till = date(till)
    end
    local ts = date(true)
    if ((active_till == nil) or (active_till > ts)) and
       ((active_from == nil) or (active_from < ts)) then
        return true
    else
        return false
    end
end

return {
    active_time_range = _active_time_range
}
