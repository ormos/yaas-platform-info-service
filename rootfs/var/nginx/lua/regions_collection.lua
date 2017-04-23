local utils = require('utils')

local base_url  = utils.base_url()
local server_id = ngx.md5(base_url)

local regions = ngx.shared.cache:get('regions-'..server_id)

if regions == nil then
    local res = ngx.location.capture('/data/regions')
    if res.status ~= ngx.HTTP_OK then
        ngx.exit(res.status)
    end

    local data = cjson.decode(res.body)
    regions = cjson.encode(data.regions)

    regions = utils.substitute(regions, { URL = base_url })

    ngx.shared.cache:set('regions-'..server_id, regions, 3600)
else
    ngx.log(ngx.INFO, 'Cache hit for regions at URL: '..base_url)
end

ngx.print(regions)