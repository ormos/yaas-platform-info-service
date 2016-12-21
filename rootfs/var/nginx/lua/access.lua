
local access_data = ngx.shared.cache:get('access-data')

if access_data == nil then
    local res = ngx.location.capture('/data/access')
    if res.status ~= 200 then
        ngx.exit(res.status)
    end

    local data = cjson.decode(res.body)
    access_data = cjson.encode(data.blocked)

    ngx.shared.cache:set('access-data', access_data, 3600)
else
    ngx.log(ngx.INFO, 'Cache hit for access')
end

ngx.print(access_data)