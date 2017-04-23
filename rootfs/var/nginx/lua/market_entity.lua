local utils = require('utils')

local base_url  = utils.base_url()
local server_id = ngx.md5(base_url)

-- check if we got a request with ../<country>/<resource> pattern
local country, resource = ngx.unescape_uri(ngx.var.request_uri):match('^.*/markets/(.[^/]+)/(.+)$')

if country == nil and resource == nil then
    -- we got an request with ../<country> pattern
    country = ngx.unescape_uri(ngx.var.request_uri):match('^.*/markets/(.+)$')
end

local market = ngx.shared.cache:get('market.'..country..'-'..server_id)

if market == nil then
    local res = ngx.location.capture('/markets')
    if res.status ~= ngx.HTTP_OK then
        ngx.exit(res.status)
    end

    local markets = cjson.decode(res.body)
    if markets[country] == nil then
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end

    market = cjson.encode(markets[country])

    ngx.shared.cache:set('market.'..country..'-'..server_id, market, 3600)
else
    ngx.log(ngx.INFO, 'Cache hit for market='..country..' at URL: '..base_url)
end

if resource ~= nil then
    local market_data = cjson.decode(market)

    if market_data ~= nil then
        -- see if we have a resource link for the specific market
        if market_data['links'][resource] ~= nil then
            ngx.log(ngx.INFO, 'Redirect resource='..resource..' at market='..country..' to URL: "'..market_data['links'][resource]..'"')
            ngx.redirect(market_data['links'][resource], ngx.HTTP_MOVED_TEMPORARILY)
            return
        else
            -- check for special supplements handling
            local element, name = resource:match('^([^/]+)/(.+)$')
            if element == 'supplements' and market_data['supplements'][name] ~= nil then
                ngx.print(cjson.encode(market_data['supplements'][name]))
                return
            end
        end
    end

    ngx.exit(ngx.HTTP_NOT_FOUND)
else
    ngx.print(market)
end
