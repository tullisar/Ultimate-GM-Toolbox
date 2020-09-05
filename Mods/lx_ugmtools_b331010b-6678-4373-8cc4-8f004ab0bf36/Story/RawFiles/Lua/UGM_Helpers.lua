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