local zone, city = ngx.unescape_uri(ngx.var.request_uri):match('^.+/(.+)/(.+)$')

local luatz = require('luatz')

-- check if zoneinfo file exists, otherwise lua will raise an exception
local name = zone..'/'..city
local f = io.open('/usr/share/zoneinfo/'..name, 'r')
if f == nil then ngx.exit(ngx.HTTP_NOT_FOUND) end
io.close(f)

local tz = luatz.get_tz(name)
local info = tz:find_current(luatz.time())

local time_zone_info = {}

time_zone_info['name']            = name
time_zone_info['zone']            = info.abbr
time_zone_info['offset']          = string.format('%+03d:%02d', (info.gmtoff / 3600), (info.gmtoff % 3600))
time_zone_info['daylight_saving'] = info.isdst

local json = cjson.encode(time_zone_info)

ngx.print(json)
