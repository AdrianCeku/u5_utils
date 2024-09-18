local HAS_DISTANCE_CHECKER_STARTED = false

local INTERACT_POINTS = {}
local INTERACT_POINTS_ID = 0

local SECTIONS_X = {}
local SECTIONS_Y = {}


--+--+--+--+--+--+--+ SETUP +--+--+--+--+--+--+--+

local function setupDistanceChecker()
    local maxX = 5000
    local maxY = 10000

    local minX = -5000
    local minY = -5000

    local totalDistanceX = maxX - minX
    local totalDistanceY = maxY - minY

    local sectionsAmountX = 10
    local sectionsAmountY = 15

    local sectionSizeX = totalDistanceX / sectionsAmountX
    local sectionSizeY = totalDistanceY / sectionsAmountY

    for i = 1, sectionsAmountX do
        SECTIONS_X[i] = {
            start = minX + (i - 1) * sectionSizeX,
            stop = minX + i * sectionSizeX,
        }
    end

    for i = 1, sectionsAmountY do
        SECTIONS_Y[i] = {
            start = minY + (i - 1) * sectionSizeY,
            stop = minY + i * sectionSizeY
        }
    end

    for i = 1, sectionsAmountX do
        INTERACT_POINTS[i] = {}

        for j = 1, sectionsAmountY do
            INTERACT_POINTS[i][j] = {}
        end
    end

end

setupDistanceChecker()

--+--+--+--+--+--+--+ HELPERS +--+--+--+--+--+--+--+

local function getInteractPointId()
    local id = INTERACT_POINTS_ID
    INTERACT_POINTS_ID = INTERACT_POINTS_ID + 1

    return tostring(id)
end

local function areCoordsInSectionX(coords, section)
    return coords.x >= section.start and coords.x <= section.stop
end

local function areCoordsInSectionY(coords, section)
    return coords.y >= section.start and coords.y <= section.stop
end

local function getSectionsIndexFromCoords(coords)
    for i = 1, #SECTIONS_X do
        local sectionX = SECTIONS_X[i]

        if areCoordsInSectionX(coords, sectionX) then

            for j = 1, #SECTIONS_Y do
                local sectionY = SECTIONS_Y[j]

                if areCoordsInSectionY(coords, sectionY) then
                    return i, j
                end
            end
        end
    end
end

local function getPlayerSectionsIndex()
    local indexX, indexY = getSectionsIndexFromCoords(GetEntityCoords(PlayerPedId()))
    return indexX, indexY
end

local function getInteractPointsInSection(indexX, indexY)
    return INTERACT_POINTS[indexX][indexY]
end

local function getMarkersAndInteractPoints(interactPoints, coords)
    local drawableMarkers = {}
    local interactablePoints = {}

    for id, point in pairs(interactPoints) do
        if point.marker then
            if areCoordsNearCoords(coords, point.coords, point.marker.range) then
                table.insert(drawableMarkers, point.marker)

                if areCoordsNearCoords(coords, point.coords, point.range) then
                    table.insert(interactablePoints, point)
                end
            end
        elseif areCoordsNearCoords(coords, point.coords, point.range) then
            table.insert(interactablePoints, point)
        end
    end

    return drawableMarkers, interactablePoints
end

--+--+--+--+--+--+--+ EXPORT FUNCTIONS +--+--+--+--+--+--+--+

local function addInteractPoint(coords, range, marker, onEnter, onExit)
    if not HAS_DISTANCE_CHECKER_STARTED then
        startDistanceChecker()
    end
    print("Adding interact point")
    local indexX, indexY = getSectionsIndexFromCoords(coords)
    local id = getInteractPointId()

    local interactTable = INTERACT_POINTS[indexX][indexY]
    local interactPoint = {
        coords = coords,
        range = range,
        marker = marker,
        onEnter = onEnter,
        onExit = onExit
    }

    if marker then
        marker.coords = coords
    end

    interactTable[id] = interactPoint
    
    return id
end

local function deleteInteractPoint(id)
    for i = 1, #INTERACT_POINTS do
        for j = 1, #INTERACT_POINTS[i] do
            if INTERACT_POINTS[i][j][id] then
                INTERACT_POINTS[i][j][id] = nil
                return
            end
        end
    end

    if INTERACT_POINTS == {} then
        stopDistanceChecker()
    end
end

--+--+--+--+--+--+--+ MAIN +--+--+--+--+--+--+--+

function startDistanceChecker()
    HAS_DISTANCE_CHECKER_STARTED = true
    
    local currentSectionX, currentSectionY = getPlayerSectionsIndex()
    local currentInteractPoints = getInteractPointsInSection(currentSectionX, currentSectionY)
    local nearbyMarkers = {}
    local nearbyInteractPoints = {}

    Citizen.CreateThread(function()
        while HAS_DISTANCE_CHECKER_STARTED do
            Citizen.Wait(2500)
            currentSectionX, currentSectionY = getPlayerSectionsIndex()
            currentInteractPoints = getInteractPointsInSection(currentSectionX, currentSectionY)
        end
    end)

    Citizen.CreateThread(function()
        while HAS_DISTANCE_CHECKER_STARTED do
            Citizen.Wait(1000)
            local markers, points = getMarkersAndInteractPoints(currentInteractPoints, GetEntityCoords(PlayerPedId()))
            nearbyMarkers = markers
            nearbyInteractPoints = points
        end
    end)

    Citizen.CreateThread(function()
        while HAS_DISTANCE_CHECKER_STARTED do
            Citizen.Wait(0)
            for i = 1, #nearbyMarkers do
                local marker = nearbyMarkers[i]
                DrawMarker(
                    2, 
                    marker.coords.x, 
                    marker.coords.y, 
                    marker.coords.z + 2, 
                    0.0, 
                    0.0, 
                    0.0, 
                    0.0, 
                    180.0, 
                    0.0, 
                    2.0, 
                    2.0, 
                    2.0, 
                    255, 
                    128, 
                    0, 
                    50, 
                    false, 
                    true, 
                    2, 
                    nil, 
                    nil, 
                    false
                )
            end
        end
    end)

    Citizen.CreateThread(function()
        local previousPoints = {}

        while HAS_DISTANCE_CHECKER_STARTED do 
            Citizen.Wait(100)

            for id, point in pairs(nearbyInteractPoints) do
                if not previousPoints[id] then
                    point.onEnter()
                end
            end

            for id, point in pairs(previousPoints) do
                if not nearbyInteractPoints[id] then
                    point.onExit()
                end
            end

            previousPoints = nearbyInteractPoints
        end
    end)
end

function stopDistanceChecker()
    HAS_DISTANCE_CHECKER_STARTED = false
end

--+--+--+--+--+--+--+ EXPORTS +--+--+--+--+--+--+--+

exports("addInteractPoint", addInteractPoint)
exports("deleteInteractPoint", deleteInteractPoint)

--+--+--+--+--+--+--+ DEBUG +--+--+--+--+--+--+--+

RegisterCommand("addInteractPoint", function()
    local coords = GetEntityCoords(PlayerPedId())
    local range = 5
    local marker = {
        coords = coords,
        range = 20
    }
    local onEnter = function()
        print("Entered")
    end

    local onExit = function()
        print("Exited")
    end

    print(addInteractPoint(coords, range, marker, onEnter, onExit))

end, false)

RegisterCommand("deleteInteractPoint", function()
    deleteInteractPoint("0")
end, false)