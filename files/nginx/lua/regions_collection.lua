local regions = ngx.shared.cache:get("regions")
if regions == nil then
    local res = ngx.location.capture("/data/regions")
    if res.status ~= 200 then
        ngx.exit(res.status)
    end
    local data = cjson.decode(res.body)
    regions = cjson.encode(data.regions)
    ngx.shared.cache:set("regions", regions, 3600)
end
ngx.say(regions)