local utils = require('utils')

local base_url  = utils.base_url()
local server_id = ngx.md5(base_url)

local country_networks = ngx.shared.cache:get('country-networks-'..server_id)

if country_networks == nil then

    local sqlite = require('sqlite3')

    local db = sqlite.open("/var/nginx/data/geoip-networks.db", sqlite.OPEN_READONLY + sqlite.OPEN_SHAREDCACHE)

    local networks_list = {}

    for row in db:rows('SELECT country_iso_code, country_name FROM Countries WHERE country_name IS NOT NULL') do
        networks_list[row['country_iso_code']] = {
            id     = row['country_iso_code'],
            name   = row['country_name'],
            _link_ = utils.base_url() .. '/networks/' .. row['country_iso_code']
        }
    end

    db:close()

    local blocked_networks = {}

    -- re-arrange the countries with export control restrictions
    local res = ngx.location.capture('/access')
    if res.status == 200 then
        local blocked_countries = cjson.decode(res.body)
        for _ , entry in ipairs(blocked_countries) do
            if networks_list[entry['id']] ~= nil then
                blocked_networks[entry['id']] = networks_list[entry['id']]
                networks_list[entry['id']]    = nil
            end
        end
    end

    local networks_overview = {
        unrestricted = networks_list,
        blocked      = blocked_networks
    }

    country_networks = cjson.encode(networks_overview)

    ngx.shared.cache:set('country-networks-'..server_id, country_networks, 3600)
else
    ngx.log(ngx.INFO, 'Cache hit for networks overview at URL: '..base_url)
end

ngx.print(country_networks)
