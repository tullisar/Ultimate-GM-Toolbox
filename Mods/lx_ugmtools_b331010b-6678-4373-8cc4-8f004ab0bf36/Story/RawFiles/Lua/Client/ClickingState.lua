local isDown = false

Ext.RegisterListener("InputEvent", function(event)
    if event.EventId ~= 1 then return end
    if not isDown then
        isDown = true
        return
    end
    local state = Ext.GetPickingState()
    Ext.PostMessageToServer("UGM_ReturnClickMovePosition", Ext.JsonStringify(state.WalkablePosition))
end)

-- Ext.RegisterNetListener("UGM_GetClickMovePosition", function(...)
    
-- end)