
local continent = ngx.var.request_uri:match("^.+/(.+)$")
local region = ngx.shared.cache:get("regions." .. continent)
if region == nil then
    local regions = ngx.shared.cache:get("regions")
    if regions == nil then
        local res = ngx.location.capture("/regions")
        if res.status ~= 200 then
            ngx.exit(res.status)
        end
        regions = res.body
    end
    local data = cjson.decode(regions)
    if data[continent] == nil then
        ngx.exit(404)
    end
    region = cjson.encode(data[continent])
    ngx.shared.cache:set("market." .. continent, region, 3600)
end
ngx.say(region)