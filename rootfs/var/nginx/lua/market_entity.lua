local utils = require('utils')

local base_url  = utils.base_url()
local server_id = ngx.md5(base_url)

-- check if we got a request with ../<country>/<resource> pattern
local country, resource = ngx.unescape_uri(ngx.var.request_uri):match('^.*/markets/(.[^/]+)/(.+)$')

if country == nil and resource == nil then
    -- we got an request with ../<country> pattern
    country = ngx.unescape_uri(ngx.var.request_uri):match('^.*/markets/(.+)$')
end

local market = ngx.shared.cache:get('market.'..country..'-'..server_id)

if market == nil then
    local res = ngx.location.capture('/markets')
    if res.status ~= ngx.HTTP_OK then
        ngx.exit(res.status)
    end

    local markets = cjson.decode(res.body)
    if markets[country] == nil then
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end

    market = cjson.encode(markets[country])

    ngx.shared.cache:set('market.'..country..'-'..server_id, market, 3600)
else
    ngx.log(ngx.INFO, 'Cache hit for market='..country..' at URL: '..base_url)
end

-- if no subelements are requested just return the market information
if resource == nil then
    ngx.print(market)
    return
end

-- provide enriched supplement data by resolving links and adding mimetypes
local function retrieve_content_info(content_url)

    if content_url:sub(1, base_url:len()) ~= base_url then
        local http = require('resty.http')
        local client = http.new()
        local res, err = client:request_uri(content_url, { method = "HEAD" })

        if res == nil then
            ngx.log(ngx.INFO, 'Failed to query supplement content at url "'..content_url..'" - Error: '..err)
        else
            if res.status == ngx.HTTP_OK then
                if res.headers['Content-Type'] then
                    return content_uri, res.headers['Content-Type']
                end
            else
                ngx.log(ngx.INFO, 'Returned status from supplements for - status: '..res.status)
            end
        end
    --else
        --local res = ngx.location.capture(content_url:sub(base_url:len() + 1))
        --ngx.log(ngx.INFO, 'status: '..res.status..' - Body: '..res.body)
        -- if res.status ~= ngx.HTTP_OK then
    end

    return content_url
end

-- provide enriched supplement data by resolving links and adding mimetypes
local function provide_supplement(supplement_name, market_data)

    for _ , item in ipairs(market_data['supplements'][supplement_name]['items']) do
        ngx.log(ngx.INFO, 'Item: '..item['name'])

        local content_url, content_type = retrieve_content_info(item['content']['data'])
        if content_url then
            item['content']['data'] = content_url
        end
        if content_type then
            item['content']['type'] = content_type
        end
    end

    return cjson.encode(market_data['supplements'][supplement_name])
end

local market_data = cjson.decode(market)
if market_data ~= nil then
    -- see if we have a resource link for the specific market
    if market_data['links'][resource] ~= nil then
        ngx.log(ngx.INFO, 'Redirect resource='..resource..' at market='..country..' to URL: "'..market_data['links'][resource]..'"')
        ngx.redirect(market_data['links'][resource], ngx.HTTP_MOVED_TEMPORARILY)
        return
    else
        -- check for special supplements handling
        local element, name = resource:match('^([^/]+)/(.+)$')
        if element == 'supplements' and market_data['supplements'][name] ~= nil then
            ngx.print(provide_supplement(name, market_data))
            return
        end
    end
end

ngx.exit(ngx.HTTP_NOT_FOUND)
