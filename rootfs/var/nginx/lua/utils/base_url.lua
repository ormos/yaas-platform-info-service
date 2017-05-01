local function _base_url()

    -- check if we have a global server variable
    local url = ngx.var.base_url

    if not url then
        -- check if we have an environment variable for debugging purpose
        url = os.getenv('DEBUG_EXTERNAL_URL')

        if not url then
            -- check if we run as cloud foundry app
            url = ngx.req.get_headers()['Hybris-External-Url']

            -- check if we have some default headers
            if not url then
                local host = ngx.req.get_headers()['Host']
                local scheme = ngx.req.get_headers()['X-Forwarded-Proto']

                -- default for host is the ngx server name
                if not host then host = ngx.var.server_name end

                -- default for port is the ngx server scheme
                if not scheme then scheme = ngx.var.scheme end

                -- build the url
                if host and scheme then
                    url = scheme..'://'..host
                    local port = ngx.req.get_headers()['X-Forwarded-Port']
                    if port and
                       (not ((scheme == 'http') and (port == '80'))) and
                       (not ((scheme == 'https') and (port == '443'))) then
                        url = url..':'..port
                    end
                else
                    url = 'http://localhost'
                end
            end
        end
    end

    return url
end

return {
    base_url = _base_url
}