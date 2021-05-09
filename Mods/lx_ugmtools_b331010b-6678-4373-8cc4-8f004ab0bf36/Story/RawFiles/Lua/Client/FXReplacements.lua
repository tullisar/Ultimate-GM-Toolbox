local function ReplaceAllFX(...)
    Ext.GetStat("GM_SELECTED").StatusEffect = "RS3_FX_UI_Icon_TriangleDown_01_Blue:Dummy_OverheadFX"
    Ext.GetStat("GM_SELECTED_DISCREET").StatusEffect = "RS3_FX_UI_Icon_TriangleDown_01_Blue:Dummy_OverheadFX"
    Ext.GetStat("GM_TARGETED").StatusEffect = "RS3_FX_UI_Icon_TriangleDown_01_Yellow:Dummy_OverheadFX"
    Ext.GetStat("GM_TARGETED_DISCREET").StatusEffect = "RS3_FX_UI_Icon_TriangleDown_01_Yellow:Dummy_OverheadFX"
end

Ext.RegisterNetListener("UGM_ReplaceFX", ReplaceAllFX)