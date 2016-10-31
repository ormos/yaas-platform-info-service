
local function _is_callable(obj)
    return type(obj) == 'function' or getmetatable(obj) and getmetatable(obj).__call and true
end

local function _substitute(s, tbl)
    local subst

    if _is_callable(tbl) then
        subst = tbl
    else
        function subst(f)
            local s = tbl[f]
            if not s then
                return '${'..f..'}'
            else
                return s
            end
        end
    end

    return (string.gsub(s, '%${([%w_]+)}', subst))
end

return {
    substitute = _substitute
}
