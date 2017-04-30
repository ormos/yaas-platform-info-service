local utils = require('utils')

local base_url  = utils.base_url()

local resource = ngx.var.uri:match('^.*/supplements/(.+)$')

if resource == nil then
    ngx.exit(ngx.HTTP_NOT_FOUND)
end

local url = utils.supplements.get_data_url(resource)
if url == nil then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

if url:sub(1, #base_url) == base_url then
    url = ngx.var.scheme..'://'..ngx.var.server_addr..url:sub(1 + #base_url)
end

ngx.var.target = url
