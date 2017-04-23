-- Token generation with expiration time (exp) : 30-JUN-2017 23:59:59
-- ngx.say(jwt:sign('SAP-Hybris Y##S', { header = { typ = 'JWT', alg = 'HS256'},
--                  payload = { iss = 'yaas.io', exp = 1498867199, sub = 'geoip data access', aud = 'yProfile', company = 'SAP-Hybris' }}))

local jwt = require('resty.jwt')

-- we use a json web token for authorization
local jwt_token = ngx.req.get_headers()['X-Access-Token']

if jwt_token ~= nil then
    local validators = require('resty.jwt-validators')

    validators.set_system_leeway(120)
    local jwt_obj = jwt:verify('SAP-Hybris Y##S', jwt_token,
                                { iss = validators.equals('yaas.io'),
                                exp = validators.is_not_expired(),
                                sub = validators.equals('geoip data access') }
                            )
    if jwt_obj['valid'] and jwt_obj['verified'] then
        -- just take the GeoIP-City mmdb file and let nginx deliver that
        ngx.header.content_type = 'application/octet-stream'
        ngx.header['Content-Disposition'] = 'filename="geoip.mmdb"'
        ngx.exec('/data/geoip/GeoIP-City.mmdb')
        ngx.exit(ngx.HTTP_OK)
    else
        ngx.log(ngx.INFO, 'Access token validation failed for reason: "'..jwt_obj['reason']..'"')
    end
end

ngx.status = ngx.HTTP_UNAUTHORIZED
ngx.exit(ngx.HTTP_UNAUTHORIZED)

