local markets = ngx.shared.cache:get("markets")
if markets == nil then
    local res = ngx.location.capture("/data/markets")
    if res.status ~= 200 then
        ngx.exit(res.status)
    end
    local data = cjson.decode(res.body)
    markets = cjson.encode(data.markets)
    ngx.shared.cache:set("markets", markets, 3600)
end
ngx.say(markets)