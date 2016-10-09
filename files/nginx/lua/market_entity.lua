local country = ngx.var.request_uri:match("^.+/(.+)$")
local market = ngx.shared.cache:get("market." .. country)
if market == nil then
    local markets = ngx.shared.cache:get("markets")
    if markets == nil then
        local res = ngx.location.capture("/markets")
        if res.status ~= 200 then
            ngx.exit(res.status)
        end
        markets = res.body
    end
    local data = cjson.decode(markets)
    if data[country] == nil then
        ngx.exit(404)
    end
    market = cjson.encode(data[country])
    ngx.shared.cache:set("market." .. country, market, 3600)
end
ngx.say(market)