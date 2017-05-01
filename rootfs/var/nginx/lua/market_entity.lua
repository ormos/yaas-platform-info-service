local utils = require('utils')

local base_url  = utils.base_url()
local server_id = ngx.md5(base_url)

-- check if we got a request with ../<country>/<resource> pattern
local country, resource = ngx.var.uri:match('^.*/markets/(.[^/]+)/(.+)$')

if country == nil and resource == nil then
    -- we got an request with ../<country> pattern
    country = ngx.var.uri:match('^.*/markets/(.+)$')
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
local function provide_supplement(supplement_name, market_data)

    local supplement = ngx.shared.cache:get('market.'..market_data['id']..'.supplements.'..supplement_name..'-'..server_id)

    if supplement == nil then
        supplement = cjson.encode(utils.supplements.get(market_data, supplement_name, base_url))
        ngx.shared.cache:set('market.'..market_data['id']..'.supplements.'..supplement_name..'-'..server_id, supplement, 3600)
    else
        ngx.log(ngx.INFO, 'Cache hit for supplement="'..supplement_name..'" at market='..market_data['id'])
    end

    return supplement
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
