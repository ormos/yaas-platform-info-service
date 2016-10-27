
local utils = require('utils')

local base_url = utils.base_url()

local continent = ngx.var.request_uri:match('^.+/(.+)$')

local region = ngx.shared.cache:get('region.'..continent..'-'..base_url)

if region == nil then
    local res = ngx.location.capture('/regions')
    if res.status ~= 200 then
        ngx.exit(res.status)
    end

    local regions = cjson.decode(res.body)
    if regions[continent] == nil then
        ngx.exit(404)
    end

    region = cjson.encode(regions[continent])

    ngx.shared.cache:set('region.'..continent..'-'..base_url, region, 3600)
end

ngx.say(region)