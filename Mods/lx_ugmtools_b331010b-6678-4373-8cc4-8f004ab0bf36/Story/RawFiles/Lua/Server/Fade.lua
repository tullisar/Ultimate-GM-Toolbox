local function FadeBlackOrWhite(char, fadeType)
    if IsTagged(char, "GM_IsFaded") == 0 then
        local id = Ext.Random(0, 10000)
        if fadeType == "b" then
            FadeOutBlack(char, 4, tostring(id))
        else
            FadeOutWhite(char, 4, tostring(id))
        end
        SetVarInteger(char, "GM_FadeID", id)
        if HasActiveStatus(char, "GM_STORYFREEZE") == 0 then
            ApplyStatus(char, "GM_STORYFREEZE", -1.0)
        end
        SetTag(char, "GM_IsFaded")
    else
        local id = GetVarInteger(char, "GM_FadeID")
        FadeIn(char, 4, tostring(id))
        RemoveStatus(char, "GM_STORYFREEZE")
        ClearTag(char, "GM_IsFaded")
    end
end

function FadeSelection(fadeType)
    if fadeType == nil then fadeType = "b" end
    local host = CharacterGetReservedUserID(CharacterGetHostCharacter())
    if GetTableSize(selected) < 1 then
        local players = Osi.DB_IsPlayer:Get(nil)
        for i,player in pairs(players) do
            if CharacterGetReservedUserID(player) ~= host and CharacterGetReservedUserID(player) ~= 65537 then
                FadeBlackOrWhite(player, fadeType)
            end
        end
    end
    for char,s in pairs(selected) do
        if CharacterGetReservedUserID(char) ~= host and CharacterGetReservedUserID(char) ~= 65537 then
            FadeBlackOrWhite(char, fadeType)
        end
    end
end