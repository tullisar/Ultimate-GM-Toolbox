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