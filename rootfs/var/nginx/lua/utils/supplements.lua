local deep_copy = require('utils.misc').deep_copy
local jwt = require('resty.jwt')

-- load supplements definition
local function _load_supplements(base_url)

    local server_id = ngx.md5(base_url)

    local data = ngx.shared.cache:get('supplements-'..server_id)

    local supplements = {}

    if not data then
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
local function _encode_url(url, language)
    local token = jwt:sign('SAP-Hybris Y##S', { header = { typ = 'JWT', alg = 'HS256'},
                           payload = { iss = 'yaas.io', exp = ngx.time() + (60 * 60 * 24), sub = 'suppl', aud = 'ypi', link = url, lng = language }})
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
        return jwt_obj['payload']['link'], jwt_obj['payload']['lng']
    end

    ngx.log(ngx.INFO, 'Invalid supplements token: "'..token..'"')
end

-- adjust request headers for upstream server requests
local function _set_request_header(language)
    local mime_types = 'application/pdf;q=0.9,'..
                       'text/htmlapplication/xhtml+xml, application/xml;q=0.8,'..
                       'application/rtf;q=0.6,'..
                       'text/plain;q=0.4,'..
                       'text/*;q=0.2,'..
                       '*/*;q=0.1'
    ngx.req.set_header('Accept', mime_types)
    ngx.req.set_header('accept-encoding', 'gzip,deflate')
    if language then
        ngx.req.set_header('Accept-Language', language)
    end
    ngx.req.clear_header('user-agent')
    ngx.req.clear_header('referer')
    ngx.req.clear_header('cache-control')
end

-- retrieve the content items details info and cache them through proxy
local function _get_content_info(url, base_url, market)

    local function _retrieve_content(url, level)
        local res = ngx.location.capture('/proxy', { args = { upstream = url },
                                                     method = ngx.HTTP_HEAD })
        if (res.status == HTTP_MOVED_PERMANENTLY or
            res.status == ngx.HTTP_MOVED_TEMPORARILY) and
           level <= 3 then
            ngx.log(ngx.INFO, 'content request "'..url..'" redirected to "'..res.header['Location']..'" - [level:'..level..']')
            return _retrieve_content(res.header['Location'], level + 1);
        end
        return res, url
    end

    _set_request_header(market['locale']['official'])
    local res, url = _retrieve_content(url, 1)

    local encoded_url = base_url.._encode_url(url, market['locale']['official'])

    if res.status == ngx.HTTP_OK then
        local content_type = res.header['Content-Type']
        local content_length = res.header['Content-Length']
        return encoded_url, content_type, content_length
    else
        ngx.log(ngx.INFO, 'Failed to retrieve supplement content "'..url..'" - status:'..res.status)
    end

    return encoded_url
end

-- enrich and return the supplement data (add items details)
local function _get_supplement(market, name, base_url)

    local supplements = _load_supplements(base_url)
    local supplement = {}

    if supplements[market['id']] and supplements[market['id']][name] then
        supplement = supplements[market['id']][name]
        for _ , item in ipairs(supplement['items']) do
            local content_url, content_type, content_length = _get_content_info(item['content']['data'], base_url, market)
            item['content']['data'] = content_url
            if content_type then
                item['content']['type'] = content_type
            end
            if content_length then
                item['content']['length'] = content_length
            end
        end
    end

    return supplement
end

-- get supplements collection
local function _get_collection(market, base_url)

    local supplements = _load_supplements(base_url)
    local collection = {}

    if supplements[market['id']] then
        collection = deep_copy(supplements[market['id']])
        for name, supplement in pairs(collection) do
            if name ~= '_link_' then
                supplement['items'] = nil
            end
        end
    end

    return collection
end

-- create a copy of the supplements as dedicate entity aside the markets
local function _adjust_markets(markets, base_url)
    local supplements = {}

    for id, market in pairs(markets) do
        if market['supplements'] then
            supplements[id] = deep_copy(market['supplements'])
            for name, supplement in pairs(market['supplements']) do
                if name ~= '_link_' then
                    market['supplements'][name] = supplement['_link_']
                end
            end
        end
    end

    return markets, supplements
end

return {
    get_proxy_url = _encode_url,
    get_data_url = _decode_url,
    get = _get_supplement,
    collection = _get_collection,
    adjust_markets = _adjust_markets,
    set_header = _set_request_header
}
