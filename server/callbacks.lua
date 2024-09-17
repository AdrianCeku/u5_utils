--+--+--+--+--+--+--+ SERVER CALLBACKS +--+--+--+--+--+--+--+
local SERVER_CALLBACKS = {}

function createServerCallback(serverCallbackName, callbackFunction)
    if SERVER_CALLBACKS[serverCallbackName] then
        print("Server Callback with name " .. serverCallbackName .. " already exists. Please use a different name.")
        return
    end
    
    SERVER_CALLBACKS[serverCallbackName] = callbackFunction
end

RegisterNetEvent("u5_utils:server:triggerCallback")
AddEventHandler("u5_utils:server:triggerCallback", function(serverCallbackName, clientCallbackId, data)
    local source = source
    local callbackFunction = SERVER_CALLBACKS[serverCallbackName]

    if callbackFunction then
        local retval = callbackFunction(source, data)
        TriggerClientEvent("u5_utils:client:callbackResult", clientCallbackId, retval)
    else
        print("Server Callback with name " .. serverCallbackName .. " does not exist.")
        return
    end
    
end)

--+--+--+--+--+--+--+ CLIENT CALLBACKS +--+--+--+--+--+--+--+

local RESOLVE_CALLBACKS = {}
local NEXT_RESOLVE_CALLBACK_ID = 0

local function getResolveCallbackId()
    NEXT_RESOLVE_CALLBACK_ID = NEXT_RESOLVE_CALLBACK_ID + 1
    return NEXT_RESOLVE_CALLBACK_ID
end

function triggerClientCallback(source, clientCallbackName, data)
    local promise = promise:new()
    local serverCallbackId = getResolveCallbackId()

    RESOLVE_CALLBACKS[serverCallbackId] = function(response)
        promise:resolve(response)
    end

    TriggerClientEvent("u5_utils:client:triggerCallback", source, clientCallbackName, serverCallbackId, data)

    return Citizen.Await(promise)
end

RegisterNetEvent("u5_utils:server:callbackResult")
AddEventHandler("u5_utils:server:callbackResult", function(serverCallbackId, response)
    local resolveFunction = RESOLVE_CALLBACKS[serverCallbackId]

    if resolveFunction then
        resolveFunction(response)
    end
end)

--+--+--+--+--+--+--+ EXPORTS +--+--+--+--+--+--+--+

exports("createServerCallback", createServerCallback)
exports("triggerClientCallback", triggerClientCallback)