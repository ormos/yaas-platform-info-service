
local email_address = nil

if ngx.var.arg_address then
    email_address = ngx.var.arg_address
else
    email_address = ngx.var.uri:match('^.*/email/(.+)$')
end

-- if no args are provided we can just cancel here
if not email_address then
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

-- check if the email is a valid address format
local function validate_email_address(email_address)

    local regex = [[^(?=[A-Z0-9][A-Z0-9@._%+-]{5,253}+$)[A-Z0-9._%+-]{1,64}+@(?:(?=[A-Z0-9-]{1,63}+\.)[A-Z0-9]++(?:-[A-Z0-9]++)*+\.){1,8}+[A-Z]{2,63}+$]]
    local m = ngx.re.match(email_address, regex, 'ix')

    if not m then
        return false
    end

    return true
end

-- check if the email domain belongs to one of the registered domains for temporary email accounts
local function verify_email_domain_validator(email_domain)

    local error  = false
    local status = 'valid'

    -- query validator.pizza about the status of the mail domain
    local http = require('resty.http')
    local client = http.new()
    local res, err = client:request_uri('https://www.validator.pizza/domain/'..email_domain)

    if not res then
        error = true
        ngx.log(ngx.INFO, 'Failed to query validator.pizza for domain='..email_domain..' - error: '..err)
    else
        if res.status == ngx.HTTP_OK then
            local data = cjson.decode(res.body)
            if data['status'] == 200 then
                if data['disposable'] or not data['mx'] then
                    status = 'suspect'
                end
                ngx.log(ngx.INFO, 'Verification result from validator.pizza for domain='..email_domain..' - result: '..status)
            else
                error = true
                ngx.log(ngx.INFO, 'Error from validator.pizza - status: '..data['status']..' - message: '..data['error'])
            end
        else
            error = true
            ngx.log(ngx.INFO, 'Returned status from validator.pizza for domain='..email_domain..' - status: '..res.status)
        end
    end

    return status, error
end


-- check if the email domain belongs to one of the registered domains for temporary email accounts
local function verify_email_domain_kickbox(email_domain)

    local error  = false
    local status = 'valid'

    -- query kickbox.com about the status of the mail domain
    local http = require('resty.http')
    local client = http.new()
    local res, err = client:request_uri('https://open.kickbox.com/v1/disposable/'..email_domain)

    if not res then
        error = true
        ngx.log(ngx.INFO, 'Failed to query kickbox.com for domain='..email_domain..' - error: '..err)
    else
        if res.status == ngx.HTTP_OK then
            local data = cjson.decode(res.body)
            if data['disposable']  then
                status = 'suspect'
            end
            ngx.log(ngx.INFO, 'Verification result from kickbox.com for domain='..email_domain..' - result: '..status)
        else
            error = true
            ngx.log(ngx.INFO, 'Returned status from kickbox.com for domain='..email_domain..' - status: '..res.status)
        end
    end

    return status, error
end

-- check if the email domain belongs to one of the registered domains for temporary email accounts
local function verify_email_domain_mogelmail(email_domain)

    local error  = false
    local status = 'valid'
    -- query mogelmail.de about the status of the mail domain
    local api_key = '1cdfa362e3f2e48c46dc1fc173b6690b07db6590'
    local http = require('resty.http')
    local client = http.new()
    local res, err = client:request_uri('https://www.mogelmail.de/api/v1/'..api_key..'/email/'..email_domain)

    if not res then
        error = true
        ngx.log(ngx.INFO, 'Failed to query mogelmail.de for domain='..email_domain..' - error: '..err)
    else
        if res.status == ngx.HTTP_OK then
            if not data['error'] then
                if data['suspected']  then
                    status = 'suspect'
                end
            else
                error = true
                ngx.log(ngx.INFO, 'Error from mogelmail.de - message: '..data['message'])
            end
            ngx.log(ngx.INFO, 'Verification result from mogelmail.de for domain='..email_domain..' - result: '..status)
        else
            error = true
            ngx.log(ngx.INFO, 'Returned status from mogelmail.de for domain='..email_domain..' - status: '..res.status)
        end
    end

    return status, error
end

local function verify_email_address(email_address)

    local recipient, domain = email_address:match('^(.+)@(.+)$')

    local error = false
    local status = ngx.shared.cache:get('email-'..domain)

    if not status then
        status, error = verify_email_domain_validator(domain)
        if error then
            status, error = verify_email_domain_kickbox(domain)
        end
        if error then
            status, error = verify_email_domain_mogelmail(domain)
        end
        if error then
            status = 'valid'
            ngx.log(ngx.INFO, 'Failed to verify email domain='..domain)
        else
            ngx.log(ngx.INFO, 'Verification result for email domain='..domain..' - result: '..status)
            ngx.shared.cache:set('email-'..domain, status, 3600)
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