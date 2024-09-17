--+--+--+--+--+--+--+ CLIENT CALLBACKS +--+--+--+--+--+--+--+
local CLIENT_CALLBACKS = {}

function createClientCallback(clientCallbackName, callbackFunction)
    if CLIENT_CALLBACKS[clientCallbackName] then
        print("Client Callback with name " .. clientCallbackName .. " already exists. Please use a different name.")
        return
    end

    CLIENT_CALLBACKS[clientCallbackName] = callbackFunction
end

RegisterNetEvent("u5_utils:client:triggerCallback")
AddEventHandler("u5_utils:client:triggerCallback", function(clientCallbackName, serverCallbackId, data)
    local callbackFunction = CLIENT_CALLBACKS[clientCallbackName]

    if callbackFunction then
        local retval = callbackFunction(data)
        TriggerServerEvent("u5_utils:server:callbackResult", serverCallbackId, retval)
    else
        print("Client Callback with name " .. clientCallbackName .. " does not exist.")
        return
    end

end)

--+--+--+--+--+--+--+ SERVER CALLBACKS +--+--+--+--+--+--+--+

local RESOLVE_CALLBACKS = {}
local NEXT_RESOLVE_CALLBACK_ID = 0

local function getResolveCallbackId()
    NEXT_RESOLVE_CALLBACK_ID = NEXT_RESOLVE_CALLBACK_ID + 1
    return NEXT_RESOLVE_CALLBACK_ID
end

function triggerServerCallback(serverCallbackName, data)
    local promise = promise:new()
    local clientCallbackId = getResolveCallbackId()

    RESOLVE_CALLBACKS[clientCallbackId] = function(response)
        promise:resolve(source, response)
    end

    TriggerServerEvent("u5_utils:server:triggerCallback", serverCallbackName, clientCallbackId, data)

    return Citizen.Await(promise)
end

RegisterNetEvent("u5_utils:client:callbackResult")
AddEventHandler("u5_utils:client:callbackResult", function(clientCallbackId, response)
    local resolveFunction = RESOLVE_CALLBACKS[clientCallbackId]

    if resolveFunction then
        resolveFunction(response)
    end
end)