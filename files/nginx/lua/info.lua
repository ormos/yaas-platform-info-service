local utils = require('utils')

-- if we got an request parameter ip just capture it
if ngx.var.arg_ip ~= nil then
    local res = ngx.location.capture('/info/' .. ngx.var.arg_ip)
    if res.status == 200 then
        ngx.say(res.body)
    end
    ngx.exit(res.status)
end

function add_info(var, table, section, item)
    if var ~=  nil and var ~= '' then
        if table[section] == nil then
            table[section] = {}
        end
        table[section][item] = cd:iconv(var)
    end
end

function add_yaas_info(country, language, base_url)
    local yaas_info_de = {
        market = { id = 'DE',
                    _link_ = base_url .. '/markets/DE',
                    _redirect_='https://yaas.io/de'
                    },
        language = language
    }

    local yaas_info_us = {
        market = { id = 'US',
                    _link_ = base_url .. '/markets/US',
                    _redirect_='https://yaas.io/us'
                    },
        language = language
    }

    local yaas_info = {
        market = { id = '_beta_',
                    _link_ = base_url .. '/markets/_beta_',
                    _redirect_='https://yaas.io/beta'
                    },
        language = language
    }

    if country == 'DE' then
        yaas_info = yaas_info_de
    end

    if country == 'US' then
        yaas_info = yaas_info_us
    end

    return yaas_info
end

-- utils.debug.start()

local info = {
    ip = ngx.var.remote_addr
}

add_info(ngx.var.geoip_city_country_code, info, 'country', 'code')
add_info(ngx.var.geoip_city_country_name, info, 'country', 'name')
add_info(ngx.var.geoip_region_code,       info, 'region',  'code')
add_info(ngx.var.geoip_region_name,       info, 'region',  'name')
add_info(ngx.var.geoip_timezone,          info, 'region',  'timezone')
add_info(ngx.var.geoip_city,              info, 'city',    'name')
add_info(ngx.var.geoip_postal_code,       info, 'city',    'postal')

-- Convert latitude and longitude to numeric values
if ngx.var.geoip_latitude ~= nil and ngx.var.geoip_longitude ~= nil then
    info['position'] = {
        latitude  = tonumber(ngx.var.geoip_latitude),
        longitude = tonumber(ngx.var.geoip_longitude)
    }
end

info['yaas'] = add_yaas_info(ngx.var.geoip_city_country_code,
                                ngx.req.get_headers()['Accept-Language'],
                                utils.base_url())

local json = cjson.encode(info)

ngx.say(json)

-- utils.debug.stop()

