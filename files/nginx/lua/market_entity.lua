local utils = require('utils')

local base_url = utils.base_url()

local country = ngx.var.request_uri:match('^.+/(.+)$')

local market = ngx.shared.cache:get('market.'..country..'-'..base_url)

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

    ngx.shared.cache:set('market.'..country..'-'..base_url, market, 3600)
end

ngx.say(market)