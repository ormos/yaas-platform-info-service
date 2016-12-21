local country = ngx.unescape_uri(ngx.var.request_uri):match('^.+/(.+)$')

local sqlite = require('sqlite3')


-- check if access should be blocked because of export restrictions
local function get_country_info(db, country)

    local select_stmt = db:prepare('SELECT id, country_iso_code, country_name, continent_code, continent_name FROM Countries WHERE country_iso_code = $country_code LIMIT 1')

    select_stmt:bind(country)

    return select_stmt:rows()(1)
end

local function get_networks(db, network_type, country_id)

    local select_stmt

    if network_type == 'IPv4' then
        select_stmt = db:prepare('SELECT network FROM IPv4 WHERE country_id = $country_id')
    else
        select_stmt = db:prepare('SELECT network FROM IPv6 WHERE country_id = $country_id')
    end

    select_stmt:bind(country_id)

    local networks = {}
    for row in select_stmt:rows() do
        table.insert(networks, row.network)
    end

    return networks
end


local db = sqlite.open("/var/nginx/data/geoip-networks.db", sqlite.OPEN_READONLY + sqlite.OPEN_SHAREDCACHE)

local country_info = get_country_info(db, country)

if country_info == nil then
    ngx.exit(ngx.HTTP_NOT_FOUND)
    db:close()
end

local networks_info = {
    id   = country_info['country_iso_code'],
    name = country_info['country_name'],
    continent = {
        id   = country_info['continent_code'],
        name = country_info['continent_name']
    },
    networks = {
    }
}

local IPv4 = get_networks(db, 'IPv4', country_info['id'])
if #IPv4 > 0 then networks_info['networks']['IPv4'] = IPv4 end

local IPv6 = get_networks(db, 'IPv6', country_info['id'])
if #IPv6 > 0 then networks_info['networks']['IPv6'] = IPv6 end

db:close()

local json = cjson.encode(networks_info)

ngx.print(json)
