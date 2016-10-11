local function base_url()

    -- check if we have a global server variable
    local url = ngx.var.base_url

    if (url == nil) then
        -- check if we have an environment variable for debugging purpose
        url = os.getenv('DEBUG_EXTERNAL_URL')

        if (url == nil) then
            -- check if we run as cloud foundry app
            url = ngx.req.get_headers()['Hybris-External-Url']

            if (url == nil) then
                -- at least build a basic base url
                url = ngx.var.scheme..'://'..ngx.var.server_name
                if (ngx.var.server_port ~= nil) and
                   (not ((ngx.var.scheme == 'http') and (ngx.var.server_port == '80'))) and
                   (not ((ngx.var.scheme == 'https') and (ngx.var.server_port == '443'))) then
                    url = url..':'..ngx.var.server_port
                end
            end
        end
    end

    return url
end

return {
    base_url = base_url
}