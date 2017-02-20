local utils = require('utils')

local base_url  = utils.base_url()
local server_id = ngx.md5(base_url)

-- check if we got a request with ../<country>/<resource> pattern
local country, resource = ngx.unescape_uri(ngx.var.request_uri):match('^.*/markets/(.+)/(.+)$')
if country == nil and resource == nil then
    -- we got an request with ../<country> pattern
    country = ngx.unescape_uri(ngx.var.request_uri):match('^.*/markets/(.+)$')
end

local market = ngx.shared.cache:get('market.'..country..'-'..server_id)

if market == nil then
    local res = ngx.location.capture('/markets')
    if res.status ~= 200 then
        ngx.exit(res.status)
    end

    local markets = cjson.decode(res.body)
    if markets[country] == nil then
        ngx.exit(404)
    end

    market = cjson.encode(markets[country])

    ngx.shared.cache:set('market.'..country..'-'..server_id, market, 3600)
else
    ngx.log(ngx.INFO, 'Cache hit for market='..country..' at URL: '..base_url)
end

if resource ~= nil then
    local market_data = cjson.decode(market)

    -- see if we have a resource link for the specific market
    if market_data ~= nil and market_data['links'][resource] ~= nil then
        ngx.log(ngx.INFO, 'Redirect resource='..resource..' at market='..country..' to URL: "'..market_data['links'][resource]..'"')
        ngx.redirect(market_data['links'][resource], ngx.HTTP_MOVED_TEMPORARILY);
    else
        ngx.exit(404)
    end
else
    ngx.print(market)
end
