
local _debug = {
    Host_Addr = os.getenv('DEBUG_HOST_ADDR')
}

function _debug.start()
    if _debug.Host_Addr ~= nil then
        _debug.debugger = require('mobdebug')
        _debug.debugger.start(_debug.Host_Addr)
    end
end

function _debug:stop()
    if _debug.debugger ~= nil then
        _debug.debugger.done()
    end
end

return _debug
