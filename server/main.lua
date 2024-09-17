u5_utils = {}

function u5_utils.triggerClientCallback(source, clientCallbackName, payload)
    return triggerCallback(source, clientCallbackName, payload)
end

exports("getObject", function()
    return u5_utils
end)