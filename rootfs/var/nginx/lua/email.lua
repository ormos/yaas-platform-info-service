
local email_address = nil

local request_args =  ngx.req.get_uri_args()
if request_args['address'] ~= nil then
    email_address = request_args['address']
else
    email_address = ngx.unescape_uri(ngx.var.request_uri):match('^.*/email/(.+)$')
end

-- if no args are provided we can just cancel here
if email_address == nil then
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

-- check if the email is a valid address format
local function validate_email_address(email_address)

    local regex = [[^(?=[A-Z0-9][A-Z0-9@._%+-]{5,253}+$)[A-Z0-9._%+-]{1,64}+@(?:(?=[A-Z0-9-]{1,63}+\.)[A-Z0-9]++(?:-[A-Z0-9]++)*+\.){1,8}+[A-Z]{2,63}+$]]
    local m = ngx.re.match(email_address, regex, 'ix')

    if m == nil then
        return false
    end

    return true
end

-- check if the email domain belongs to one of the registered domains for temporary email accounts
local function verify_email_address(email_address)

    local recipient, domain = email_address:match('^(.+)@(.+)$')

    local status = ngx.shared.cache:get('email-'..domain)

    if status == nil then
        status = 'valid'

        -- query mogelmail.de about the status of the mail domain
        local http = require('resty.http')
        local client = http.new()
        local res, err = client:request_uri('http://www.mogelmail.de/q/'..domain, { method = 'GET' } )

        if res == nil then
            ngx.log(ngx.INFO, 'Failed to query mogelmail.de for domain='..domain..' - error: '..err)
        else
            if res.status == ngx.HTTP_OK then
                if res.body:match('^%s*1%s*.*$') then
                    status = 'disposable'
                end
                ngx.log(ngx.INFO, 'Verification result from mogelmail.de for domain='..domain..' - result: '..status)
                ngx.shared.cache:set('email-'..domain, status, 3600)
            else
                ngx.log(ngx.INFO, 'Returned status from mogelmail.de for domain='..domain..' - status: '..res.status)
            end
        end
    else
        ngx.log(ngx.INFO, 'Cache hit for email domain='..domain..' with result: '..status)
    end

    return status, domain
end


local info = {}

info['email']  = email_address
-- check if the mail address has a least a valid format
if (validate_email_address(email_address)) then
    info['status'] = 'valid'

    -- check if we got an disposable email
    local verified, domain = verify_email_address(email_address)
    info['domain'] = domain
    info['status'] = verified
else
    info['status'] = 'invalid'
end

local json = cjson.encode(info)

ngx.print(json)