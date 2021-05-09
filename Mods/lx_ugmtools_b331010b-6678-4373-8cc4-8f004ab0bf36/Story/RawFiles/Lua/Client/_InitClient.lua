Ext.Require("Client/ShroudManager.lua")
Ext.Require("Client/SessionLoaded.lua")
Ext.Require("Client/FXReplacements.lua")
-- Ext.Require("Client/ClickingState.lua")
-- Ext.Require("Client/CustomStatsTooltipFix.lua")
Ext.AddPathOverride("Public/Game/GUI/GM/GMPanelHUD.swf", "Public/lx_ugmtools_b331010b-6678-4373-8cc4-8f004ab0bf36/Game/GUI/GM/GMPanelHUD.swf")

local function SetCharacterScale(call, data)
    local character = string.gsub(data, "%:.*", "")
    local value = string.gsub(data, ".*%:", "")
    local char = nil
    local b,err = xpcall(function()
        char = Ext.GetCharacter(tonumber(character))
        local check = char.DisplayName
    end, debug.traceback)
    if not b then return end
    if char == nil then return end
    char:SetScale(tonumber(value))
    -- print("Set scale to",value)
end

Ext.RegisterNetListener("UGM_SetCharacterScale", SetCharacterScale)


-- Quick Selection feature
local function UI_QuickSelect(ui, call, ...)
    local params = {...}
    if params[2] == 0.0 then
        local targetBar = Ext.GetBuiltinUI("Public/Game/GUI/GM/GMPanelHUD.swf")
        local char = Ext.GetCharacter(Ext.DoubleToHandle(targetBar:GetValue("targetHandle", "number")))
        if char == nil then return end
        Ext.PostMessageToServer("UGM_QuickDeselection", tostring(char.NetID))
    else
        local char = Ext.GetCharacter(Ext.DoubleToHandle(params[2]))
        Ext.PostMessageToServer("UGM_QuickSelection", tostring(char.NetID))
    end
    local root = Ext.GetBuiltinUI("Public/Game/GUI/GM/GMPanelHUD.swf"):GetRoot()
    --Ext.Print(root.GMButtonArray)
end

local function UI_Test(ui, call, ...)
    local root = Ext.GetBuiltinUI("Public/Game/GUI/GM/GMPanelHUD.swf"):GetRoot()
    -- root.GMBar_mc.slotBGContainer_mc.x = 500
    -- root.GMBar_mc.slotBGContainer_mc.y = -200
    -- for i=0,20,1 do
    --     Ext.Print(i, root.GMBar_mc.slotList.getAt(i))
    -- end
    root.GMActionsArray[51] = 50.0
    root.GMActionsArray[52] = 2.0
    root.GMActionsArray[53] = "Unselect All"

    root.GMActionsArray[54] = 51.0
    root.GMActionsArray[55] = 2.0
    root.GMActionsArray[56] = "Lock Selection"

    root.GMActionsArray[57] = 52.0
    root.GMActionsArray[58] = 2.0
    root.GMActionsArray[59] = "Toggle Bark Mode"

    root.GMActionsArray[60] = 53.0
    root.GMActionsArray[61] = 2.0
    root.GMActionsArray[62] = "Story Freeze"

    root.GMActionsArray[63] = 54.0
    root.GMActionsArray[64] = 2.0
    root.GMActionsArray[65] = "Start Follow Target"

    -- root.GMActionsArray[66] = 55.0
    -- root.GMActionsArray[67] = 2.0
    -- root.GMActionsArray[68] = "Run to Position"

end

local function UI_Test2(ui, call, ...)
    Ext.Print(call)
    local params = {...}
    Ext.Print(Ext.JsonStringify({...}))
    local root = Ext.GetBuiltinUI("Public/Game/GUI/GM/monstersSelection.swf"):GetRoot()
    Ext.Print(Ext.DoubleToHandle(params[1]))
end

itemFunctions = {
    ["22- Move to position (Run)"] = ""

}

local function UI_TopbarFunctions(ui, call, ...)
    local monster = Ext.GetBuiltinUI("Public/Game/GUI/GM/monstersSelection.swf")
    if call == "buttonCallback_50" then
        Ext.Print("Unselected all")
        Ext.PostMessageToServer("UGM_Hotbar_UnselectAll", "")
    elseif call == "buttonCallback_51" then
        Ext.PostMessageToServer("UGM_Hotbar_SelectionLock", "")
    elseif call == "buttonCallback_52" then
        Ext.Print("Toggle Bark")
        Ext.PostMessageToServer("UGM_Hotbar_ToggleBark", "")
    elseif call == "buttonCallback_53" then
        Ext.Print("Toggle story freeze")
        Ext.PostMessageToServer("UGM_Hotbar_StoryFreeze", "")
    elseif call == "buttonCallback_54" then
        Ext.Print("Start follow")
        Ext.PostMessageToServer("UGM_Hotbar_StartFollow", "")
    -- elseif call == "buttonCallback_55" then
    --     Ext.Print("")
    --     monster:ExternalInterfaceCall("startDragging", itemFunctions["22- Move to position (Run)"], 1)
    end
end

local function UI_MonstersSelection(ui, call, ...)
    local params = {...}
    local root = ui:GetRoot()
    Ext.Print(Ext.DoubleToHandle(params[1]))
    Ext.Print(root.items_mc)
    Ext.Print(root.items_mc.groupList)
    local entry
    for i=0,20,1 do
        local temp = root.items_mc.groupList.content_array[i].entriesList.content_array
        for j=0,20,1 do
            if temp[j] ~= nil then
                local temp2 = temp[j].nameStr
                if temp2 == "22- Move to position (Run)" then
                    Ext.Print("TEST")
                    -- root.selectedItem = temp[j]
                    -- root.deselectElements()
                    -- root.setSelectedList2()
                    -- temp[j].parentList.select(temp[j].list_pos, true)
                end
                --Ext.Print(temp2)
            end
        end
        if temp ~= nil then
            entry = temp
        end
    end
end


local function UI_GetItemsID(ui, call, ...)
    local root = Ext.GetBuiltinUI("Public/Game/GUI/GM/monstersSelection.swf"):GetRoot()
    for i=0,20000,1 do
        for item,handle in pairs(itemFunctions) do
        -- Ext.Print(root.itemsUpdateList[i])
            if root.itemsUpdateList[i] == item then
                itemFunctions[item] = root.itemsUpdateList[i-1]
                -- for j=i,i+63,7 do
                --     Ext.Print(root.itemsUpdateList[j])
                --     Ext.Print(Ext.DoubleToHandle(root.itemsUpdateList[j+6]))
                -- end
            end
        end
    end
end


local function UGM_SetupUI()
    local targetBar = Ext.GetBuiltinUI("Public/Game/GUI/GM/GMPanelHUD.swf")
    local monsterPanel = Ext.GetBuiltinUI("Public/Game/GUI/GM/monstersSelection.swf")
    local possessionBar = Ext.GetBuiltinUI("Public/Game/GUI/GM/possessionBar.swf")
    if targetBar ~= nil then
        Ext.RegisterUIInvokeListener(targetBar, "showTargetBar", UI_QuickSelect)
        Ext.RegisterUINameInvokeListener("initActionSlots", UI_Test)
        Ext.RegisterUICall(targetBar, "buttonCallback_50", UI_TopbarFunctions)
        Ext.RegisterUICall(targetBar, "buttonCallback_51", UI_TopbarFunctions)
        Ext.RegisterUICall(targetBar, "buttonCallback_52", UI_TopbarFunctions)
        Ext.RegisterUICall(targetBar, "buttonCallback_53", UI_TopbarFunctions)
        Ext.RegisterUICall(targetBar, "buttonCallback_54", UI_TopbarFunctions)
        Ext.RegisterUICall(targetBar, "buttonCallback_55", UI_TopbarFunctions)
        --Ext.RegisterUICall(monsterPanel, "selectForSpawn", UI_Test2)
        -- Ext.RegisterUICall(monsterPanel, "selectForSpawn", UI_MonstersSelection)
        -- Ext.RegisterUIInvokeListener(monsterPanel, "updateAll", UI_GetItemsID)
    else
        Ext.PrintError("Failed to register calls!!")
    end

    --local root = targetBar:GetRoot()
    -- root.secActionList.x = -100
    -- root.stickiesBar_mx.x = -100
end

Ext.RegisterListener("SessionLoaded", UGM_SetupUI)