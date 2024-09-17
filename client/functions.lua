function areCoordsNearCoords(coords1, coords2, range)
    local distSquared = (coords1.x - coords2.x)^2 + (coords1.y - coords2.y)^2 + (coords1.z - coords2.z)^2
    
    return distSquared <= range^2
end

--+--+--+--+--+--+--+ EXPORTS +--+--+--+--+--+--+--+

exports("areCoordsNearCoords", areCoordsNearCoords)