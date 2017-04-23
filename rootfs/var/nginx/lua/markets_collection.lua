local utils = require('utils')

local base_url  = utils.base_url()
local server_id = ngx.md5(base_url)

local markets = ngx.shared.cache:get('markets-'..server_id)

if markets == nil then
    local res = ngx.location.capture('/data/markets')
    if res.status ~= ngx.HTTP_OK then
        ngx.exit(res.status)
    end

    local data = cjson.decode(res.body)
    markets = cjson.encode(data.markets)

    markets = utils.substitute(markets, { URL = base_url })

    ngx.shared.cache:set('markets-'..server_id, markets, 3600)
else
    ngx.log(ngx.INFO, 'Cache hit for markets at URL: '..base_url)
end

ngx.print(markets)