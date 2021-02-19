function CharacterSetAbility(ability, value)
    for char,x in pairs(selected) do
        NRD_PlayerSetBaseAbility(char, ability, tonumber(value))
        CharacterAddCivilAbilityPoint(char, 0)
    end
end

function CharacterAddAbilityPoints(amount)
    for char,x in pairs(selected) do
        CharacterAddAbilityPoint(char, tonumber(amount))
    end
end

function CharacterSetAttribute(attribute, value)
    for char,x in pairs(selected) do
        NRD_PlayerSetBaseAttribute(char, attribute, tonumber(value))
        CharacterAddCivilAbilityPoint(char, 0)
    end
end

function CharacterAddAttributePoints(amount)
    for char,x in pairs(selected) do
        CharacterAddAttributePoint(char, tonumber(amount))
    end
end

function CharacterEnableTalent(talent, enable)
    for char,x in pairs(selected) do
        NRD_PlayerSetBaseTalent(char, talent, tonumber(enable))
        CharacterAddCivilAbilityPoint(char, 0)
    end
end

function CharacterAddTalentPoints(amount)
    for char,x in pairs(selected) do
        CharacterAddTalentPoint(char, tonumber(amount))
    end
end

function CharacterGiveSkill(skill)
    for char,x in pairs(selected) do
        CharacterAddSkill(char, skill, 1)
    end
end

function CharacterCheckSkills()
    for char,x in pairs(selected) do
        char = Ext.GetCharacter(char)
        Ext.Print(Ext.JsonStringify(char.GetSkills(char)))
    end
end