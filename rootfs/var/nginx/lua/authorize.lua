local utils = require('utils')

-- check if some one is trying to access from a country on embargo
if utils.policy.get(ngx.var.geoip_country_code) == 'blocked' then
    ngx.status = 403
    ngx.exit(403)
end