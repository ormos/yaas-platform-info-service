
local zone, city = ngx.var.uri:match('^.*/timezone/(.+)/(.+)$')

local luatz = require('luatz')

-- check if zoneinfo file exists, otherwise lua will raise an exception
local name = zone..'/'..city
local f = io.open('/usr/share/zoneinfo/'..name, 'r')
if not f then ngx.exit(ngx.HTTP_NOT_FOUND) end
io.close(f)

local tz     = luatz.get_tz(name)
local utc_ts = luatz.time()
local info   = tz:find_current(utc_ts)

local time_zone_info = {}

time_zone_info['name']            = name
time_zone_info['zone']            = info.abbr
time_zone_info['offset']          = string.format('%+03d:%02d', (info.gmtoff / 3600), (info.gmtoff % 3600))
time_zone_info['daylight_saving'] = info.isdst
time_zone_info['time']            = luatz.timetable.new_from_timestamp(utc_ts):rfc_3339()
time_zone_info['local']           = luatz.timetable.new_from_timestamp(tz:localize(utc_ts)):rfc_3339()..time_zone_info['offset']

local json = cjson.encode(time_zone_info)

ngx.print(json)
