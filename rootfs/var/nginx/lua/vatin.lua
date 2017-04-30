
local country, vatin = ngx.var.uri:match('^.*/vatin/(.+)/(.+)$')

if country == nil or vatin == nil or string.len(country) ~= 2 then
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

function validate_vatin(vatin, country)

    -- TO do
    if vatin ~= nil and string.len(vatin) == 11 and string.upper(string.sub(vatin, 1, 2)) == 'DE' then
        return true
    end

    return false
end

function verify_vatin(vatin, country)

    local status = ngx.shared.cache:get('vatin-'..country..'.'..vatin)

    if status == nil then
        local soap_client = require('soap.client')

        local request = {
            url = 'http://ec.europa.eu/taxation_customs/vies/services/checkVatService',
            soapaction = 'None',
            namespace = 'urn:ec.europa.eu:taxud:vies:services:checkVat:types',
            method = 'checkVat',
            entries = {
                { tag = 'countryCode' , country },
                { tag = 'vatNumber'   , vatin   }
            }
        }

        local ns, method, entries = soap_client.call(request)

        local idn = nil
        local valid = 'valid'

        if (method == 'checkVatResponse') then
            local tags  = {
                vatNumber = function(element) idn = element[1] end,
                valid     = function(element) if element[1]:lower() == 'true' then valid = 'verified' end end
            }

            for _, element in ipairs(entries) do
                local f = tags[element['tag']]
                if f ~= nil then f(element) end
            end

            ngx.log(ngx.INFO, 'Successfully verfified vatin='..vatin..', country='..country..' with status: ('..idn..'='..valid..')')

            ngx.shared.cache:set('vatin-'..country..'.'..vatin, idn..'='..valid, 3600)
        else
            ngx.log(ngx.INFO, 'Failed to verify vatin for vatin='..vatin..', country='..country)
        end

        return valid, idn
    else
        local idn, valid = status:match('^([^=]+)=([^⁼]+)$')

        ngx.log(ngx.INFO, 'Cache hit for vatin='..vatin..', country='..country..' with status: ('..idn..'='..valid..')')

        return valid, idn
    end
end

local info = {}

info['country']  = country
info['vatin']    = vatin
info['status']   = 'invalid'

if validate_vatin(vatin, country) then
  info['status']   = 'valid'

  local verified, idn = verify_vatin(string.sub(vatin,3), country)
  info['status'] = verified
  info['vatin']  = idn
end

local json = cjson.encode(info)

ngx.print(json)
