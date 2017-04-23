local date = require('date')

local function _load_policies()
    -- use the policy information if we got one
    local res = ngx.location.capture('/policies')
    if res.status == ngx.HTTP_OK then
        return cjson.decode(res.body)
    end
end

-- check if access should be blocked because of export restrictions
local function _get_policy(country)

    local policies = _load_policies()
    if policies[country] ~= nil then
        local ts = date(true)
        if (date(policies[country]['_begin']) <= ts) and (date(policies[country]['_end']) >= ts) then
            ngx.log(ngx.INFO, 'Network access blocked for country: '..country..' - '..policies[country]['name'])
            return "blocked"
        end
    end

    return "unrestricted"
end

local function _get_policy_info(country)
    local policy_info = {}

    local policies = _load_policies()
    if policies[country] ~= nil then
        policy_info['access'] = 'bocked'
        policy_info['active-from'] = date(policies[country]['_begin']):fmt("${iso}")
        policy_info['active_till'] = date(policies[country]['_end']):fmt("${iso}")
        if policies[country]['comment'] ~= nil then
            policy_info['comment'] = policies[country]['comment']
        end
    else
        policy_info['access'] = 'unrestricted'
    end

    return policy_info
end

local function _get_blocked_countries()
    local blocked_countries = {}

    local policies = _load_policies()
    for _, entry in pairs(policies) do
        local ts = date(true)
        if (date(entry['_begin']) <= ts) and (date(entry['_end']) >= ts) then
            blocked_countries[#blocked_countries + 1] = entry['id']
        end
    end

    return blocked_countries
end

return {
    get = _get_policy,
    info = _get_policy_info,
    get_blocked_countries = _get_blocked_countries
}
