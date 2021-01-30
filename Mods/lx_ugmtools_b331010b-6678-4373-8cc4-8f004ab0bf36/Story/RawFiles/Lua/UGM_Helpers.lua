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

function string.startswith(String,Start)
    return string.sub(String,1,string.len(Start))==Start
 end

 function ClosestHalf(number)
    local negative = 0 > number
    local int = math.floor(math.abs(number))
    local decimal = math.abs(number)-int
    local higher = false
    local half = 0.5
    if decimal > half then
        higher = true
        decimal = decimal - half
    end
    if negative then 
        int = -int
        half = -half
    end
    if math.abs(decimal) < math.abs(decimal-0.5) then
        if higher then
            return int+half
        else
            return int
        end
    else
        return int+2*half
    end
 end