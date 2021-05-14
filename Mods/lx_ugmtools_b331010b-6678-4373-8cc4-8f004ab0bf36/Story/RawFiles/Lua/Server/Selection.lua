-- Selection type feature
local function SwitchType(tab)
    local newAlternate = tab.alternate
    local newCurrent = tab.current
    tab.alternate = newCurrent
    tab.current = newAlternate
end

function SwitchSelectionType()
    -- local selectType = PersistentVars.selectType
    -- local newAlternate = selectType.alternate
    -- local newCurrent = selectType.current
    -- selectType.alternate = newCurrent
    -- selectType.current = newAlternate
    SwitchType(PersistentVars.selectType)
    SwitchType(PersistentVars.targetType)
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
        RemoveStatus(char, PersistentVars.targetType.current)
    end
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", AddToSelection)

local function RegisterSelection(char, status, causee)
    if (char ~= nil) and (status == "GM_SELECTED" or status == "GM_SELECTED_DISCREET") then
        selected[char] = status
        Ext.Print("Selected "..Ext.GetCharacter(char).DisplayName)
    end
end

Ext.RegisterOsirisListener("CharacterStatusApplied", 3, "after", RegisterSelection)

local function RemoveFromSelection(char, status, ...)
    if (char ~= nil) and (status == "GM_SELECTED" or status == "GM_SELECTED_DISCREET") then
        if quickSelection == nil then quickSelection = "" end
        selected[char] = nil
        Ext.Print("Unselected "..Ext.GetCharacter(char).DisplayName)
        if PersistentVars.lock or quickSelection == GetUUID(char) then
            if bypasslock then bypasslock = false; return end
            ApplyStatus(char, status, -1.0, 1)
        end
    end
    if quickSelection == "" then quickSelection = nil end
end

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "after", RemoveFromSelection)

-- Lock selection
function ManageLock(object, event)
    if event == "GM_Lock_Select" then
        PersistentVars.lock = true
        if object ~= nil then ItemRemove(object) end
    elseif event == "GM_Unlock_Select" then
        PersistentVars.lock = false
        if object ~= nil then ItemRemove(object) end
    elseif event == "GM_Lock_Switch" then
        if PersistentVars.lock then 
            PersistentVars.lock = false
            print("Lock disabled")
        else 
            PersistentVars.lock = true
            print("Lock enabled")
        end
    end
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", ManageLock)

-- Target feature
local function Targeting(char, event)
    if event ~= "GM_Target_Apply" then return end
    ApplyStatus(char, PersistentVars.targetType.current, -1.0, 1)
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", Targeting)

local function TargetingStatus(char, status, event)
    if status ~= PersistentVars.targetType.current then return end
    local displayName = Ext.GetCharacter(char).DisplayName
    -- Only one target at a time
    if target ~= nil then
        print("Untargeted "..Ext.GetCharacter(target).DisplayName)
        RemoveStatus(target, PersistentVars.targetType.current)
    end
    target = char
    print("Targeting "..displayName)
    RemoveStatus(char, PersistentVars.selectType.current)
end

Ext.RegisterOsirisListener("CharacterStatusApplied", 3, "before", TargetingStatus)

local function RemoveTargeting(char, status, causee)
    if status ~= PersistentVars.targetType.current then return end
    if target ~= nil then
        local name = ""
        local b,err = xpcall(function()
            name = Ext.GetCharacter(target).DisplayName
        end, debug.traceback)
        if name ~= "" then
            print("Untargeted "..name)
        end
    end
    if target == char then
        target = nil
    end
end

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", RemoveTargeting)

-- Quick selection feature
local function QuickSelect(call, netID)
    local char = Ext.GetCharacter(tonumber(netID))
    if quickSelection ~= char.MyGuid then
        -- If selecting different character, remove the previous one selection status
        if quickSelection ~= nil then
            RemoveStatus(quickSelection, PersistentVars.selectType.current)
        end
        if HasActiveStatus(char.MyGuid, PersistentVars.selectType.current) == 0 then
            quickSelectionLock = true
            AddToSelection(char.MyGuid, "GM_Select")
        end
        quickSelection = char.MyGuid
    -- Double click on a targeted character will make it switch between Target and Selected status
    elseif quickSelection == char.MyGuid then
        if HasActiveStatus(char.MyGuid, PersistentVars.selectType.current) == 1 then
            Targeting(char.MyGuid, "GM_Target_Apply")
            bypasslock = true
            RemoveStatus(char.MyGuid, PersistentVars.selectType.current)
        else
            RemoveStatus(char.MyGuid, PersistentVars.targetType.current)
            AddToSelection(char.MyGuid, "GM_Select")
        end
    end
end

Ext.RegisterNetListener("UGM_QuickSelection", QuickSelect)

local function QuickDeselect(call, netID)
    local char = Ext.GetCharacter(tonumber(netID))
    RemoveStatus(char.MyGuid, PersistentVars.selectType.current)
    quickSelection = nil
end

Ext.RegisterNetListener("UGM_QuickDeselection", QuickDeselect)

function ClearSelectionAndTarget()
    if not PersistentVars.lock then
        for char,x in pairs(selected) do
            local qs = ""
            if quickSelection ~= nil then qs = quickSelection end
            if GetUUID(char) ~= GetUUID(qs) then
                RemoveStatus(char, PersistentVars.selectType.current)
            end
        end
        if target ~= nil then
            RemoveStatus(target, PersistentVars.targetType.current)
        end
    end
end

local function ClearFromOsi(item, event)
    if event ~= "GM_Unselect" then return end
    ClearSelectionAndTarget()
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", ClearFromOsi)
