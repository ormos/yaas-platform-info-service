local utils = require('utils')

local base_url = utils.base_url()

local markets = ngx.shared.cache:get('markets-'..base_url)

if markets == nil then
    local res = ngx.location.capture('/data/markets')
    if res.status ~= 200 then
        ngx.exit(res.status)
    end

    local data = cjson.decode(res.body)
    markets = cjson.encode(data.markets)

    markets = utils.substitute(markets, { URL = base_url })
    ngx.shared.cache:set('markets-'..base_url, markets, 3600)

    local mapping = data.mapping
    ngx.shared.cache:set('markets-mapping', mapping, 3600)
end

ngx.say(markets)