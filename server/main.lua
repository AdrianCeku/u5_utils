u5_utils = {}

function u5_utils.createServerCallback(serverCallbackName, callbackFunction)
    createServerCallback(serverCallbackName, callbackFunction)
end

function u5_utils.triggerClientCallback(source, clientCallbackName, payload)
    return triggerClientCallback(source, clientCallbackName, payload)
end

exports("getObject", function()
    return u5_utils
end)