Ext.Require("UGM_Selection.lua")

local function RegisterPatrolBeacon(object, event)
    if event ~= "GM_Place_Patrol_Beacon" then return end
    for char, status in pairs(selected) do
        local beacons = PersistentVars[currentLevel].patrols[char]
        if beacons == nil then beacons = {} end
        local x,y,z = GetPosition(object)
        local size = GetTableSize(beacons)
        beacons[size+1] = {x,y,z}
        PersistentVars[currentLevel].patrols[char] = beacons
        Ext.Print("Added patrol point at ",x,y,z)
    end
    ItemRemove(object)
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", RegisterPatrolBeacon)

local function StartPatrol(object, event)
    if event ~= "GM_Start_Multipatrol" then return end
    for char, status in pairs(selected) do
        if GetTableSize(PersistentVars[currentLevel].patrols[char]) < 2 then return end
        local pos = PersistentVars[currentLevel].patrols[char][1]
        CharacterMoveToPosition(char, pos[1], pos[2], pos[3], 0, "UGM_Loop_Patrol")
        ApplyStatus(char, "GM_PATROLING", -1.0)
        RemoveStatus(char, PersistentVars.selectType.current)
    end
    ItemRemove(object)
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", StartPatrol)

local function LoopPatrol(char, event)
    if event ~= "UGM_Loop_Patrol" then return end
    local shiftedBeacons = ShiftTable(PersistentVars[currentLevel].patrols[char])
    local pos = shiftedBeacons[1]
    CharacterMoveToPosition(char, pos[1], pos[2], pos[3], 0, "UGM_Loop_Patrol")
    PersistentVars[currentLevel].patrols[char] = shiftedBeacons
    --Ext.Print(Ext.JsonStringify(PersistentVars[currentLevel].patrols[char]))
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", LoopPatrol)

local function ClearPatrol(char, status, causee)
    if Ext.GetGameState() ~= "Running" then return end
    if status ~= "GM_PATROLING" then return end
    CharacterPurgeQueue(char)
    PersistentVars[currentLevel].patrols[char] = nil
end

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", ClearPatrol)

-- Regroup
local function Regroup(object, event)
    if event ~= "GM_Regroup" then return end
    ItemRemove(object)
    if target == nil then return end
    local tx, ty, tz = GetPosition(target)
    local grid = {}
    for char, x in pairs(selected) do
        if char ~= target then
            
        end
    end
end

-- Move
local function GetClosest(item)
    local closest = nil
    local chosen = nil
    for char, x in pairs(selected) do
        local dist = GetDistanceTo(char, item)
        if closest == nil or closest > dist then closest = dist; chosen = char end
    end
    return chosen
end

local function ClassicMoveRun(object, event)
    if event ~= "GM_Move_Run" then return end
    local closest = GetClosest(object)
    local vx,vy,vz = GetPosition(object)
    local itemPos = {x = vx, y = vy, z = vz}
    Ext.Print(Ext.JsonStringify(itemPos))
    ItemRemove(object)
    vx, vy, vz = GetPosition(closest)
    local closestPos = {x = vx, y = vy, z = vz}
    local vector = SubtractCoordinates(closestPos, itemPos)
    for char, status in pairs(selected) do
        vx, vy, vz = GetPosition(char)
        local pos = {x = vx, y = vy, z = vz}
        Ext.Print(Ext.JsonStringify(pos))
        local vector = SubtractCoordinates(itemPos, pos)
        Ext.Print(Ext.JsonStringify(vector))
        local destination = AddCoordinates(pos, vector)
        Ext.Print(Ext.JsonStringify(destination))
        CharacterMoveToPosition(char, destination.x, destination.y, destination.z, 1, "NPC_Move_Done")
    end
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", ClassicMoveRun)