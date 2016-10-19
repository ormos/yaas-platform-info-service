

local country, vatin = ngx.var.request_uri:match("^.+/(.+)/(.+)$")

function check_vatin(vatin, country)

  local soap_client = require('soap.client')

  local request = {
    url = 'http://ec.europa.eu/taxation_customs/vies/services/checkVatService',
    soapaction = 'None',
    namespace = 'urn:ec.europa.eu:taxud:vies:services:checkVat:types',
    method = "checkVat",
    entries = {
        { tag = 'countryCode' , country },
        { tag = 'vatNumber'   , vatin   }
    }
  }

  local ns, method, entries = soap_client.call(request)

  local id = nil
  local valid = false

  if (method == 'checkVatResponse') then
    local tags  = {
      vatNumber = function(element) id = element[1] end,
      valid     = function(element) if element[1]:lower() == 'true' then valid = true end end
    }

    for i, element in ipairs(entries) do
      local f = tags[element['tag']]
      if f ~= nil then f(element) end
  	end
  end

  return valid, id
end

local valid, id = check_vatin(vatin, country)

local result = {
    vatin = id,
    status = valid
}

local json = cjson.encode(result)

ngx.say(json)
