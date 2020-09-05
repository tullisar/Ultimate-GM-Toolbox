Ext.Require("UGM_ShroudManager.lua")

local function SetCharacterScale(call, data)
    print("CALL")
    print(call.." "..data)
    local character = string.gsub(data, "%:.*", "")
    local value = string.gsub(data, ".*%:", "")
    print(character.." "..value)
    local char = Ext.GetCharacter(tonumber(character))
    print(char)
    char:SetScale(tonumber(value))
    print("Set scale to",value)
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
end

local function UI_QuickDeselect(ui, call, ...)
    Ext.Print("Target deselected")
    local targetBar = Ext.GetBuiltinUI("Public/Game/GUI/GM/GMPanelHUD.swf")
    local char = Ext.GetCharacter(Ext.DoubleToHandle(targetBar:GetValue("targetHandle", "number")))
    Ext.PostMessageToServer("UGM_QuickDeselection", tostring(char.NetID))
end

local function UGM_SetupUI()
    local targetBar = Ext.GetBuiltinUI("Public/Game/GUI/GM/GMPanelHUD.swf")
    if targetBar ~= nil then
        Ext.RegisterUIInvokeListener(targetBar, "showTargetBar", UI_QuickSelect)
        Ext.RegisterUICall(targetBar, "showTargetBar", UI_QuickDeselect)
        Ext.Print("Registered call")
    else
        Ext.PrintError("Failed to register calls!!")
    end
end

Ext.RegisterListener("SessionLoaded", UGM_SetupUI)