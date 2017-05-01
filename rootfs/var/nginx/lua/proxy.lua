local utils = require('utils')

local base_url  = utils.base_url()

local url = ngx.unescape_uri(ngx.var.arg_upstream)

-- replace base url with the local server host address
if url:sub(1, #base_url) == base_url then
    url = ngx.var.scheme..'://'..ngx.var.server_addr..url:sub(1 + #base_url)
end

ngx.var.url = url
