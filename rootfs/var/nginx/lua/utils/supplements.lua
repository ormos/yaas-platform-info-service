local deep_copy = require('utils.misc').deep_copy
local jwt = require('resty.jwt')

-- load supplements definition
local function _load_supplements(base_url)

    local server_id = ngx.md5(base_url)

    local data = ngx.shared.cache:get('supplements-'..server_id)

    local supplements = {}

    if data == nil then
        _, supplements = require('utils.markets').load(base_url)
        data = cjson.encode(supplements)
        ngx.shared.cache:set('supplements-'..server_id, data, 3600)
    else
        ngx.log(ngx.INFO, 'Cache hit for supplements at URL: '..base_url)
        supplements = cjson.decode(data)
    end

    return supplements
end

local _supplements_base = '/supplements/'

-- encode content url using base64
local function _encode_url(url)
    local token = jwt:sign('SAP-Hybris Y##S', { header = { typ = 'JWT', alg = 'HS256'},
                           payload = { iss = 'yaas.io', exp = ngx.time() + (60 * 60 * 24), sub = 'suppl', aud = 'ypi', link = url }})
    return _supplements_base..token
end

-- decode content url
local function _decode_url(url)
    local token = url
    if url:sub(1, #_supplements_base) == _supplements_base then
        token = url:sub(1 + #_supplements_base)
    end
    local validators = require('resty.jwt-validators')
    validators.set_system_leeway(120)
    local jwt_obj = jwt:verify('SAP-Hybris Y##S', token,
                               { iss = validators.equals('yaas.io'),
                                 exp = validators.is_not_expired(),
                                 sub = validators.equals('suppl') }
                              )
    if jwt_obj['valid'] and jwt_obj['verified'] then
        return jwt_obj['payload']['link']
    end

    ngx.log(ngx.INFO, 'Invalid supplements token: "'..token..'"')
end

local function _get_content_info(url, base_url)

    local proxy_url = _encode_url(url)

    local res = ngx.location.capture(proxy_url, { method = ngx.HTTP_HEAD })
    ngx.log(ngx.INFO, 'status: '..res.status..' - Body: '..res.body)

    if res.status == ngx.HTTP_OK then
        if res.headers['Content-Type'] then
            return base_url..proxy_url, res.headers['Content-Type']
        end
    else
        ngx.log(ngx.INFO, 'Returned status from supplements for - status: '..res.status)
    end

    return base_url..proxy_url
end

local function _get_supplement(market, name, base_url)

    local supplements = _load_supplements(base_url)

    local supplement = {}

    if supplements[market] and supplements[market][name] then
        supplement = supplements[market][name]
        for _ , item in ipairs(supplement['items']) do
            local content_url, content_type = _get_content_info(item['content']['data'], base_url)
            if content_url then
                item['content']['data'] = content_url
            end
            if content_type then
                item['content']['type'] = content_type
            end
        end
    end

    return supplement
end

local function _adjust_markets(markets)
    local supplements = {}

    for id, market in pairs(markets) do
        if market['supplements'] then
            supplements[id] = deep_copy(market['supplements'])
            for _, supplement in pairs(market['supplements']) do
                supplement['items'] = nil
            end
        end
    end

    return markets, supplements
end

return {
    get_proxy_url = _encode_url,
    get_data_url = _decode_url,
    get_content_info = _get_content_info,
    get = _get_supplement,
    adjust_markets = _adjust_markets
}
