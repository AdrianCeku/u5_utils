local CALLBACKS = {}
local NEXT_CALLBACK_ID = 0

local function getCallbackId()
    NEXT_CALLBACK_ID = NEXT_CALLBACK_ID + 1
    return NEXT_CALLBACK_ID
end

function triggerCallback(source, clientCallbackName, payload)
    local promise = promise:new()
    local serverCallbackId = getCallbackId()

    CALLBACKS[serverCallbackId] = function(response)
        promise:resolve(response)
    end

    TriggerClientEvent("u5_utils:client:triggerCallback", source, serverCallbackId, clientCallbackName, payload)

    return Citizen.Await(promise)
end

RegisterNetEvent("u5_utils:server:callbackReslut")
AddEventHandler("u5_utils:server:callbackReslut", function(serverCallbackId, response)
    local resolveFunction = SERVER_CALLBACKS[serverCallbackId]

    if resolveFunction then
        resolveFunction(response)
    end
end)