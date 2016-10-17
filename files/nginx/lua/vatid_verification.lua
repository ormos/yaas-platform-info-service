
package.path = package.path .. "/home/ralf/.luarocks/share/lua/5.1/?;/home/ralf/.luarocks/share/lua/5.1/?.lua;/home/ralf/.luarocks/share/lua/5.1/?/init.lua"
package.cpath = package.cpath .. ";/home/ralf/.luarocks/lib/lua/5.1/?.so"

local soap_client = require('soap.client')

local request = {
  url = 'http://ec.europa.eu/taxation_customs/vies/services/checkVatService',
  soapaction = 'None',
  namespace = 'urn:ec.europa.eu:taxud:vies:services:checkVat:types',
  method = "checkVat",
  entries = {
      { tag = 'countryCode' , 'DE' },
      { tag = 'vatNumber'   , '811233781' }
  }
}

local ns, meth, ent = soap_client.call (request)

print("namespace = ", ns, "element name = ", meth)

if (meth == 'checkVatResponse') then
  for i, elem in ipairs(ent) do print(elem['tag'], ' : ', elem[1]) end
end

print"Ok!"