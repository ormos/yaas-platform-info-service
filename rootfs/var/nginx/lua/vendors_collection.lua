local utils = require('utils')

local base_url  = utils.base_url()
local server_id = ngx.md5(base_url)

local vendors = ngx.shared.cache:get('vendors-'..server_id)

if vendors == nil then
    local res = ngx.location.capture('/markets')
    if res.status ~= ngx.HTTP_OK then
        ngx.exit(res.status)
    end

    local markets = cjson.decode(res.body)

    local data = {}

    for _, market in pairs(markets) do
        if market['billing'] ~= nil and market['billing']['vendor'] ~= nil then
            local info = {}
            info['id'] = market['billing']['vendor']
            info['_link_'] = utils.base_url()..'/vendors/'..market['billing']['vendor']
            info['market'] = market['_link_']

            if market['region'] ~= nil then
                info['region'] = market['region']['_link_']
            end

            data[info['id']] = info
        end
    end

    vendors = cjson.encode(data)

    ngx.shared.cache:set('vendors-'..server_id, vendors, 3600)
else
    ngx.log(ngx.INFO, 'Cache hit for vendors at URL: '..base_url)
end

ngx.print(vendors)