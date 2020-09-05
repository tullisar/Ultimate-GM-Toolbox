PersistentVars = {}
selected = {}

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


function SwitchSelectionType()
    local selectType = PersistentVars.selectType
    local newAlternate = selectType.alternate
    local newCurrent = selectType.current
    selectType.alternate = newCurrent
    selectType.current = newAlternate
    print("Switched selection type")
end

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
        selected[char] = status
        if status == "GM_SELECTED_DISCREET" then
            print("Selected "..CharacterGetDisplayName(char).." "..char)
        end
    end
end

Ext.RegisterOsirisListener("CharacterStatusApplied", 3, "before", RegisterSelection)

local function RemoveFromSelection(char, status, causee)
    if status == "GM_SELECTED" or status == "GM_SELECTED_DISCREET" then
        selected[char] = nil
        if status == "GM_SELECTED_DISCREET" then
            print("Unselected "..CharacterGetDisplayName(char).." "..char)
        end
    end
end

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", RemoveFromSelection)