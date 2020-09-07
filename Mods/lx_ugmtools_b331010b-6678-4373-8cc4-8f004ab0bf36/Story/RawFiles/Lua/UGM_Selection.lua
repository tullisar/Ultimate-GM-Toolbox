PersistentVars = {}
selected = {}
target = nil
lock = false
quickSelection = nil
bypasslock = false

-- Initialization
currentLevel = ""

local function GetCurrentLevel(map, isEditor)
    currentLevel = map
    if PersistentVars[currentLevel] == nil then
        PersistentVars[currentLevel] = {}
        PersistentVars[currentLevel].patrols = {}
    end
end

Ext.RegisterOsirisListener("GameStarted", 2, "before", GetCurrentLevel)

function LoadVars()
    Ext.Print(Ext.JsonStringify(PersistentVars))
    if PersistentVars.selectType == nil then
        PersistentVars.selectType = {
            current = "GM_SELECTED",
            alternate = "GM_SELECTED_DISCREET"
        }
    end
    if PersistentVars.options == nil then
        PersistentVars.options = {
            activatedOnly = "off",
            deactivatedOnly = "off",
        }
    end
end

Ext.RegisterListener("SessionLoaded", LoadVars)

-- Selection type feature
function SwitchSelectionType()
    local selectType = PersistentVars.selectType
    local newAlternate = selectType.alternate
    local newCurrent = selectType.current
    selectType.alternate = newCurrent
    selectType.current = newAlternate
    print("Switched selection type")
end

-- Selection DB management
local function AddToSelection(char, event)
    if event ~= "GM_Select" then return end
    local option = PersistentVars.options
    local selectType = PersistentVars.selectType
    if option.activatedOnly == "on" then
        if HasActiveStatus(char, "DEACTIVATED") == 0 then ApplyStatus(char, selectType.current, -1.0, 1) end
    elseif option.deactivatedOnly == "on" then
        if HasActiveStatus(char, "DEACTIVATED") == 1 then ApplyStatus(char, selectType.current, -1.0, 1) end
    else
        ApplyStatus(char, selectType.current, -1.0, 1)
    end
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", AddToSelection)

local function RegisterSelection(char, status, causee)
    if status == "GM_SELECTED" or status == "GM_SELECTED_DISCREET" then
        Ext.Print("Registered selection")
        selected[char] = status
        if status == "GM_SELECTED_DISCREET" then
            print("Selected "..CharacterGetDisplayName(char).." "..char)
        end
    end
end

Ext.RegisterOsirisListener("CharacterStatusApplied", 3, "before", RegisterSelection)

local function RemoveFromSelection(char, status, causee)
    if status == "GM_SELECTED" or status == "GM_SELECTED_DISCREET" then
        if bypasslock then
            bypasslock = false
            return
        end
        if not lock then
            selected[char] = nil
            if status == "GM_SELECTED_DISCREET" then
                print("Unselected "..CharacterGetDisplayName(char).." "..char)
            end
        else
            ApplyStatus(char, status, -1.0, 1)
        end
    end
end

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", RemoveFromSelection)

-- Lock selection
function ManageLock(object, event)
    if event == "GM_Lock_Select" then
        lock = true
        if object ~= nil then ItemRemove(object) end
    elseif event == "GM_Unlock_Select" then
        lock = false
        if object ~= nil then ItemRemove(object) end
    elseif event == "GM_Lock_Switch" then
        if lock then 
            lock = false
        else 
            lock = true
        end
    end
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", ManageLock)

-- Quick selection feature
local function QuickSelect(call, netID)
    local char = Ext.GetCharacter(tonumber(netID))
    if quickSelection ~= char.MyGuid then
        if quickSelection ~= nil then
            bypasslock = true
            RemoveStatus(quickSelection, PersistentVars.selectType.current)
        end
        if HasActiveStatus(char.MyGuid, PersistentVars.selectType.current) == 0 then
            ApplyStatus(char.MyGuid, PersistentVars.selectType.current, -1, 1)
        end
        lock = true
        quickSelection = char.MyGuid
    end
end

Ext.RegisterNetListener("UGM_QuickSelection", QuickSelect)

local function QuickDeselect(call, netID)
    local char = Ext.GetCharacter(tonumber(netID))
    lock = false
    RemoveStatus(char.MyGuid, PersistentVars.selectType.current)
    quickSelection = nil
end

Ext.RegisterNetListener("UGM_QuickDeselection", QuickDeselect)

-- Target feature
local function Targeting(char, event)
    if event ~= "GM_Target_Apply" then return end
    if target ~= nil then
        RemoveStatus(target, "GM_TARGETED")
    end
    target = char
    ApplyStatus(char, "GM_TARGETED", -1.0, 1)
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", Targeting)

local function RemoveTargeting(char, status, causee)
    if status ~= "GM_TARGETED" then return end
    target = nil
end

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", RemoveTargeting)