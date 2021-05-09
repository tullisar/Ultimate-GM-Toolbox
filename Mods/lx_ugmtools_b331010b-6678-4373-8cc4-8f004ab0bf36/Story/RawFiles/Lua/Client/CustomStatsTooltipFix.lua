-- ---@param character EsvCharacter
-- ---@param skill string
-- ---@param tooltip TooltipData
-- local function OnStatTooltip(character, stat, tooltip)
--     if tooltip == nil then return end
--     Ext.Dump(tooltip:GetElement("StatName"))
--     local stat = tooltip:GetElement("StatName").Label
--     local statsDescription = tooltip:GetElement("StatsDescription")

--     if stat == "UNKNOWN STAT" then
--         tooltip:GetElement("StatName").Label = "Tenebrium Energy"
--         statsDescription.Label = "How active is the Tenebrium Infusion. Increase with missed and resisted attacks, by receiving a critical hit or when being incapacitated. The stronger the infusion is, the more energy it will generate. If you leave a combat while your energy value is above your infusion value, the infusion might increase."
--     end
-- end

-- local function SRP_Tooltips_Init()
--     Game.Tooltip.RegisterListener("CustomStat", nil, OnStatTooltip)
-- end

-- Ext.RegisterListener("SessionLoaded", SRP_Tooltips_Init)

local function ServeTestStatTooltip(ui, call, handle, ...)
    Ext.Dump({...})
    if not ui:GetRoot().isGameMasterChar then
        ui:ExternalInterfaceCall("showStatTooltip", 24, ...)
    end
end

local function Test(ui, call, handle, ...)
    Ext.Dump({...})
    -- if not ui:GetRoot().isGameMasterChar then
    --     ui:ExternalInterfaceCall("showCustomStatTooltip", 24, 353, 300, 30.0, "right")
    -- end
end

local function UGM_SetupUI()
    local charSheet = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
    local statusConsole = Ext.GetBuiltinUI("Public/Game/GUI/statusConsole.swf")
    local hotbar = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
    -- statusConsole:GetRoot().console_mc.sourceHolder_mc.y = -53
    -- Ext.Print("statusconsole", statusConsole.GetTypeId(statusConsole))
    -- Ext.RegisterUICall(charSheet, "plusCustomStat", CustomStatChanged)
    -- Ext.RegisterUICall(charSheet, "minusCustomStat", CustomStatChanged)
    -- Ext.RegisterUIInvokeListener(charSheet, "updateArraySystem", AddCustomInfo)
    -- Ext.RegisterUICall(statusConsole, "statusConsoleRollOver", DisplayTEInfo)
    -- Ext.RegisterUICall(statusConsole, "statusConsoleRollOut", DisplayTEInfo)
    -- Ext.RegisterUICall(statusConsole, "BackToGMPressed", SwitchShadowBarDisplay)
    -- Ext.RegisterUINameCall("possess", TestTooltip4, "After")
    -- Ext.RegisterUITypeCall(32, "charSel", UpdateShadowBarValue)
    -- Ext.RegisterUITypeCall(119, "selectCharacter", UpdateShadowBarValue)
    -- Ext.RegisterUITypeCall(119, "centerCamOnCharacter", UpdateShadowBarValue)
    -- Ext.RegisterUIInvokeListener(hotbar, "setPlayerHandle", UpdateShadowBarValue)
    Ext.RegisterUIInvokeListener(charSheet, "showTooltipForMC", Test)
    -- Ext.RegisterUITypeCall(119, "showCustomStatTooltip", ServeTestStatTooltip)
end

Ext.RegisterListener("SessionLoaded", UGM_SetupUI)