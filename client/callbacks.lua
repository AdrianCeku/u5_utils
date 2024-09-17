local RESOLVE_CALLBACKS = {}
local NEXT_RESOLVE_CALLBACK_ID = 0

local CLIENT_CALLBACKS = {}

local function getResolveCallbackId()
    NEXT_RESOLVE_CALLBACK_ID = NEXT_RESOLVE_CALLBACK_ID + 1
    return NEXT_RESOLVE_CALLBACK_ID
end

function createClientCallback(clientCallbackName, callbackFunction)
    if CLIENT_CALLBACKS[clientCallbackName] then
        print("Client Callback with name " .. clientCallbackName .. " already exists. Please use a different name.")
        return
    end

    CLIENT_CALLBACKS[clientCallbackName] = callbackFunction
end

function triggerServerCallback(serverCallbackName, payload)
    local promise = promise:new()
    local clientCallbackId = getResolveCallbackId()

    RESOLVE_CALLBACKS[clientCallbackId] = function(response)
        promise:resolve(source, response)
    end

    TriggerServerEvent("u5_utils:server:triggerCallback", clientCallbackId, serverCallbackName, payload)

    return Citizen.Await(promise)
end

RegisterNetEvent("u5_utils:client:triggerCallback")
AddEventHandler("u5_utils:client:triggerCallback", function(serverCallbackId, clientCallbackName, payload)
    local callbackFunction = CLIENT_CALLBACKS[clientCallbackName]
    local retval

    if callbackFunction then
        retval = callbackFunction(payload)
    else
        print("Client Callback with name " .. clientCallbackName .. " does not exist.")
        return
    end

    TriggerServerEvent("u5_utils:server:callbackReslut", serverCallbackId, retval)
end)

RegisterNetEvent("u5_utils:client:callbackReslut")
AddEventHandler("u5_utils:client:callbackReslut", function(clientCallbackId, response)
    local resolveFunction = RESOLVE_CALLBACKS[clientCallbackId]

    if resolveFunction then
        resolveFunction(response)
    end
end)