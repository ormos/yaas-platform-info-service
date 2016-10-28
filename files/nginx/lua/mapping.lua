
local mapping = ngx.shared.cache:get('markets-mapping')

if mapping == nil then
    local res = ngx.location.capture('/data/markets')
    if res.status ~= 200 then
        ngx.exit(res.status)
    end

    local data = cjson.decode(res.body)
    local mapping = cjson.encode(data.mapping)

    ngx.shared.cache:set('markets-mapping', mapping, 3600)
end

ngx.say(mapping)