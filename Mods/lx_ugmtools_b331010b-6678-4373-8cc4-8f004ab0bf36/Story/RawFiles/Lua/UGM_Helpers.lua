function GetTableSize(table)
    if table == nil then return 0 end
    local i = 0
    for j,k in pairs(table) do
        i = i + 1
    end
    return i
end

function ShiftTable(t)
    local temp = CopyTable(t)
    for i,content in pairs(t) do
        local j = i+1
        if j > GetTableSize(t) then j = 1 end
        t[i] = temp[j]
    end
    return t
end

function CopyTable(t)
    local newTable = {}
    for i,j in pairs(t) do
        newTable[i] = j
    end
    return newTable
end

function SubtractCoordinates(t, t2)
    local result = {x = t.x - t2.x, y = t.y - t2.y, z = t.z - t2.z}
    return result
end

function AddCoordinates(t, t2)
    local result = {x = t.x + t2.x, y = t.y + t2.y, z = t.z + t2.z}
    return result
end