test = false

Ext.RegisterNetListener("UGM_ReturnClickMovePosition", function(channel, payload)
    if test then
        local state = Ext.JsonParse(payload)
        local item = CreateItemTemplateAtPosition("bf9a1dc0-791a-4828-b8ed-97ecce2cfe97", state[1], state[2], state[3])
        SetStoryEvent(item, "GM_Move_Walk")
    end
end)