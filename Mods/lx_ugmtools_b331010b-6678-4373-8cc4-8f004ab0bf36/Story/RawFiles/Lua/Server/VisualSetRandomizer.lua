local slots = {
    HairHelmet = 1,
    Head = 2,
    Torso = 3,
    Arms = 4,
    Trousers = 5,
    Boots = 6,
    Beard = 7,
    Visual8 = 8,
    Visual9 = 9,
}

-- Randomize visual set
function RandomizeVisualSet(item, event)
    if event ~= "GM_RandomizeVisuals" then return end
    for char,select in pairs(selected) do
        local choices = {}
        local character = Ext.GetCharacter(char)
        for slot, i in pairs(slots) do
            choices[slot] = character.RootTemplate:GetVisualChoices(slot)
        end
        for slot,visuals in pairs(choices) do
            if #visuals > 0 then
                local roll = math.random(1, GetTableSize(choices[slot]))
                CharacterSetVisualElement(char, slots[slot], VisualResources[visuals[roll]])
            end
        end
    end
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", RandomizeVisualSet)