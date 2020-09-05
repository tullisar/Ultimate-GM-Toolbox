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