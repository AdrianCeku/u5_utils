local RESOLVE_CALLBACKS = {}
local NEXT_RESOLVE_CALLBACK_ID = 0

local SERVER_CALLBACKS = {}

local function getResolveCallbackId()
    NEXT_RESOLVE_CALLBACK_ID = NEXT_RESOLVE_CALLBACK_ID + 1
    return NEXT_RESOLVE_CALLBACK_ID
end

function createServerCallback(serverCallbackName, callbackFunction)
    if SERVER_CALLBACKS[serverCallbackName] then
        print("Server Callback with name " .. serverCallbackName .. " already exists. Please use a different name.")
        return
    end

    SERVER_CALLBACKS[serverCallbackName] = callbackFunction
end

function triggerClientCallback(source, clientCallbackName, payload)
    local promise = promise:new()
    local serverCallbackId = getResolveCallbackId()

    RESOLVE_CALLBACKS[serverCallbackId] = function(response)
        promise:resolve(response)
    end

    TriggerClientEvent("u5_utils:client:triggerCallback", source, serverCallbackId, clientCallbackName, payload)

    return Citizen.Await(promise)
end

RegisterNetEvent("u5_utils:server:triggerCallback")
AddEventHandler("u5_utils:server:triggerCallback", function(clientCallbackId, serverCallbackName, payload)
    local source = source
    local callbackFunction = SERVER_CALLBACKS[serverCallbackName]
    local retval

    if callbackFunction then
        retval = callbackFunction(source, payload)
    else
        print("Server Callback with name " .. serverCallbackName .. " does not exist.")
        return
    end

    TriggerClientEvent("u5_utils:client:callbackReslut", clientCallbackId, retval)
end)

RegisterNetEvent("u5_utils:server:callbackReslut")
AddEventHandler("u5_utils:server:callbackReslut", function(serverCallbackId, response)
    local resolveFunction = RESOLVE_CALLBACKS[serverCallbackId]

    if resolveFunction then
        resolveFunction(response)
    end
end)