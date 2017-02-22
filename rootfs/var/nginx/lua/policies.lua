local date = require('date')

local function _get_datetime(str, expand)
    local dt
    if str ~= nil then
        dt = date(str)
        -- if no time was given, set the time to end of the day
        if expand and (dt ~= nil) and (str:find('T') == nil) and
           (dt:gethours() == 0) and (dt:getminutes() == 0) and
           (dt:getseconds() == 0) then
           dt:sethours(23, 59, 59)
        end
    end
    -- if we have no datetime specified at all use the maximum and minimum
    if dt == nil then
        if expand then
            dt = date(0x7FFFFFFF)
        else
            dt = date(0)
        end
    end

    return date.diff(dt, date.epoch()):spanseconds()
end

local policies_data = ngx.shared.cache:get('policies-data')

if policies_data == nil then
    local res = ngx.location.capture('/data/policies')
    if res.status ~= 200 then
        ngx.exit(res.status)
    end

    local data = cjson.decode(res.body)

    -- convert the array into a hash for later usage
    local policies_info = {}
    for _ , entry in ipairs(data.blocked) do
        entry['_begin'] = _get_datetime(entry['active-from'], false)
        entry['_end']   = _get_datetime(entry['active-till'], true)
        policies_info[entry['id']] = entry
    end

    policies_data = cjson.encode(policies_info)

    ngx.shared.cache:set('policies-data', policies_data, 3600)
else
    ngx.log(ngx.INFO, 'Cache hit for policies')
end

ngx.print(policies_data)