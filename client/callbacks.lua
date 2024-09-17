local CLIENT_CALLBACKS = {}

function createCallback(clientCallbackName, callbackFunction)
    if CLIENT_CALLBACKS[clientCallbackName] then
        print("Callback with name " .. clientCallbackName .. " already exists. Please use a different name.")
        return
    end

    CLIENT_CALLBACKS[clientCallbackName] = callbackFunction
end

RegisterNetEvent("u5_utils:client:triggerCallback")
AddEventHandler("u5_utils:client:triggerCallback", function(serverCallbackId, clientCallbackName, payload)
    local callbackFunction = CLIENT_CALLBACKS[clientCallbackName]
    local retval

    if callbackFunction then
        retval = callbackFunction(payload)
    else
        print("Callback with name " .. clientCallbackName .. " does not exist.")
        return
    end

    TriggerServerEvent("u5_utils:server:callbackReslut", serverCallbackId, retval)
end)