local utils = require('utils')

local base_url  = utils.base_url()

local resource = ngx.var.uri:match('^.*/supplements/(.+)$')

if not resource then
    ngx.exit(ngx.HTTP_NOT_FOUND)
end

-- get the url from the token
local url, lang = utils.supplements.get_data_url(resource)
if not url then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

-- set acceptance and language headers
utils.supplements.set_header(lang)

-- load the content via caching proxy
ngx.exec('/proxy', { upstream = url })
