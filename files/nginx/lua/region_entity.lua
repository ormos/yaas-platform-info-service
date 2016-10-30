
local utils = require('utils')

local base_url  = utils.base_url()
local server_id = ngx.md5(base_url)

local continent = ngx.unescape_uri(ngx.var.request_uri):match('^.+/(.+)$')

local region = ngx.shared.cache:get('region.'..continent..'-'..server_id)

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

    ngx.shared.cache:set('region.'..continent..'-'..server_id, region, 3600)
else
    ngx.log(ngx.INFO, 'Cache hit for region='..continent..' at URL: '..base_url)
end

ngx.print(region)
