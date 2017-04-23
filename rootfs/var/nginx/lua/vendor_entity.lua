local utils = require('utils')

local base_url  = utils.base_url()
local server_id = ngx.md5(base_url)

local vendor_id = ngx.unescape_uri(ngx.var.request_uri):match('^.*/vendors/(.+)$')

local vendor = ngx.shared.cache:get('vendor.'..vendor_id..'-'..server_id)

if vendor == nil then
    local res = ngx.location.capture('/vendors')
    if res.status ~= ngx.HTTP_OK then
        ngx.exit(res.status)
    end

    local vendors = cjson.decode(res.body)
    if vendors[vendor_id] == nil then
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end

    vendor = cjson.encode(vendors[vendor_id])

    ngx.shared.cache:set('vendor.'..vendor_id..'-'..server_id, vendor, 3600)
else
    ngx.log(ngx.INFO, 'Cache hit for vendor='..vendor_id..' at URL: '..base_url)
end

ngx.print(vendor)