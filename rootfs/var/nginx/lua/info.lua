local utils = require('utils')

-- if we got an request parameter ip just capture it
if ngx.var.arg_ip ~= nil then
    local res = ngx.location.capture('/info/'..ngx.var.arg_ip)
    if res.status == ngx.HTTP_OK then
        ngx.print(res.body)
    end
    ngx.exit(res.status)
end

-- analyze the accepted language set by the 'Accept-Language' header
local function get_accepted_languages()

    local accepted_languages_scores = {}

    if not ngx.req.get_headers()['Accept-Language'] then
        accepted_languages_scores['*'] = 1.0
    else
        for range in ngx.req.get_headers()['Accept-Language']:gmatch(' *([^,]+) *') do
            accepted_languages_scores[range:match('([^;]+)')] = range:match('q *= *([0-9.]+)') or 1.0
        end
    end

    -- Hack for user agents which don't send quality values for wildcards
    if ngx.req.get_headers()['Accept-Language'] and not ngx.req.get_headers()['Accept-Language']:find('q=') then
        for language, score in pairs(accepted_languages_scores) do
            if language == '*' then
                accepted_languages_scores[language] = 0.01
            end
        end
    end

    return accepted_languages_scores
end

-- get the prefered language language based on the 'Accept-Language' header
local function get_prefered_language(provided_languages, accepted_languages)

    -- analyze the accept-language header
    if accepted_languages == nil then
        accepted_languages = get_accepted_languages()
    end

    -- default if we can find nothing
    local prefered_language = provided_languages[1]
    local highest_score = 0

    -- iterate through the provided languages and select the one with the highest score
    for _ , language in ipairs(provided_languages) do
        local s1 = accepted_languages[language] or accepted_languages['*'] or 0.0
        -- for language-country combination let's try a second run with the language only
        local s2 = accepted_languages[language:match('^([^-]+)')] or accepted_languages['*'] or 0.0
        if math.max(s1, s2) > highest_score then
            prefered_language = language
            highest_score = math.max(s1, s2)
        end
    end

    return prefered_language
end

-- add optional location information
local function add_location_info(table, var, section, item)
    if var ~=  nil and var ~= '' then
        if table[section] == nil then
            table[section] = {}
        end
        table[section][item] = var
    end
end

-- map from a country to the market
local function map_country_to_market(country, markets)

    local market_id = country

    -- use the mapping if we got one
    local res = ngx.location.capture('/mapping')
    if res.status == 200 then
        local mapping = cjson.decode(res.body)
        market_id = mapping[country] or (markets[country] and markets[country].id) or mapping['*'] or market_id
    end

    ngx.log(ngx.INFO, 'Detected '..country..' market: '..market_id)

    return markets[market_id]
end

-- load the market data
local res = ngx.location.capture('/markets')
if res.status ~= 200 then
    ngx.exit(res.status)
end
local markets = cjson.decode(res.body)

-- prepare the country information (uppercase 2-letter)
local country = ngx.var.geoip_country_code
if country ~= nil and country:len() >= 2 then
    country = country:gsub(' *(%S%S)', string.upper)
else
    country = '??'
end

-- get the market based on the country
local market = map_country_to_market(country, markets) or markets['_beta_']

ngx.log(ngx.INFO, 'Detected country='..country..':market='..market['id']..' for IP-address:'..ngx.var.remote_addr)

-- the default information structure
local info = {
    network = {
        ip     = ngx.var.remote_addr,
        access = utils.policy.get(country)
    },
    yaas = { language = {
                preferred = get_prefered_language(market['locale']['languages']),
                official  = market['locale']['official'],
                default   = market['locale']['default']
             },
             market = {
                 id         = market['id'],
                 _redirect_ = market['url'],
                 _link_     = market['_link_']
             }
    }
}

-- add optional location specific information
add_location_info(info, ngx.var.geoip_continent_code, 'continent', 'code')
add_location_info(info, ngx.var.geoip_continent_name, 'continent', 'name')
add_location_info(info, ngx.var.geoip_country_code,   'country',   'code')
add_location_info(info, ngx.var.geoip_country_name,   'country',   'name')
add_location_info(info, ngx.var.geoip_region_code,    'region',    'code')
add_location_info(info, ngx.var.geoip_region_name,    'region',    'name')
add_location_info(info, ngx.var.geoip_city_name,      'city',      'name')
add_location_info(info, ngx.var.geoip_city_postal,    'city',      'postal')

if ngx.var.geoip_time_zone ~= nil and ngx.var.geoip_time_zone ~= '' then
    local time_zone_info = {
        name   = ngx.var.geoip_time_zone,
        _link_ = utils.base_url()..'/timezone/'..ngx.var.geoip_time_zone
    }
    add_location_info(info, time_zone_info, 'region', 'timezone')
end

-- Convert latitude and longitude to numeric values
if ngx.var.geoip_location_latitude ~= nil and ngx.var.geoip_location_longitude ~= nil then
    info['position'] = {
        latitude  = tonumber(ngx.var.geoip_location_latitude),
        longitude = tonumber(ngx.var.geoip_location_longitude)
    }
    info['position']['_map_'] = 'https://www.google.com/maps/@'..ngx.var.geoip_location_latitude..','..ngx.var.geoip_location_longitude..',10z'
end

local json = cjson.encode(info)

ngx.print(json)


