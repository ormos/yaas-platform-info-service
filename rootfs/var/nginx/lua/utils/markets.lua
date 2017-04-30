
local function _load_markets(base_url)
    local res = ngx.location.capture('/data/markets')
    if res.status ~= ngx.HTTP_OK then
        ngx.exit(res.status)
    end

    local substitute = require('utils.substitute').substitute
    local adjust_markets = require('utils.supplements').adjust_markets

    -- substitute placeholder variable
    local json = substitute(res.body, { URL = base_url })

    return adjust_markets(cjson.decode(json)['markets'])
end

return {
    load = _load_markets
}
