local utils = require('utils')

local base_url = utils.base_url()

local regions = ngx.shared.cache:get('regions-'..base_url)

if regions == nil then
    local res = ngx.location.capture('/data/regions')
    if res.status ~= 200 then
        ngx.exit(res.status)
    end

    local data = cjson.decode(res.body)
    regions = cjson.encode(data.regions)

    regions = utils.substitute(regions, { URL = base_url })

    ngx.shared.cache:set('regions-'..base_url, regions, 3600)
end

ngx.say(regions)