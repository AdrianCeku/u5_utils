u5_utils = {}

function u5_utils.createClientCallback(clientCallbackName, callbackFunction)
    createClientCallback(clientCallbackName, callbackFunction)
end

function u5_utils.triggerServerCallback(serverCallbackName, payload)
    return triggerServerCallback(serverCallbackName, payload)
end

exports("getObject", function()
    return u5_utils
end)